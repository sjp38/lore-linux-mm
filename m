Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3C4F86B0070
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 20:15:20 -0500 (EST)
Message-ID: <4EC2FDA9.6050401@jp.fujitsu.com>
Date: Tue, 15 Nov 2011 19:02:49 -0500
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH V2] Enforce RSS+Swap rlimit
References: <4EB3FA89.6090601@redhat.com> <4EC264AA.30306@redhat.com>
In-Reply-To: <4EC264AA.30306@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jmarchan@redhat.com
Cc: bsingharora@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/15/2011 8:10 AM, Jerome Marchand wrote:
> 
> Change since V1: rebase on 3.2-rc1
> 
> Currently RSS rlimit is not enforced. We can not forbid a process to exceeds
> its RSS limit and allow it swap out. That would hurts the performance of all
> system, even when memory resources are plentiful.
> 
> Therefore, instead of enforcing a limit on rss usage alone, this patch enforces
> a limit on rss+swap value. This is similar to memsw limits of cgroup.
> If a process rss+swap usage exceeds RLIMIT_RSS max limit, he received a SIGBUS
> signal. 

No good idea.
 - RLIMIT_RSS has clear definition and this patch break it. you should makes
   another rlimit at least.
 - SIGBUS can be ignored. rlimit shouldn't ignorable.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
