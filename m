Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 583C36B0005
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 19:14:28 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id g187so7410333wmg.2
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 16:14:28 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 14si4794620wmf.11.2018.02.04.16.14.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 04 Feb 2018 16:14:22 -0800 (PST)
Subject: Re: [PATCH 2/6] genalloc: selftest
References: <20180204164732.28241-1-igor.stoppa@huawei.com>
 <20180204164732.28241-3-igor.stoppa@huawei.com>
 <e05598c1-3c7c-15c6-7278-ed52ceff0acf@infradead.org>
 <20180204230346.GA12502@bombadil.infradead.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <02f42250-949b-83af-f030-159fc46f6f81@infradead.org>
Date: Sun, 4 Feb 2018 16:14:01 -0800
MIME-Version: 1.0
In-Reply-To: <20180204230346.GA12502@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Igor Stoppa <igor.stoppa@huawei.com>, jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 02/04/2018 03:03 PM, Matthew Wilcox wrote:
> On Sun, Feb 04, 2018 at 02:19:22PM -0800, Randy Dunlap wrote:
>>> +#ifndef __GENALLOC_SELFTEST_H__
>>> +#define __GENALLOC_SELFTEST_H__
>>
>> Please use _LINUX_GENALLOC_SELFTEST_H_
> 
> willy@bobo:~/kernel/linux$ git grep define.*_H__$ include/linux/*.h |wc -l
> 98
> willy@bobo:~/kernel/linux$ git grep define.*_H_$ include/linux/*.h |wc -l
> 110
> willy@bobo:~/kernel/linux$ git grep define.*_H$ include/linux/*.h |wc -l
> 885
> 
> No trailing underscore is 8x as common as one trailing underscore.

OK, ack.

thanks,
-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
