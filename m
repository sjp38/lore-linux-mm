Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0E76B0260
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 03:49:17 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c206so20531746wme.3
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 00:49:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e7si14160574wrd.188.2017.01.14.00.49.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 14 Jan 2017 00:49:16 -0800 (PST)
Date: Sat, 14 Jan 2017 09:49:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/6] treewide: use kv[mz]alloc* rather than opencoded
 variants
Message-ID: <20170114084912.GB9962@dhcp22.suse.cz>
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-6-mhocko@kernel.org>
 <20170112172906.GB31509@dhcp22.suse.cz>
 <c0b2f24d-a5e1-5ac7-ccba-347e0f17fd62@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c0b2f24d-a5e1-5ac7-ccba-347e0f17fd62@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Sat 14-01-17 12:01:50, Tetsuo Handa wrote:
> On 2017/01/13 2:29, Michal Hocko wrote:
> > Ilya has noticed that I've screwed up some k[zc]alloc conversions and
> > didn't use the kvzalloc. This is an updated patch with some acks
> > collected on the way
> > ---
> > From a7b89c6d0a3c685045e37740c8f97b065f37e0a4 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Wed, 4 Jan 2017 13:30:32 +0100
> > Subject: [PATCH] treewide: use kv[mz]alloc* rather than opencoded variants
> > 
> > There are many code paths opencoding kvmalloc. Let's use the helper
> > instead. The main difference to kvmalloc is that those users are usually
> > not considering all the aspects of the memory allocator. E.g. allocation
> > requests < 64kB are basically never failing and invoke OOM killer to
> 
> Isn't this "requests <= 32kB" because allocation requests for 33kB will be
> rounded up to 64kB?

Yes

> Same for "smaller than 64kB" in PATCH 6/6. But strictly speaking, isn't
> it bogus to refer actual size because PAGE_SIZE is not always 4096?

This is just an example and I didn't want to pull
PAGE_ALLOC_COSTLY_ORDER here. So I've instead fixed the wording to:
"
E.g. allocation requests <= 32kB (with 4kB pages) are basically never
failing and invoke OOM killer to satisfy the allocation.
"
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
