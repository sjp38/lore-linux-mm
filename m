Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id F12DE6B006E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 03:10:56 -0400 (EDT)
Received: by ggm4 with SMTP id 4so1376435ggm.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 00:10:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <84FF21A720B0874AA94B46D76DB98269045F7890@008-AM1MPN1-004.mgdnok.nokia.com>
References: <20120601122118.GA6128@lizard> <1338553446-22292-2-git-send-email-anton.vorontsov@linaro.org>
 <4FD170AA.10705@gmail.com> <20120608065828.GA1515@lizard> <84FF21A720B0874AA94B46D76DB98269045F7890@008-AM1MPN1-004.mgdnok.nokia.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Fri, 8 Jun 2012 03:10:35 -0400
Message-ID: <CAHGf_=rHGotkPYJt65wv+ZDNeO2x+3c5sA8oJmGJX8ehsMHqoA@mail.gmail.com>
Subject: Re: [PATCH 2/5] vmevent: Convert from deferred timer to deferred work
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: anton.vorontsov@linaro.org, penberg@kernel.org, b.zolnierkie@samsung.com, john.stultz@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Fri, Jun 8, 2012 at 3:05 AM,  <leonid.moiseichuk@nokia.com> wrote:
>> -----Original Message-----
>> From: ext Anton Vorontsov [mailto:anton.vorontsov@linaro.org]
>> Sent: 08 June, 2012 09:58
> ...
>> If you're saying that we should set up a timer in the userland and constantly
>> read /proc/vmstat, then we will cause CPU wake up every 100ms, which is
>> not acceptable. Well, we can try to introduce deferrable timers for the
>> userspace. But then it would still add a lot more overhead for our task, as this
>> solution adds other two context switches to read and parse /proc/vmstat. I
>> guess this is not a show-stopper though, so we can discuss this.
>>
>> Leonid, Pekka, what do you think about the idea?
>
> Seems to me not nice solution. Generating/parsing vmstat every 100ms plus wakeups it is what exactly should be avoid to have sense to API.

No. I don't suggest to wake up every 100ms. I suggest to integrate
existing subsystems. If you need any enhancement, just do it.


> It also will cause page trashing because user-space code could be pushed out from cache if VM decide.

This is completely unrelated issue. Even if notification code is not
swapped, userland notify handling code still may be swapped. So,
if you must avoid swap, you must use mlock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
