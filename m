Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id D88146B0031
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 08:34:01 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id rq2so1657692pbb.7
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 05:34:01 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id yh3si4958955pab.170.2014.06.25.05.33.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 25 Jun 2014 05:33:59 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N7Q00K0A5K6SH00@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 25 Jun 2014 13:33:42 +0100 (BST)
Message-id: <53AAC1B4.5000204@samsung.com>
Date: Wed, 25 Jun 2014 14:33:56 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v3 -next 0/9] CMA: generalize CMA reserved area management
 code
References: <1402897251-23639-1-git-send-email-iamjoonsoo.kim@lge.com>
 <539EB4C7.3080106@samsung.com> <20140617012507.GA6825@js1304-P5Q-DELUXE>
 <20140618135144.297c785260f9e2aebead867c@linux-foundation.org>
In-reply-to: <20140618135144.297c785260f9e2aebead867c@linux-foundation.org>
Content-type: text/plain; charset=UTF-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Hello,

On 2014-06-18 22:51, Andrew Morton wrote:
> On Tue, 17 Jun 2014 10:25:07 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>>>> v2:
>>>>    - Although this patchset looks very different with v1, the end result,
>>>>    that is, mm/cma.c is same with v1's one. So I carry Ack to patch 6-7.
>>>>
>>>> This patchset is based on linux-next 20140610.
>>> Thanks for taking care of this. I will test it with my setup and if
>>> everything goes well, I will take it to my -next tree. If any branch
>>> is required for anyone to continue his works on top of those patches,
>>> let me know, I will also prepare it.
>> Hello,
>>
>> I'm glad to hear that. :)
>> But, there is one concern. As you already know, I am preparing further
>> patches (Aggressively allocate the pages on CMA reserved memory). It
>> may be highly related to MM branch and also slightly depends on this CMA
>> changes. In this case, what is the best strategy to merge this
>> patchset? IMHO, Anrew's tree is more appropriate branch. If there is
>> no issue in this case, I am willing to develope further patches based
>> on your tree.
> That's probably easier.  Marek, I'll merge these into -mm (and hence
> -next and git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git)
> and shall hold them pending you review/ack/test/etc, OK?

Ok. I've tested them and they work fine. I'm sorry that you had to wait for
me for a few days. You can now add:

Acked-and-tested-by: Marek Szyprowski <m.szyprowski@samsung.com>

I've also rebased my pending patches onto this set (I will send them soon).

The question is now if you want to keep the discussed patches in your 
-mm tree,
or should I take them to my -next branch. If you like to keep them, I assume
you will also take the patches which depends on the discussed changes.

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
