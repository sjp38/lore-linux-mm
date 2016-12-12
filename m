Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 09DCC6B025E
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 03:52:58 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id xy5so22243634wjc.0
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 00:52:57 -0800 (PST)
Received: from mail-wj0-f193.google.com (mail-wj0-f193.google.com. [209.85.210.193])
        by mx.google.com with ESMTPS id v186si27462560wma.24.2016.12.12.00.52.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 00:52:56 -0800 (PST)
Received: by mail-wj0-f193.google.com with SMTP id xy5so10256912wjc.1
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 00:52:56 -0800 (PST)
Date: Mon, 12 Dec 2016 09:52:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
 automatically
Message-ID: <20161212085254.GC18163@dhcp22.suse.cz>
References: <201612061938.DDD73970.QFHOFJStFOLVOM@I-love.SAKURA.ne.jp>
 <20161206192242.GA10273@dhcp22.suse.cz>
 <201612082153.BHC81241.VtMFFHOLJOOFSQ@I-love.SAKURA.ne.jp>
 <20161208134718.GC26530@dhcp22.suse.cz>
 <201612112023.HBB57332.QOFFtJLOOMFSVH@I-love.SAKURA.ne.jp>
 <201612112253.GGH60933.tOMHJQOFSOFFVL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612112253.GGH60933.tOMHJQOFSOFFVL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 11-12-16 22:53:55, Tetsuo Handa wrote:
> Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Thu 08-12-16 21:53:44, Tetsuo Handa wrote:
> > > > If we could agree
> > > > with calling __alloc_pages_nowmark() before out_of_memory() if __GFP_NOFAIL
> > > > is given, we can avoid locking up while minimizing possibility of invoking
> > > > the OOM killer...
> > >
> > > I do not understand. We do __alloc_pages_nowmark even when oom is called
> > > for GFP_NOFAIL.
> > 
> > Where is that? I can find __alloc_pages_nowmark() after out_of_memory()
> > if __GFP_NOFAIL is given, but I can't find __alloc_pages_nowmark() before
> > out_of_memory() if __GFP_NOFAIL is given.
> > 
> > What I mean is below patch folded into
> > "[PATCH 1/2] mm: consolidate GFP_NOFAIL checks in the allocator slowpath".
> > 
> Oops, I wrongly implemented "__alloc_pages_nowmark() before out_of_memory() if
> __GFP_NOFAIL is given." case. Updated version is shown below.

If you want to introduce such a change then make sure to justify it
properly in the changelog. I will not comment on this change here
because I believe it is not directly needed for neither of the two
patches.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
