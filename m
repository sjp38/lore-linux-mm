Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 7C0AA6B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 03:09:52 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 77D7A3EE0BD
	for <linux-mm@kvack.org>; Thu, 31 May 2012 16:09:50 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B35445DEB3
	for <linux-mm@kvack.org>; Thu, 31 May 2012 16:09:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 43A6545DEAD
	for <linux-mm@kvack.org>; Thu, 31 May 2012 16:09:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 32A47E38006
	for <linux-mm@kvack.org>; Thu, 31 May 2012 16:09:50 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DC13BE38003
	for <linux-mm@kvack.org>; Thu, 31 May 2012 16:09:49 +0900 (JST)
Message-ID: <4FC718BA.8060608@jp.fujitsu.com>
Date: Thu, 31 May 2012 16:07:38 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
References: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com> <alpine.DEB.2.00.1205301433490.9716@chino.kir.corp.google.com> <4FC6B68C.2070703@jp.fujitsu.com> <CAHGf_=pFbsy4FO_UNu6O1-KyTd6O=pkmR8=3EGuZB5Reu3Vb9w@mail.gmail.com> <4FC6BC3E.5010807@jp.fujitsu.com> <alpine.DEB.2.00.1205301737530.25774@chino.kir.corp.google.com> <4FC6C111.2060108@jp.fujitsu.com> <alpine.DEB.2.00.1205301831270.25774@chino.kir.corp.google.com> <4FC6D881.4090706@jp.fujitsu.com> <alpine.DEB.2.00.1205302156090.25774@chino.kir.corp.google.com> <4FC70355.70805@jp.fujitsu.com> <alpine.DEB.2.00.1205302314190.25774@chino.kir.corp.google.com> <4FC70E5E.1010003@gmail.com> <alpine.DEB.2.00.1205302325500.25774@chino.kir.corp.google.com> <4FC711A5.4090003@gmail.com>
In-Reply-To: <4FC711A5.4090003@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: David Rientjes <rientjes@google.com>, Gao feng <gaofeng@cn.fujitsu.com>, hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org

(2012/05/31 15:37), KOSAKI Motohiro wrote:
> (5/31/12 2:28 AM), David Rientjes wrote:
>> On Thu, 31 May 2012, KOSAKI Motohiro wrote:
>>
>>>> An application should always know the cgroup that its attached to and be
>>>> able to read its state using the command that I gave earlier.
>>>
>>> No. you don't need why userland folks want namespaces. Even though you don't
>>> need namespaces. It doesn't good reason to refuse another use case.
>>>
>>
>> This is tangent to the discussion, we need to revisit why an application
>> other than a daemon managing a set of memcgs would ever need to know the
>> information in /proc/meminfo. No use-case was ever presented in the
>> changelog and its not clear how this is at all relevant. So before
>> changing the kernel, please describe how this actually matters in a real-
>> world scenario.
>
> Huh? Don't you know a meanings of a namespace ISOLATION? isolation mean,
> isolated container shouldn't be able to access global information. If you
> want to lean container/namespace concept, tasting openvz or solaris container
> is a good start.
>
> But anyway, I dislike current implementaion. So, I NAK this patch too.

Could you give us advice for improving this ? What idea do you have ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
