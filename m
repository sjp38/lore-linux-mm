Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 594B36B0009
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 22:58:38 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id yy13so83744864pab.3
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 19:58:38 -0800 (PST)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id 12si36717788pfb.80.2016.02.21.19.58.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Feb 2016 19:58:37 -0800 (PST)
Received: by mail-pf0-x22b.google.com with SMTP id e127so85451665pfe.3
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 19:58:37 -0800 (PST)
Date: Mon, 22 Feb 2016 12:59:54 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH v2 3/3] mm/zsmalloc: increase ZS_MAX_PAGES_PER_ZSPAGE
Message-ID: <20160222035954.GC11961@swordfish>
References: <1456061274-20059-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1456061274-20059-4-git-send-email-sergey.senozhatsky@gmail.com>
 <20160222002515.GB21710@bbox>
 <20160222004758.GB4958@swordfish>
 <20160222013442.GB27829@bbox>
 <20160222020113.GB488@swordfish>
 <20160222023432.GC27829@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160222023432.GC27829@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (02/22/16 11:34), Minchan Kim wrote:
[..]
> > I'll take a look at dynamic class page addition.
> 
> Thanks, Sergey.
> 
> Just a note:
> 
> I am preparing zsmalloc migration now and almost done so I hope
> I can send it within two weeks. In there, I changed a lot of
> things in zsmalloc, page chaining, struct page fields usecases
> and locking scheme and so on. The zsmalloc fragment/migration
> is really painful now so we should solve it first so I hope
> you help to review that and let's go further dynamic chaining
> after that, please. :)

oh, sure.

so let's keep dynamic page allocation out of sight for now.
I'll do more tests with the increase ORDER and if it's OK then
hopefully we can just merge it, it's quite simple and shouldn't
interfere with any of the changes you are about to introduce.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
