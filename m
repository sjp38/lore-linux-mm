Subject: Re: Swapping for diskless nodes
Date: Tue, 14 Aug 2001 13:57:54 +0100 (BST)
In-Reply-To: <20010811011329.C55@toy.ucw.cz> from "Pavel Machek" at Aug 11, 2001 01:13:29 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E15Wdla-00018V-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@suse.cz>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Bulent Abali <abali@us.ibm.com>, "Dirk W. Steinberg" <dws@dirksteinberg.de>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Ultimately its an insoluble problem, neither SunOS, Solaris or NetBSD are
> > infallible, they just never fail for any normal situation, and thats good
> > enough for me as a solution
> 
> Oops,  really? And if I can DoS such machine with ping -f (to eat atomic
> ram)? And what are you going to tel your users? "It died so reboot"?

For the simplistic case you can stop queueing data to user sockets but that
isnt neccessarily a cure - it can lead to bogus OOM by preventing progress
of apps that would otherwise read a packet then exit.

The good example of the insoluble end of it is a box with no default route
doing BGP4 routing with NFS swap. Now thats an extremely daft practical 
proposition but it illustrates the fact the priority ordering is not known
to the kernel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
