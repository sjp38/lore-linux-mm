Date: Thu, 26 Jun 2008 09:36:01 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] prevent incorrect oom under split_lru
In-Reply-To: <1214395885.15232.17.camel@twins>
References: <28c262360806242356n3f7e02abwfee1f6acf0fd2c61@mail.gmail.com> <1214395885.15232.17.camel@twins>
Message-Id: <20080626093338.FCF7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com, MinChan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, akpm@linux-foundation.org, Takenori Nagano <t-nagano@ah.jp.nec.com>
List-ID: <linux-mm.kvack.org>

> > But if such emergency happen in embedded system, application can't be
> > executed for some time.
> > I am not sure how long time it take.
> > But In some application, schedule period is very important than memory
> > reclaim latency.
> > 
> > Now, In your patch, when such emergency happen, it continue to reclaim
> > page until it will scan entire page of lru list.
> > It
> 
> IMHO embedded real-time apps shoud mlockall() and not do anything that
> can result in memory allocations in their fast (deterministic) paths.

Indeed.

> The much more important case is desktop usage - that is where we run non
> real-time code, but do expect 'low' latency due to user-interaction.
> 
> >From hitting swap on my 512M laptop (rather frequent occurance) I know
> we can do better here,..

nice suggestion.
thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
