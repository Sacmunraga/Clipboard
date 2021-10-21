import java.awt.*;
import java.awt.datatransfer.*;
import java.io.*;
import java.net.*;
import java.util.Scanner;

/**
 * Class designed to handle sending and receiving clipboard content between a jailbroken iDevice
 * and any computer capable of running Java.
 * @author Tim Shumeyko
 */
public class Server {
   /**
    * Creates a new server and waits for data from iPhone.
    * TODO: Add multithreading to enable the server to create sub-servers to handle multiple clipboard tasks
    * @param args None
    */
   public static void main(String[] args) {
      Scanner               scnr = new Scanner(System.in);
      ByteArrayOutputStream buffer = new ByteArrayOutputStream();
      String                clientText, serverText;
      byte[]                bytes = new byte[1024];

      // Temporarily use 9999 as the port to bind to
      //System.out.print("Port to bind to: ");
      // int port = scnr.nextInt();
      int port = 9999;

      try (ServerSocket serverSocket = new ServerSocket(port)) {

         // Estbalish TCP connection with client - a jailbroken iDevice.
         System.out.println("Server is listening on port " + port);
         Socket socket = serverSocket.accept();
         System.out.println("New client connected");
         System.out.println("IP of client: " + socket.getRemoteSocketAddress().toString());

         // InputStream used for handling input
         InputStream input = socket.getInputStream();
         BufferedReader reader = new BufferedReader(new InputStreamReader(input));

         // OutputStream used for handling output
         OutputStream output = socket.getOutputStream();
         PrintWriter writer = new PrintWriter(output, true);

         // Clipboard listener to access clipboard of machine running Server.java
         ClipBoardListener b = new ClipBoardListener(writer);
         Thread thread = new Thread(b);
         thread.start();

         // Continunosly wait for data from client
         while (true) {
            char c;
            clientText = "";

            System.out.println("Ready to receive data from client");


            while ((c = (char) reader.read()) != '\0') {
               clientText += c;
            }

            // Get current clipboard contents of machine running Server.java
            Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
            Transferable transferable = new StringSelection(clientText);
            clipboard.setContents(transferable, null);

            // Print out recieved clipboard contents of iDevice client
            System.out.println("Client wrote " + clientText + " to us.");
            b.setFirstRun();
            b.setDataFromClient(clientText);
            // TODO: figure out a way to terminate connection properly.
            if (clientText.equals("1643")) break;

            /*
            System.out.print("What would you like to send to the client? ");
            serverText = scnr.nextLine();
            if (serverText.equals("quit"))
            {
               break;
            }
            writer.println(serverText);

             */
         }

         socket.close();

      } catch (IOException ex) {
         System.out.println("Server exception: " + ex.getMessage());
         ex.printStackTrace();
      }

   }
}
