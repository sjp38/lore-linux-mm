Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 068286B006C
	for <linux-mm@kvack.org>; Sun, 28 Oct 2012 22:03:25 -0400 (EDT)
Date: Mon, 29 Oct 2012 11:09:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 5/5] mm, highmem: get virtual address of the page using
 PKMAP_ADDR()
Message-ID: <20121029020910.GJ15767@bbox>
References: <Yes>
 <1351451576-2611-1-git-send-email-js1304@gmail.com>
 <1351451576-2611-6-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1351451576-2611-6-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Oct 29, 2012 at 04:12:56AM +0900, Joonsoo Kim wrote:
> In flush_all_zero_pkmaps(), we have an index of the pkmap associated the page.
> Using this index, we can simply get virtual address of the page.
> So change it.
> 
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
