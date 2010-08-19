Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E16FD6B02AC
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 11:29:44 -0400 (EDT)
Received: by pxi5 with SMTP id 5so870953pxi.14
        for <linux-mm@kvack.org>; Thu, 19 Aug 2010 08:29:45 -0700 (PDT)
Date: Fri, 20 Aug 2010 00:29:37 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 1/2] oom: fix NULL pointer dereference
Message-ID: <20100819152937.GE6805@barrios-desktop>
References: <20100819194707.5FC4.A69D9226@jp.fujitsu.com>
 <20100819195310.5FC7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100819195310.5FC7.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 19, 2010 at 07:53:31PM +0900, KOSAKI Motohiro wrote:
> commit b940fd7035 (oom: remove unnecessary code and cleanup) added
> unnecessary NULL pointer dereference. remove it.
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
