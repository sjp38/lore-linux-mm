Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 649B86B0006
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 09:28:25 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id b195so3760400wmb.1
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 06:28:25 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id n55si1917302wrn.539.2018.02.09.06.28.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 06:28:24 -0800 (PST)
Subject: Re: [PATCH 1/6] genalloc: track beginning of allocations
References: <20180204164732.28241-1-igor.stoppa@huawei.com>
 <20180204164732.28241-2-igor.stoppa@huawei.com>
 <60e66c5a-c1de-246f-4be8-b02cb0275da6@infradead.org>
 <20180205034531.GA18559@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <ca8891c9-c916-abf1-7370-5e4f37beaac9@huawei.com>
Date: Fri, 9 Feb 2018 16:28:06 +0200
MIME-Version: 1.0
In-Reply-To: <20180205034531.GA18559@bombadil.infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Randy Dunlap <rdunlap@infradead.org>
Cc: jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 05/02/18 05:45, Matthew Wilcox wrote:
> On Sun, Feb 04, 2018 at 02:34:08PM -0800, Randy Dunlap wrote:
>>> +/**
>>> + * cleart_bits_ll - according to the mask, clears the bits specified by
>>
>>       clear_bits_ll
> 
> 'make W=1' should catch this ... yes?
> 
> (hint: building with 'make C=1 W=1' finds all kinds of interesting issues
> in your code.  W=12 or W=123 finds too many false positives for my tastes)

ok, thank you, I will start using it

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
