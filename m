Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 68B1E6B0035
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 14:47:14 -0400 (EDT)
Received: by mail-qa0-f45.google.com with SMTP id cm18so2165641qab.4
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 11:47:14 -0700 (PDT)
Received: from mail-qa0-x22d.google.com (mail-qa0-x22d.google.com [2607:f8b0:400d:c00::22d])
        by mx.google.com with ESMTPS id a6si6454130qam.0.2014.07.17.11.47.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 17 Jul 2014 11:47:13 -0700 (PDT)
Received: by mail-qa0-f45.google.com with SMTP id cm18so2182447qab.18
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 11:47:13 -0700 (PDT)
From: j.glisse@gmail.com
Subject: mmu_notifier: preparatory patches for hmm and or iommuv2 v6
Date: Thu, 17 Jul 2014 14:46:46 -0400
Message-Id: <1405622809-3797-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>

Nutshell few patches to improve mmu_notifier :
 - patch 1/3 allow to free resources when mm_struct is destroy.
 - patch 2/3 provide context informations to mmu_notifier listener.
 - patch 3/3 pass vma to range_start/range_end to avoid duplicate
   vma lookup inside the listener.

I restricted myself to set of less controversial patches and i believe
i have addressed all comments that were previously made. Thanks again
for all feedback, i hope this version is the good one.

This is somewhat of a v5 but i do not include core hmm with those
patches. So previous discussion thread :
v1 http://www.spinics.net/lists/linux-mm/msg72501.html
v2 http://www.spinics.net/lists/linux-mm/msg74532.html
v3 http://www.spinics.net/lists/linux-mm/msg74656.html
v4 http://www.spinics.net/lists/linux-mm/msg75401.html
v5 http://www.spinics.net/lists/linux-mm/msg75875.html

Cheers,
JA(C)rA'me Glisse


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
