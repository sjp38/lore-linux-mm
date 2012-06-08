Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 8A7396B006E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 23:35:24 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so821874qcs.14
        for <linux-mm@kvack.org>; Thu, 07 Jun 2012 20:35:23 -0700 (PDT)
Message-ID: <4FD172F8.7050301@gmail.com>
Date: Thu, 07 Jun 2012 23:35:20 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Some vmevent fixes...
References: <CAOJsxLHQcDZSHJZg+zbptqmT9YY0VTkPd+gG_zgMzs+HaV_cyA@mail.gmail.com> <CAHGf_=q1nbu=3cnfJ4qXwmngMPB-539kg-DFN2FJGig8+dRaNw@mail.gmail.com> <CAOJsxLFAavdDbiLnYRwe+QiuEHSD62+Sz6LJTk+c3J9gnLVQ_w@mail.gmail.com> <CAHGf_=pSLfAue6AR5gi5RQ7xvgTxpZckA=Ja1fO1AkoO1o_DeA@mail.gmail.com> <CAOJsxLG1+zhOKgi2Rg1eSoXSCU8QGvHVED_EefOOLP-6JbMDkg@mail.gmail.com> <20120601122118.GA6128@lizard> <alpine.LFD.2.02.1206032125320.1943@tux.localdomain> <4FCC7592.9030403@kernel.org>	<20120604113811.GA4291@lizard> <20120604121722.GA2768@barrios>	<20120604133527.GA13650@lizard> <CAOJsxLHkzubReaR0utB4xdage0Omb4r=jhXCLwXQ8XOSct4LGg@mail.gmail.com> <4FCDBC8E.1000705@kernel.org> <CAOJsxLHOdnQKSfLqFG4hdabhuwhHt+HqKGerP23YuNQc4TZS_g@mail.gmail.com> <84FF21A720B0874AA94B46D76DB98269045EBBD8@008-AM1MPN1-003.mgdnok.nokia.com>
In-Reply-To: <84FF21A720B0874AA94B46D76DB98269045EBBD8@008-AM1MPN1-003.mgdnok.nokia.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: penberg@kernel.org, minchan@kernel.org, cbouatmailru@gmail.com, kosaki.motohiro@gmail.com, john.stultz@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

(6/5/12 4:16 AM), leonid.moiseichuk@nokia.com wrote:
>> -----Original Message-----
>> From: penberg@gmail.com [mailto:penberg@gmail.com] On Behalf Of ext
>> Pekka Enberg
>> Sent: 05 June, 2012 11:02
>> To: Minchan Kim
> ...
>>> Next concern is that periodic timer of implementation.
>>> I think it would add direct hook in vmscan.c rather than peeking raw
>>> vmstat periodically by timer so we can control more fine-grained way
>> without unnecessary overhead.
>>
>> If the hooks are clean and it doesn't hurt the  !CONFIG_VMEVENT case, I'm
>> completely OK with that.
>
> On the previous iteration hooking vm was pointed as very bad idea, so in my version I installed shrinker to handle cases when we have memory pressure.
> Using deferred timer with adequate timeout (0.250 ms or larger) fully suitable for userspace and produce adequate overhead
> ->  by nature such API should not be 100% accurate, anyhow applications cannot handle situation as good as kernel can provide, 0.5MB space accuracy, 100ms is maximum user-space require for 64-1024MB devices.

I believe that's bad idea. In fact, An "adequate" timeout depend on hardware, not application performance tendency. Thus, applications can't know "adequate" value.

  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
