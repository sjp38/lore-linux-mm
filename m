Date: Wed, 25 Jun 2008 16:29:10 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] prevent incorrect oom under split_lru
In-Reply-To: <28c262360806242358q348e18a4vb9c48b4b853b0384@mail.gmail.com>
References: <28c262360806242356n3f7e02abwfee1f6acf0fd2c61@mail.gmail.com> <28c262360806242358q348e18a4vb9c48b4b853b0384@mail.gmail.com>
Message-Id: <20080625161753.D848.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: MinChan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, akpm@linux-foundation.org, Takenori Nagano <t-nagano@ah.jp.nec.com>
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
> with my mistake, I omit following message. :(
> 
> So, we need cut-off mechanism to reduce application latency.
> So In my opinion, If we modify some code of Takenori's patch, we can
> apply his idea to prevent latency probelm.

Yup.
Agreed with latency is as important as throughput.

if anyone explain that patch have reduce some latency and 
no throughput degression by benchmark result,
I have no objection, Of cource.

Can you post any performance result?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
