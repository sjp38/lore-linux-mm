Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B0DFC6B0006
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 08:27:05 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 87-v6so2805197pfq.8
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 05:27:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d37-v6sor937947pla.28.2018.10.03.05.27.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Oct 2018 05:27:04 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Date: Wed, 3 Oct 2018 21:26:56 +0900
Subject: Re: [PATCH] zsmalloc: fix fall-through annotation
Message-ID: <20181003122656.GA30267@tigerII.localdomain>
References: <20181003105114.GA24423@embeddedor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181003105114.GA24423@embeddedor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (10/03/18 12:51), Gustavo A. R. Silva wrote:
> Replace "fallthru" with a proper "fall through" annotation.
> 
> This fix is part of the ongoing efforts to enabling
> -Wimplicit-fallthrough

Hmm, comments as annotations?


> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss
