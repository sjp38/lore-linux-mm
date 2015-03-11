Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id D6E9390002E
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 00:32:54 -0400 (EDT)
Received: by pdjy10 with SMTP id y10so7840313pdj.12
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 21:32:54 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com. [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id xu6si4698807pab.113.2015.03.10.21.32.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Mar 2015 21:32:53 -0700 (PDT)
Received: by pdjz10 with SMTP id z10so7838843pdj.11
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 21:32:53 -0700 (PDT)
Date: Wed, 11 Mar 2015 13:32:47 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -next] zsmalloc: Include linux/sched.h to fix build error
Message-ID: <20150311043247.GC4794@blaptop>
References: <1426045262-14739-1-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1426045262-14739-1-git-send-email-linux@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello Guenter,

On Tue, Mar 10, 2015 at 08:41:02PM -0700, Guenter Roeck wrote:
> Fix:
> 
> mm/zsmalloc.c: In function '__zs_compact':
> mm/zsmalloc.c:1747:2: error: implicit declaration of function 'cond_resched'
> 
> seen when building mips:allmodconfig.
> 
> Fixes: c4d204c38734 ("zsmalloc: support compaction")
> Cc: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Thanks for the fixing!

A few hours ago, Geert Uytterhoeven sent a patch.
http://www.spinics.net/lists/linux-mm/msg85571.html

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
