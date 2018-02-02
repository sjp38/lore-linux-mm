Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 72FB26B0005
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 10:56:38 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id g16so3861845wmg.6
        for <linux-mm@kvack.org>; Fri, 02 Feb 2018 07:56:38 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id v8si1824109wrd.114.2018.02.02.07.56.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Feb 2018 07:56:36 -0800 (PST)
Subject: Re: [PATCH 5/6] Documentation for Pmalloc
References: <20180130151446.24698-1-igor.stoppa@huawei.com>
 <20180130151446.24698-6-igor.stoppa@huawei.com>
 <20180130100852.2213b94d@lwn.net>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <56eb3e0d-d74d-737a-9f85-fead2c40c17c@huawei.com>
Date: Fri, 2 Feb 2018 17:56:29 +0200
MIME-Version: 1.0
In-Reply-To: <20180130100852.2213b94d@lwn.net>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, willy@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

Thanks for the review and apologies for the delay.
Replies inlined below.

On 30/01/18 19:08, Jonathan Corbet wrote:
> On Tue, 30 Jan 2018 17:14:45 +0200
> Igor Stoppa <igor.stoppa@huawei.com> wrote:

[...]

> Please don't put plain-text files into core-api - that's a directory full

ok

>> diff --git a/Documentation/core-api/pmalloc.txt b/Documentation/core-api/pmalloc.txt
>> new file mode 100644
>> index 0000000..934d356
>> --- /dev/null
>> +++ b/Documentation/core-api/pmalloc.txt
>> @@ -0,0 +1,104 @@
> 
> We might as well put the SPDX tag here, it's a new file.

ok, this is all new stuff to me ... I suppose I should do it also for
all the other new files I create

But what is the license for the documentation? It's not code, so GPL
seems wrong. Creative commons?

I just noticed a patch for checkpatch.pl about SPDX and asked the same
question there.

https://lkml.org/lkml/2018/2/2/365

>> +============================
>> +Protectable memory allocator
>> +============================
>> +
>> +Introduction
>> +------------

[...]

> This is all good information, but I'd suggest it belongs more in the 0/n
> patch posting than here.  The introduction of *this* document should say
> what it actually covers.

ok

> 
>> +
>> +Design
>> +------

[...]

>> +To keep it to a minimum, locking is left to the user of the API, in
>> +those cases where it's not strictly needed.
> 
> This seems like a relevant and important aspect of the API that shouldn't
> be buried in the middle of a section talking about random things.

I'll move it to the Use section.

[...]

>> +Use
>> +---
>> +
>> +The typical sequence, when using pmalloc, is:
>> +
>> +1. create a pool
>> +2. [optional] pre-allocate some memory in the pool
>> +3. issue one or more allocation requests to the pool
>> +4. initialize the memory obtained
>> +   - iterate over points 3 & 4 as needed -
>> +5. write protect the pool
>> +6. use in read-only mode the handlers obtained through the allocations
>> +7. [optional] destroy the pool
> 
> So one gets this far, but has no actual idea of how to do these things.
> Which leads me to wonder: what is this document for?  Who are you expecting
> to read it?

I will add a reference to the selftest file.
In practice it can also work as example.

> You could improve things a lot by (once again) going to RST and using
> directives to bring in the kerneldoc comments from the source (which, I
> note, do exist).  But I'd suggest rethinking this document and its
> audience.  Most of the people reading it are likely wanting to learn how to
> *use* this API; I think it would be best to not leave them frustrated.

ok, the example route should be more explicative.

--
thanks again for the review, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
