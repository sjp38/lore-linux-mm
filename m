Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 067E26B0255
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 08:53:53 -0500 (EST)
Received: by igbdj2 with SMTP id dj2so35374701igb.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 05:53:52 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id r18si19522187igs.82.2015.11.04.05.53.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 04 Nov 2015 05:53:52 -0800 (PST)
Date: Wed, 4 Nov 2015 07:53:50 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] arm64: Increase the max granular size
In-Reply-To: <20151104123640.GK7637@e104818-lin.cambridge.arm.com>
Message-ID: <alpine.DEB.2.20.1511040748590.17248@east.gentwo.org>
References: <1442944788-17254-1-git-send-email-rric@kernel.org> <20151028190948.GJ8899@e104818-lin.cambridge.arm.com> <CAMuHMdWQygbxMXoOsbwek6DzZcr7J-C23VCK4ubbgUr+zj=giw@mail.gmail.com> <20151103120504.GF7637@e104818-lin.cambridge.arm.com>
 <20151103143858.GI7637@e104818-lin.cambridge.arm.com> <CAMuHMdWk0fPzTSKhoCuS4wsOU1iddhKJb2SOpjo=a_9vCm_KXQ@mail.gmail.com> <20151103185050.GJ7637@e104818-lin.cambridge.arm.com> <alpine.DEB.2.20.1511031724010.8178@east.gentwo.org>
 <20151104123640.GK7637@e104818-lin.cambridge.arm.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Robert Richter <rric@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Linux-sh list <linux-sh@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Robert Richter <rrichter@cavium.com>, Tirumalesh Chalamarla <tchalamarla@cavium.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-mm@kvack.org

On Wed, 4 Nov 2015, Catalin Marinas wrote:

> The simplest option would be to make sure that off slab isn't allowed
> for caches of KMALLOC_MIN_SIZE or smaller, with the drawback that not
> only "kmalloc-128" but any other such caches will be on slab.

The reason for an off slab configuration is denser object packing.

> I think a better option would be to first check that there is a
> kmalloc_caches[] entry for freelist_size before deciding to go off-slab.

Hmmm.. Yes seems to be an option.

Maybe we simply revert commit 8fc9cf420b36 instead? That does not seem to
make too much sense to me and the goal of the commit cannot be
accomplished on ARM. Your patch essentially reverts the effect anyways.

Smaller slabs really do not need off slab management anyways since they
will only loose a few objects per slab page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
