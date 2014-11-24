Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0F31E800CA
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 02:49:16 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id fp1so9214930pdb.14
        for <linux-mm@kvack.org>; Sun, 23 Nov 2014 23:49:15 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id fa4si19846223pbc.238.2014.11.23.23.49.13
        for <linux-mm@kvack.org>;
        Sun, 23 Nov 2014 23:49:14 -0800 (PST)
Date: Mon, 24 Nov 2014 16:49:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm/zsmalloc: avoid duplicate assignment of prev_class
Message-ID: <20141124074930.GA22312@bbox>
References: <1416577403-7887-1-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1416577403-7887-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mahendran Ganesh <opensource.ganesh@gmail.com>
Cc: ngupta@vflare.org, iamjoonsoo.kim@lge.com, ddstreet@ieee.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Nov 21, 2014 at 09:43:23PM +0800, Mahendran Ganesh wrote:
> In zs_create_pool(), prev_class is assigned (ZS_SIZE_CLASSES - 1)
> times. And the prev_class only references to the previous size_class.
> So we do not need unnecessary assignement.
> 
> This patch assigns *prev_class* when a new size_class structure
> is allocated and uses prev_class to check whether the first class
> has been allocated.
> 
> Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
