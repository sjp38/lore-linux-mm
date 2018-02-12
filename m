Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1F9AD6B0003
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 06:17:22 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 73so8696306wrb.13
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 03:17:22 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id b27si1110187edb.12.2018.02.12.03.17.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 03:17:20 -0800 (PST)
Subject: Re: [PATCH 1/6] genalloc: track beginning of allocations
References: <20180211031920.3424-1-igor.stoppa@huawei.com>
 <20180211031920.3424-2-igor.stoppa@huawei.com>
 <20180211122444.GB13931@rapoport-lnx>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <f0a244f2-f63a-376b-28f2-debbe914da34@huawei.com>
Date: Mon, 12 Feb 2018 13:17:01 +0200
MIME-Version: 1.0
In-Reply-To: <20180211122444.GB13931@rapoport-lnx>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: willy@infradead.org, rdunlap@infradead.org, corbet@lwn.net, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, jglisse@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 11/02/18 14:24, Mike Rapoport wrote:
> On Sun, Feb 11, 2018 at 05:19:15AM +0200, Igor Stoppa wrote:
[...]

>> +/**
>> + * mem_to_units - convert references to memory into orders of allocation
> 
> Documentation/doc-guide/kernel-doc.rst recommends to to include brackets
> for function comments. I haven't noticed any difference in the resulting
> html, so I'm not sure if the brackets are actually required.

This is what I see in the example from mailine docs:

/**
 * foobar() - Brief description of foobar.
 * @argument1: Description of parameter argument1 of foobar.
 * @argument2: Description of parameter argument2 of foobar.
 *
 * Longer description of foobar.
 *
 * Return: Description of return value of foobar.
 */
int foobar(int argument1, char *argument2)


What are you referring to?

[...]

>> + * @size: amount in bytes
>> + * @order: power of 2 represented by each entry in the bitmap
>> + *
>> + * Returns the number of units representing the size.
> 
> Please s/Return/Return:/

:-( I thought I had fixed them all. thanks for spotting this.

[...]

>> + * Return: If two users alter the same bit, to one it will return
>> + * remaining entries, to the other it will return 0.
> 
> And what if there are three or four concurrent users? ;-)
> 
> I believe that a more elaborate description about what happens with
> concurrent attempts to alter the bitmap would be really helpful.

ok

--
thanks, igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
