Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 68F5D6B0088
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 13:56:44 -0400 (EDT)
Date: Mon, 1 Oct 2012 17:56:43 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH linux-next-20120928] slab: Fix build failure.
In-Reply-To: <201209301736.HDH56776.tJVFLFQOHOOMSF@I-love.SAKURA.ne.jp>
Message-ID: <0000013a1d790c63-77f1e62b-f565-4949-8cd4-f98c3f543e89-000000@email.amazonses.com>
References: <201209301736.HDH56776.tJVFLFQOHOOMSF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: penberg@kernel.org, linux-mm@kvack.org

On Sun, 30 Sep 2012, Tetsuo Handa wrote:

> Fix build failure with CONFIG_DEBUG_SLAB=y && CONFIG_DEBUG_PAGEALLOC=y caused
> by commit 8a13a4cc "mm/sl[aou]b: Shrink __kmem_cache_create() parameter lists".

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
