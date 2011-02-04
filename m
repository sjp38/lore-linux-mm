Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D6E758D0040
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 13:17:35 -0500 (EST)
MIME-Version: 1.0
Message-ID: <85990ed5-f5d4-4ab2-809c-d181c865e86d@default>
Date: Fri, 4 Feb 2011 10:16:49 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [LSF/MM TOPIC] improving in-kernel transcendent memory
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@linuxfoundation.org
Cc: linux-mm@kvack.org

The concepts of transcendent memory, including cleancache and frontswap,
have now graduated beyond virtualization to have real value in a
standalone kernel.  See the proposed kztmem patch:

http://lwn.net/Articles/423540/=20

For the page cache, this effectively extends the split LRU (active/inactive=
)
page queues to now include a new "queue" containing compressed clean page
cache pages.

For swap (as with ramzswap/zram), compressed in-memory swap pages may
negatively impact memory pressure in some workloads and a method
needs to be contrived to move these pages to a physical swap disk.

Some things to discuss:
1) What is the appropriate page count balance between the active queue,
   the inactive queue, and cleancache-compressed pages?
2) What triggers can be used for rebalancing?
3) Is there a better "source" for cleancache than pages reclaimed from
   the inactive queue?
4) Under what conditions should frontswap-compressed pages be "repatriated"
   to normal kernel memory (and possibly to disk)?

I also hope to also be able to describe and possibly demo a brand new in-ke=
rnel
(non-virtualization) user of transcendent memory (including both cleancache
and frontswap) that I think attendees in ALL tracks will find intriguing, b=
ut
I'm not ready to talk about until closer to LSF/MM workshop.  (Hopefully,
this will make a good lightning talk.)

Thanks,
Dan Magenheimer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
