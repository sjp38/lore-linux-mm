Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id EC5AF6B0253
	for <linux-mm@kvack.org>; Tue, 31 May 2016 03:26:52 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 85so315209401ioq.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 00:26:52 -0700 (PDT)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id p73si42815654ioe.171.2016.05.31.00.26.51
        for <linux-mm@kvack.org>;
        Tue, 31 May 2016 00:26:52 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <001701d1ba44$b9c0d560$2d428020$@alibaba-inc.com> <001901d1ba4a$514eccc0$f3ec6640$@alibaba-inc.com> <87mvn71rwc.fsf@skywalker.in.ibm.com> <002b01d1baef$e6246530$b26d2f90$@alibaba-inc.com> <87h9de201i.fsf@skywalker.in.ibm.com>
In-Reply-To: <87h9de201i.fsf@skywalker.in.ibm.com>
Subject: Re: [RFC PATCH 2/4] mm: Change the interface for __tlb_remove_page
Date: Tue, 31 May 2016 15:26:36 +0800
Message-ID: <004f01d1bb0d$c4537db0$4cfa7910$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Aneesh Kumar K.V'" <aneesh.kumar@linux.vnet.ibm.com>
Cc: 'linux-kernel' <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> > Do you want to update ->addr here?
> >
> 
> I don't get that question. We wanted to track the alst adjusted addr in
> tlb->addr because when we do a tlb_flush_mmu_tlbonly() we does a
> __tlb_reset_range(), which clears tlb->start and tlb->end. Now we need
> to update the range again with the last adjusted addr before we can call
> __tlb_remove_page(). Look for VM_BUG_ON(!tlb->end); in
> __tlb_remove_page().
> 
Got, thanks.

Hillf


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
