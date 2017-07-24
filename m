Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id DB2536B02C3
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 05:00:51 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l3so23929523wrc.12
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 02:00:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v7si8704156wrc.439.2017.07.24.02.00.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Jul 2017 02:00:50 -0700 (PDT)
Date: Mon, 24 Jul 2017 11:00:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v12 6/8] mm: support reporting free page blocks
Message-ID: <20170724090042.GF25221@dhcp22.suse.cz>
References: <1499863221-16206-1-git-send-email-wei.w.wang@intel.com>
 <1499863221-16206-7-git-send-email-wei.w.wang@intel.com>
 <20170714123023.GA2624@dhcp22.suse.cz>
 <20170714181523-mutt-send-email-mst@kernel.org>
 <20170717152448.GN12888@dhcp22.suse.cz>
 <596D6E7E.4070700@intel.com>
 <20170719081311.GC26779@dhcp22.suse.cz>
 <596F4A0E.4010507@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <596F4A0E.4010507@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, virtio-dev@lists.oasis-open.org, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Wed 19-07-17 20:01:18, Wei Wang wrote:
> On 07/19/2017 04:13 PM, Michal Hocko wrote:
[...
> >All you should need is the check for the page reference count, no?  I
> >assume you do some sort of pfn walk and so you should be able to get an
> >access to the struct page.
> 
> Not necessarily - the guest struct page is not seen by the hypervisor. The
> hypervisor only gets those guest pfns which are hinted as unused. From the
> hypervisor (host) point of view, a guest physical address corresponds to a
> virtual address of a host process. So, once the hypervisor knows a guest
> physical page is unsued, it knows that the corresponding virtual memory of
> the process doesn't need to be transferred in the 1st round.

I am sorry, but I do not understand. Why cannot _guest_ simply check the
struct page ref count and send them to the hypervisor? Is there any
documentation which describes the workflow or code which would use your
new API?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
