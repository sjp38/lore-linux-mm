Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 867916B0035
	for <linux-mm@kvack.org>; Mon, 29 Sep 2014 03:44:23 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id eu11so1639382pac.14
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 00:44:23 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ze3si21502781pbb.208.2014.09.29.00.44.20
        for <linux-mm@kvack.org>;
        Mon, 29 Sep 2014 00:44:22 -0700 (PDT)
Date: Mon, 29 Sep 2014 16:44:18 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [REGRESSION] [PATCH 1/3] mm/slab: use percpu allocator for cpu
 cache
Message-ID: <20140929074418.GA29310@js1304-P5Q-DELUXE>
References: <1408608675-20420-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20140928062449.GA1277@hudson.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140928062449.GA1277@hudson.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeremiah Mahler <jmmahler@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Sep 27, 2014 at 11:24:49PM -0700, Jeremiah Mahler wrote:
> On Thu, Aug 21, 2014 at 05:11:13PM +0900, Joonsoo Kim wrote:
> > Because of chicken and egg problem, initializaion of SLAB is really
> > complicated. We need to allocate cpu cache through SLAB to make
> > the kmem_cache works, but, before initialization of kmem_cache,
> > allocation through SLAB is impossible.
> > 
> > On the other hand, SLUB does initialization with more simple way. It
> > uses percpu allocator to allocate cpu cache so there is no chicken and
> > egg problem.
> > 
> > So, this patch try to use percpu allocator in SLAB. This simplify
> > initialization step in SLAB so that we could maintain SLAB code more
> > easily.
> > 
> > From my testing, there is no performance difference.
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> I just encountered a problem on a Lenovo Carbon X1 where it will
> suspend but won't resume.  A bisect indicated that this patch
> is causing the problem.
> 
> 997888488ef92da365b870247de773255227ce1f
> 
> I imagine the patch author, Joonsoo Kim, might have a better idea
> why this is happening than I do.  But if I can provide any information
> or run any tests that might be of help just let me know.

Hello,

Yeah, there is a bug. Below will fix your issue.
Could you test it and report the result?

Thanks for reporting it.

--------->8---------------
