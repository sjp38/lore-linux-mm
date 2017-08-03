Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 18C1A6B06DD
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 12:39:18 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id l3so2674734wrc.12
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 09:39:18 -0700 (PDT)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id 35si2063396edo.462.2017.08.03.09.39.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 09:39:16 -0700 (PDT)
Received: by mail-wm0-x22d.google.com with SMTP id m85so44388wma.0
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 09:39:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170803163350.45245-1-mka@chromium.org>
References: <20170803163350.45245-1-mka@chromium.org>
From: Doug Anderson <dianders@chromium.org>
Date: Thu, 3 Aug 2017 09:39:15 -0700
Message-ID: <CAD=FV=WpERBYJgaJ8LTK0z0EagkMztVCy6bhC0Qzr_AfxHapzg@mail.gmail.com>
Subject: Re: [PATCH v2] zram: Rework copy of compressor name in comp_algorithm_store()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Kaehlcke <mka@chromium.org>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Nick Desaulniers <ndesaulniers@google.com>

Hi,

On Thu, Aug 3, 2017 at 9:33 AM, Matthias Kaehlcke <mka@chromium.org> wrote:
> comp_algorithm_store() passes the size of the source buffer to strlcpy()
> instead of the destination buffer size. Make it explicit that the two
> buffers have the same size and use strcpy() instead of strlcpy().
> The latter can be done safely since the function ensures that the string
> in the source buffer is terminated.
>
> Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
> ---
> Changes in v2:
> - make destination buffer explicitly of the same size as source buffer
> - use strcpy() instead of strlcpy()
> - updated subject and commit message
>
>  drivers/block/zram/zram_drv.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Looks great.  Commit message could be explicit that this change fixes
no bugs and is mostly a no-op (strcpy may be slightly faster than
strlcpy), but I guess that's obvious to anyone looking at the patch.

Reviewed-by: Douglas Anderson <dianders@chromium.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
