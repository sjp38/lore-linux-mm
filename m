Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E75846B004D
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 12:10:39 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 03B6D82CCB3
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 12:11:42 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id BEjZr1-wp-Y5 for <linux-mm@kvack.org>;
	Wed, 26 Aug 2009 12:11:37 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5912782CE4A
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 12:11:27 -0400 (EDT)
Date: Wed, 26 Aug 2009 12:10:24 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 1/4] compcache: xvmalloc memory allocator
In-Reply-To: <4A94358C.6060708@vflare.org>
Message-ID: <alpine.DEB.1.10.0908261209240.9933@gentwo.org>
References: <200908241007.47910.ngupta@vflare.org> <84144f020908241033l4af09e7h9caac47d8d9b7841@mail.gmail.com> <4A92EBB4.1070101@vflare.org> <Pine.LNX.4.64.0908242132320.8144@sister.anvils> <4A930313.9070404@vflare.org> <Pine.LNX.4.64.0908242224530.10534@sister.anvils>
 <4A93FAA5.5000001@vflare.org> <4A94358C.6060708@vflare.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Aug 2009, Nitin Gupta wrote:

> I went crazy. I meant 40 bits for PFN -- not 48. This 40-bit PFN should be
> sufficient for all archs. For archs where 40 + PAGE_SHIFT < MAX_PHYSMEM_BITS
> ramzswap will just issue a compiler error.

How about restricting the xvmalloc memory allocator to 32 bit? If I
understand correctly xvmalloc main use in on 32 bit in order to be
able to use HIGHMEM?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
