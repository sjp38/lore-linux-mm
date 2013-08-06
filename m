Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id AF1BC6B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 03:17:13 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id d17so19310eek.0
        for <linux-mm@kvack.org>; Tue, 06 Aug 2013 00:17:12 -0700 (PDT)
Message-ID: <5200A29C.9060702@gmail.com>
Date: Tue, 06 Aug 2013 09:15:40 +0200
From: Wladislav Wiebe <wladislav.kw@gmail.com>
MIME-Version: 1.0
Subject: Re: mm/slab: ppc: ubi: kmalloc_slab WARNING / PPC + UBI driver
References: <51F8F827.6020108@gmail.com> <alpine.DEB.2.02.1307310858150.30572@gentwo.org> <alpine.DEB.2.02.1307311015320.30997@gentwo.org> <000001403567762a-60a27288-f0b2-4855-b88c-6a6f21ec537c-000000@email.amazonses.com> <51F93C64.4090601@gmail.com> <0000014035b06a9d-e8b10680-e321-4d3b-95a8-0833fa3fb7c9-000000@email.amazonses.com>
In-Reply-To: <0000014035b06a9d-e8b10680-e321-4d3b-95a8-0833fa3fb7c9-000000@email.amazonses.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, dedekind1@gmail.com, dwmw2@infradead.org, linux-mtd@lists.infradead.org, Mel Gorman <mel@csn.ul.ie>

Hi,

On 31/07/13 19:04, Christoph Lameter wrote:
> On Wed, 31 Jul 2013, Wladislav Wiebe wrote:
> 
>> Thanks for the point, do you plan to make kmalloc_large available for extern access in a separate mainline patch?
>> Since kmalloc_large is statically defined in slub_def.h and when including it to seq_file.c
>> we have a lot of conflicting types:
> 
> You cannot separatly include slub_def.h. slab.h includes slub_def.h for
> you. What problem did you try to fix by doing so?
> 
> There is a patch pending that moves kmalloc_large to slab.h. So maybe we
> have to wait a merge period in order to be able to use it with other
> allocators than slub.
> 
> 

ok, just saw in slab/for-linus branch that those stuff is reverted again..

commit 4932163637fbb9aaa654ca0703c5a624b7809da2
Author: Pekka Enberg <penberg@kernel.org>
Date:   Wed Jul 10 10:16:01 2013 +0300

    Revert "mm/sl[aou]b: Move kmalloc_node functions to common code"

..

commit 35be03cafb8f5ddcc1236e90144b6ec76296b789
Author: Pekka Enberg <penberg@kernel.org>
Date:   Wed Jul 10 09:56:49 2013 +0300

    Revert "mm/sl[aou]b: Move kmalloc definitions to slab.h"


--
WBR, WLadislav Wiebe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
