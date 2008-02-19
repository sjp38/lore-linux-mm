Date: Tue, 19 Feb 2008 16:09:07 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] the proposal of improve page reclaim by throttle
In-Reply-To: <200802191735.00222.nickpiggin@yahoo.com.au>
References: <20080219134715.7E90.KOSAKI.MOTOHIRO@jp.fujitsu.com> <200802191735.00222.nickpiggin@yahoo.com.au>
Message-Id: <20080219160711.7E99.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Nick,

> Yeah this is definitely needed and a nice result.
> 
> I'm worried about a) placing a global limit on parallelism, and b)
> placing a limit on parallelism at all.

sorry, i don't understand yet.
a) and b) have any relation?

> 
> I think it should maybe be a per-zone thing...
> 
> What happens if you make it a per-zone mutex, and allow just a single
> process to reclaim pages from a given zone at a time? I guess that is
> going to slow down throughput a little bit in some cases though...

That makes sense.

OK.
I'll repost after 2-3 days.

Thanks.

- kosaki


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
