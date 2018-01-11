Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id A3CEE6B0069
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 15:59:16 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id s24so2786999ioa.9
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 12:59:16 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e3si1097143ith.129.2018.01.11.12.59.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Jan 2018 12:59:15 -0800 (PST)
Subject: Re: [mm? 4.15-rc7] Random oopses under memory pressure.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20180110124519.GU1732@dhcp22.suse.cz>
	<201801102237.BED34322.QOOJMFFFHVLSOt@I-love.SAKURA.ne.jp>
	<20180111135721.GC1732@dhcp22.suse.cz>
	<201801112311.EHI90152.FLJMQOStVHFOFO@I-love.SAKURA.ne.jp>
	<CA+55aFwj+x42UtTg4AEbgdW2p6TaZRPjT+BpN1qDrrBh1G8aRA@mail.gmail.com>
In-Reply-To: <CA+55aFwj+x42UtTg4AEbgdW2p6TaZRPjT+BpN1qDrrBh1G8aRA@mail.gmail.com>
Message-Id: <201801120559.FIE00099.MHJFVQSOFFOtLO@I-love.SAKURA.ne.jp>
Date: Fri, 12 Jan 2018 05:59:04 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: mhocko@suse.com, linux-mm@kvack.org, x86@kernel.org, linux-fsdevel@vger.kernel.org

Linus Torvalds wrote:
> On Thu, Jan 11, 2018 at 6:11 AM, Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
> >
> > I retested with some debug printk() patch.
> 
> Could you perhaps enable KASAN too?

Unfortunately, KASAN is not available for x86_32 kernels. Thus, I'm stuck.

> So presumably "page->mem_cgroup" was just a random pointer. Which
> probably means that "page" itself is not actually a page pointer, sinc
> e I assume there was no memory hotplug going on here?

Nothing special. No memory hotplug etc.

> Most (all?) of your other oopses seem to have somewhat similar
> patterns: shrink_inactive_list() -> rmap_walk_file() -> oops due to
> garbage.

Yes. In most cases, problems are detected by that sequence.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
