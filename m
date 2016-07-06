Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id B3FE8828E1
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 22:39:43 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id wu1so97311693obb.0
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 19:39:43 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id h131si1496442ioa.82.2016.07.05.19.39.42
        for <linux-mm@kvack.org>;
        Tue, 05 Jul 2016 19:39:43 -0700 (PDT)
Date: Wed, 6 Jul 2016 11:40:15 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 3/8] mm/zsmalloc: take obj index back from
 find_alloced_obj
Message-ID: <20160706024015.GD13566@bbox>
References: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
 <1467614999-4326-3-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
In-Reply-To: <1467614999-4326-3-git-send-email-opensource.ganesh@gmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com

On Mon, Jul 04, 2016 at 02:49:54PM +0800, Ganesh Mahendran wrote:
> the obj index value should be updated after return from
> find_alloced_obj() to avoid CPU buring caused by unnecessary
> object scanning.
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
