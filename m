Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 777676B0092
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 08:16:09 -0500 (EST)
Received: from localhost.localdomain ([127.0.0.1]:49673 "EHLO
        duck.linux-mips.net" rhost-flags-OK-OK-OK-FAIL)
        by eddie.linux-mips.org with ESMTP id S1491048Ab1AXNQG (ORCPT
        <rfc822;linux-mm@kvack.org>); Mon, 24 Jan 2011 14:16:06 +0100
Date: Mon, 24 Jan 2011 14:15:36 +0100
From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH] fix build error when CONFIG_SWAP is not set
Message-ID: <20110124131536.GA6246@linux-mips.org>
References: <20110124210813.ba743fc5.yuasa@linux-mips.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110124210813.ba743fc5.yuasa@linux-mips.org>
Sender: owner-linux-mm@kvack.org
To: Yoichi Yuasa <yuasa@linux-mips.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mips <linux-mips@linux-mips.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 24, 2011 at 09:08:13PM +0900, Yoichi Yuasa wrote:

> In file included from
> linux-2.6/arch/mips/include/asm/tlb.h:21,
>                  from mm/pgtable-generic.c:9:
> include/asm-generic/tlb.h: In function 'tlb_flush_mmu':
> include/asm-generic/tlb.h:76: error: implicit declaration of function
> 'release_pages'
> include/asm-generic/tlb.h: In function 'tlb_remove_page':
> include/asm-generic/tlb.h:105: error: implicit declaration of function
> 'page_cache_release'
> make[1]: *** [mm/pgtable-generic.o] Error 1
> 
> Signed-off-by: Yoichi Yuasa <yuasa@linux-mips.org>

Works as advertised for me.

Tested-by: Ralf Baechle <ralf@linux-mips.org>

  Ralf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
