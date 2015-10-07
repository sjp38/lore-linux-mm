Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id D8A5D6B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 03:53:39 -0400 (EDT)
Received: by qgev79 with SMTP id v79so8890460qge.0
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 00:53:39 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n68si33084374qhb.62.2015.10.07.00.53.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Oct 2015 00:53:39 -0700 (PDT)
Date: Wed, 7 Oct 2015 00:58:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: convert threshold to bytes
Message-Id: <20151007005820.54a0b2da.akpm@linux-foundation.org>
In-Reply-To: <20151007073002.GA17444@dhcp22.suse.cz>
References: <fc100a5a381d1961c3b917489eb82b098d9e0840.1444081366.git.shli@fb.com>
	<20151006170122.GB2752@dhcp22.suse.cz>
	<20151006122225.8a499b42f49d8484b61632a8@linux-foundation.org>
	<20151007073002.GA17444@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Shaohua Li <shli@fb.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>

On Wed, 7 Oct 2015 09:30:02 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> On Tue 06-10-15 12:22:25, Andrew Morton wrote:
> > On Tue, 6 Oct 2015 19:01:23 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > > On Mon 05-10-15 14:44:22, Shaohua Li wrote:
> > > > The page_counter_memparse() returns pages for the threshold, while
> > > > mem_cgroup_usage() returns bytes for memory usage. Convert the threshold
> > > > to bytes.
> > > > 
> > > > Looks a regression introduced by 3e32cb2e0a12b69150
> > > 
> > > Yes. This suggests
> > > Cc: stable # 3.19+
> > 
> > But it's been this way for 2 years and nobody noticed it.  How come?
> 
> Maybe we do not have that many users of this API with newer kernels.

Either it's zero or all the users have worked around this bug.

> > Or at least, nobody reported it.  Maybe people *have* noticed it, and
> > adjusted their userspace appropriately.  In which case this patch will
> > cause breakage.
> 
> I dunno, I would rather have it fixed than keep bug to bug compatibility
> because they would eventually move to a newer kernel one day when they
> see the "breakage" anyway.

They'd only see breakage if we fixed this in the newer kernel.

We could just change the docs and leave it as-is.  That it is called
"usage_in_bytes" makes that a bit awkward.

A bit of googling indicates that people are using usage_in_bytes.  A
few.  All the discussions I found clearly predate this bug.

So did people just stop using this?  Is there some alternative way of
getting the same info?

Why does memcg_write_event_control() says "DO NOT USE IN NEW FILES"
and "DO NOT ADD NEW FILES"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
