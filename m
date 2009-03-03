Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C7B866B00AA
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 11:05:11 -0500 (EST)
Date: Tue, 3 Mar 2009 17:05:03 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] generic debug pagealloc
Message-ID: <20090303160503.GA6538@elte.hu>
References: <20090303160103.GB5812@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090303160103.GB5812@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>


* Akinobu Mita <akinobu.mita@gmail.com> wrote:

> CONFIG_DEBUG_PAGEALLOC is now supported by x86, powerpc, sparc 
> (64bit), and s390. This patch implements it for the rest of 
> the architectures by filling the pages with poison byte 
> patterns after free_pages() and verifying the poison patterns 
> before alloc_pages().
> 
> This generic one cannot detect invalid read accesses and it 
> can only detect invalid write accesses after a long delay. But 
> it is an feasible way for nommu architectures.

if every architecture supports it now then i guess this config 
switch can go away:

> +config ARCH_SUPPORTS_DEBUG_PAGEALLOC
> +	def_bool y

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
