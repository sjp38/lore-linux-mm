Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 26B216B025E
	for <linux-mm@kvack.org>; Thu,  6 Oct 2016 10:02:22 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id j85so523746wmj.5
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 07:02:22 -0700 (PDT)
Received: from arcturus.aphlor.org (arcturus.ipv6.aphlor.org. [2a03:9800:10:4a::2])
        by mx.google.com with ESMTPS id n8si17032192wju.259.2016.10.06.07.02.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Oct 2016 07:02:20 -0700 (PDT)
Date: Thu, 6 Oct 2016 10:02:17 -0400
From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: page_cache_tree_insert WARN_ON hit on 4.8+
Message-ID: <20161006140217.a7hsj3lzu5v3v6ig@codemonkey.org.uk>
References: <20161004170955.n25polpcsotmwcdq@codemonkey.org.uk>
 <20161004173425.GA1223@cmpxchg.org>
 <20161004174645.urwwmvgibabaokjn@codemonkey.org.uk>
 <20161006134145.GA13177@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161006134145.GA13177@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, Oct 06, 2016 at 03:41:45PM +0200, Johannes Weiner wrote:
 > On Tue, Oct 04, 2016 at 01:46:45PM -0400, Dave Jones wrote:
 > > On Tue, Oct 04, 2016 at 07:34:25PM +0200, Johannes Weiner wrote:
 > >  > On Tue, Oct 04, 2016 at 01:09:55PM -0400, Dave Jones wrote:
 > >  > > Hit this during a trinity run.
 > >  > > Kernel built from v4.8-1558-g21f54ddae449
 > >  > > 
 > >  > > WARNING: CPU: 0 PID: 5670 at ./include/linux/swap.h:276 page_cache_tree_insert+0x198/0x1b0
 > 
 > To tie up this thread, we tracked it down in another thread and Linus
 > merged a fix for this:
 > 
 > https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=d3798ae8c6f3767c726403c2ca6ecc317752c9dd

Yep, can confirm I've seen no reoccurrences since that merge.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
