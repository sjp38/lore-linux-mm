Received: from kleopatra.acc.umu.se (root@kleopatra.acc.umu.se [130.239.18.150])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA19885
	for <linux-mm@kvack.org>; Sun, 10 Jan 1999 09:45:57 -0500
Date: Sun, 10 Jan 1999 15:45:38 +0100 (MET)
From: David Weinehall <tao@acc.umu.se>
Subject: Re: [PATCH] MM fix & improvement
In-Reply-To: <87k8yw295p.fsf@atlas.CARNet.hr>
Message-ID: <Pine.A41.4.05.9901101543290.10784-100000@lenin.acc.umu.se>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Cc: Linus Torvalds <torvalds@transmeta.com>, Linux-MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On 9 Jan 1999, Zlatko Calusic wrote:

> OK, here it goes. Patch is unbelievably small, and improvement is
> BIG.

[Snip]

> pre6 + MM cleanup (needed for swap cache hit rate)
>  
>     hogmem 100 3	-	10.75 MB/sec
> 2 x hogmem 50 3		-	2.01 + 1.97 MB/sec (disk thrashing)
> swap cache		-	add 194431 find 13315/194300 (6.9% hit rate)
> 
> pre6 + MM cleanup + patch below
> 
>     hogmem 100 3	-	13.27 MB/sec
> 2 x hogmem 50 3		-	6.15 + 5.77 MB/sec (perfect)
> swap cache		-	add 175887 find 76003/237711 (32% hit rate)
> 
> Notice how swap cache done it's job much better with changes applied!!!

Looks REALLY nice...

> Both tests were run in single user mode, after reboot, on 64MB
> machine. Don't be disappointed if you get smaller numbers, I have two
> swap partitions on different disks and transports (IDE + SCSI). :)

Have you tried your patch on a low-memory machine and/or a low-capacity
processor, ie a 386 with say 4 MB's of memory?!

/David Weinehall
  _                                                                 _ 
 // David Weinehall <tao@acc.umu.se> /> Northern lights wander      \\ 
//  Project MCA Linux hacker        //  Dance across the winter sky // 
\>  http://www.acc.umu.se/~tao/    </   Full colour fire           </ 

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
