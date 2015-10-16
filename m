Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0901482F64
	for <linux-mm@kvack.org>; Fri, 16 Oct 2015 16:46:32 -0400 (EDT)
Received: by wijp11 with SMTP id p11so26454164wij.0
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 13:46:31 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id vf8si25961350wjc.207.2015.10.16.13.46.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Oct 2015 13:46:30 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so23977534wic.1
        for <linux-mm@kvack.org>; Fri, 16 Oct 2015 13:46:30 -0700 (PDT)
Date: Fri, 16 Oct 2015 23:46:29 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] ARM: thp: fix unterminated ifdef in header file
Message-ID: <20151016204629.GA1817@node.shutemov.name>
References: <5446974.UXhT00HeJk@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5446974.UXhT00HeJk@wuerfel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Fri, Oct 16, 2015 at 10:02:04PM +0200, Arnd Bergmann wrote:
> A recent change accidentally removed one line more than it should
> have, causing the build to fail with ARM LPAE:
> 
> In file included from /git/arm-soc/arch/arm/include/asm/pgtable.h:31:0,
>                  from /git/arm-soc/include/linux/mm.h:55,
>                  from /git/arm-soc/arch/arm/kernel/asm-offsets.c:15:
> /git/arm-soc/arch/arm/include/asm/pgtable-3level.h:20:0: error: unterminated #ifndef
>  #ifndef _ASM_PGTABLE_3LEVEL_H
> 
> This puts the line back where it was.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: f054144a1b23 ("arm, thp: remove infrastructure for handling splitting PMDs")

Sorry.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
