Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 448116B0006
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 09:30:44 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id g65so3954913wmf.7
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 06:30:44 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id f2si1628053wmh.242.2018.02.09.06.30.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 06:30:43 -0800 (PST)
Subject: Re: [PATCH 2/6] genalloc: selftest
References: <20180204164732.28241-1-igor.stoppa@huawei.com>
 <20180204164732.28241-3-igor.stoppa@huawei.com>
 <e05598c1-3c7c-15c6-7278-ed52ceff0acf@infradead.org>
 <20180204230346.GA12502@bombadil.infradead.org>
 <02f42250-949b-83af-f030-159fc46f6f81@infradead.org>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <fe437c92-98a7-aba9-33eb-f6aaa5526ef9@huawei.com>
Date: Fri, 9 Feb 2018 16:30:28 +0200
MIME-Version: 1.0
In-Reply-To: <02f42250-949b-83af-f030-159fc46f6f81@infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>, Matthew Wilcox <willy@infradead.org>
Cc: jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 05/02/18 02:14, Randy Dunlap wrote:
> On 02/04/2018 03:03 PM, Matthew Wilcox wrote:
>> On Sun, Feb 04, 2018 at 02:19:22PM -0800, Randy Dunlap wrote:
>>>> +#ifndef __GENALLOC_SELFTEST_H__
>>>> +#define __GENALLOC_SELFTEST_H__
>>>
>>> Please use _LINUX_GENALLOC_SELFTEST_H_
>>
>> willy@bobo:~/kernel/linux$ git grep define.*_H__$ include/linux/*.h |wc -l
>> 98
>> willy@bobo:~/kernel/linux$ git grep define.*_H_$ include/linux/*.h |wc -l
>> 110
>> willy@bobo:~/kernel/linux$ git grep define.*_H$ include/linux/*.h |wc -l
>> 885
>>
>> No trailing underscore is 8x as common as one trailing underscore.
> 
> OK, ack.

ok, I'll move to _LINUX_xxx_yyy_H format

--
thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
