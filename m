Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7D6D36B0035
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 15:19:40 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id ft15so1811398pdb.25
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 12:19:40 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id sp2si9543224pac.210.2014.09.12.12.19.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Sep 2014 12:19:39 -0700 (PDT)
Date: Fri, 12 Sep 2014 12:19:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3 v3] mmu_notifier: Allow to manage CPU external TLBs
Message-Id: <20140912121937.ebb3010d52abd4196e9341de@linux-foundation.org>
In-Reply-To: <20140912184739.GF2519@suse.de>
References: <1410277434-3087-1-git-send-email-joro@8bytes.org>
	<20140910150125.31a7495c7d0fe814b85fd514@linux-foundation.org>
	<20140912184739.GF2519@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <jroedel@suse.de>
Cc: Joerg Roedel <joro@8bytes.org>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Jay.Cornwall@amd.com, Oded.Gabbay@amd.com, John.Bridgman@amd.com, Suravee.Suthikulpanit@amd.com, ben.sander@amd.com, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iommu@lists.linux-foundation.org

On Fri, 12 Sep 2014 20:47:39 +0200 Joerg Roedel <jroedel@suse.de> wrote:

> thanks for your review, I tried to answer your questions below.

You'd be amazed how helpful that was ;)

> Fair enough, I hope I clarified a few things with my explanations
> above. I will also update the description of the patch-set when I
> re-send.

Sounds good, thanks.


How does HMM play into all of this?  Would HMM make this patchset
obsolete, or could HMM be evolved to do so?  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
