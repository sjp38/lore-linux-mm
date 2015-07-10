Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 070DD6B0038
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 02:00:28 -0400 (EDT)
Received: by pdbqm3 with SMTP id qm3so34545062pdb.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 23:00:27 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id aa8si12838316pad.127.2015.07.09.23.00.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 23:00:27 -0700 (PDT)
Received: by pdbqm3 with SMTP id qm3so34544700pdb.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 23:00:26 -0700 (PDT)
Date: Fri, 10 Jul 2015 15:00:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] zsmalloc: consider ZS_ALMOST_FULL as migrate source
Message-ID: <20150710060000.GA11760@bgram>
References: <1436506319-12885-1-git-send-email-minchan@kernel.org>
 <20150710054654.GE692@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150710054654.GE692@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan.kim@lge.com>

On Fri, Jul 10, 2015 at 02:46:54PM +0900, Sergey Senozhatsky wrote:
> On (07/10/15 14:31), Minchan Kim wrote:
> > There is no reason to prevent select ZS_ALMOST_FULL as migration
> > source if we cannot find source from ZS_ALMOST_EMPTY.
> > 
> > With this patch, zs_can_compact will return more exact result.
> > 
> > * From v1
> >   * remove unnecessary found variable - Sergey
> > 
> > Signed-off-by: Minchan Kim <minchan.kim@lge.com>
> > 
> 
> Acked-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> 

Thanks, Sergey!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
