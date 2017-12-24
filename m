Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id BE6CA6B0069
	for <linux-mm@kvack.org>; Sat, 23 Dec 2017 22:24:40 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id d4so15983939plr.8
        for <linux-mm@kvack.org>; Sat, 23 Dec 2017 19:24:40 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id g12si19233864pla.602.2017.12.23.19.24.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 23 Dec 2017 19:24:39 -0800 (PST)
Date: Sat, 23 Dec 2017 19:24:37 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] zsmalloc: use U suffix for negative literals being
 shifted
Message-ID: <20171224032437.GB5273@bombadil.infradead.org>
References: <1514082821-24256-1-git-send-email-nick.desaulniers@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1514082821-24256-1-git-send-email-nick.desaulniers@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Desaulniers <nick.desaulniers@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Dec 23, 2017 at 09:33:40PM -0500, Nick Desaulniers wrote:
> Fixes warnings about shifting unsigned literals being undefined
> behavior.

Do you mean signed literals?

>  			 */
> -			link->next = -1 << OBJ_TAG_BITS;
> +			link->next = -1U << OBJ_TAG_BITS;
>  		}

I don't understand what -1U means.  Seems like a contradiction in terms,
a negative unsigned number.  Is this supposed to be ~0U?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
