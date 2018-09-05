Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 184C56B7319
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 08:28:45 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id q11-v6so8396268oih.15
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 05:28:45 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r4-v6si1250903oih.116.2018.09.05.05.28.43
        for <linux-mm@kvack.org>;
        Wed, 05 Sep 2018 05:28:44 -0700 (PDT)
Date: Wed, 5 Sep 2018 13:28:57 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v2 0/5] Extend and consolidate mmu_gather into new file
Message-ID: <20180905122857.GH20186@arm.com>
References: <1536061533-16188-1-git-send-email-will.deacon@arm.com>
 <20180904125501.642e1004825350aca476a653@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180904125501.642e1004825350aca476a653@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, peterz@infradead.org, npiggin@gmail.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, aneesh.kumar@linux.vnet.ibm.com

On Tue, Sep 04, 2018 at 12:55:01PM -0700, Andrew Morton wrote:
> On Tue,  4 Sep 2018 12:45:28 +0100 Will Deacon <will.deacon@arm.com> wrote:
> 
> > This series builds on the core changes I previously posted here:
> > 
> >   rfc:	http://lists.infradead.org/pipermail/linux-arm-kernel/2018-August/597821.html
> >   v1:	http://lists.infradead.org/pipermail/linux-arm-kernel/2018-August/598919.html
> > 
> > The main changes are:
> > 
> >   * Move the mmu_gather bits out of memory.c and into their own file
> >     (looped in the mm people for this)
> > 
> >   * Add a MAINTAINERS entry for the new file, and all tlb.h headers.
> >     If any mm developers would like to be included here as well, please
> >     just ask.
> > 
> > I'd like to queue these patches on their own branch in the arm64 git so
> > that others can develop on top of them for the next merge window. Peter
> > and Nick have both expressed an interest in that, and I already have a
> > bunch of arm64 optimisations on top which I posted previously.
> 
> All looks good to me - please proceed that way.  Please also add me to
> the MAINTAINERS record so I get more emails.

Cheers, Andrew. I'll add you to the MAINTAINERS entry and get this lot into
-next once the kbuild robot is happy that I've got all the header files
right.

Will
