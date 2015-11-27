Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 554B66B0038
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 04:09:48 -0500 (EST)
Received: by padhx2 with SMTP id hx2so109783558pad.1
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 01:09:48 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id 133si3129349pfa.16.2015.11.27.01.09.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Nov 2015 01:09:47 -0800 (PST)
Received: by pacej9 with SMTP id ej9so109664886pac.2
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 01:09:47 -0800 (PST)
Date: Fri, 27 Nov 2015 18:10:47 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: linux-next: Tree for Nov 27 (mm stuff)
Message-ID: <20151127091047.GA585@swordfish>
References: <20151127160514.7b2022f2@canb.auug.org.au>
 <56580097.8050405@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56580097.8050405@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>

On (11/26/15 23:04), Randy Dunlap wrote:
> 
> on i386:
> 
> mm/built-in.o: In function `page_referenced_one':
> rmap.c:(.text+0x362a2): undefined reference to `pmdp_clear_flush_young'
> mm/built-in.o: In function `page_idle_clear_pte_refs_one':
> page_idle.c:(.text+0x4b2b8): undefined reference to `pmdp_test_and_clear_young'
> 

Hello,

https://lkml.org/lkml/2015/11/24/160

corresponding patch mm-add-page_check_address_transhuge-helper-fix.patch added
to -mm tree.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
