Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 751CF6B0071
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 07:15:50 -0400 (EDT)
Message-Id: <b9dded$gtgeib@orsmga002.jf.intel.com>
Date: Wed, 27 Oct 2010 12:15:45 +0100
Subject: Re: [PATCH] mm,x86: fix kmap_atomic_push vs ioremap_32.c
References: <20100918155326.478277313@chello.nl> <849307$a582r7@azsmga001.ch.intel.com> <1288175638.15336.1538.camel@twins>
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <1288175638.15336.1538.camel@twins>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Wed, 27 Oct 2010 12:33:58 +0200, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> Christoph just complained about the same on IRC, the below seems to cure
> things for i386-defconfig with CONFIG_HIGHMEM=n

Compiles and boots on the misbehaving box.
Thanks,
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
