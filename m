Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 54EFE6B0260
	for <linux-mm@kvack.org>; Sat,  6 Jan 2018 15:40:53 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id a17so4223405otd.15
        for <linux-mm@kvack.org>; Sat, 06 Jan 2018 12:40:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l56sor3375491otd.280.2018.01.06.12.40.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 06 Jan 2018 12:40:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAH7mPvgqLf5x5QvdP1u1hpJCD+p2vy3aj=nt0RsHQH+aKTdovA@mail.gmail.com>
References: <1514082821-24256-1-git-send-email-nick.desaulniers@gmail.com>
 <20171224032437.GB5273@bombadil.infradead.org> <CAH7mPvgqLf5x5QvdP1u1hpJCD+p2vy3aj=nt0RsHQH+aKTdovA@mail.gmail.com>
From: Nick Desaulniers <nick.desaulniers@gmail.com>
Date: Sat, 6 Jan 2018 12:40:51 -0800
Message-ID: <CAH7mPvhTC4N32cxk4y_mE61d9hfRwk30YCdGEUn3kkp7N-pwWg@mail.gmail.com>
Subject: Re: [PATCH] zsmalloc: use U suffix for negative literals being shifted
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hello,
What are the next steps for this patch?

Note: the MAINTAINERS file does not contain a T: (tree) entry for
ZSMALLOC, so I can't check to see if this has already been merged or
not.  Unless you work out of the mm tree?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
