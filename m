Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B8D6F6B005C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 01:28:36 -0500 (EST)
Message-ID: <496ED76D.6070000@cn.fujitsu.com>
Date: Thu, 15 Jan 2009 14:27:57 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] [PATCH] memcg: fix infinite loop
References: <496ED2B7.5050902@cn.fujitsu.com> <20090115151657.84eb1a03.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090115151657.84eb1a03.nishimura@mxp.nes.nec.co.jp>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura wrote:
> On Thu, 15 Jan 2009 14:07:51 +0800, Li Zefan <lizf@cn.fujitsu.com> wrote:
>> 1. task p1 is in /memcg/0
>> 2. p1 does mmap(4096*2, MAP_LOCKED)
>> 3. echo 4096 > /memcg/0/memory.limit_in_bytes
>>
>> The above 'echo' will never return, unless p1 exited or freed the memory.
>> The cause is we can't reclaim memory from p1, so the while loop in
>> mem_cgroup_resize_limit() won't break.
>>
> But it can be interrupted, right ?
> 

So we expect users track how long does this operation take, and send some
signal to stop it if it takes a long time ? I don't think this is user-friendly..

> I don't think this would be a big problem.
> 

It's a problem, though it may not be a big problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
