Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F3B856B004F
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 12:23:54 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 20F8F82C90C
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 12:25:07 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id WSgyrQvH++5w for <linux-mm@kvack.org>;
	Thu, 27 Aug 2009 12:25:07 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 68AC682C910
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 12:25:02 -0400 (EDT)
Date: Thu, 27 Aug 2009 12:23:46 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] SLUB: fix ARCH_KMALLOC_MINALIGN cases 64 and 256
In-Reply-To: <4A96AE4E.5000105@nokia.com>
Message-ID: <alpine.DEB.1.10.0908271220140.17470@gentwo.org>
References: <> <1251387491-8417-1-git-send-email-aaro.koskinen@nokia.com> <alpine.DEB.1.10.0908271151100.17470@gentwo.org> <4A96AE4E.5000105@nokia.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Artem Bityutskiy <Artem.Bityutskiy@nokia.com>
Cc: "Koskinen Aaro (Nokia-D/Helsinki)" <aaro.koskinen@nokia.com>, "mpm@selenic.com" <mpm@selenic.com>, "penberg@cs.helsinki.fi" <penberg@cs.helsinki.fi>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 27 Aug 2009, Artem Bityutskiy wrote:

> Just a related question. KMALLOC_MIN_SIZE sounds confusing. If this is
> about alignment, why not to call it KMALLOC_MIN_ALIGN instead?


KMALLOC_MIN_SIZE is the size of the smallest kmalloc slab.

ARCH_KMALLOC_MINALIGN is the minimum alignment required by the arch code.

KMALLOC_MIN_SIZE is set to ARCH_KMALLOC_MINALIGN if the alignment is
greater than 8 (see slub_def.h)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
