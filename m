Content-Type: text/plain;
  charset="iso-8859-1"
From: Jordi Polo <mumismo@wanadoo.es>
Subject: Re: suspend processes at load  (memory locking)
Date: Tue, 24 Apr 2001 21:27:12 +0200
MIME-Version: 1.0
Message-Id: <01042421271201.00472@mioooldpc>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
Cc: chromi@cyberspace.org, jknapka@earthlink.net, linux-mm@kvack.org, jas88@cam.ac.uk
List-ID: <linux-mm.kvack.org>

After reading this thread , i wonder several things , 

is linux able to have swap that growns with time (ala windows)???

Why allways suppose the processes will eventually end and free resources? may 
be your systems just stays working very slow and no more, maybe that can 
angry some net admin that prefer a machine go down with trashing that a 
machine that seems to work (very slowly ). This is a stupid example but my 
point is that must thing that this "no-much-memory-slow-everything" can last 
forever and no just think " i give this process 2 secs and now it frees x mb 
of ram". 

How will you choose the process ? it must be in a secuencial manner so every 
process will sometime have his 2 sec or whatever of execution .
But for instance giving 2 secs to a x terminal with no input that can't be 
redraw because it needs X windows ........
I have a little idea about this , when you are in danger of trashing , you  
lock the memory of the current process for a time ( 2 secs or whatever you 
think is correct) as process takes more memory you leave him take it and lock 
it . then other process run ( with the usual schedule ) and make the same 
thing . Let's say  3 big processes takes  all the  physical memory , the rest 
of the process are waiting for memory to be free (as if it was any other 
resource) and you for the time you have the process' memory locked you just 
choose between that process and the other two .
As the memory is locked the other process can't make any more allocations ( 
they wait as the other processes) but it's no deadlock because when the timer 
expires all the memory of one process will be freed.
I think this way you make the same that sigstop all the processes but now you 
are able to have several processes in memory and no trashing so you  have the 
advantages of having several processes at once in memory.
My point is : in the practical way this is very similar than sigstop 
processes but it also gives every process what needs as if it were the WS 
method. This is a simple way of taking rid of this .


Feedback is really , really wellcome.


 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
