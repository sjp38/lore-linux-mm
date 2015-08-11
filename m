Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 29EE26B0253
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 18:20:40 -0400 (EDT)
Received: by igbij6 with SMTP id ij6so100564398igb.1
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 15:20:40 -0700 (PDT)
Received: from BLU004-OMC1S13.hotmail.com (blu004-omc1s13.hotmail.com. [65.55.116.24])
        by mx.google.com with ESMTPS id t91si2493581ioi.103.2015.08.11.15.20.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 11 Aug 2015 15:20:39 -0700 (PDT)
Message-ID: <BLU436-SMTP1324E8C8AB9AA60DBF9C748807F0@phx.gbl>
Subject: Re: [PATCH] mm/hwpoison: fix panic due to split huge zero page
References: <BLU437-SMTP5348473FAB81C31638A9A0807F0@phx.gbl>
 <20150811141404.ecb19c1a66c32abf60d6663c@linux-foundation.org>
From: Wanpeng Li <wanpeng.li@hotmail.com>
Date: Wed, 12 Aug 2015 06:20:33 +0800
MIME-Version: 1.0
In-Reply-To: <20150811141404.ecb19c1a66c32abf60d6663c@linux-foundation.org>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>



On 8/12/15 5:14 AM, Andrew Morton wrote:
> On Tue, 11 Aug 2015 18:47:57 +0800 Wanpeng Li <wanpeng.li@hotmail.com> wrote:
>
>> ...
>>
>> Huge zero page is allocated if page fault w/o FAULT_FLAG_WRITE flag.
>> The get_user_pages_fast() which called in madvise_hwpoison() will get
>> huge zero page if the page is not allocated before. Huge zero page is
>> a tranparent huge page, however, it is not an anonymous page. memory_failure
>> will split the huge zero page and trigger BUG_ON(is_huge_zero_page(page));
>> After commit (98ed2b0: mm/memory-failure: give up error handling for
>> non-tail-refcounted thp), memory_failure will not catch non anon thp
>> from madvise_hwpoison path and this bug occur.
> So I'm assuming this patch is needed for 4.2 but not in earlier
> kernels.

I think so. :-)  Btw, how about my other hwpoison patches?

Regards,
Wanpeng Li

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
