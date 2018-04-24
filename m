Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9E19A6B002D
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 08:32:41 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b23so135846wme.3
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 05:32:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k62sor1376649wma.55.2018.04.24.05.32.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Apr 2018 05:32:40 -0700 (PDT)
Subject: Re: [PATCH 7/9] Pmalloc Rare Write: modify selected pools
References: <20180423125458.5338-1-igor.stoppa@huawei.com>
 <20180423125458.5338-8-igor.stoppa@huawei.com>
 <20180424115050.GD26636@bombadil.infradead.org>
From: lazytyped <lazytyped@gmail.com>
Message-ID: <eb23fbd9-1b9e-8633-b0eb-241b8ad24d95@gmail.com>
Date: Tue, 24 Apr 2018 14:32:36 +0200
MIME-Version: 1.0
In-Reply-To: <20180424115050.GD26636@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Igor Stoppa <igor.stoppa@gmail.com>
Cc: keescook@chromium.org, paul@paul-moore.com, sds@tycho.nsa.gov, mhocko@kernel.org, corbet@lwn.net, labbott@redhat.com, linux-cc=david@fromorbit.com, --cc=rppt@linux.vnet.ibm.com, --security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>, Carlos Chinea Perez <carlos.chinea.perez@huawei.com>, Remi Denis Courmont <remi.denis.courmont@huawei.com>



On 4/24/18 1:50 PM, Matthew Wilcox wrote:
> struct modifiable_data {
> 	struct immutable_data *d;
> 	...
> };
>
> Then allocate a new pool, change d and destroy the old pool.

With the above, you have just shifted the target of the arbitrary write
from the immutable data itself to the pointer to the immutable data, so
got no security benefit.

The goal of the patch is to reduce the window when stuff is writeable,
so that an arbitrary write is likely to hit the time when data is read-only.


A A A A A A  -A  Enrico
