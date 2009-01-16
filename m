Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 18C876B0044
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 02:01:21 -0500 (EST)
Message-ID: <49703099.4090904@cn.fujitsu.com>
Date: Fri, 16 Jan 2009 15:00:41 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [BUG] memcg: panic when rmdir()
References: <497025E8.8050207@cn.fujitsu.com>	<20090116151900.f86cc1a3.kamezawa.hiroyu@jp.fujitsu.com>	<49702827.2060207@cn.fujitsu.com> <20090116153059.64bc5b45.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090116153059.64bc5b45.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Fri, 16 Jan 2009 14:24:39 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
>> KAMEZAWA Hiroyuki wrote:
>>> On Fri, 16 Jan 2009 14:15:04 +0800
>>> Li Zefan <lizf@cn.fujitsu.com> wrote:
>>>
>>>> Found this when testing memory resource controller, can be triggered
>>>> with:
>>>> - CONFIG_CGROUP_MEM_RES_CTLR_SWAP=n
>>>> - or CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y
>>>> - or CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y && boot with noswapaccount
>>>>
>>>> # mount -t cgroup -o memory xxx /mnt
>>>> # mkdir /mnt/0
>>>> # for pid in `cat /mnt/tasks`; do echo $pid > /mnt/0/tasks; done
>>>> # echo "low limit" > /mnt/0/tasks
>>>> # do whatever to allocate some memory
>>>> # swapoff -a
>>>> killed (by OOM)
>>>> # for pid in `cat /mnt/0/tasks`; do echo $pid > /mnt/tasks; done
>>>> # rmdir /mnt/0
>>>>
>>> Isn't this a problem Nishimura fixed today ?
>>>
>> Are you sure?
>>
> Sorry, I didn't see BUG! line in you log.
> 

I've tested with Nishimura's patch applied, and as is expected, this bug
is totally different from the one Nishimura has fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
