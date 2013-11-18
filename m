Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id DE6116B0031
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 18:08:09 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so5643288pdj.16
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 15:08:09 -0800 (PST)
Received: from psmtp.com ([74.125.245.185])
        by mx.google.com with SMTP id gn4si10721577pbc.81.2013.11.18.15.08.07
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 15:08:08 -0800 (PST)
Date: Mon, 18 Nov 2013 18:08:04 -0500 (EST)
Message-Id: <20131118.180804.1868971161928013977.davem@davemloft.net>
Subject: Re: [PATCH] sparc64: fix build regession
From: David Miller <davem@davemloft.net>
In-Reply-To: <1384767850-2574-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1384767850-2574-1-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill.shutemov@linux.intel.com
Cc: geert@linux-m68k.org, sfr@canb.auug.org.au, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Date: Mon, 18 Nov 2013 11:44:09 +0200

> Commit ea1e7ed33708 triggers build regression on sparc64.
> 
> include/linux/mm.h:1391:2: error: implicit declaration of function 'pgtable_cache_init' [-Werror=implicit-function-declaration]
> arch/sparc/include/asm/pgtable_64.h:978:13: error: conflicting types for 'pgtable_cache_init' [-Werror]
> 
> It happens due headers include loop:
> 
> <linux/mm.h> -> <asm/pgtable.h> -> <asm/pgtable_64.h> ->
> 	<asm/tlbflush.h> -> <asm/tlbflush_64.h> -> <linux/mm.h>
> 
> Let's drop <linux/mm.h> include from asm/tlbflush_64.h.
> Build tested with allmodconfig.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>

Applied, please post sparc patches to sparclinux@vger.kernel.org in the
future so that I can properly track them.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
