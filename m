Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 263326B0055
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 12:08:28 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6615082C54B
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 12:09:20 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id G2eoVDWGOuBO for <linux-mm@kvack.org>;
	Wed, 26 Aug 2009 12:09:20 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 43D1C82CE37
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 12:09:07 -0400 (EDT)
Date: Wed, 26 Aug 2009 12:07:47 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 1/4] compcache: xvmalloc memory allocator
In-Reply-To: <4A92EBB4.1070101@vflare.org>
Message-ID: <alpine.DEB.1.10.0908261204400.9933@gentwo.org>
References: <200908241007.47910.ngupta@vflare.org> <84144f020908241033l4af09e7h9caac47d8d9b7841@mail.gmail.com> <4A92EBB4.1070101@vflare.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Aug 2009, Nitin Gupta wrote:

> PFNs are 32-bit on all archs while for 'struct page *', we require 32-bit or
> 64-bit depending on arch. ramzswap allocates a table entry <pagenum, offset>
> corresponding to every swap slot. So, the size of table will unnecessarily
> increase on 64-bit archs. Same is the argument for xvmalloc free list sizes.

Wrong. PFNs must be longer than 32 bit otherwise a system cannot
address more than 2^12 + 2^32 = 2^44 =>  16TB.

The type used for PFNs is unsigned long which are 64 bit on 64 bit platforms.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
