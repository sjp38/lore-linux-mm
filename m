Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id A37BD6B0032
	for <linux-mm@kvack.org>; Mon, 20 Apr 2015 22:27:12 -0400 (EDT)
Received: by lbbzk7 with SMTP id zk7so145045794lbb.0
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 19:27:12 -0700 (PDT)
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com. [209.85.217.180])
        by mx.google.com with ESMTPS id ap7si306927lac.21.2015.04.20.19.27.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Apr 2015 19:27:10 -0700 (PDT)
Received: by lbcga7 with SMTP id ga7so145143892lbc.1
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 19:27:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1504201040010.2264@gentwo.org>
References: <1429349091-11785-1-git-send-email-gavin.guo@canonical.com>
	<alpine.DEB.2.11.1504201040010.2264@gentwo.org>
Date: Tue, 21 Apr 2015 10:27:09 +0800
Message-ID: <CA+eFSM3yfHQ58ruSP3sFq8EyJQsxdSoX3gB9CU38SAkh2+t19w@mail.gmail.com>
Subject: Re: [PATCH] mm/slab_common: Support the slub_debug boot option on
 specific object size
From: Gavin Guo <gavin.guo@canonical.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>

Hi Christoph,

On Mon, Apr 20, 2015 at 11:40 PM, Christoph Lameter <cl@linux.com> wrote:
> On Sat, 18 Apr 2015, Gavin Guo wrote:
>
>> The slub_debug=PU,kmalloc-xx cannot work because in the
>> create_kmalloc_caches() the s->name is created after the
>> create_kmalloc_cache() is called. The name is NULL in the
>> create_kmalloc_cache() so the kmem_cache_flags() would not set the
>> slub_debug flags to the s->flags. The fix here set up a temporary
>> kmalloc_names string array for the initialization purpose. After the
>> kmalloc_caches are already it can be used to create s->name in the
>> kasprintf.
>
> Ok if you do that then the dynamic creation of the kmalloc hostname can
> also be removed. This patch should do that as well.

Thanks for your reply. I put the kmalloc_names in the __initdata
section. And it will be cleaned. Do you think the kmalloc_names should
be put in the global data section to avoid the dynamic creation of the
kmalloc hostname again?

Gavin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
