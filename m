Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 398086B0038
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 19:37:02 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id u98so14540587wrb.17
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 16:37:02 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u33si22036541wrc.46.2017.11.27.16.37.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 16:37:01 -0800 (PST)
Date: Mon, 27 Nov 2017 16:36:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01/23] slab: make kmalloc_index() return "unsigned int"
Message-Id: <20171127163658.44c3121e47ea3b2cf230c36b@linux-foundation.org>
In-Reply-To: <20171123221628.8313-1-adobriyan@gmail.com>
References: <20171123221628.8313-1-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com

On Fri, 24 Nov 2017 01:16:06 +0300 Alexey Dobriyan <adobriyan@gmail.com> wrote:

> kmalloc_index() return index into an array of kmalloc kmem caches,
> therefore should unsigned.
> 
> Space savings:
> 
> 	add/remove: 0/0 grow/shrink: 0/2 up/down: 0/-6 (-6)
> 	Function                                     old     new   delta
> 	rtsx_scsi_handler                           9116    9114      -2
> 	vnic_rq_alloc                                424     420      -4

While I applaud the use of accurate and appropriate types, that's one
heck of a big patch series.  What do the slab maintainers think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
