Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id A734D6B004D
	for <linux-mm@kvack.org>; Wed,  2 May 2012 01:04:01 -0400 (EDT)
Message-ID: <4FA0C042.9010907@kernel.org>
Date: Wed, 02 May 2012 14:04:02 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH v4] vmevent: Implement greater-than attribute state and
 one-shot mode
References: <20120418083208.GA24904@lizard> <20120418083523.GB31556@lizard> <alpine.LFD.2.02.1204182259580.11868@tux.localdomain> <20120418224629.GA22150@lizard> <alpine.LFD.2.02.1204190841290.1704@tux.localdomain> <20120419162923.GA26630@lizard> <20120501131806.GA22249@lizard> <4FA04FD5.6010900@redhat.com> <20120502002026.GA3334@lizard> <4FA08BDB.1070009@gmail.com> <20120502033136.GA14740@lizard>
In-Reply-To: <20120502033136.GA14740@lizard>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, Glauber Costa <glommer@parallels.com>, kamezawa.hiroyu@jp.fujitsu.com, Suleiman Souhlal <suleiman@google.com>

On 05/02/2012 12:31 PM, Anton Vorontsov wrote:

> Hello KOSAKI,
> 
> On Tue, May 01, 2012 at 09:20:27PM -0400, KOSAKI Motohiro wrote:
> [...]
>>> It would be great indeed, but so far I don't see much that
>>> vmevent could share. Plus, sharing the code at this point is not
>>> that interesting; it's mere 500 lines of code (comparing to
>>> more than 10K lines for cgroups, and it's not including memcg_
>>> hooks and logic that is spread all over mm/).
>>>
>>> Today vmevent code is mostly an ABI implementation, there is
>>> very little memory management logic (in contrast to the memcg).
>>
>> But, if it doesn't work desktop/server area, it shouldn't be merged.
> 
> What makes you think that vmevent won't work for desktop or servers?
> :-)
> 
> E.g. for some servers you don't always want memcg, really. Suppose,
> a kvm farm or a database server. Sometimes there's really no need for
> the memcg, but there's still a demand for low memory notifications.
> 
> Current Linux desktops don't use any notifications at all, I think.
> So nothing to say about, neither on cgroup's nor on vmevent's behalf.
> I hardly imagine why desktop would use the whole memcg thing, but
> still have a use case for memory notifications.
> 
>> We have to consider the best design before kernel inclusion. They cann't
>> be separeted to discuss.
> 
> Of course, no objections here. But I somewhat disagree with the
> "best design" term. Which design is better, reading a file via
> read() or mmap()? It depends. Same here.


I think hardest problem in low mem notification is how to define _lowmem situation_.
We all guys (server, desktop and embedded) should reach a conclusion on define lowmem situation
before progressing further implementation because each part can require different limits.
Hopefully, I want it.

What is the best situation we can call it as "low memory"?

As a matter of fact, if we can define it well, I think even we don't need vmevent ABI.
In my opinion, it's not easy to generalize each use-cases so we can pass it to user space and
just export low attributes of vmstat in kernel by vmevent.
Userspace program can determine low mem situation well on his environment with other vmstats
when notification happens. Of course, it has a drawback that userspace couples kernel's vmstat
but at least I think that's why we need vmevent for triggering event when we start watching carefully.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
