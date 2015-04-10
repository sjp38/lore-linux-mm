Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id A6F666B0038
	for <linux-mm@kvack.org>; Fri, 10 Apr 2015 13:56:18 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so28296538pab.3
        for <linux-mm@kvack.org>; Fri, 10 Apr 2015 10:56:18 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id i10si3928464pat.132.2015.04.10.10.56.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Apr 2015 10:56:17 -0700 (PDT)
Received: by paboj16 with SMTP id oj16so28441517pab.0
        for <linux-mm@kvack.org>; Fri, 10 Apr 2015 10:56:17 -0700 (PDT)
Date: Fri, 10 Apr 2015 10:56:07 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [Question] ksm: rmap_item pointing to some stale vmas
In-Reply-To: <55268741.8010301@codeaurora.org>
Message-ID: <alpine.LSU.2.11.1504101047200.28925@eggly.anvils>
References: <55268741.8010301@codeaurora.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Susheel Khiani <skhiani@codeaurora.org>
Cc: akpm@linux-foundation.org, peterz@infradead.org, neilb@suse.de, dhowells@redhat.com, hughd@google.com, paulmcquad@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 9 Apr 2015, Susheel Khiani wrote:

> Hi,
> 
> We are seeing an issue during try_to_unmap_ksm where in call to
> try_to_unmap_one is failing.
> 
> try_to_unmap_ksm in this particular case is trying to go through vmas
> associated with each rmap_item->anon_vma. What we see is this that the
> corresponding page is not mapped to any of the vmas associated with 2
> rmap_item.
> 
> The associated rmap_item in this case looks like pointing to some valid vma
> but the said page is not found to be mapped under it. try_to_unmap_one thus
> fails to find valid ptes for these vmas.
> 
> At the same time we can see that the page actually is mapped in 2 separate
> and different vmas which are not part of rmap_item associated with page.
> 
> So whether rmap_item is pointing to some stale vmas and now the mapping has
> changed? Or there is something else going on here.
> p
> Any pointer would be appreciated.

I expected to be able to argue this away, but no: I think you've found
a bug, and I think I get it too.  I have no idea what's wrong at this
point, will set aside some time to investigate, and report back.

Which kernel are you using?  try_to_unmap_ksm says v3.13 or earlier.
Probably doesn't affect the bug, but may affect the patch you'll need.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
