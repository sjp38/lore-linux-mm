Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B35E46B00DD
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 18:04:36 -0400 (EDT)
Date: Mon, 24 Aug 2009 21:39:02 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 1/4] compcache: xvmalloc memory allocator
In-Reply-To: <4A92EBB4.1070101@vflare.org>
Message-ID: <Pine.LNX.4.64.0908242132320.8144@sister.anvils>
References: <200908241007.47910.ngupta@vflare.org>
 <84144f020908241033l4af09e7h9caac47d8d9b7841@mail.gmail.com>
 <4A92EBB4.1070101@vflare.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Aug 2009, Nitin Gupta wrote:
> On 08/24/2009 11:03 PM, Pekka Enberg wrote:
> >
> > What's the purpose of passing PFNs around? There's quite a lot of PFN
> > to struct page conversion going on because of it. Wouldn't it make
> > more sense to return (and pass) a pointer to struct page instead?
> 
> PFNs are 32-bit on all archs

Are you sure?  If it happens to be so for all machines built today,
I think it can easily change tomorrow.  We consistently use unsigned long
for pfn (there, now I've said that, I bet you'll find somewhere we don't!)

x86_64 says MAX_PHYSMEM_BITS 46 and ia64 says MAX_PHYSMEM_BITS 50 and
mm/sparse.c says
unsigned long max_sparsemem_pfn = 1UL << (MAX_PHYSMEM_BITS-PAGE_SHIFT);

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
