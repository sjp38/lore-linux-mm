Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 290D36B0036
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 10:45:30 -0400 (EDT)
Received: by mail-qg0-f50.google.com with SMTP id q108so3390403qgd.9
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 07:45:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k12si11350423qav.129.2014.07.24.07.45.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jul 2014 07:45:29 -0700 (PDT)
Date: Thu, 24 Jul 2014 16:44:49 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 0/3] mmu_notifier: Allow to manage CPU external TLBs
Message-ID: <20140724144449.GC27715@redhat.com>
References: <1406212541-25975-1-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1406212541-25975-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Jerome Glisse <jglisse@redhat.com>, jroedel@suse.de, Jay.Cornwall@amd.com, Oded.Gabbay@amd.com, John.Bridgman@amd.com, Suravee.Suthikulpanit@amd.com, ben.sander@amd.com, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org

On Thu, Jul 24, 2014 at 04:35:38PM +0200, Joerg Roedel wrote:
> To solve this situation I wrote a patch-set to introduce a
> new notifier call-back: mmu_notifer_invalidate_range(). This
> notifier lifts the strict requirements that no new
> references are taken in the range between _start() and
> _end(). When the subsystem can't guarantee that any new
> references are taken is has to provide the
> invalidate_range() call-back to clear any new references in
> there.
> 
> It is called between invalidate_range_start() and _end()
> every time the VMM has to wipe out any references to a
> couple of pages. This are usually the places where the CPU
> TLBs are flushed too and where its important that this
> happens before invalidate_range_end() is called.
> 
> Any comments and review appreciated!

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
