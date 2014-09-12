Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5F0286B003A
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 15:27:40 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id g10so1849184pdj.24
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 12:27:40 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id wq6si9632039pac.179.2014.09.12.12.27.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Sep 2014 12:27:39 -0700 (PDT)
Date: Fri, 12 Sep 2014 12:27:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3 v3] mmu_notifier: Allow to manage CPU external TLBs
Message-Id: <20140912122737.53a7947e5378fa501092887b@linux-foundation.org>
In-Reply-To: <20140912192100.GB5196@gmail.com>
References: <1410277434-3087-1-git-send-email-joro@8bytes.org>
	<20140910150125.31a7495c7d0fe814b85fd514@linux-foundation.org>
	<20140911000211.GA4989@gmail.com>
	<20140912121036.1fb998af4147ad9ea35166db@linux-foundation.org>
	<20140912192100.GB5196@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Joerg Roedel <joro@8bytes.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, jroedel@suse.de, Peter Zijlstra <a.p.zijlstra@chello.nl>, John.Bridgman@amd.com, Jesse Barnes <jbarnes@virtuousgeek.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, ben.sander@amd.com, linux-mm@kvack.org, Jerome Glisse <jglisse@redhat.com>, Jay.Cornwall@amd.com, Mel Gorman <mgorman@suse.de>, David Woodhouse <dwmw2@infradead.org>, Johannes Weiner <jweiner@redhat.com>, iommu@lists.linux-foundation.org

On Fri, 12 Sep 2014 15:21:01 -0400 Jerome Glisse <j.glisse@gmail.com> wrote:

> > > I think this sumup all motivation behind this patchset and also behind
> > > my other patchset. As usual i am happy to discuss alternative way to do
> > > things but i think that the path of least disruption from current code
> > > is the one implemented by those patchset.
> > 
> > "least disruption" is nice, but "good implementation" is better.  In
> > other words I'd prefer the more complex implementation if the end
> > result is better.  Depending on the magnitudes of "complex" and
> > "better" :) Two years from now (which isn't very long), I don't think
> > we'll regret having chosen the better implementation.
> > 
> > Does this patchset make compromises to achieve low disruption?
> 
> Well right now i think we are lacking proper userspace support with which
> this code and the global new usecase can be stress tested allowing to gather
> profiling information.
> 
> I think as a first step we should take this least disruptive path and if
> it proove to perform badly then we should work toward possibly more complex
> design. Note that only complex design i can think of involve an overhaul of
> how process memory management is done and probably linking cpu page table
> update with the scheduler to try to hide cost of those update by scheduling
> other thread meanwhile.

OK.  Often I'd resist merging a patchset when we're not sure it will be
sufficient.  But there are practical advantages to doing so and the
present patchset is quite simple.  So if we decide to remove it later
on the impact will be small.  If the patchset made userspace-visible
changes then things would be different!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
