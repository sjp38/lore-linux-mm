Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8E7BB6B0037
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 06:12:04 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id hi2so14459825wib.0
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 03:12:02 -0700 (PDT)
Received: from mail.8bytes.org (8bytes.org. [2a01:238:4242:f000:64f:6c43:3523:e535])
        by mx.google.com with ESMTP id n9si40501418wiz.23.2014.07.07.03.12.01
        for <linux-mm@kvack.org>;
        Mon, 07 Jul 2014 03:12:01 -0700 (PDT)
Received: from localhost (localhost [127.0.0.1])
	by mail.8bytes.org (Postfix) with SMTP id 2383C12B1A2
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 12:12:01 +0200 (CEST)
Date: Mon, 7 Jul 2014 12:11:59 +0200
From: "joro@8bytes.org" <joro@8bytes.org>
Subject: Re: [PATCH 1/6] mmput: use notifier chain to call subsystem exit
 handler.
Message-ID: <20140707101158.GD1958@8bytes.org>
References: <20140630183556.GB3280@gmail.com>
 <20140701091535.GF26537@8bytes.org>
 <019CCE693E457142B37B791721487FD91806DD8B@storexdag01.amd.com>
 <20140701110018.GH26537@8bytes.org>
 <20140701193343.GB3322@gmail.com>
 <20140701210620.GL26537@8bytes.org>
 <20140701213208.GC3322@gmail.com>
 <20140703183024.GA3306@gmail.com>
 <20140703231541.GR26537@8bytes.org>
 <019CCE693E457142B37B791721487FD918085329@storexdag01.amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <019CCE693E457142B37B791721487FD918085329@storexdag01.amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Gabbay, Oded" <Oded.Gabbay@amd.com>
Cc: "dpoole@nvidia.com" <dpoole@nvidia.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "jweiner@redhat.com" <jweiner@redhat.com>, "mhairgrove@nvidia.com" <mhairgrove@nvidia.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "j.glisse@gmail.com" <j.glisse@gmail.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Lewycky, Andrew" <Andrew.Lewycky@amd.com>, "sgutti@nvidia.com" <sgutti@nvidia.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "riel@redhat.com" <riel@redhat.com>, "arvindg@nvidia.com" <arvindg@nvidia.com>, "SCheung@nvidia.com" <SCheung@nvidia.com>, "jakumar@nvidia.com" <jakumar@nvidia.com>, "jhubbard@nvidia.com" <jhubbard@nvidia.com>, "Cornwall, Jay" <Jay.Cornwall@amd.com>, "mgorman@suse.de" <mgorman@suse.de>, "cabuschardt@nvidia.com" <cabuschardt@nvidia.com>, "ldunning@nvidia.com" <ldunning@nvidia.com>

On Sun, Jul 06, 2014 at 07:25:18PM +0000, Gabbay, Oded wrote:
> Once we can agree on that, than I think we can agree that kfd and hmm
> can and should be bounded to mm struct and not file descriptors.

The file descriptor concept is the way it works in the rest of the
kernel. It works for numerous drivers and subsystems (KVM, VFIO, UIO,
...), when you close a file descriptor handed out from any of those
drivers (already in the kernel) all related resources will be freed. I
don't see a reason why HSA drivers should break these expectations and
be different.


	Joerg


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
