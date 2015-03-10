Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 235A490002E
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 19:16:07 -0400 (EDT)
Received: by pdev10 with SMTP id v10so5899849pde.13
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 16:16:06 -0700 (PDT)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com. [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id u14si3724329pdi.41.2015.03.10.16.16.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Mar 2015 16:16:06 -0700 (PDT)
Received: by pdbfp1 with SMTP id fp1so5953490pdb.7
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 16:16:06 -0700 (PDT)
Date: Wed, 11 Mar 2015 08:15:57 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: Add missing #include <linux/sched.h>
Message-ID: <20150310231557.GA4794@blaptop>
References: <1426023991-30407-1-git-send-email-geert@linux-m68k.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1426023991-30407-1-git-send-email-geert@linux-m68k.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-next@vger.kernel.org

On Tue, Mar 10, 2015 at 10:46:31PM +0100, Geert Uytterhoeven wrote:
> mips/allmodconfig:
> 
> mm/zsmalloc.c: In function '__zs_compact':
> mm/zsmalloc.c:1747:2: error: implicit declaration of function
> 'cond_resched' [-Werror=implicit-function-declaration]
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
