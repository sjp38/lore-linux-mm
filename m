Received: from Galois.suse.de (Zuse.suse.de [195.125.217.2])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA02261
	for <linux-mm@kvack.org>; Thu, 26 Mar 1998 09:47:04 -0500
Date: Thu, 26 Mar 1998 15:44:50 +0100
Message-Id: <199803261444.PAA01409@boole.suse.de>
From: "Dr. Werner Fink" <werner@suse.de>
In-reply-to: <Pine.LNX.3.91.980326150617.566A-100000@mirkwood.dummy.home>
	(message from Rik van Riel on Thu, 26 Mar 1998 15:08:12 +0100 (MET))
Subject: Re: [PATCH] linux-2.1.91-pre2 crash fixed
Sender: owner-linux-mm@kvack.org
To: H.H.vanRiel@fys.ruu.nl
Cc: torvalds@transmeta.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> I've found a small typo in mm/filemap.c, which prevented
> proper operation of the VM subsystem and, in effect, threw
> kswapd in a loop.
> 
> In effect, it refused to free buffer memory when it was
> _above_ the minimum percentage :)

This small type with its enormous effect I've mentioned a hour ago or so :)


BTW: Rik? I've a simple suggestion for the calculation of the number of
     free pages.  After the last kernel driver has done its allocation
     it would be usefull to remember the number of free pages with
     a global variable num_availpages and use this one instead of
     num_physpages for the most memory management operations.
     This would give a better protection for systems with less amount of
     physical ram to be out of the choosen limits for the VM subsystem.


              Werner
