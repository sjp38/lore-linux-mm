Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id F14726B000E
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 06:34:24 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id j100so4436026wrj.4
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 03:34:24 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id r39si1951096eda.348.2018.02.09.03.34.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 03:34:23 -0800 (PST)
Subject: Re: [PATCH 3/6] struct page: add field for vm_struct
References: <20180130151446.24698-1-igor.stoppa@huawei.com>
 <20180130151446.24698-4-igor.stoppa@huawei.com>
 <alpine.DEB.2.20.1801311758340.21272@nuc-kabylake>
 <48fde114-d063-cfbf-e1b6-262411fcd963@huawei.com>
 <alpine.DEB.2.20.1802021240370.31548@nuc-kabylake>
 <a12afe9b-79cf-d5c1-3795-89fbf61c6c9d@huawei.com>
 <alpine.DEB.2.20.1802050931190.10647@nuc-kabylake>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <47f64329-32e2-44ba-c878-ee3cccdebfea@huawei.com>
Date: Fri, 9 Feb 2018 13:34:05 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1802050931190.10647@nuc-kabylake>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, willy@infradead.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 05/02/18 17:33, Christopher Lameter wrote:
> On Sat, 3 Feb 2018, Igor Stoppa wrote:
> 
>> - the property of the compound page will affect the property of all the
>> pages in the compound, so when one is write protected, it can generate a
>> lot of wasted memory, if there is too much slack (because of the order)
>> With vmalloc, I can allocate any number of pages, minimizing the waste.
> 
> I thought the intend here is to create a pool where the whole pool becomes
> RO?

Yes, but why would I force the number of pages in the pool to be a power
of 2, when it can be any number?

If a need, say, 17 pages, I would have to allocate 32.
But it can be worse than that.
Since the size of the overall allocated memory is not known upfront, I
wold have a problem to decide how many pages to allocate, every time
there is need to grow the pool.

Or push the problem to the user of the API, who might be equally unaware.

Notice that there is already a function (prealloc) available to the user
of the API, if the size is known upfront.

So I do not really see how using compound pages would make memory
utilization better or even not worse.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
