Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 75A3D6B0005
	for <linux-mm@kvack.org>; Sun,  3 Jul 2016 19:58:08 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 143so362692119pfx.0
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 16:58:08 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id zn5si818045pac.61.2016.07.03.16.58.07
        for <linux-mm@kvack.org>;
        Sun, 03 Jul 2016 16:58:07 -0700 (PDT)
Date: Mon, 4 Jul 2016 08:58:50 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 4/8] mm/zsmalloc: use class->objs_per_zspage to get num
 of max objects
Message-ID: <20160703235850.GC19044@bbox>
References: <1467355266-9735-1-git-send-email-opensource.ganesh@gmail.com>
 <1467355266-9735-4-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
In-Reply-To: <1467355266-9735-4-git-send-email-opensource.ganesh@gmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com

On Fri, Jul 01, 2016 at 02:41:02PM +0800, Ganesh Mahendran wrote:
> num of max objects in zspage is stored in each size_class now.
> So there is no need to re-calculate it.
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
