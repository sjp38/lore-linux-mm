Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 003E26B0069
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 11:21:06 -0400 (EDT)
Received: by yhr47 with SMTP id 47so2000472yhr.14
        for <linux-mm@kvack.org>; Thu, 14 Jun 2012 08:21:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4fd9db8d.c4e2440a.6bf6.4a46@mx.google.com>
References: <4fd9db8d.c4e2440a.6bf6.4a46@mx.google.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Thu, 14 Jun 2012 11:20:45 -0400
Message-ID: <CAHGf_=oUYKaGfYHzpZdTwxSPKLPa46gB7bVZR+R0JogofrPWZw@mail.gmail.com>
Subject: Re: [PATCH] mm: fix page reclaim comment error
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "[A" <liwp.linux@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, trivial@kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>

On Thu, Jun 14, 2012 at 8:38 AM, [A <liwp.linux@gmail.com> wrote:
> From: Wanpeng Li <liwp.linux@gmail.com>
>
> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
>
> Since there are five lists in LRU cache, the array nr in get_scan_count
> should be:
>
> nr[0] = anon inactive pages to scan; nr[1] = anon active pages to scan
> nr[2] = file inactive pages to scan; nr[3] = file active pages to scan
>
> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
