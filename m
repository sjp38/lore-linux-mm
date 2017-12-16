Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 712426B0033
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 02:10:52 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id a107so6187893wrc.11
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 23:10:52 -0800 (PST)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id m19si5665101wma.113.2017.12.15.23.10.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Dec 2017 23:10:51 -0800 (PST)
Subject: Re: [Question ]: Avoid kernel panic when killing an application if
 happen RAS page table error
References: <0184EA26B2509940AA629AE1405DD7F2019C8B36@DGGEMA503-MBS.china.huawei.com>
 <20171205165727.GG3070@tassilo.jf.intel.com>
 <0276f3b3-94a5-8a47-dfb7-8773cd2f99c5@huawei.com>
 <dedf9af6-7979-12dc-2a52-f00b2ec7f3b6@huawei.com>
 <0b7bb7b3-ae39-0c97-9c0a-af37b0701ab4@huawei.com>
 <eab54efe-0ab4-bf6a-5831-128ff02a018b@huawei.com> <5A3419F3.1030804@arm.com>
 <20171215193551.GD27160@bombadil.infradead.org>
From: gengdongjiu <gengdongjiu@huawei.com>
Message-ID: <42ebc814-fd8d-0de5-5c3c-e2eec02ebf66@huawei.com>
Date: Sat, 16 Dec 2017 15:09:42 +0800
MIME-Version: 1.0
In-Reply-To: <20171215193551.GD27160@bombadil.infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, James Morse <james.morse@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Huangshaoyu <huangshaoyu@huawei.com>, Wuquanming <wuquanming@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 2017/12/16 3:35, Matthew Wilcox wrote:
>> It's going to be complicated to do, I don't think its worth the effort.
> We can find a bit in struct page that we guarantee will only be set if
> this is allocated as a pagetable.  Bit 1 of the third union is currently
> available (compound_head is a pointer if bit 0 is set, so nothing is
> using bit 1).  We can put a pointer to the mm_struct in the same word.
> 
> Finding all the allocated pages will be the tricky bit.  We could put a
> list_head into struct page; perhaps in the same spot as page_deferred_list
> for tail pages.  Then we can link all the pagetables belonging to
> this mm together and tear them all down if any of them get an error.
> They'll repopulate on demand.  It won't be quick or scalable, but when
> the alternative is death, it looks relatively attractive.
Thanks for the comments, I will check it in detailed and investigate whether it is worth to do for it.
Thanks!

> 
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
