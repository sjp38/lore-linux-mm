Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id B99426B009B
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 18:52:00 -0400 (EDT)
Received: by mail-ig0-f175.google.com with SMTP id uq10so66441igb.8
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 15:52:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id dr20si17940239icb.98.2014.07.24.15.51.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jul 2014 15:52:00 -0700 (PDT)
Date: Thu, 24 Jul 2014 15:51:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/7] mmu_notifier: pass through vma to invalidate_range
 and invalidate_page v3
Message-Id: <20140724155157.c7e651db5f4947909123e602@linux-foundation.org>
In-Reply-To: <1405622809-3797-4-git-send-email-j.glisse@gmail.com>
References: <1405622809-3797-1-git-send-email-j.glisse@gmail.com>
	<1405622809-3797-4-git-send-email-j.glisse@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: j.glisse@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>

On Thu, 17 Jul 2014 14:46:49 -0400 j.glisse@gmail.com wrote:

> New user of the mmu_notifier interface need to lookup vma in order to
> perform the invalidation operation. Instead of redoing a vma lookup
> inside the callback just pass through the vma from the call site where
> it is already available.

Well..  what's wrong with performing the vma lookup within the
callback?  Is it a correctness thing?  Deadlock avoidance, for example?

Or is it a performance thing?  If so, that's a bit surprising - please
provide details?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
