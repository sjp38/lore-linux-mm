Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0406B0031
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 19:50:54 -0400 (EDT)
Received: by mail-qc0-f180.google.com with SMTP id r5so5799772qcx.25
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 16:50:54 -0700 (PDT)
Received: from mail-qc0-x22a.google.com (mail-qc0-x22a.google.com [2607:f8b0:400d:c01::22a])
        by mx.google.com with ESMTPS id b10si34470799qcf.35.2014.07.08.16.50.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Jul 2014 16:50:53 -0700 (PDT)
Received: by mail-qc0-f170.google.com with SMTP id c9so127379qcz.1
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 16:50:53 -0700 (PDT)
Date: Tue, 8 Jul 2014 19:50:45 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: mm: Various preparatory patches for hmm and kfd
Message-ID: <20140708235044.GA5222@gmail.com>
References: <1404856801-11702-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1404856801-11702-1-git-send-email-j.glisse@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>

On Tue, Jul 08, 2014 at 05:59:57PM -0400, j.glisse@gmail.com wrote:
> So here is updated patchset. I believe the first patch despite Joerg
> opposition, is still a welcome change to mmput. Wether or not kfd and
> hmm could register might still be debated but i strongly believe that
> the fact that we are tie to mm_struct and the file lifespan is not tie
> to a specific mm_struct is a testimony that we should interface with
> mm_struct destruction.
> 
> The third patch have updated comment and i hope address all Linus'
> worries. The event description have been updated and i hope is clear
> enough.
> 
> The last patch also been updated and now only pass vma to various
> mmu_notifier callback. This does means that instead of calling once
> the mmu_notifier for zapping whole address range, it will be call
> once per vma. I believe that given this change only impact process
> that use vma and that by restricting ourself to existing vma the
> impact will be small and might even turn to be a win as mmu listener
> will not have to traverse whole secondary page table full of non
> existant entry but only do job on thing that migth exist in the
> secondary page table.
> 
> Hope this address any previous concern about those patches.
> 
> Cheers,
> Jerome
> 
> 

I manage to forget mailing list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
