Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id E3731828E1
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 22:40:30 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id x68so448073493ioi.0
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 19:40:30 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 65si1226891iow.43.2016.07.05.19.40.29
        for <linux-mm@kvack.org>;
        Tue, 05 Jul 2016 19:40:30 -0700 (PDT)
Date: Wed, 6 Jul 2016 11:41:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 5/8] mm/zsmalloc: avoid calculate max objects of
 zspage twice
Message-ID: <20160706024119.GE13566@bbox>
References: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
 <1467614999-4326-5-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
In-Reply-To: <1467614999-4326-5-git-send-email-opensource.ganesh@gmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com

On Mon, Jul 04, 2016 at 02:49:56PM +0800, Ganesh Mahendran wrote:
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
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
