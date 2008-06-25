Date: Wed, 25 Jun 2008 15:08:59 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] prevent incorrect oom under split_lru
In-Reply-To: <28c262360806242259k3ac308c4n7cee29b72456e95b@mail.gmail.com>
References: <20080624092824.4f0440ca@bree.surriel.com> <28c262360806242259k3ac308c4n7cee29b72456e95b@mail.gmail.com>
Message-Id: <20080625150141.D845.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: MinChan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, akpm@linux-foundation.org, Takenori Nagano <t-nagano@ah.jp.nec.com>
List-ID: <linux-mm.kvack.org>

Hi Kim-san,

> >> So, if priority==0, We should try to reclaim all page for prevent OOM.
> >
> > You are absolutely right.  Good catch.
> 
> I have a concern about application latency.
> If lru list have many pages, it take a very long time to scan pages.
> More system have many ram, More many time to scan pages.

No problem.

priority==0 indicate emergency.
it doesn't happend on typical workload.


> Of course I know this is trade-off between memory efficiency VS latency.
> But In embedded, some application think latency is more important
> thing than memory efficiency.
> We need some mechanism to cut off scanning time.
> 
> I think Takenori Nagano's "memory reclaim more efficiently patch" is
> proper to reduce application latency in this case If we modify some
> code.

I think this is off-topic.

but Yes.
both my page reclaim throttle and nagano-san's patch provide 
reclaim cut off mechanism.


and more off-topic,
nagano-san's patch improve only priority==12.
So, typical embedded doesn't improve so big because 
embedded system does't have so large memory.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
