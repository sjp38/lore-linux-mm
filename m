Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id DF29E6B0033
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 10:57:09 -0400 (EDT)
Date: Tue, 6 Aug 2013 14:57:08 +0000
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: mm/slab: ppc: ubi: kmalloc_slab WARNING / PPC + UBI driver
In-Reply-To: <5200A29C.9060702@gmail.com>
Message-ID: <000001405421b036-0b2994fa-3dd8-4ce7-995c-81660d804803-000000@email.amazonses.com>
References: <51F8F827.6020108@gmail.com> <alpine.DEB.2.02.1307310858150.30572@gentwo.org> <alpine.DEB.2.02.1307311015320.30997@gentwo.org> <000001403567762a-60a27288-f0b2-4855-b88c-6a6f21ec537c-000000@email.amazonses.com> <51F93C64.4090601@gmail.com>
 <0000014035b06a9d-e8b10680-e321-4d3b-95a8-0833fa3fb7c9-000000@email.amazonses.com> <5200A29C.9060702@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wladislav Wiebe <wladislav.kw@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, dedekind1@gmail.com, dwmw2@infradead.org, linux-mtd@lists.infradead.org, Mel Gorman <mel@csn.ul.ie>

On Tue, 6 Aug 2013, Wladislav Wiebe wrote:

> ok, just saw in slab/for-linus branch that those stuff is reverted again..

No that was only for the 3.11 merge by Linus. The 3.12 patches have not
been put into pekkas tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
