Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D78D06B0261
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 02:06:27 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id a74so1146679pfg.20
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 23:06:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x1sor2844836pln.85.2018.01.10.23.06.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 23:06:26 -0800 (PST)
Date: Thu, 11 Jan 2018 16:06:22 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2] zsmalloc: use U suffix for negative literals being
 shifted
Message-ID: <20180111070622.GI494@jagdpanzerIV>
References: <20180110055338.h3cs5hw7mzsdtcad@eng-minchan1.roam.corp.google.com>
 <1515642078-4259-1-git-send-email-nick.desaulniers@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1515642078-4259-1-git-send-email-nick.desaulniers@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Desaulniers <nick.desaulniers@gmail.com>
Cc: akpm@linux-foundation.org, Andy Shevchenko <andy.shevchenko@gmail.com>, Matthew Wilcox <willy@infradead.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (01/10/18 19:41), Nick Desaulniers wrote:
> Fixes warnings about shifting unsigned literals being undefined
> behavior.
> 
> Suggested-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Nick Desaulniers <nick.desaulniers@gmail.com>

looks good to me.

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
