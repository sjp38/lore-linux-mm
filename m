Received: by rv-out-0708.google.com with SMTP id f25so10904094rvb.26
        for <linux-mm@kvack.org>; Tue, 24 Jun 2008 10:35:52 -0700 (PDT)
Message-ID: <2f11576a0806241035p45a440e1gb798091ef39cffc8@mail.gmail.com>
Date: Wed, 25 Jun 2008 02:35:51 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] fix to putback_lru_page()/unevictable page handling rework v3
In-Reply-To: <1214327987.6563.22.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080621185408.E832.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080624184122.D838.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <1214327987.6563.22.camel@lts-notebook>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> 'lru' was not being set to 'UNEVICTABLE when page was, in fact,
> unevictable [really "nonreclaimable" :-)], so retry would never
> happen, and culled pages never counted.
>
> Also, redundant mem_cgroup_move_lists()--one with incorrect 'lru',
> in the case of unevictable pages--messes up memcontroller tracking [I think].

indeed.
sorry, I forgot to send this fix.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

but I still happend panic on usex and nishimura-san's cpuset migration test.
  -> http://marc.info/?l=linux-mm&m=121375647720110&w=2


I'll  investigate it tommorow.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
