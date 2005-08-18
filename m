Received: by wproxy.gmail.com with SMTP id i6so634561wra
        for <linux-mm@kvack.org>; Thu, 18 Aug 2005 14:58:57 -0700 (PDT)
Message-ID: <e692861c05081814582671a6a3@mail.gmail.com>
Date: Thu, 18 Aug 2005 17:58:57 -0400
From: Gregory Maxwell <gmaxwell@gmail.com>
Subject: Preswapping
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

With the ability to measure something approximating least frequently
used inactive pages now, would it not make sense to begin more
aggressive nonevicting preswapping?

For example, if the swap disks are not busy, we scan the least
frequently used inactive pages, and write them out in nice large
chunks. The pages are moved to another list, but not evicted from
memory. The normal swapping algorithm is used to decide when/if to
actually evict these pages from memory.  If they are used prior to
being evicted, they can be remarked active (and their blocks on swap
marked as unused) without a disk seek.

This approach makes sense because swapping performance is often
limited by seeks rather than disk throughput or capacity. While under
memory pressure a system with preswapping has a substantial head start
on other systems because it is likely that majority of the unneeded 
pages are going to already be on disk, all that is needed is to evict
them. Also, this process allows us to be very aggressive in what we
write to disk so that the truly useless pages get out, but not run the
risk of overswapping on a system with plenty of free memory.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
