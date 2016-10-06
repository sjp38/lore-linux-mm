Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 33C626B0038
	for <linux-mm@kvack.org>; Thu,  6 Oct 2016 09:41:51 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i130so222889wmg.4
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 06:41:51 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l130si17671197wmf.42.2016.10.06.06.41.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Oct 2016 06:41:49 -0700 (PDT)
Date: Thu, 6 Oct 2016 15:41:45 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: page_cache_tree_insert WARN_ON hit on 4.8+
Message-ID: <20161006134145.GA13177@cmpxchg.org>
References: <20161004170955.n25polpcsotmwcdq@codemonkey.org.uk>
 <20161004173425.GA1223@cmpxchg.org>
 <20161004174645.urwwmvgibabaokjn@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161004174645.urwwmvgibabaokjn@codemonkey.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@codemonkey.org.uk>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, Oct 04, 2016 at 01:46:45PM -0400, Dave Jones wrote:
> On Tue, Oct 04, 2016 at 07:34:25PM +0200, Johannes Weiner wrote:
>  > On Tue, Oct 04, 2016 at 01:09:55PM -0400, Dave Jones wrote:
>  > > Hit this during a trinity run.
>  > > Kernel built from v4.8-1558-g21f54ddae449
>  > > 
>  > > WARNING: CPU: 0 PID: 5670 at ./include/linux/swap.h:276 page_cache_tree_insert+0x198/0x1b0

To tie up this thread, we tracked it down in another thread and Linus
merged a fix for this:

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=d3798ae8c6f3767c726403c2ca6ecc317752c9dd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
