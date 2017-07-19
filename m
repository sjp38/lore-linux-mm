Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7D4066B02C3
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 04:13:17 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z48so6589819wrc.4
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 01:13:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w16si3625061wrc.86.2017.07.19.01.13.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 01:13:16 -0700 (PDT)
Date: Wed, 19 Jul 2017 10:13:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v12 6/8] mm: support reporting free page blocks
Message-ID: <20170719081311.GC26779@dhcp22.suse.cz>
References: <1499863221-16206-1-git-send-email-wei.w.wang@intel.com>
 <1499863221-16206-7-git-send-email-wei.w.wang@intel.com>
 <20170714123023.GA2624@dhcp22.suse.cz>
 <20170714181523-mutt-send-email-mst@kernel.org>
 <20170717152448.GN12888@dhcp22.suse.cz>
 <596D6E7E.4070700@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <596D6E7E.4070700@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, virtio-dev@lists.oasis-open.org, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Tue 18-07-17 10:12:14, Wei Wang wrote:
[...]
> Probably I should have included the introduction of the usages in
> the log. Hope it is not too later to explain here:

Yes this should have been described in the cover.
 
> Live migration needs to transfer the VM's memory from the source
> machine to the destination round by round. For the 1st round, all the VM's
> memory is transferred. From the 2nd round, only the pieces of memory
> that were written by the guest (after the 1st round) are transferred. One
> method that is popularly used by the hypervisor to track which part of
> memory is written is to write-protect all the guest memory.
> 
> This patch enables the optimization of the 1st round memory transfer -
> the hypervisor can skip the transfer of guest unused pages in the 1st round.

All you should need is the check for the page reference count, no?  I
assume you do some sort of pfn walk and so you should be able to get an
access to the struct page.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
