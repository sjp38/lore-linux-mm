Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 456C46B055C
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 21:11:16 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o82so3335269pfj.11
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 18:11:16 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id f1si210981plk.489.2017.08.03.18.11.14
        for <linux-mm@kvack.org>;
        Thu, 03 Aug 2017 18:11:15 -0700 (PDT)
Date: Fri, 4 Aug 2017 10:11:13 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] zram: Rework copy of compressor name in
 comp_algorithm_store()
Message-ID: <20170804011113.GB8368@bbox>
References: <20170803163350.45245-1-mka@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170803163350.45245-1-mka@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Kaehlcke <mka@chromium.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Doug Anderson <dianders@chromium.org>, Nick Desaulniers <ndesaulniers@google.com>

On Thu, Aug 03, 2017 at 09:33:50AM -0700, Matthias Kaehlcke wrote:
> comp_algorithm_store() passes the size of the source buffer to strlcpy()
> instead of the destination buffer size. Make it explicit that the two
> buffers have the same size and use strcpy() instead of strlcpy().
> The latter can be done safely since the function ensures that the string
> in the source buffer is terminated.
> 
> Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
