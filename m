From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [patch 0/3] activate pages in batch
References: <20081022225006.010250557@saeurebad.de>
	<20081023104002.1CEA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Date: Thu, 23 Oct 2008 04:00:35 +0200
In-Reply-To: <20081023104002.1CEA.KOSAKI.MOTOHIRO@jp.fujitsu.com> (KOSAKI
	Motohiro's message of "Thu, 23 Oct 2008 10:41:36 +0900 (JST)")
Message-ID: <87prlsjcjg.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> writes:

> Hi, Hannes
>
>> Instead of re-acquiring the highly contented LRU lock on every single
>> page activation, deploy an extra pagevec to do page activation in
>> batch.
>
> Do you have any mesurement result?

Not yet, sorry.

Spinlocks are no-ops on my architecture, though, so the best I can come
up with is results from emulating an SMP machine, would that be okay?

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
