Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 124EA6B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 04:16:17 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q27so4963269pfi.8
        for <linux-mm@kvack.org>; Wed, 24 May 2017 01:16:17 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id e184si22966415pfh.275.2017.05.24.01.16.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 01:16:16 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id s62so16299626pgc.0
        for <linux-mm@kvack.org>; Wed, 24 May 2017 01:16:16 -0700 (PDT)
Date: Wed, 24 May 2017 17:16:18 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: fix -Wunneeded-internal-declaration warning
Message-ID: <20170524081617.GA3311@jagdpanzerIV.localdomain>
References: <20170524053859.29059-1-nick.desaulniers@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170524053859.29059-1-nick.desaulniers@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Desaulniers <nick.desaulniers@gmail.com>
Cc: md@google.com, mka@chromium.org, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (05/23/17 22:38), Nick Desaulniers wrote:
> 
> is_first_page() is only called from the macro VM_BUG_ON_PAGE() which is
> only compiled in as a runtime check when CONFIG_DEBUG_VM is set,
> otherwise is checked at compile time and not actually compiled in.
> 
> Fixes the following warning, found with Clang:
> 
> mm/zsmalloc.c:472:12: warning: function 'is_first_page' is not needed and
> will not be emitted [-Wunneeded-internal-declaration]
> static int is_first_page(struct page *page)
>            ^
> 
> Signed-off-by: Nick Desaulniers <nick.desaulniers@gmail.com>

well, no objections from my side. MM seems to be getting more and
more `__maybe_unused' annotations because of clang.

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
