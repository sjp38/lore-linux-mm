Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id D6AB46B006E
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 09:14:07 -0500 (EST)
Received: by mail-ig0-f180.google.com with SMTP id h15so5109233igd.13
        for <linux-mm@kvack.org>; Mon, 15 Dec 2014 06:14:07 -0800 (PST)
Received: from resqmta-po-04v.sys.comcast.net (resqmta-po-04v.sys.comcast.net. [2001:558:fe16:19:96:114:154:163])
        by mx.google.com with ESMTPS id dw9si6682268igb.58.2014.12.15.06.14.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 15 Dec 2014 06:14:06 -0800 (PST)
Date: Mon, 15 Dec 2014 08:14:04 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [Question] Crash of kmem_cache_cpu->freelist access
In-Reply-To: <CAAh6nknX5=8ucX_ObxB+_Dy9NCmTgNH1QRhQFKxJ+pgbDsRRaw@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1412150812580.20101@gentwo.org>
References: <CAAh6nknX5=8ucX_ObxB+_Dy9NCmTgNH1QRhQFKxJ+pgbDsRRaw@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Guo <tuffkidtt@gmail.com>
Cc: linux-mm@kvack.org, penberg@kernel.org, mpm@selenic.com

On Sun, 14 Dec 2014, Gavin Guo wrote:

> I tried to disassembly and found that the object is from c->freelist
> and it has an abnormal value which caused the fault. My first thought
> is to try to add slub_debug in the kernel command line. But, the
> kernel is a production kernel and may not have the chance to add
> kernel parameters. The other way is to "echo 1 >

the slub_debug option is there so that production kernels *can* run with
debugging and that we can locate these issues.

If you cannot get to a boot prompt then please change the grub
configuration and add the slub_debug parameter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
