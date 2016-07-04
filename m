Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DFE376B0005
	for <linux-mm@kvack.org>; Sun,  3 Jul 2016 20:10:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e189so362179958pfa.2
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 17:10:31 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id ae6si801107pad.92.2016.07.03.17.10.29
        for <linux-mm@kvack.org>;
        Sun, 03 Jul 2016 17:10:30 -0700 (PDT)
Date: Mon, 4 Jul 2016 09:11:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 8/8] mm/zsmalloc: use helper to clear page->flags bit
Message-ID: <20160704001112.GG19044@bbox>
References: <1467355266-9735-1-git-send-email-opensource.ganesh@gmail.com>
 <1467355266-9735-8-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
In-Reply-To: <1467355266-9735-8-git-send-email-opensource.ganesh@gmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com

On Fri, Jul 01, 2016 at 02:41:06PM +0800, Ganesh Mahendran wrote:
> user ClearPagePrivate/ClearPagePrivate2 helper to clear
> PG_private/PG_private_2 in page->flags
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
