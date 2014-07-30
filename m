Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id C11DB6B0036
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 06:52:54 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id hz1so1312688pad.36
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 03:52:54 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id ik3si1940367pbc.249.2014.07.30.03.52.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 30 Jul 2014 03:52:53 -0700 (PDT)
Message-ID: <1406717571.9336.19.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] mm: BUG when __kmap_atomic_idx crosses boundary
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Wed, 30 Jul 2014 03:52:51 -0700
In-Reply-To: <1406716641.9336.17.camel@buesod1.americas.hpqcorp.net>
References: <1406710355-4360-1-git-send-email-cpandya@codeaurora.org>
	 <20140730020615.2f943cf7.akpm@linux-foundation.org>
	 <1406716641.9336.17.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chintan Pandya <cpandya@codeaurora.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 2014-07-30 at 03:37 -0700, Davidlohr Bueso wrote:
> On Wed, 2014-07-30 at 02:06 -0700, Andrew Morton wrote:
> > On Wed, 30 Jul 2014 14:22:35 +0530 Chintan Pandya <cpandya@codeaurora.org> wrote:
> > 
> > > __kmap_atomic_idx >= KM_TYPE_NR or < ZERO is a bug.
> > > Report it even if CONFIG_DEBUG_HIGHMEM is not enabled.
> > > That saves much debugging efforts.
> > 
> > Please take considerably more care when preparing patch changelogs.
> > 
> > kmap_atomic() is a very commonly called function so we'll need much
> > more detail than this to justify adding overhead to it.
> > 
> > I don't think CONFIG_DEBUG_HIGHMEM really needs to exist.  We could do
> > s/CONFIG_DEBUG_HIGHMEM/CONFIG_DEBUG_VM/g and perhaps your secret bug
> > whatever it was would have been found more easily.
> 
> Agreed, it would be nice to fold DEBUG_HIGHMEM into DEBUG_VM. However
> you'd still need some kind of intermediate option as DEBUG_VM must still
> exist if !HIGHMEM.

Actually no, it's a lot more straightforward than I thought.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
