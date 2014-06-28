Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id A6BE46B0031
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 22:00:47 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id r5so5191256qcx.8
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 19:00:47 -0700 (PDT)
Received: from mail-qc0-x232.google.com (mail-qc0-x232.google.com [2607:f8b0:400d:c01::232])
        by mx.google.com with ESMTPS id f5si3222921qcq.17.2014.06.27.19.00.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Jun 2014 19:00:47 -0700 (PDT)
Received: by mail-qc0-f178.google.com with SMTP id c9so5142555qcz.23
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 19:00:46 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <j.glisse@gmail.com>
Subject: mm preparatory patches for HMM and IOMMUv2
Date: Fri, 27 Jun 2014 22:00:18 -0400
Message-Id: <1403920822-14488-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: mgorman@suse.de, hpa@zytor.com, peterz@infraread.org, aarcange@redhat.com, riel@redhat.com, jweiner@redhat.com, torvalds@linux-foundation.org, Mark Hairgrove <mhairgrove@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Oded Gabbay <Oded.Gabbay@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Andrew Lewycky <Andrew.Lewycky@amd.com>

Andrew so here are a set of mm patch that do some ground modification to core
mm code. They apply on top of today's linux-next and they pass checkpatch.pl
with flying color (except patch 4 but i did not wanted to be a nazi about 80
char line).

Patch 1 is the mmput notifier call chain we discussed with AMD.

Patch 2, 3 and 4 are so far only useful to HMM but i am discussing with AMD and
i believe it will be useful to them to (in the context of IOMMUv2).

Patch 2 allows to differentiate page unmap for vmscan reason or for poisoning.

Patch 3 associate mmu_notifier with an event type allowing to take different code
path inside mmu_notifier callback depending on what is currently happening to the
cpu page table. There is no functional change, it just add a new argument to the
various mmu_notifier calls and callback.

Patch 4 pass along the vma into which the range invalidation is happening. There
is few functional changes in place where mmu_notifier_range_invalidate_start/end
used [0, -1] as range, instead now those place call the notifier once for each
vma. This might prove to add unwanted overhead hence why i did it as a separate
patch.

I did not include the core hmm patch but i intend to send a v4 next week. So i
really would like to see those included for next release.

As usual comments welcome.

Cheers,
JA(C)rA'me Glisse

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
