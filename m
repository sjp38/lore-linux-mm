Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D6C9F6B007E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 04:01:48 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g64so94919855pfb.2
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 01:01:48 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id o70si1541228pfi.220.2016.06.03.01.01.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 01:01:48 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id x1so5386845pav.1
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 01:01:47 -0700 (PDT)
Date: Fri, 3 Jun 2016 17:01:41 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm: add NR_ZSMALLOC to vmstat
Message-ID: <20160603080141.GA490@swordfish>
References: <1464919731-13255-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464919731-13255-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>, Chanho Min <chanho.min@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>

On (06/03/16 11:08), Minchan Kim wrote:
> Now, zram is very popular for some of embedded world(e.g., TV, mobile
> phone). On those system, zsmalloc consumed memory size is never trivial
> (one of example from real product system, total memory: 800M, zsmalloc
> consumed: 150M), so we have used this out of tree patch to monitor system
> memory behavior via /proc/vmstat.
> 
> With zsmalloc in vmstat, it helps tracking down system behavior by
> memory usage.

Hello,

may be use zsmalloc stats file instead? as far as I know, you keep
zsmalloc stats enabled in production anyway.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
