Received: from Galois.suse.de (Galois.suse.de [195.125.217.193])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA13261
	for <linux-mm@kvack.org>; Thu, 26 Feb 1998 14:02:03 -0500
Date: Thu, 26 Feb 1998 19:57:54 +0100
Message-Id: <199802261857.TAA13144@boole.fs100.suse.de>
From: "Dr. Werner Fink" <werner@suse.de>
In-reply-to: <Pine.LNX.3.91.980226123303.26424F-100000@mirkwood.dummy.home>
	(message from Rik van Riel on Thu, 26 Feb 1998 12:34:40 +0100 (MET))
Subject: Re: Fairness in love and swapping
Sender: owner-linux-mm@kvack.org
To: H.H.vanRiel@fys.ruu.nl
Cc: sct@dcs.ed.ac.uk, torvalds@transmeta.com, nahshon@actcom.co.il, alan@lxorguk.ukuu.org.uk, paubert@iram.es, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> > There is one point more which makes ageing a bit unfair.  In
> > include/linux/pagemap.h PAGE_AGE_VALUE is defined to 16 which is used in
> > __add_page_to_hash_queue() to set the age of a hashed page ... IMHO only
> > touch_page() should be used.  Nevertheless a static value of 16
> > breaks the dynamic manner of swap control via /proc/sys/vm/swapctl
> 
> Without my mmap-age patch, page cache pages aren't aged
> at all... They're just freed whenever they weren't referenced
> since the last scan. The PAGE_AGE_VALUE is quite useless IMO
> (but I could be wrong, Stephen?).

The age of a page cache page isn't changed if a process took it (?). IMHO that
means that this age is the starting age of such a process page, isn't it?
Maybe it would be a win if the initial page age, the increase and decrease
amount for the page age depends on the priority or the amount of
the time slice of the owner process(es).


          Werner
