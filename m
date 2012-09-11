Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 5200B6B00A5
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 02:19:59 -0400 (EDT)
Date: Tue, 11 Sep 2012 15:21:56 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: Fix compiler warning in copy_page_range
Message-ID: <20120911062156.GB15214@bbox>
References: <504C3DCF.9090702@mellanox.com>
 <1347277228-15057-1-git-send-email-haggaie@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347277228-15057-1-git-send-email-haggaie@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Haggai Eran <haggaie@mellanox.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sagi Grimberg <sagig@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>

On Mon, Sep 10, 2012 at 02:40:28PM +0300, Haggai Eran wrote:
> This patch fixes the warning about mmun_start/end used uninitialized in
> copy_page_range, by initializing them regardless of whether the notifiers are
> actually called.  It also makes sure the vm_flags in copy_page_range are only
> read once.
> 
> Cc: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Haggai Eran <haggaie@mellanox.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
