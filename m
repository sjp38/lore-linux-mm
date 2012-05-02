Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 5E68E6B004D
	for <linux-mm@kvack.org>; Wed,  2 May 2012 03:41:45 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1SPUBy-0003HZ-SB
	for linux-mm@kvack.org; Wed, 02 May 2012 09:41:43 +0200
Received: from 121.50.20.41 ([121.50.20.41])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 02 May 2012 09:41:42 +0200
Received: from minchan by 121.50.20.41 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 02 May 2012 09:41:42 +0200
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v4] vmevent: Implement greater-than attribute state and
 one-shot mode
Date: Wed, 02 May 2012 16:41:31 +0900
Message-ID: <4FA0E52B.7000907@kernel.org>
References: <20120418083208.GA24904@lizard> <20120418083523.GB31556@lizard> <alpine.LFD.2.02.1204182259580.11868@tux.localdomain> <20120418224629.GA22150@lizard> <alpine.LFD.2.02.1204190841290.1704@tux.localdomain> <20120419162923.GA26630@lizard> <20120501131806.GA22249@lizard> <4FA04FD5.6010900@redhat.com> <20120502002026.GA3334@lizard> <4FA08BDB.1070009@gmail.com> <20120502033136.GA14740@lizard> <4FA0C042.9010907@kernel.org> <CAOJsxLHdy8pBCBmbYfiHL681Bd=p_XPXjJHgVKqhT9nYquAjOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
In-Reply-To: <CAOJsxLHdy8pBCBmbYfiHL681Bd=p_XPXjJHgVKqhT9nYquAjOg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On 05/02/2012 03:57 PM, Pekka Enberg wrote:

> On Wed, May 2, 2012 at 8:04 AM, Minchan Kim <minchan@kernel.org> wrote:
>> I think hardest problem in low mem notification is how to define _lowmem situation_.
>> We all guys (server, desktop and embedded) should reach a conclusion on define lowmem situation
>> before progressing further implementation because each part can require different limits.
>> Hopefully, I want it.
>>
>> What is the best situation we can call it as "low memory"?
> 
> Looking at real-world scenarios, it seems to be totally dependent on
> userspace policy.


That's why I insist on defining low memory state in user space, not kernel.

> 
> On Wed, May 2, 2012 at 8:04 AM, Minchan Kim <minchan@kernel.org> wrote:
>> As a matter of fact, if we can define it well, I think even we don't neead vmevent ABI.
>> In my opinion, it's not easy to generalize each use-cases so we can pass it to user space and
>> just export low attributes of vmstat in kernel by vmevent.
>> Userspace program can determine low mem situation well on his environment with other vmstats
>> when notification happens. Of course, it has a drawback that userspace couples kernel's vmstat
>> but at least I think that's why we need vmevent for triggering event when we start watching carefully.
> 
> Please keep in mind that VM events is not only about "low memory"
> notification. The ABI might be useful for other kinds of VM events as
> well.


Fully agreed but we should prove why such event is useful in real scenario before adding more features.


> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
