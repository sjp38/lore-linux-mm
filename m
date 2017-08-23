Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1B12803FE
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 19:31:27 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id q16so19378027pgc.15
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 16:31:27 -0700 (PDT)
Received: from mail-pg0-x232.google.com (mail-pg0-x232.google.com. [2607:f8b0:400e:c05::232])
        by mx.google.com with ESMTPS id b5si1829769ple.560.2017.08.23.16.31.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 16:31:26 -0700 (PDT)
Received: by mail-pg0-x232.google.com with SMTP id u191so7040657pgc.2
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 16:31:26 -0700 (PDT)
Date: Wed, 23 Aug 2017 16:31:24 -0700
From: Matthias Kaehlcke <mka@chromium.org>
Subject: Re: [PATCH] mm/zsmalloc: Change stat type parameter to int
Message-ID: <20170823233124.GF173745@google.com>
References: <20170731175000.56538-1-mka@chromium.org>
 <20170801073014.GA513@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170801073014.GA513@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Doug Anderson <dianders@chromium.org>

El Tue, Aug 01, 2017 at 04:30:14PM +0900 Sergey Senozhatsky ha dit:

> On (07/31/17 10:50), Matthias Kaehlcke wrote:
> > zs_stat_inc/dec/get() uses enum zs_stat_type for the stat type, however
> > some callers pass an enum fullness_group value. Change the type to int
> > to reflect the actual use of the functions and get rid of
> > 'enum-conversion' warnings
> > 
> > Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
> 
> Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Ping, it seems this one went under Andrew's radar. Mea culpa for not
putting him in cc: in the first place.

Thanks

Matthias

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
