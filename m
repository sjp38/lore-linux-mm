Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3B2B96B0069
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 04:40:39 -0500 (EST)
Message-ID: <4EC38511.3020006@redhat.com>
Date: Wed, 16 Nov 2011 10:40:33 +0100
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH V2] Enforce RSS+Swap rlimit
References: <4EB3FA89.6090601@redhat.com> <4EC264AA.30306@redhat.com> <4EC2FDA9.6050401@jp.fujitsu.com>
In-Reply-To: <4EC2FDA9.6050401@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: bsingharora@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/16/2011 01:02 AM, KOSAKI Motohiro wrote:
> On 11/15/2011 8:10 AM, Jerome Marchand wrote:
>>
>> Change since V1: rebase on 3.2-rc1
>>
>> Currently RSS rlimit is not enforced. We can not forbid a process to exceeds
>> its RSS limit and allow it swap out. That would hurts the performance of all
>> system, even when memory resources are plentiful.
>>
>> Therefore, instead of enforcing a limit on rss usage alone, this patch enforces
>> a limit on rss+swap value. This is similar to memsw limits of cgroup.
>> If a process rss+swap usage exceeds RLIMIT_RSS max limit, he received a SIGBUS
>> signal. 
> 
> No good idea.
>  - RLIMIT_RSS has clear definition and this patch break it. you should makes
>    another rlimit at least.

I couldn't decide if we needed a new rlimit or not. I shall admit that I chose
the lazy option. If that's a problem, I can add a new rlimit, RLIMIT_MEMSW for
instance.

>  - SIGBUS can be ignored. rlimit shouldn't ignorable.

The SIGBUS can be ignored, not the rlimit: if RLIMIT_RSS is exceeded, the process
does not the memory it requested. The SIGBUS is here to notify the process that
something wrong has happened.

Thanks,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
