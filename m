Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B4CF66B01DA
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 10:46:12 -0400 (EDT)
Received: by pvg6 with SMTP id 6so740464pvg.14
        for <linux-mm@kvack.org>; Wed, 16 Jun 2010 07:46:11 -0700 (PDT)
Date: Wed, 16 Jun 2010 23:46:05 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/9] oom: rename badness() to oom_badness()
Message-ID: <20100616144605.GB9278@barrios-desktop>
References: <20100616201948.72D7.A69D9226@jp.fujitsu.com>
 <20100616202920.72DA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100616202920.72DA.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 16, 2010 at 08:31:20PM +0900, KOSAKI Motohiro wrote:
> 
> badness() is wrong name because it's too generic name. rename it.
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
