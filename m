Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 50E436B0005
	for <linux-mm@kvack.org>; Mon, 30 May 2016 23:52:53 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id q18so136625206igr.2
        for <linux-mm@kvack.org>; Mon, 30 May 2016 20:52:53 -0700 (PDT)
Received: from out4133-50.mail.aliyun.com (out4133-50.mail.aliyun.com. [42.120.133.50])
        by mx.google.com with ESMTP id 68si28821436itm.58.2016.05.30.20.52.51
        for <linux-mm@kvack.org>;
        Mon, 30 May 2016 20:52:52 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <001701d1ba44$b9c0d560$2d428020$@alibaba-inc.com> <001901d1ba4a$514eccc0$f3ec6640$@alibaba-inc.com> <87mvn71rwc.fsf@skywalker.in.ibm.com>
In-Reply-To: <87mvn71rwc.fsf@skywalker.in.ibm.com>
Subject: Re: [RFC PATCH 2/4] mm: Change the interface for __tlb_remove_page
Date: Tue, 31 May 2016 11:52:48 +0800
Message-ID: <002b01d1baef$e6246530$b26d2f90$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Aneesh Kumar K.V'" <aneesh.kumar@linux.vnet.ibm.com>
Cc: 'linux-kernel' <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> >> @@ -1202,7 +1205,12 @@ again:
> >>  	if (force_flush) {
> >>  		force_flush = 0;
> >>  		tlb_flush_mmu_free(tlb);
> >> -
> >> +		if (pending_page) {
> >> +			/* remove the page with new size */
> >> +			__tlb_adjust_range(tlb, tlb->addr);
> >
> > Would you please specify why tlb->addr is used here?
> >
> 
> That is needed because tlb_flush_mmu_tlbonly() does a __tlb_reset_range().
> 
If ->addr is updated in resetting, then it is a noop here to deliver tlb->addr to
__tlb_adjust_range().
On the other hand, if ->addr is not updated in resetting, then it is also a noop here.

Do you want to update ->addr here?

thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
