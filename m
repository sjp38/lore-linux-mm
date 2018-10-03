Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8F5276B0008
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 08:32:15 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id t8-v6so5373314plo.4
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 05:32:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n4-v6sor1035044pfj.0.2018.10.03.05.32.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Oct 2018 05:32:14 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Wed, 3 Oct 2018 21:32:06 +0900
Subject: Re: [PATCH] zsmalloc: fix fall-through annotation
Message-ID: <20181003123206.GC30267@tigerII.localdomain>
References: <20181003105114.GA24423@embeddedor.com>
 <20181003122656.GA30267@tigerII.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181003122656.GA30267@tigerII.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Gustavo A. R. Silva" <gustavo@embeddedor.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Oh, Cc-ing Andrew

message id: lkml.kernel.org/r/20181003105114.GA24423@embeddedor.com


---

On (10/03/18 21:26), Sergey Senozhatsky wrote:
> On (10/03/18 12:51), Gustavo A. R. Silva wrote:
> Replace "fallthru" with a proper "fall through" annotation.
> 
> This fix is part of the ongoing efforts to enabling
> -Wimplicit-fallthrough

Hmm, comments as annotations?


> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
