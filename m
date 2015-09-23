Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id A5A736B0253
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 06:21:45 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so62060506wic.1
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 03:21:45 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id ao8si8427949wjc.186.2015.09.23.03.21.44
        for <linux-mm@kvack.org>;
        Wed, 23 Sep 2015 03:21:44 -0700 (PDT)
Date: Wed, 23 Sep 2015 12:21:42 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: HMM (Heterogeneous Memory Management) v10
Message-ID: <20150923102142.GA12746@amd>
References: <1439493328-1028-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1439493328-1028-1-git-send-email-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jeff Law <law@redhat.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>

Hi!

> Minor fixes since last post (1), apply on top of 4.2-rc6 done
> that because conflict in infiniband are harder to solve then

is.

> conflict with mm tree.
> 
> Tree with the patchset:
> git://people.freedesktop.org/~glisse/linux hmm-v10 branch
> 
> Previous cover letter :
> 
> 
> 
> HMM (Heterogeneous Memory Management) is an helper layer for device
> that want to mirror a process address space into their own mmu. Main
> target is GPU but other hardware, like network device can take also

GPU, ... devices

> use HMM.
> 
> There is two side to HMM, first one is mirroring of process address

There are

> space on behalf of a device. HMM will manage a secondary page table
> for the device and keep it synchronize with the CPU page table. HMM

synchronized

> also do DMA mapping on behalf of the device (which would allow new

also does

> kind of optimization further down the road (2)).

kinds of optimalizations

> Second side is allowing to migrate process memory to device memory

,

> where device memory is unmappable by the CPU. Any CPU access will
> trigger special fault that will migrate memory back. This patchset
> does not deal with remote memory migration.
> 
> 
> Why doing this ?
> 
> Mirroring a process address space is mandatory with OpenCL 2.0 and
> with other GPU compute API. OpenCL 2.0 allow different level of

APIs... allows

> implementation and currently only the lowest 2 are supported on
> Linux. To implement the highest level, where CPU and GPU access
> can happen concurently and are cache coherent, HMM is needed, or
> something providing same functionality, for instance through
> platform hardware.
> 
> Hardware solution such as PCIE ATS/PASID is limited to mirroring
> system memory and does not provide way to migrate memory to device
> memory (which offer significantly more bandwidth up to 10 times

, up to

> faster than regular system memory with discret GPU, also have

discrete? 

> lower latency than PCIE transaction).

> Current CPU with GPU on same die (AMD or Intel) use the ATS/PASID
> and for Intel a special level of cache (backed by a large pool of
> fast memory).
> 
> For foreeseeable futur, discrete GPU will remain releveant as they

future .. GPUs

> can have a large quantity of faster memory than integrated GPU.
> 
> Thus we believe HMM will allow to leverage discret GPU memory in

allow us... discrete

> a transparent fashion to the application, with minimum disruption
> to the linux kernel mm code. Also HMM can work along hardware
> solution such as PCIE ATS/PASID (leaving regular case to ATS/PASID
> while HMM handles the migrated memory case).

Best regards,
									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
