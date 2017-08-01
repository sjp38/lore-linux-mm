Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 399156B04FD
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 03:30:02 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v77so9288293pgb.15
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 00:30:02 -0700 (PDT)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id t4si17451270pgt.664.2017.08.01.00.30.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 00:30:01 -0700 (PDT)
Received: by mail-pf0-x235.google.com with SMTP id z129so4465697pfb.3
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 00:30:01 -0700 (PDT)
Date: Tue, 1 Aug 2017 16:30:14 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: Change stat type parameter to int
Message-ID: <20170801073014.GA513@jagdpanzerIV.localdomain>
References: <20170731175000.56538-1-mka@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170731175000.56538-1-mka@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Kaehlcke <mka@chromium.org>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Doug Anderson <dianders@chromium.org>

On (07/31/17 10:50), Matthias Kaehlcke wrote:
> zs_stat_inc/dec/get() uses enum zs_stat_type for the stat type, however
> some callers pass an enum fullness_group value. Change the type to int
> to reflect the actual use of the functions and get rid of
> 'enum-conversion' warnings
> 
> Signed-off-by: Matthias Kaehlcke <mka@chromium.org>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
