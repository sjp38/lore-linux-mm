Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id D4D656B0070
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 17:17:59 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so6377124ghr.14
        for <linux-mm@kvack.org>; Tue, 19 Jun 2012 14:17:58 -0700 (PDT)
Message-ID: <4FE0EC86.706@gmail.com>
Date: Tue, 19 Jun 2012 17:17:58 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [resend][PATCH] mm, vmscan: fix do_try_to_free_pages() livelock
References: <1339661592-3915-1-git-send-email-kosaki.motohiro@gmail.com> <20120614145716.GA2097@barrios> <CAHGf_=qcA5OfuNgk0BiwyshcLftNWoPfOO_VW9H6xQTX2tAbuA@mail.gmail.com> <4FDAE3CC.60801@kernel.org> <CAJd=RBBSa2TuRDVGrY9JT9m3K68N1LWiZKyo3Y1mdQRo5TxBLQ@mail.gmail.com>
In-Reply-To: <CAJd=RBBSa2TuRDVGrY9JT9m3K68N1LWiZKyo3Y1mdQRo5TxBLQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Nick Piggin <npiggin@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> Who left comment on unreclaimable there, and why?
> 		/*
> 		 * balance_pgdat() skips over all_unreclaimable after
> 		 * DEF_PRIORITY. Effectively, it considers them balanced so
> 		 * they must be considered balanced here as well if kswapd
> 		 * is to sleep
> 		 */

Thank you for finding this! I'll fix.



> BTW, are you still using prefetch_prev_lru_page?

No. we should kill it. ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
