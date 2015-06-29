Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 53EE96B0032
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 02:40:23 -0400 (EDT)
Received: by pdcu2 with SMTP id u2so111260081pdc.3
        for <linux-mm@kvack.org>; Sun, 28 Jun 2015 23:40:23 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id yr1si62722996pbc.78.2015.06.28.23.40.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Jun 2015 23:40:22 -0700 (PDT)
Received: by pdbep18 with SMTP id ep18so89453176pdb.1
        for <linux-mm@kvack.org>; Sun, 28 Jun 2015 23:40:21 -0700 (PDT)
Date: Mon, 29 Jun 2015 15:40:29 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCHv3 3/7] zsmalloc: always keep per-class stats
Message-ID: <20150629064029.GA13179@bbox>
References: <1434628004-11144-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1434628004-11144-4-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1434628004-11144-4-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Thu, Jun 18, 2015 at 08:46:40PM +0900, Sergey Senozhatsky wrote:
> Always account per-class `zs_size_stat' stats. This data will
> help us make better decisions during compaction. We are especially
> interested in OBJ_ALLOCATED and OBJ_USED, which can tell us if
> class compaction will result in any memory gain.
> 
> For instance, we know the number of allocated objects in the class,
> the number of objects being used (so we also know how many objects
> are not used) and the number of objects per-page. So we can ensure
> if we have enough unused objects to form at least one ZS_EMPTY
> zspage during compaction.
> 
> We calculate this value on per-class basis so we can calculate a
> total number of zspages that can be released. Which is exactly what
> a shrinker wants to know.
> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
