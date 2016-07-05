Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 197EC6B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 21:18:09 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ts6so375486994pac.1
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 18:18:09 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id i72si4374867pfi.282.2016.07.04.18.18.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jul 2016 18:18:08 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id i123so17517544pfg.3
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 18:18:08 -0700 (PDT)
Date: Tue, 5 Jul 2016 10:18:12 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2 5/8] mm/zsmalloc: avoid calculate max objects of
 zspage twice
Message-ID: <20160705011812.GC459@swordfish>
References: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
 <1467614999-4326-5-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467614999-4326-5-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com

On (07/04/16 14:49), Ganesh Mahendran wrote:
> Currently, if a class can not be merged, the max objects of zspage
> in that class may be calculated twice.
> 
> This patch calculate max objects of zspage at the begin, and pass
> the value to can_merge() to decide whether the class can be merged.
> 
> Also this patch remove function get_maxobj_per_zspage(), as there
> is no other place to call this funtion.
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
