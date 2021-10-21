import java.awt.HeadlessException;
import java.awt.Toolkit;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.DataFlavor;
import java.awt.datatransfer.UnsupportedFlavorException;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Arrays;
import java.util.List;

/**
 * @author Matthias Hinz (Original Source)
 * @author Tim Shumeyko, modified
 */
class ClipBoardListener implements Runnable {

   Clipboard sysClip = Toolkit.getDefaultToolkit().getSystemClipboard();
   PrintWriter writer;
   String clientData = "";
   boolean firstRun = true;

   private volatile boolean running = true;

   public ClipBoardListener(PrintWriter writer)
   {
      this.writer = writer;
   }

   public void terminate() {
      running = false;
   }

   public void run() {
      System.out.println("CBL: Listening to clipboard...");
      // the first output will be when a non-empty text is detected
      String recentContent = "";
      // continuously perform read from clipboard
      while (running) {
         try {
            Thread.sleep(200);
         } catch (InterruptedException e) {
            e.printStackTrace();
         }
         try {
            // request what kind of data-flavor is supported
            List<DataFlavor> flavors = Arrays.asList(sysClip.getAvailableDataFlavors());
            // this implementation only supports string-flavor
            if (flavors.contains(DataFlavor.stringFlavor)) {
               String data = (String) sysClip.getData(DataFlavor.stringFlavor);
               // Detect a change of clipboard contents
               if (!data.equals(recentContent) && !data.equals(clientData) && !firstRun) {
                  recentContent = data;
                  // Do whatever you want to do when a clipboard change was detected, e.g.:
                  System.out.println("CBL: Sending new clipboard text to iphone: " + data);
                  sendFromServer(data);
               }
            }

         } catch (HeadlessException e1) {
            e1.printStackTrace();
         } catch (UnsupportedFlavorException e1) {
            e1.printStackTrace();
         } catch (IOException e1) {
            e1.printStackTrace();
         }
      }
   }

   public void setDataFromClient(String data)
   {
      clientData = data;
   }

   public void setFirstRun()
   {
      firstRun = false;
   }
   public void sendFromServer(String text)
   {
      this.writer.println(text);
   }

   public static void main(String[] args) {
      //ClipBoardListener b = new ClipBoardListener();
      //Thread thread = new Thread(b);
      //thread.start();
   }
}
