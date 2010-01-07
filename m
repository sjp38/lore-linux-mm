Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6E1A26B003D
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 07:34:56 -0500 (EST)
Received: by ewy24 with SMTP id 24so24341983ewy.6
        for <linux-mm@kvack.org>; Thu, 07 Jan 2010 04:34:54 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 7 Jan 2010 12:34:54 +0000
Message-ID: <87a5b0801001070434m7f6b0fd6vfcdf49ab73a06cbb@mail.gmail.com>
Subject: Commit f50de2d38 seems to be breaking my oom killer
From: Will Newton <will.newton@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I'm having some problems on a small embedded box with 24Mb of RAM and
no swap. If a process tries to use large amounts of memory and gets
OOM killed, with 2.6.32 it's fine, but with 2.6.33-rc2 kswapd gets
stuck and the system locks up. The problem appears to have been
introduced with f50de2d38. If I change sleeping_prematurely to skip
the for_each_populated_zone test then OOM killing operates as
expected. I'm guessing it's caused by the new code not allowing kswapd
to schedule when it is required to let the killed task exit. Does that
sound plausible?

I'll try and investigate further into what's going on.

Thanks,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
