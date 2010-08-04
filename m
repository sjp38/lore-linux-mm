Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 22041620138
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 07:49:47 -0400 (EDT)
Date: Wed, 4 Aug 2010 19:49:33 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Over-eager swapping
Message-ID: <20100804114933.GA13527@localhost>
References: <20100802124734.GI2486@arachsys.com>
 <AANLkTinnWQA-K6r_+Y+giEC9zs-MbY6GFs8dWadSq0kh@mail.gmail.com>
 <20100803033108.GA23117@arachsys.com>
 <AANLkTinjmZOOaq7FgwJOZ=UNGS8x8KtQWZg6nv7fqJMe@mail.gmail.com>
 <20100803042835.GA17377@localhost>
 <20100803214945.GA2326@arachsys.com>
 <20100804022148.GA5922@localhost>
 <AANLkTi=wRPXY9BTuoCe_sDCwhnRjmmwtAf_bjDKG3kXQ@mail.gmail.com>
 <20100804032400.GA14141@localhost>
 <20100804095811.GC2326@arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100804095811.GC2326@arachsys.com>
Sender: owner-linux-mm@kvack.org
To: Chris Webb <chris@arachsys.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 04, 2010 at 05:58:12PM +0800, Chris Webb wrote:
> Wu Fengguang <fengguang.wu@intel.com> writes:
> 
> > This is interesting. Why is it waiting for 1m here? Are there high CPU
> > loads? Would you do a
> > 
> >         echo t > /proc/sysrq-trigger
> > 
> > and show us the dmesg?
> 
> Annoyingly, magic-sysrq isn't compiled in on these kernels. Is there another
> way I can get this info for you? Replacing the kernels on the machines is a
> painful job as I have to give the clients running on them quite a bit of
> notice of the reboot, and I haven't been able to reproduce the problem on a
> test machine.

Maybe turn off KSM? It helps to isolate problems. It's a relative new
and complex feature after all.

> I also think the swap use is much better following a reboot, and only starts
> to spiral out of control after the machines have been running for a week or
> so.

Something deteriorates over long time.. It may take time to catch this bug..

> However, your suggestion is right that the CPU loads on these machines are
> typically quite high. The large number of kvm virtual machines they run mean
> thatl oads of eight or even sixteen in /proc/loadavg are not unusual, and
> these are higher when there's swap than after it has been removed. I assume
> this is mostly because of increased IO wait, as this number increases
> significantly in top.

iowait = CPU (idle) waiting for disk IO

So iowait means not CPU load, but somehow disk load :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
