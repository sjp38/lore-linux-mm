Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 271FD6B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 03:30:05 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so198844608wic.1
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 00:30:04 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id bz9si2229609wib.8.2015.10.07.00.30.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Oct 2015 00:30:04 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so199733778wic.0
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 00:30:04 -0700 (PDT)
Date: Wed, 7 Oct 2015 09:30:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: convert threshold to bytes
Message-ID: <20151007073002.GA17444@dhcp22.suse.cz>
References: <fc100a5a381d1961c3b917489eb82b098d9e0840.1444081366.git.shli@fb.com>
 <20151006170122.GB2752@dhcp22.suse.cz>
 <20151006122225.8a499b42f49d8484b61632a8@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151006122225.8a499b42f49d8484b61632a8@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shaohua Li <shli@fb.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>

On Tue 06-10-15 12:22:25, Andrew Morton wrote:
> On Tue, 6 Oct 2015 19:01:23 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Mon 05-10-15 14:44:22, Shaohua Li wrote:
> > > The page_counter_memparse() returns pages for the threshold, while
> > > mem_cgroup_usage() returns bytes for memory usage. Convert the threshold
> > > to bytes.
> > > 
> > > Looks a regression introduced by 3e32cb2e0a12b69150
> > 
> > Yes. This suggests
> > Cc: stable # 3.19+
> 
> But it's been this way for 2 years and nobody noticed it.  How come?

Maybe we do not have that many users of this API with newer kernels.

> Or at least, nobody reported it.  Maybe people *have* noticed it, and
> adjusted their userspace appropriately.  In which case this patch will
> cause breakage.

I dunno, I would rather have it fixed than keep bug to bug compatibility
because they would eventually move to a newer kernel one day when they
see the "breakage" anyway.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
