Received: from Galois.suse.de (Galois.suse.de [195.125.217.193])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA06102
	for <linux-mm@kvack.org>; Thu, 26 Feb 1998 06:10:27 -0500
Date: Thu, 26 Feb 1998 12:03:50 +0100
Message-Id: <199802261103.MAA03115@boole.fs100.suse.de>
From: "Dr. Werner Fink" <werner@suse.de>
In-reply-to: <Pine.LNX.3.91.980225232521.1846B-100000@mirkwood.dummy.home>
	(message from Rik van Riel on Wed, 25 Feb 1998 23:27:25 +0100 (MET))
Subject: Re: Fairness in love and swapping
Sender: owner-linux-mm@kvack.org
To: H.H.vanRiel@fys.ruu.nl
Cc: sct@dcs.ed.ac.uk, torvalds@transmeta.com, nahshon@actcom.co.il, alan@lxorguk.ukuu.org.uk, paubert@iram.es, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[...]
> 
> It looks kinda valid, and I'll try and tune it RSN. If
> it gives any improvement, I'll send it to Linus for
> inclusion.

There is one point more which makes ageing a bit unfair.  In
include/linux/pagemap.h PAGE_AGE_VALUE is defined to 16 which is used in
__add_page_to_hash_queue() to set the age of a hashed page ... IMHO only
touch_page() should be used.  Nevertheless a static value of 16
breaks the dynamic manner of swap control via /proc/sys/vm/swapctl


         Werner
