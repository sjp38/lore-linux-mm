Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f176.google.com (mail-ve0-f176.google.com [209.85.128.176])
	by kanga.kvack.org (Postfix) with ESMTP id 15C226B0035
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 09:04:21 -0500 (EST)
Received: by mail-ve0-f176.google.com with SMTP id oz11so1257577veb.21
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 06:04:20 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2402:b800:7003:1:1::1])
        by mx.google.com with ESMTPS id t2si1120879qat.147.2014.01.08.06.04.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jan 2014 06:04:19 -0800 (PST)
Date: Thu, 9 Jan 2014 01:03:58 +1100
From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Message-ID: <20140109010358.0f9b30c4@kryten>
In-Reply-To: <871u0k5lri.fsf@tassilo.jf.intel.com>
References: <20140107132100.5b5ad198@kryten>
	<871u0k5lri.fsf@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: benh@kernel.crashing.org, paulus@samba.org, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, nacc@linux.vnet.ibm.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org


Hi Andi,

> > Thoughts? It seems like we could hit a similar situation if a
> > machine is balanced but we run out of memory on a single node.
> 
> Yes I agree, but your patch doesn't seem to attempt to handle this?

It doesn't. I was hoping someone with more mm knowledge than I could
suggest a lightweight way of doing this.

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
