Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DF5696B0088
	for <linux-mm@kvack.org>; Sat,  8 Jan 2011 17:56:56 -0500 (EST)
Received: by qyk7 with SMTP id 7so470034qyk.14
        for <linux-mm@kvack.org>; Sat, 08 Jan 2011 14:56:56 -0800 (PST)
MIME-Version: 1.0
Date: Sat, 8 Jan 2011 22:56:55 +0000
Message-ID: <AANLkTi=no+m+pan+5nyxMGb=gJkW8YctdUu+BCRLfk_2@mail.gmail.com>
Subject: bootmem -> buddy allocator accounting
From: Andrew Murray <amurray@mpcdata.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

I've added instrumentation into mm/bootm.c __free and __reserve
functions to report how many accumulative pages the bootmem allocator
reserves prior to the zone allocator. I had expected this figure
multiplied by the page size to equal the 'reserved' figure in the
'Memory: 126604k/126604k available, 4468k reserved, 0K highmem' line.
However this seems to be 'out by one'.

I'm using the latest stable kernel.org kernel, with
versatile_defconfig (ARM) - it seems that the figure reported by
arch/arm/mm/init.c (mem_init) - reports the reserved pages - via the
PageReserved macro's - a page size smaller (4468k) than that found via
my instrumentation (4472k).

Is a page being lost somewhere? not accounted for? or is it being
reserved elsewhere?

Many Thanks,

Andrew Murray

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
