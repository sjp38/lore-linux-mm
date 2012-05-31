Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id B22EF6B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 02:23:31 -0400 (EDT)
Received: by qabg27 with SMTP id g27so2839293qab.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 23:23:30 -0700 (PDT)
Message-ID: <4FC70E5E.1010003@gmail.com>
Date: Thu, 31 May 2012 02:23:26 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
References: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com> <alpine.DEB.2.00.1205301433490.9716@chino.kir.corp.google.com> <4FC6B68C.2070703@jp.fujitsu.com> <CAHGf_=pFbsy4FO_UNu6O1-KyTd6O=pkmR8=3EGuZB5Reu3Vb9w@mail.gmail.com> <4FC6BC3E.5010807@jp.fujitsu.com> <alpine.DEB.2.00.1205301737530.25774@chino.kir.corp.google.com> <4FC6C111.2060108@jp.fujitsu.com> <alpine.DEB.2.00.1205301831270.25774@chino.kir.corp.google.com> <4FC6D881.4090706@jp.fujitsu.com> <alpine.DEB.2.00.1205302156090.25774@chino.kir.corp.google.com> <4FC70355.70805@jp.fujitsu.com> <alpine.DEB.2.00.1205302314190.25774@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1205302314190.25774@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Gao feng <gaofeng@cn.fujitsu.com>, hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org

(5/31/12 2:17 AM), David Rientjes wrote:
> On Thu, 31 May 2012, Kamezawa Hiroyuki wrote:
>
>>> The bottomline is that /proc/meminfo is one of many global resource state
>>> interfaces and doesn't imply that every thread has access to the full
>>> resources.  It never has.  It's very simple for another thread to consume
>>> a large amount of memory as soon as your read() of /proc/meminfo completes
>>> and then that information is completely bogus.
>>
>> Why you need to discuss this here ? We know all information are snapshot.
>>
>
> MemTotal is usually assumed to be static from /proc/meminfo and could now
> change radically without notification to the application.
>
>> Hmm....maybe need to mount cgroup in the container (again) and get an access
>> to cgroup
>> hierarchy and find the cgroup it belongs to......if it's allowed.
>
> An application should always know the cgroup that its attached to and be
> able to read its state using the command that I gave earlier.

No. you don't need why userland folks want namespaces. Even though you don't
need namespaces. It doesn't good reason to refuse another use case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
