Message-ID: <47793562.1000608@hp.com>
Date: Mon, 31 Dec 2007 13:30:58 -0500
From: Mark Seger <Mark.Seger@hp.com>
MIME-Version: 1.0
Subject: Re: collectl and the new slab allocator [slub] statistics
References: <476A850A.1080807@hp.com> <Pine.LNX.4.64.0712201138280.30648@schroedinger.engr.sgi.com> <476AFC6C.3080903@hp.com> <476B122E.7010108@hp.com> <Pine.LNX.4.64.0712211338380.3795@schroedinger.engr.sgi.com> <4773B50B.6060206@hp.com> <4773CBD2.10703@hp.com> <Pine.LNX.4.64.0712271141390.30555@schroedinger.engr.sgi.com> <477403A6.6070208@hp.com> <Pine.LNX.4.64.0712271157190.30817@schroedinger.engr.sgi.com> <47741156.4060500@hp.com> <Pine.LNX.4.64.0712271258340.533@schroedinger.engr.sgi.com> <47743A10.7080605@hp.com> <Pine.LNX.4.64.0712271551290.1144@schroedinger.engr.sgi.com> <477511F7.3010307@hp.com>
In-Reply-To: <477511F7.3010307@hp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mark Seger <Mark.Seger@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Even though I know you won't be around for a few days I found a few more 
cycles to put into this and have implemented quite a lot in collectl.  
Rather than send along a bunch of output, I started to put together a 
web page as part of collectl web site though I haven't linked it in yet 
as I haven't yet released the associated version.  In any event, I took 
a shot of trying to include a few high level words about slabs in 
general as well as show what some of the different output formats will 
look like as I'd much rather make changes before I release it than after.

That said if you or anyone else on this list want to have a look at what 
I've been up to you can see it at 
http://collectl.sourceforge.net/SlabInfo.html

-mark

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
