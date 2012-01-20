Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 79C556B004D
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 06:10:09 -0500 (EST)
Message-ID: <4F194B5D.6080701@parallels.com>
Date: Fri, 20 Jan 2012 15:09:17 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: linux-next: Tree for Jan 19 (mm/memcontrol.c)
References: <20120119125932.a4c67005cf6a0938558e8b36@canb.auug.org.au> <4F189A97.5080007@xenotime.net> <20120120090037.e32a119f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120120090037.e32a119f.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 01/20/2012 04:00 AM, KAMEZAWA Hiroyuki wrote:
> On Thu, 19 Jan 2012 14:35:03 -0800
> Randy Dunlap<rdunlap@xenotime.net>  wrote:
>
>> On 01/18/2012 05:59 PM, Stephen Rothwell wrote:
>>> Hi all,
>>>
>>> Changes since 20120118:
>>
>>
>> on i386:
>>
>> mm/built-in.o:(__jump_table+0x8): undefined reference to `memcg_socket_limit_enabled'
>> mm/built-in.o:(__jump_table+0x14): undefined reference to `memcg_socket_limit_enabled'
>>
>>
>> Full randconfig file is attached.
>>
>
> Thank you. Forwarding this to Costa.
>
> Thanks,
> -Kame
>
Oh dear lord... So what happened here, is that I moved this code out of 
CONFIG_INET to fix another problem, and forgot that it needed to be 
wrapped under CONFIG_NET instead.

It is not an excuse, but I did compiled it over at least 6 random 
configs, and thought it was okay. I guess so many things select 
CONFIG_NET that it ends up being hard to generate a config without it.

I think the fix for this needs to go through dave's tree, since it is 
where the original fix went through.

I will send a fix shortly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
