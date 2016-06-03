Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 07A266B007E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 04:23:43 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b124so95872654pfb.1
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 01:23:43 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id w129si6178178pfb.139.2016.06.03.01.23.41
        for <linux-mm@kvack.org>;
        Fri, 03 Jun 2016 01:23:42 -0700 (PDT)
Date: Fri, 3 Jun 2016 17:23:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: add NR_ZSMALLOC to vmstat
Message-ID: <20160603082336.GA18488@bbox>
References: <1464919731-13255-1-git-send-email-minchan@kernel.org>
 <20160603080141.GA490@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160603080141.GA490@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>, Chanho Min <chanho.min@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>

Hello,

On Fri, Jun 03, 2016 at 05:01:41PM +0900, Sergey Senozhatsky wrote:
> On (06/03/16 11:08), Minchan Kim wrote:
> > Now, zram is very popular for some of embedded world(e.g., TV, mobile
> > phone). On those system, zsmalloc consumed memory size is never trivial
> > (one of example from real product system, total memory: 800M, zsmalloc
> > consumed: 150M), so we have used this out of tree patch to monitor system
> > memory behavior via /proc/vmstat.
> > 
> > With zsmalloc in vmstat, it helps tracking down system behavior by
> > memory usage.
> 
> Hello,
> 
> may be use zsmalloc stats file instead? as far as I know, you keep
> zsmalloc stats enabled in production anyway.

It doesn't support per-zone stat which is important to show
the fragmentation of the zone, for exmaple.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
