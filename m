Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2AD9E6B025E
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 11:24:45 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id j3so6762032pld.0
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 08:24:45 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id 75si2452808pfj.125.2018.02.12.08.24.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 08:24:44 -0800 (PST)
Subject: Re: [PATCH 3/6] struct page: add field for vm_struct
References: <20180211031920.3424-1-igor.stoppa@huawei.com>
 <20180211031920.3424-4-igor.stoppa@huawei.com>
 <20180211211646.GC4680@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <cef01110-dc23-4442-f277-88d1d3662e00@huawei.com>
Date: Mon, 12 Feb 2018 18:24:20 +0200
MIME-Version: 1.0
In-Reply-To: <20180211211646.GC4680@bombadil.infradead.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: rdunlap@infradead.org, corbet@lwn.net, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, jglisse@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com



On 11/02/18 23:16, Matthew Wilcox wrote:
> On Sun, Feb 11, 2018 at 05:19:17AM +0200, Igor Stoppa wrote:
>> The struct page has a "mapping" field, which can be re-used, to store a
>> pointer to the parent area. This will avoid more expensive searches.
>>
>> As example, the function find_vm_area is reimplemented, to take advantage
>> of the newly introduced field.
> 
> Umm.  Is it more efficient?  You're replacing an rb-tree search with a
> page-table walk.  You eliminate a spinlock, which is great, but is the
> page-table walk more efficient?  I suppose it'll depend on the depth of
> the rb-tree, and (at least on x86), the page tables should already be
> in cache.

I thought the tradeoff favorable. How to verify it?

> Unrelated to this patch, I'm working on a patch to give us page_type,
> and I think I'll allocate a bit to mark pages which are vmalloced.

pmalloced too?

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
