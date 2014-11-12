Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 786906B0131
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 20:20:35 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id fp1so11124906pdb.37
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 17:20:35 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id oj10si18818522pdb.108.2014.11.11.17.20.32
        for <linux-mm@kvack.org>;
        Tue, 11 Nov 2014 17:20:33 -0800 (PST)
Date: Wed, 12 Nov 2014 10:22:45 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [Bug 87891] New: kernel BUG at mm/slab.c:2625!
Message-ID: <20141112012244.GA21576@js1304-P5Q-DELUXE>
References: <bug-87891-27@https.bugzilla.kernel.org/>
 <alpine.DEB.2.11.1411111833220.8762@gentwo.org>
 <20141111164913.3616531c21c91499871c46de@linux-foundation.org>
 <201411120054.04651.luke@dashjr.org>
 <20141111170243.c24ce5fdb5efaf0814071847@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141111170243.c24ce5fdb5efaf0814071847@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Luke Dashjr <luke@dashjr.org>, Christoph Lameter <cl@linux.com>, Ming Lei <ming.lei@canonical.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Pauli Nieminen <suokkos@gmail.com>, Dave Airlie <airlied@linux.ie>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, bugzilla-daemon@bugzilla.kernel.org, luke-jr+linuxbugs@utopios.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org

On Tue, Nov 11, 2014 at 05:02:43PM -0800, Andrew Morton wrote:
> On Wed, 12 Nov 2014 00:54:01 +0000 Luke Dashjr <luke@dashjr.org> wrote:
> 
> > On Wednesday, November 12, 2014 12:49:13 AM Andrew Morton wrote:
> > > But anyway - Luke, please attach your .config to
> > > https://bugzilla.kernel.org/show_bug.cgi?id=87891?
> > 
> > Done: https://bugzilla.kernel.org/attachment.cgi?id=157381
> > 
> 
> OK, thanks.  No CONFIG_HIGHMEM of course.  I'm stumped.

Hello, Andrew.

I think that the cause is GFP_HIGHMEM.
GFP_HIGHMEM is always defined regardless CONFIG_HIGHMEM.
Please look at the do_huge_pmd_anonymous_page().
It calls alloc_hugepage_vma() and then alloc_pages_vma() is called
with alloc_hugepage_gfpmask(). This gfpmask includes GFP_TRANSHUGE
and then GFP_HIGHUSER_MOVABLE.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
