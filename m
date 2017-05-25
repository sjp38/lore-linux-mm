Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 720FC6B0279
	for <linux-mm@kvack.org>; Thu, 25 May 2017 01:38:31 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e7so209712567pfk.9
        for <linux-mm@kvack.org>; Wed, 24 May 2017 22:38:31 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id k20si16098683pfb.241.2017.05.24.22.38.30
        for <linux-mm@kvack.org>;
        Wed, 24 May 2017 22:38:30 -0700 (PDT)
Date: Thu, 25 May 2017 14:38:29 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/zsmalloc: fix -Wunneeded-internal-declaration warning
Message-ID: <20170525053829.GC15087@bbox>
References: <20170524053859.29059-1-nick.desaulniers@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170524053859.29059-1-nick.desaulniers@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Desaulniers <nick.desaulniers@gmail.com>
Cc: md@google.com, mka@chromium.org, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, May 23, 2017 at 10:38:57PM -0700, Nick Desaulniers wrote:
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
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
