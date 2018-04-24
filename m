Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 55F886B002D
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 08:39:15 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id e22-v6so11354062ita.0
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 05:39:15 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x19-v6sor5101091itb.63.2018.04.24.05.39.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Apr 2018 05:39:14 -0700 (PDT)
Subject: Re: [PATCH 7/9] Pmalloc Rare Write: modify selected pools
References: <20180423125458.5338-1-igor.stoppa@huawei.com>
 <20180423125458.5338-8-igor.stoppa@huawei.com>
 <20180424115050.GD26636@bombadil.infradead.org>
 <eb23fbd9-1b9e-8633-b0eb-241b8ad24d95@gmail.com>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <c5344284-f205-8465-0b04-f6da96e21609@gmail.com>
Date: Tue, 24 Apr 2018 16:39:11 +0400
MIME-Version: 1.0
In-Reply-To: <eb23fbd9-1b9e-8633-b0eb-241b8ad24d95@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lazytyped <lazytyped@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: keescook@chromium.org, paul@paul-moore.com, sds@tycho.nsa.gov, mhocko@kernel.org, corbet@lwn.net, labbott@redhat.com, david@fromorbit.com, rppt@linux.vnet.ibm.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>, Carlos Chinea Perez <carlos.chinea.perez@huawei.com>, Remi Denis Courmont <remi.denis.courmont@huawei.com>



On 24/04/18 16:32, lazytyped wrote:
> 
> 
> On 4/24/18 1:50 PM, Matthew Wilcox wrote:
>> struct modifiable_data {
>> 	struct immutable_data *d;
>> 	...
>> };
>>
>> Then allocate a new pool, change d and destroy the old pool.
> 
> With the above, you have just shifted the target of the arbitrary write
> from the immutable data itself to the pointer to the immutable data, so
> got no security benefit.
> 
> The goal of the patch is to reduce the window when stuff is writeable,
> so that an arbitrary write is likely to hit the time when data is read-only.

Indeed, that was my - poorly explained, I admit it - idea.

For example, that's the reason why I am remapping one page at a time in 
a loop, instead of doing the whole array, to limit exposure and increase 
randomness.

WRT the implementation, I'm sure there are bugs that need squashing.

But if I have overlooked some aspect in the overall design, I need 
guidance, because i still do not see what I am missing :-(

--
igor
