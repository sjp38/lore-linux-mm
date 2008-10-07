Date: Tue, 7 Oct 2008 13:17:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: split-lru performance mesurement part2
Message-Id: <20081007131719.8bb24698.akpm@linux-foundation.org>
In-Reply-To: <20081007231851.3B88.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081003153810.5dd0a33e@bree.surriel.com>
	<20081004232549.CE53.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20081007231851.3B88.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: riel@redhat.com, Lee.Schermerhorn@hp.com, a.p.zijlstra@chello.nl, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, dlezcano@fr.ibm.com, penberg@cs.helsinki.fi, neilb@suse.de, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Tue,  7 Oct 2008 23:26:54 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Hi
> 
> > yup,
> > I know many people want to other benchmark result too.
> > I'll try to mesure other bench at next week.
> 
> I ran another benchmark today.
> I choice dbench because dbench is one of most famous and real workload like i/o benchmark.
> 
> 
> % dbench client.txt 4000
> 
> mainline:  Throughput 13.4231 MB/sec  4000 clients  4000 procs  max_latency=1421988.159 ms
> mmotm(*):  Throughput  7.0354 MB/sec  4000 clients  4000 procs  max_latency=2369213.380 ms
> 
> (*) mmotm 2/Oct + Hugh's recently slub fix
> 
> 
> Wow!
> mmotm is slower than mainline largely (about half performance).
> 
> Therefore, I mesured it on "mainline + split-lru(only)" build.
> 
> 
> mainline + split-lru(only): Throughput 14.4062 MB/sec  4000 clients  4000 procs  max_latency=1152231.896 ms
> 
> 
> OK!
> split-lru outperform mainline from viewpoint of both throughput and latency :)
> 
> 
> 
> However, I don't understand why this regression happend.

erk.

dbench is pretty chaotic and it could be that a good change causes
dbench to get worse.  That's happened plenty of times in the past.


> Do you have any suggestion?


One of these:

vmscan-give-referenced-active-and-unmapped-pages-a-second-trip-around-the-lru.patch
vm-dont-run-touch_buffer-during-buffercache-lookups.patch

perhaps?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
