Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id DC60C6B0032
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 12:51:32 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id z20so18498067igj.4
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 09:51:32 -0800 (PST)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com. [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id th10si8294519igb.1.2015.02.02.09.51.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Feb 2015 09:51:32 -0800 (PST)
Received: by mail-ig0-f173.google.com with SMTP id a13so20104389igq.0
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 09:51:32 -0800 (PST)
Date: Mon, 2 Feb 2015 09:51:30 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: export "high_memory" symbol on !MMU
In-Reply-To: <2715923.qFZi90ffep@wuerfel>
Message-ID: <alpine.DEB.2.10.1502020951180.5117@chino.kir.corp.google.com>
References: <2715923.qFZi90ffep@wuerfel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, gerg@uclinux.org, linux-arm-kernel@lists.infradead.org

On Wed, 28 Jan 2015, Arnd Bergmann wrote:

> The symbol 'high_memory' is provided on both MMU- and NOMMU-kernels,
> but only one of them is exported, which leads to module build errors
> in drivers that work fine built-in:
> 
> ERROR: "high_memory" [drivers/net/virtio_net.ko] undefined!
> ERROR: "high_memory" [drivers/net/ppp/ppp_mppe.ko] undefined!
> ERROR: "high_memory" [drivers/mtd/nand/nand.ko] undefined!
> ERROR: "high_memory" [crypto/tcrypt.ko] undefined!
> ERROR: "high_memory" [crypto/cts.ko] undefined!
> 
> This exports the symbol to get these to work on NOMMU as well.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
