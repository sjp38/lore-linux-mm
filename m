Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA12214
	for <linux-mm@kvack.org>; Thu, 26 Feb 1998 09:04:23 -0500
Date: Thu, 26 Feb 1998 12:34:40 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: Fairness in love and swapping
In-Reply-To: <199802261103.MAA03115@boole.fs100.suse.de>
Message-ID: <Pine.LNX.3.91.980226123303.26424F-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Dr. Werner Fink" <werner@suse.de>
Cc: sct@dcs.ed.ac.uk, torvalds@transmeta.com, nahshon@actcom.co.il, alan@lxorguk.ukuu.org.uk, paubert@iram.es, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Feb 1998, Dr. Werner Fink wrote:

> There is one point more which makes ageing a bit unfair.  In
> include/linux/pagemap.h PAGE_AGE_VALUE is defined to 16 which is used in
> __add_page_to_hash_queue() to set the age of a hashed page ... IMHO only
> touch_page() should be used.  Nevertheless a static value of 16
> breaks the dynamic manner of swap control via /proc/sys/vm/swapctl

Without my mmap-age patch, page cache pages aren't aged
at all... They're just freed whenever they weren't referenced
since the last scan. The PAGE_AGE_VALUE is quite useless IMO
(but I could be wrong, Stephen?).

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
