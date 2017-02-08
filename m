Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C25B6B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 09:01:18 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id v96so145753216ioi.5
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 06:01:18 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t84si3027840ioi.216.2017.02.08.06.01.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 06:01:17 -0800 (PST)
Subject: Re: mm: kernel BUG at __free_one_page() or free_pcppages_bulk()
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201702081932.IJD35962.LJFMFQFOtSOHVO@I-love.SAKURA.ne.jp>
	<5224177e-ca22-e726-c5ad-485ad5c9fd74@suse.cz>
In-Reply-To: <5224177e-ca22-e726-c5ad-485ad5c9fd74@suse.cz>
Message-Id: <201702082301.CGG05233.HLSMtFOJVFQFOO@I-love.SAKURA.ne.jp>
Date: Wed, 8 Feb 2017 23:01:11 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vbabka@suse.cz, linux-mm@kvack.org
Cc: mgorman@techsingularity.net, mhocko@suse.cz, akpm@linux-foundation.org

Vlastimil Babka wrote:
> On 02/08/2017 11:32 AM, Tetsuo Handa wrote:
> > I trivially get race conditions while testing below diff on linux-next-20170207.
> > Is this diff doing something wrong? I tried CONFIG_KASAN=y but it reported nothing.
> 
> You can't revert "mm, page_alloc: drain per-cpu pages from workqueue context" 
> without "mm, page_alloc: only use per-cpu allocator for irq-safe requests".

OK. So, this test was invalid. Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
