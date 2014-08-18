Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7FD4B6B0036
	for <linux-mm@kvack.org>; Sun, 17 Aug 2014 20:06:11 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id ho1so2919985wib.14
        for <linux-mm@kvack.org>; Sun, 17 Aug 2014 17:06:11 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id iz10si14120223wic.40.2014.08.17.17.06.07
        for <linux-mm@kvack.org>;
        Sun, 17 Aug 2014 17:06:09 -0700 (PDT)
Date: Mon, 18 Aug 2014 09:06:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v14 5/8] s390: add pmd_[dirty|mkclean] for THP
Message-ID: <20140818000630.GA32075@bbox>
References: <1407981212-17818-1-git-send-email-minchan@kernel.org>
 <1407981212-17818-6-git-send-email-minchan@kernel.org>
 <20140814091614.4a0d5178@mschwide>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20140814091614.4a0d5178@mschwide>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Heiko Carstens <heiko.carstens@de.ibm.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-s390@vger.kernel.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>

Hello,

On Thu, Aug 14, 2014 at 09:16:14AM +0200, Martin Schwidefsky wrote:
> On Thu, 14 Aug 2014 10:53:29 +0900
> Minchan Kim <minchan@kernel.org> wrote:
> 
> > MADV_FREE needs pmd_dirty and pmd_mkclean for detecting recent
> > overwrite of the contents since MADV_FREE syscall is called for
> > THP page but for s390 pmds only referenced bit is available
> > because there is no free bit left in the pmd entry for the
> > software dirty bit so this patch adds dumb pmd_dirty which
> > returns always true by suggesting by Martin.
> > 
> > They finally find a solution in future.
> > http://marc.info/?l=linux-api&m=140440328820808&w=2
> 
> The solution is already there, see git commit 152125b7a882df36.
> You can drop this patch.

Thanks for the heads up. I will drop it in next spin.
> 
> -- 
> blue skies,
>    Martin.
> 
> "Reality continues to ruin my life." - Calvin.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
