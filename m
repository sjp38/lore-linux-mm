Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id A94AD6B0035
	for <linux-mm@kvack.org>; Fri, 25 Jul 2014 11:14:50 -0400 (EDT)
Received: by mail-qa0-f53.google.com with SMTP id v10so4581513qac.26
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 08:14:50 -0700 (PDT)
Received: from mail-qg0-x236.google.com (mail-qg0-x236.google.com [2607:f8b0:400d:c04::236])
        by mx.google.com with ESMTPS id 8si952145qgz.7.2014.07.25.08.14.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Jul 2014 08:14:50 -0700 (PDT)
Received: by mail-qg0-f54.google.com with SMTP id z60so5295038qgd.27
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 08:14:49 -0700 (PDT)
Date: Fri, 25 Jul 2014 11:14:41 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 3/7] mmu_notifier: pass through vma to invalidate_range
 and invalidate_page v3
Message-ID: <20140725151440.GA3218@gmail.com>
References: <1405622809-3797-1-git-send-email-j.glisse@gmail.com>
 <1405622809-3797-4-git-send-email-j.glisse@gmail.com>
 <20140724155157.c7e651db5f4947909123e602@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140724155157.c7e651db5f4947909123e602@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Thu, Jul 24, 2014 at 03:51:57PM -0700, Andrew Morton wrote:
> On Thu, 17 Jul 2014 14:46:49 -0400 j.glisse@gmail.com wrote:
> 
> > New user of the mmu_notifier interface need to lookup vma in order to
> > perform the invalidation operation. Instead of redoing a vma lookup
> > inside the callback just pass through the vma from the call site where
> > it is already available.
> 
> Well..  what's wrong with performing the vma lookup within the
> callback?  Is it a correctness thing?  Deadlock avoidance, for example?
> 
> Or is it a performance thing?  If so, that's a bit surprising - please
> provide details?

No i have no benchmark showing any issue on that, just that 99% of call
place to mmu_notifier already had the vma handy and i thought it would
be helpful to other but all current user are not using vma. So as there
is no strong argument in favor of this change if you feel it is unnecessary
and fear any kind of regression than just ignore it and i will live with
vma lookup inside my code.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
