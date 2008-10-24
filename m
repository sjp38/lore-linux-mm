From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [patch] mm: more likely reclaim MADV_SEQUENTIAL mappings II
References: <878wsigp2e.fsf_-_@saeurebad.de> <87zlkuj10z.fsf@saeurebad.de>
	<20081024213527.492B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Date: Fri, 24 Oct 2008 16:02:17 +0200
In-Reply-To: <20081024213527.492B.KOSAKI.MOTOHIRO@jp.fujitsu.com> (KOSAKI
	Motohiro's message of "Fri, 24 Oct 2008 21:55:44 +0900 (JST)")
Message-ID: <87skqmhz12.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Linux MM Mailing List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> writes:

> I'm sorry for late responce.
> but I'd like to you know this mesurement need spent long time in my
> time.

No problem, I really appreciate this.

> Hanns, Actually I recomend to spent a bit more time for proper
> benchmark design and settings.

I shall dig into it.

> 	Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Thanks a lot,

        Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
