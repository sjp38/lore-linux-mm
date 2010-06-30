Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0F0546006F7
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 10:10:12 -0400 (EDT)
Received: by pzk33 with SMTP id 33so29008pzk.14
        for <linux-mm@kvack.org>; Wed, 30 Jun 2010 07:10:10 -0700 (PDT)
Date: Wed, 30 Jun 2010 23:10:03 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 06/11] oom: kill duplicate OOM_DISABLE check
Message-ID: <20100630141003.GD15644@barrios-desktop>
References: <20100630172430.AA42.A69D9226@jp.fujitsu.com>
 <20100630183019.AA59.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100630183019.AA59.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 30, 2010 at 06:31:00PM +0900, KOSAKI Motohiro wrote:
> 
> select_bad_process() and badness() have the same OOM_DISABLE check.
> This patch kill one.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
