Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f178.google.com (mail-vc0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 81E856B0035
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 12:55:00 -0400 (EDT)
Received: by mail-vc0-f178.google.com with SMTP id ij19so7418541vcb.37
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 09:54:59 -0700 (PDT)
Received: from mail-vc0-x22e.google.com (mail-vc0-x22e.google.com [2607:f8b0:400c:c03::22e])
        by mx.google.com with ESMTPS id mw5si21839676vec.34.2014.07.09.09.54.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 09:54:58 -0700 (PDT)
Received: by mail-vc0-f174.google.com with SMTP id hy4so7434756vcb.19
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 09:54:58 -0700 (PDT)
Date: Wed, 9 Jul 2014 12:55:10 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 4/8] mmu_notifier: pass through vma to invalidate_range
 and invalidate_page v2
Message-ID: <20140709165448.GA4249@gmail.com>
References: <1404856801-11702-1-git-send-email-j.glisse@gmail.com>
 <1404856801-11702-5-git-send-email-j.glisse@gmail.com>
 <20140709164131.GQ1958@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140709164131.GQ1958@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 09, 2014 at 06:41:31PM +0200, Joerg Roedel wrote:
> On Tue, Jul 08, 2014 at 06:00:01PM -0400, j.glisse@gmail.com wrote:
> > New user of the mmu_notifier interface need to lookup vma in order to
> > perform the invalidation operation. Instead of redoing a vma lookup
> > inside the callback just pass through the vma from the call site where
> > it is already available.
> 
> Why do you need to lookup the vma during the invalidation operation?
> Given that invalidate_range_start/end can be expensive to implement on
> the call-back side those calls should happen less instead of more
> frequently.
> 

To do different thing if vma is file backed and depending on the block
device the file is in.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
