Received: from ferret.lmh.ox.ac.uk (qmailr@ferret.lmh.ox.ac.uk [163.1.138.204])
	by kvack.org (8.8.7/8.8.7) with SMTP id PAA20975
	for <linux-mm@kvack.org>; Mon, 31 May 1999 15:34:00 -0400
Date: Mon, 31 May 1999 20:33:54 +0100 (GMT)
From: Matthew Kirkwood <weejock@ferret.lmh.ox.ac.uk>
Subject: Re: Application load times
In-Reply-To: <199905311911.PAA13206@bucky.physics.ncsu.edu>
Message-ID: <Pine.LNX.3.96.990531203217.18436A-100000@ferret.lmh.ox.ac.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Emil Briggs <briggs@bucky.physics.ncsu.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 31 May 1999, Emil Briggs wrote:

> Communicator takes 14 seconds to load on a freshly booted system
> On the other hand it takes 4 seconds to load using a program of this sort
> 
>   fd = open("/opt/netscape/netscape", O_RDONLY);
>   read(fd, buffer, 13858288);    
>   execv("/opt/netscape/netscape", argv);
> 
> With StarOffice the load time drops from 40 seconds to 15 seconds.

Drop something bigger into /proc/sys/vm/page-cluster on bootup.

I don't know how much bigger, but I suspect that 16 or 32 (4k pages)
should improve matters on a lightly loaded 64Mb machine.

Matthew.

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
