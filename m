Date: Fri, 22 Aug 2008 10:05:45 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/2] Show quicklist at meminfo
In-Reply-To: <2f11576a0808210036icd9b61eue58049f15381bcc8@mail.gmail.com>
References: <20080820113559.f559a411.akpm@linux-foundation.org> <2f11576a0808210036icd9b61eue58049f15381bcc8@mail.gmail.com>
Message-Id: <20080822100049.F562.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org, tokunaga.keiich@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> > quicklist_total_size() is racy against cpu hotplug.  That's OK for
> > /proc/meminfo purposes (occasional transient inaccuracy?), but will it
> > crash?  Not in the current implementation of per_cpu() afaict, but it
> > might crash if we ever teach cpu hotunplug to free up the percpu
> > resources.
> 
> First, Quicklist doesn't concern to cpu hotplug at all.
> it is another quicklist problem.
> 
> Next, I think it doesn't cause crash. but I haven't any test.
> So, I'll test cpu hotplug/unplug testing today.
> 
> I'll report result tommorow.

OK.
I ran cpu hotplug/unplug coutinuous workload over 12H.
then, system crash doesn't happend.

So, I believe my patch is cpu unplug safe.


test method
--------------------------------------------------------------
1. open 7 terminal and following script run on each console.

CPU=cpuXXX; while true; do echo 0 > /sys/devices/system/cpu/$CPU/online; echo 1 > /sys/devi
ces/system/cpu/$CPU/online;done

2. open another console, following command run.

watch -n 1 cat /proc/meminfo



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
