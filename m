Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3749D6B0089
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 14:56:28 -0500 (EST)
Subject: Re: Memory overcommit
Received: by mail-bw0-f215.google.com with SMTP id 7so7287751bwz.6
        for <linux-mm@kvack.org>; Mon, 02 Nov 2009 11:56:27 -0800 (PST)
Message-ID: <4AEF3968.6080903@gmail.com>
Date: Mon, 02 Nov 2009 20:56:24 +0100
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
References: <alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com> <4AE846E8.1070303@gmail.com> <alpine.DEB.2.00.0910281307370.23279@chino.kir.corp.google.com> <4AE9068B.7030504@gmail.com> <alpine.DEB.2.00.0910290132320.11476@chino.kir.corp.google.com> <4AE97618.6060607@gmail.com> <alpine.DEB.2.00.0910291225460.27732@chino.kir.corp.google.com> <4AEAEFDD.5060009@gmail.com> <20091030141250.GQ9640@random.random> <4AEAFB08.8050305@gmail.com> <20091030151544.GR9640@random.random>
In-Reply-To: <20091030151544.GR9640@random.random>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:

> On Fri, Oct 30, 2009 at 03:41:12PM +0100, Vedran FuraA? wrote:
>> Oh... so this is because apps "reserve" (Committed_AS?) more then they
>> currently need.
> 
> They don't actually reserve, they end up "reserving" if overcommit is
> set to 2 (OVERCOMMIT_NEVER)... Apps aren't reserving, more likely they
> simply avoid a flood of mmap when a single one is enough to map an
> huge MAP_PRIVATE region like shared libs that you may only execute
> partially (this is why total_vm is usually much bigger than real ram
> mapped by pagetables represented in rss). But those shared libs are
> 99% pageable and they don't need to stay in swap or ram, so
> overcommit-as greatly overstimates the actual needs even if shared lib
> loading wouldn't be 64bit optimized (i.e. large and a single one).

Thanks for info!

>> A the time of "malloc: Cannot allocate memory":
>>
>> CommitLimit:     3364440 kB
>> Committed_AS:    3240200 kB
>>
>> So probably everything is ok (and free is misleading). Overcommit is
>> unfortunately necessary if I want to be able to use all my memory.
> 
> Add more swap.

I don't use swap. With current prices of RAM, swap is history, at least
for desktops. I hate when e.g. firefox gets swapped out if I don't use
it for a while. Removing swap decreased desktop latencies drastically.
And I don't care much if I'll loose 100MB of potential free memory that
could be used for disk cache...

Regards.

Vedran

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
