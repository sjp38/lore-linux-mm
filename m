Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A330A6B01F2
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 06:25:33 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2UAPUSi006872
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 30 Mar 2010 19:25:31 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B444945DE4E
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 19:25:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9412445DD70
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 19:25:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 81CF1E38003
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 19:25:30 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 35CDEE08004
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 19:25:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
In-Reply-To: <28c262361003300317g6df68fc6m4385cfbe3e8a1b04@mail.gmail.com>
References: <20100330055304.GA2983@sli10-desk.sh.intel.com> <28c262361003300317g6df68fc6m4385cfbe3e8a1b04@mail.gmail.com>
Message-Id: <20100330192219.328C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 30 Mar 2010 19:25:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

> Yes. It made subtle change.
> But we should not depend that change.
> Current logic seems to be good and clear than old.
> I think you were lucky at that time by not-good and not-clear logic.
> 
> BTW, How about this?

Unfortunatelly, memcg need your removed code. if removed, swapping out
might happen although sc->may_swap==0 when priority==0.

Please give me little investigate time.



> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 79c8098..f0df563 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1646,11 +1646,6 @@ static void shrink_zone(int priority, struct zone *zone,
>                 int file = is_file_lru(l);
>                 unsigned long scan;
> 
> -               if (percent[file] == 0) {
> -                       nr[l] = 0;
> -                       continue;
> -               }
> -
>                 scan = zone_nr_lru_pages(zone, sc, l);
>                 if (priority) {
>                         scan >>= priority;
> 
> 
> 
> 
> -- 
> Kind regards,
> Minchan Kim
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a hrefmailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
