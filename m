Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E00C6B0253
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 06:24:38 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b124so99786766pfb.1
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 03:24:38 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id h5si5048352pah.28.2016.06.03.03.24.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 03:24:37 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id f144so11210184pfa.2
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 03:24:37 -0700 (PDT)
Date: Fri, 3 Jun 2016 19:24:32 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] mm: add NR_ZSMALLOC to vmstat
Message-ID: <20160603102432.GB586@swordfish>
References: <1464919731-13255-1-git-send-email-minchan@kernel.org>
 <20160603080141.GA490@swordfish>
 <20160603082336.GA18488@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160603082336.GA18488@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sangseok Lee <sangseok.lee@lge.com>, Chanho Min <chanho.min@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>

Hello,

On (06/03/16 17:23), Minchan Kim wrote:
> On Fri, Jun 03, 2016 at 05:01:41PM +0900, Sergey Senozhatsky wrote:
> > On (06/03/16 11:08), Minchan Kim wrote:
> > > Now, zram is very popular for some of embedded world(e.g., TV, mobile
> > > phone). On those system, zsmalloc consumed memory size is never trivial
> > > (one of example from real product system, total memory: 800M, zsmalloc
> > > consumed: 150M), so we have used this out of tree patch to monitor system
> > > memory behavior via /proc/vmstat.
> > > 
> > > With zsmalloc in vmstat, it helps tracking down system behavior by
> > > memory usage.
> > 
> > Hello,
> > 
> > may be use zsmalloc stats file instead? as far as I know, you keep
> > zsmalloc stats enabled in production anyway.
> 
> It doesn't support per-zone stat which is important to show
> the fragmentation of the zone, for exmaple.

Ah, I see.

*just an idea*

may be zbud and z3fold folks will be interested as well, so may
be more generic name and define... um, my head doesn't work toay..
ZALLOC... ZPOOLALLOC... hm.. I think you got the idea.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
