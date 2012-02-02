Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 0BE296B13F0
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 19:00:45 -0500 (EST)
Received: by qcsd16 with SMTP id d16so1246198qcs.14
        for <linux-mm@kvack.org>; Wed, 01 Feb 2012 16:00:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120201135442.0491d882.kamezawa.hiroyu@jp.fujitsu.com>
References: <CALWz4iypV=k-7gVcFx=OsHJsWcUzQsfEoYbQ4+ySQoTob_PWcQ@mail.gmail.com>
	<20120201135442.0491d882.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 1 Feb 2012 16:00:44 -0800
Message-ID: <CALWz4iwHq6rX72gv4XMVAviqtFT8mjW2OgCBtjU6AVX94YsnGg@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] [ATTEND] memcg: soft limit reclaim (continue) and others
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Tue, Jan 31, 2012 at 8:54 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 31 Jan 2012 11:59:40 -0800
> Ying Han <yinghan@google.com> wrote:
>
>> some topics that I would like to discuss this year:
>>
>> 1) we talked about soft limit redesign during last LSF, and there are
>> quite a lot of efforts and changes being pushed after that. I would
>> like to take this time to sync-up our efforts and also discuss some of
>> the remaining issues.
>>
>> Discussion from last year :
>> http://www.spinics.net/lists/linux-mm/msg17102.html and lots of
>> changes have been made since then.
>>
>
> Yes, it seems re-sync is required.
>
>> 2) memory.stat, this is the main stat file for all memcg statistics.
>> are we planning to keep stuff it for something like per-memcg
>> vmscan_stat, vmstat or not.
>>
>
> Could you calrify ? Do you want to have another stat file like memory.vmstat ?

I was planning to add per-memcg vmstat file at one point, but there
were discussions of just extending memory.stat. I don't mind to have
very long memory.stat file since my screen is now vertical anyway.
Just want to sync-up our final decision for later patches.

>
>
>> 3) root cgroup now becomes quite interesting, especially after we
>> bring back the exclusive lru to root. To be more specific, root cgroup
>> now is like a sink which contains pages allocated on its own, and also
>> pages being re-parented. Those pages won't be reclaimed until there is
>> a global pressure, and we want to see anything we can do better.
>>
>
> I'm sorry I can't get your point.
>
> Do you think it's better to shrink root mem cgroup LRU even if there are
> no memory pressure ?

The benefit will be reduced memory reclaim latency.

That is something I am thinking now. Now what we do in removing a
cgroup is re-parent all the pages, and root become a sink with all the
left-over pages. There is no external memory pressure to push those
pages out unless global reclaim, and the machine size will look
smaller and smaller on admin perspective.

I am thinking to use some existing reclaim mechanism to apply pressure
on those pages inside the kernel.

--Ying

> Or Do you think root memcg should have some soft limit and should be
> reclaimed in the same schedule line as other memcgs ? The benefit will be fairness.
>
> or other idea ?
>
> Thanks,
> -Kame
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
