Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CE9396B0253
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 18:58:37 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id d123so224436287pfd.0
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 15:58:37 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id d11si14082972plj.282.2017.01.30.15.58.36
        for <linux-mm@kvack.org>;
        Mon, 30 Jan 2017 15:58:37 -0800 (PST)
Date: Tue, 31 Jan 2017 08:58:34 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] mm: vmpressure: fix sending wrong events on underflow
Message-ID: <20170130235834.GC7942@bbox>
References: <1485504817-3124-1-git-send-email-vinmenon@codeaurora.org>
 <1485504817-3124-2-git-send-email-vinmenon@codeaurora.org>
MIME-Version: 1.0
In-Reply-To: <1485504817-3124-2-git-send-email-vinmenon@codeaurora.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, mhocko@suse.com, riel@redhat.com, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, shashim@codeaurora.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 27, 2017 at 01:43:37PM +0530, Vinayak Menon wrote:
> At the end of a window period, if the reclaimed pages
> is greater than scanned, an unsigned underflow can
> result in a huge pressure value and thus a critical event.
> Reclaimed pages is found to go higher than scanned because
> of the addition of reclaimed slab pages to reclaimed in
> shrink_node without a corresponding increment to scanned
> pages. Minchan Kim mentioned that this can also happen in
> the case of a THP page where the scanned is 1 and reclaimed
> could be 512.
> 
> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
Acked-by: Minchan Kim <minchan@kernel.org>

Thanks for the fix up!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
