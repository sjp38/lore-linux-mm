Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8BF556B0201
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 23:30:36 -0400 (EDT)
Message-ID: <4BBE9FAA.7000907@cn.fujitsu.com>
Date: Fri, 09 Apr 2010 11:31:54 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] fix cgroup procs documentation
References: <20100409121143.9610dc8f.kamezawa.hiroyu@jp.fujitsu.com>	<4BBE9D58.2010602@cn.fujitsu.com> <20100409122001.60967001.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100409122001.60967001.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, stable@kernel.org, Ben Blum <bblum@andrew.cmu.edu>
List-ID: <linux-mm.kvack.org>

Cc: Ben Blum

KAMEZAWA Hiroyuki wrote:
> On Fri, 09 Apr 2010 11:22:00 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
>> KAMEZAWA Hiroyuki wrote:
>>> 2.6.33's Documentation has the same wrong information. So, I CC'ed to stable.
>>> If people believe this information, they'll usr cgroup.procs file and will
>>> see cgroup doesn'w work as expected.
>>> The patch itself is against -mm.
>>>
>>> ==
>>> Writing to cgroup.procs is not supported now.
>>>
>>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>> ---
>>>  Documentation/cgroups/cgroups.txt |    3 +--
>>>  1 file changed, 1 insertion(+), 2 deletions(-)
>>>
>>> Index: mmotm-temp/Documentation/cgroups/cgroups.txt
>>> ===================================================================
>>> --- mmotm-temp.orig/Documentation/cgroups/cgroups.txt
>>> +++ mmotm-temp/Documentation/cgroups/cgroups.txt
>>> @@ -235,8 +235,7 @@ containing the following files describin
>>>   - cgroup.procs: list of tgids in the cgroup.  This list is not
>>>     guaranteed to be sorted or free of duplicate tgids, and userspace
>>>     should sort/uniquify the list if this property is required.
>>> -   Writing a tgid into this file moves all threads with that tgid into
>>> -   this cgroup.
>>> +   This is a read-only file, now.
>> I think the better wording is "for now". :)
>>
> ok. BTW, does anyone work on this ?

It was Ben Blum, don't know if he's still working on it.

> ==
> 
> Writing to cgroup.procs is not supported now.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Li Zefan <lizf@cn.fujitsu.com>

> ---
>  Documentation/cgroups/cgroups.txt |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> Index: mmotm-temp/Documentation/cgroups/cgroups.txt
> ===================================================================
> --- mmotm-temp.orig/Documentation/cgroups/cgroups.txt
> +++ mmotm-temp/Documentation/cgroups/cgroups.txt
> @@ -235,8 +235,7 @@ containing the following files describin
>   - cgroup.procs: list of tgids in the cgroup.  This list is not
>     guaranteed to be sorted or free of duplicate tgids, and userspace
>     should sort/uniquify the list if this property is required.
> -   Writing a tgid into this file moves all threads with that tgid into
> -   this cgroup.
> +   This is a read-only file, for now.
>   - notify_on_release flag: run the release agent on exit?
>   - release_agent: the path to use for release notifications (this file
>     exists in the top cgroup only)
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
