Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id A9F846B0320
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 03:11:08 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id v137so13982192ywg.4
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 00:11:08 -0700 (PDT)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id k39si2230223ybj.367.2017.09.12.00.11.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Sep 2017 00:11:07 -0700 (PDT)
Subject: Re: [PATCH v6 00/11] Add support for eXclusive Page Frame Ownership
References: <20170907173609.22696-1-tycho@docker.com>
 <23e5bac9-329a-3a32-049e-7e7c9751abd0@huawei.com>
 <20170911150204.nn5v5olbxyzfafou@docker>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <60c4ad22-d920-2754-30dd-b1f228c0a87d@huawei.com>
Date: Tue, 12 Sep 2017 15:07:29 +0800
MIME-Version: 1.0
In-Reply-To: <20170911150204.nn5v5olbxyzfafou@docker>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@docker.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>

Hi Tycho,

On 2017/9/11 23:02, Tycho Andersen wrote:
> Hi Yisheng,
> 
> On Mon, Sep 11, 2017 at 06:34:45PM +0800, Yisheng Xie wrote:
>> Hi Tycho ,
>>
>> On 2017/9/8 1:35, Tycho Andersen wrote:
>>> Hi all,
>>>
>>> Here is v6 of the XPFO set; see v5 discussion here:
>>> https://lkml.org/lkml/2017/8/9/803
>>>
>>> Changelogs are in the individual patch notes, but the highlights are:
>>> * add primitives for ensuring memory areas are mapped (although these are quite
>>>   ugly, using stack allocation; I'm open to better suggestions)
>>> * instead of not flushing caches, re-map pages using the above
>>> * TLB flushing is much more correct (i.e. we're always flushing everything
>>>   everywhere). I suspect we may be able to back this off in some cases, but I'm
>>>   still trying to collect performance numbers to prove this is worth doing.
>>>
>>> I have no TODOs left for this set myself, other than fixing whatever review
>>> feedback people have. Thoughts and testing welcome!
>>
>> According to the paper of Vasileios P. Kemerlis et al, the mainline kernel
>> will not set the Pro. of physmap(direct map area) to RW(X), so do we really
>> need XPFO to protect from ret2dir attack?
> 
> I guess you're talking about section 4.3? 
Yes

> They mention that that x86
> only gets rw, but that aarch64 is rwx still.
IIRC, the in kernel of v4.13 the aarch64 is not rwx, I will check it.

> 
> But in either case this still provides access protection, similar to
> SMAP. Also, if I understand things correctly the protections are
> unmanaged, so a page that had the +x bit set at some point, it could
> be used for ret2dir.
So you means that the Pro. of direct map area maybe changed to +x, then ret2dir attack can use it?

Thanks
Yisheng Xie


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
