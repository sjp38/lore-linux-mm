Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B00096B0007
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 11:41:32 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id z83so3911699wmc.5
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 08:41:32 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id b200si1781037wmf.157.2018.02.09.08.41.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 08:41:31 -0800 (PST)
Subject: Re: [PATCH 6/6] Documentation for Pmalloc
References: <20180204164732.28241-1-igor.stoppa@huawei.com>
 <20180204170056.28772-1-igor.stoppa@huawei.com>
 <20180204170056.28772-2-igor.stoppa@huawei.com>
 <29176ee0-f253-ccd7-8201-3f061b5890b0@infradead.org>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <33d85206-abfb-86cf-d303-b7efba9cc325@huawei.com>
Date: Fri, 9 Feb 2018 18:41:18 +0200
MIME-Version: 1.0
In-Reply-To: <29176ee0-f253-ccd7-8201-3f061b5890b0@infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>, jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, willy@infradead.org
Cc: cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 04/02/18 23:37, Randy Dunlap wrote:

[...]

>> +reason, could neither be declared as constant, nor it could take advantage
> 
>                                                   nor could it

ok

[...]

>> +Ex: A policy that is loaded from userspace.
> 
> Either
>    Example:
> or
>    E.g.:
> (meaning For example)

ok

[...]

>> +Different kernel idrivers and threads can use different pools, for finer
> 
>                     drivers

:-( ok

[...]

>> +  in use anymore by the requestor, however it will not become avaiable for
> 
>                            requester; however,                   available

ok

[...]

>> +- pmalloc does not provide locking support wrt allocating vs protecting
> 
> Write out "wrt" -> with respect to.

ok

>> +  an individual pool, for performance reason. It is recommended to not
> 
>                                          reasons.                  not to

ok & ok

[...]

>> +  in the case of using directly vmalloc. The exact number depends on size
> 
>                  of using vmalloc directly.                          on the size

ok & ok

[...]

>> +6. write protect the pool
> 
>       write-protect

ok

[...]

>> +7. use in read-only mode the handlers obtained through the allocations
> 
>                                 handles ??

yes

---
thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
