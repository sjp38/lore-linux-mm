Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 19B3E6B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 23:26:10 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so104749268pab.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 20:26:09 -0700 (PDT)
Received: from us-alimail-mta1.hst.scl.en.alidc.net (mail113-251.mail.alibaba.com. [205.204.113.251])
        by mx.google.com with ESMTP id pv8si26040468pbc.74.2015.10.22.20.26.08
        for <linux-mm@kvack.org>;
        Thu, 22 Oct 2015 20:26:09 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <062101d10cae$91d986d0$b58c9470$@alibaba-inc.com> <20151022142618.GC2914@redhat.com>
In-Reply-To: <20151022142618.GC2914@redhat.com>
Subject: Re: [PATCH v11 07/14] HMM: mm add helper to update page table when migrating memory v2.
Date: Fri, 23 Oct 2015 11:25:54 +0800
Message-ID: <071501d10d42$86fd39c0$94f7ad40$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Jerome Glisse' <jglisse@redhat.com>
Cc: 'linux-kernel' <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> > > This is a multi-stage process, first we save and replace page table
> > > entry with special HMM entry, also flushing tlb in the process. If
> > > we run into non allocated entry we either use the zero page or we
> > > allocate new page. For swaped entry we try to swap them in.
> > >
> > Please elaborate why swap entry is handled this way.
> 
> So first, this is only when you have a device then use HMM and a device
> that use memory migration. So far it only make sense for discrete GPUs.
> So regular workload that do not use a GPUs with HMM are not impacted and
> will not go throught this code path.
> 
> Now, here we are migrating memory because the device driver is asking for
> it, so presumably we are expecting that the device will use that memory
> hence we want to swap in anything that have been swap to disk. Once it is
> swap in memory we copy it to device memory and free the pages. So in the
> end we only need to allocate a page temporarily until we move things to
> the device.
> 
I prefer it is in log message.

thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
