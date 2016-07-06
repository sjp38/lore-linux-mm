Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1FC12828E1
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 22:40:53 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id g8so284566874itb.2
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 19:40:53 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id n186si2151481ita.76.2016.07.05.19.40.51
        for <linux-mm@kvack.org>;
        Tue, 05 Jul 2016 19:40:52 -0700 (PDT)
Date: Wed, 6 Jul 2016 11:41:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 6/8] mm/zsmalloc: keep comments consistent with code
Message-ID: <20160706024136.GF13566@bbox>
References: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
 <1467614999-4326-6-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
In-Reply-To: <1467614999-4326-6-git-send-email-opensource.ganesh@gmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com

On Mon, Jul 04, 2016 at 02:49:57PM +0800, Ganesh Mahendran wrote:
> some minor change of comments:
> 1). update zs_malloc(),zs_create_pool() function header
> 2). update "Usage of struct page fields"
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
