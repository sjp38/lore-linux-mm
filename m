Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2924C6B04FB
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 02:54:05 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r62so6482744pfj.1
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 23:54:05 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id g6si16762411pln.930.2017.07.31.23.54.03
        for <linux-mm@kvack.org>;
        Mon, 31 Jul 2017 23:54:04 -0700 (PDT)
Date: Tue, 1 Aug 2017 15:54:02 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm/zsmalloc: Change stat type parameter to int
Message-ID: <20170801065402.GC19932@bbox>
References: <20170731175000.56538-1-mka@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170731175000.56538-1-mka@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Kaehlcke <mka@chromium.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Doug Anderson <dianders@chromium.org>

On Mon, Jul 31, 2017 at 10:50:00AM -0700, Matthias Kaehlcke wrote:
> zs_stat_inc/dec/get() uses enum zs_stat_type for the stat type, however
> some callers pass an enum fullness_group value. Change the type to int
> to reflect the actual use of the functions and get rid of
> 'enum-conversion' warnings

Maybe clang?
        
> 
> Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
Anyway,

Acked-by: Minchan Kim <minchan@kernel.org>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
