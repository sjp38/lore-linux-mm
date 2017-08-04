Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 558AC6B054E
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 21:04:51 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u7so3446068pgo.6
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 18:04:51 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id e2si169741pgp.908.2017.08.03.18.04.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 18:04:50 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id j68so316235pfc.2
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 18:04:50 -0700 (PDT)
Date: Fri, 4 Aug 2017 10:05:04 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2] zram: Rework copy of compressor name in
 comp_algorithm_store()
Message-ID: <20170804010503.GA6084@jagdpanzerIV.localdomain>
References: <20170803163350.45245-1-mka@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170803163350.45245-1-mka@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Kaehlcke <mka@chromium.org>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Doug Anderson <dianders@chromium.org>, Nick Desaulniers <ndesaulniers@google.com>

On (08/03/17 09:33), Matthias Kaehlcke wrote:
> comp_algorithm_store() passes the size of the source buffer to strlcpy()
> instead of the destination buffer size. Make it explicit that the two
> buffers have the same size and use strcpy() instead of strlcpy().
> The latter can be done safely since the function ensures that the string
> in the source buffer is terminated.
> 
> Signed-off-by: Matthias Kaehlcke <mka@chromium.org>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
