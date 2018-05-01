Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 900416B0003
	for <linux-mm@kvack.org>; Tue,  1 May 2018 12:44:01 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id w84-v6so10190287vkw.2
        for <linux-mm@kvack.org>; Tue, 01 May 2018 09:44:01 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id 203-v6si5171845vkv.140.2018.05.01.09.43.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 May 2018 09:44:00 -0700 (PDT)
Date: Tue, 1 May 2018 11:43:58 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v4 16/16] slub: Remove kmem_cache->reserved
In-Reply-To: <20180430202247.25220-17-willy@infradead.org>
Message-ID: <alpine.DEB.2.21.1805011142420.16325@nuc-kabylake>
References: <20180430202247.25220-1-willy@infradead.org> <20180430202247.25220-17-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>

On Mon, 30 Apr 2018, Matthew Wilcox wrote:

> The reserved field was only used for embedding an rcu_head in the data
> structure.  With the previous commit, we no longer need it.  That lets
> us remove the 'reserved' argument to a lot of functions.

Great work!

Acked-by: Christoph Lameter <cl@linux.com>

> @@ -5106,7 +5105,7 @@ SLAB_ATTR_RO(destroy_by_rcu);
>
>  static ssize_t reserved_show(struct kmem_cache *s, char *buf)
>  {
> -	return sprintf(buf, "%u\n", s->reserved);
> +	return sprintf(buf, "0\n");
>  }
>  SLAB_ATTR_RO(reserved);


Hmmm... Maybe its better if you remove the reserved file from sysfs
instead? I doubt anyone was using it.
