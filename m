Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 2B19C6B004F
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 22:42:00 -0500 (EST)
Received: by obbta7 with SMTP id ta7so6545061obb.14
        for <linux-mm@kvack.org>; Wed, 18 Jan 2012 19:41:59 -0800 (PST)
Date: Wed, 18 Jan 2012 19:41:44 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [BUG] kernel BUG at mm/memcontrol.c:1074!
In-Reply-To: <20120119122354.66eb9820.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LSU.2.00.1201181932040.2287@eggly.anvils>
References: <1326949826.5016.5.camel@lappy> <20120119122354.66eb9820.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, hannes <hannes@cmpxchg.org>, mhocko@suse.cz, bsingharora@gmail.com, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu, 19 Jan 2012, KAMEZAWA Hiroyuki wrote:
> On Thu, 19 Jan 2012 07:10:26 +0200
> Sasha Levin <levinsasha928@gmail.com> wrote:
> 
> > Hi all,
> > 
> > During testing, I have triggered the OOM killer by mmap()ing a large block of memory. The OOM kicked in and tried to kill the process:
> > 
> 
> two questions.
> 
> 1. What is the kernel version  ?

It says 3.2.0-next-20120119-sasha #128

> 2. are you using memcg moutned ?

I notice that, unlike Linus's git, this linux-next still has
mm-isolate-pages-for-immediate-reclaim-on-their-own-lru.patch in.

I think that was well capable of oopsing in mem_cgroup_lru_del_list(),
since it didn't always know which lru a page belongs to.

I'm going to be optimistic and assume that was the cause.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
