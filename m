Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id D2B8F82F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 10:28:37 -0500 (EST)
Received: by iofz202 with SMTP id z202so57013405iof.2
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 07:28:37 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id uh6si5678448igb.44.2015.11.04.07.28.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 04 Nov 2015 07:28:36 -0800 (PST)
Date: Wed, 4 Nov 2015 09:28:34 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] arm64: Increase the max granular size
In-Reply-To: <20151104145445.GL7637@e104818-lin.cambridge.arm.com>
Message-ID: <alpine.DEB.2.20.1511040927510.18745@east.gentwo.org>
References: <1442944788-17254-1-git-send-email-rric@kernel.org> <20151028190948.GJ8899@e104818-lin.cambridge.arm.com> <CAMuHMdWQygbxMXoOsbwek6DzZcr7J-C23VCK4ubbgUr+zj=giw@mail.gmail.com> <20151103120504.GF7637@e104818-lin.cambridge.arm.com>
 <20151103143858.GI7637@e104818-lin.cambridge.arm.com> <CAMuHMdWk0fPzTSKhoCuS4wsOU1iddhKJb2SOpjo=a_9vCm_KXQ@mail.gmail.com> <20151103185050.GJ7637@e104818-lin.cambridge.arm.com> <alpine.DEB.2.20.1511031724010.8178@east.gentwo.org>
 <20151104123640.GK7637@e104818-lin.cambridge.arm.com> <alpine.DEB.2.20.1511040748590.17248@east.gentwo.org> <20151104145445.GL7637@e104818-lin.cambridge.arm.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Robert Richter <rric@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Linux-sh list <linux-sh@vger.kernel.org>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Robert Richter <rrichter@cavium.com>, linux-mm@kvack.org, Tirumalesh Chalamarla <tchalamarla@cavium.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Wed, 4 Nov 2015, Catalin Marinas wrote:

> BTW, assuming L1_CACHE_BYTES is 512 (I don't ever see this happening but
> just in theory), we potentially have the same issue. What would save us
> is that INDEX_NODE would match the first "kmalloc-512" cache, so we have
> it pre-populated.

Ok maybe add some BUILD_BUG_ONs to ensure that builds fail until we have
addressed that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
