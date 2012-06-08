Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id E6E366B0071
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 23:55:43 -0400 (EDT)
Received: by qabg27 with SMTP id g27so594377qab.14
        for <linux-mm@kvack.org>; Thu, 07 Jun 2012 20:55:43 -0700 (PDT)
Message-ID: <4FD177BD.1070004@gmail.com>
Date: Thu, 07 Jun 2012 23:55:41 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Some vmevent fixes...
References: <20120507121527.GA19526@lizard> <4FA82056.2070706@gmail.com> <CAOJsxLHQcDZSHJZg+zbptqmT9YY0VTkPd+gG_zgMzs+HaV_cyA@mail.gmail.com> <CAHGf_=q1nbu=3cnfJ4qXwmngMPB-539kg-DFN2FJGig8+dRaNw@mail.gmail.com> <CAOJsxLFAavdDbiLnYRwe+QiuEHSD62+Sz6LJTk+c3J9gnLVQ_w@mail.gmail.com> <CAHGf_=pSLfAue6AR5gi5RQ7xvgTxpZckA=Ja1fO1AkoO1o_DeA@mail.gmail.com> <CAOJsxLG1+zhOKgi2Rg1eSoXSCU8QGvHVED_EefOOLP-6JbMDkg@mail.gmail.com> <20120601122118.GA6128@lizard> <alpine.LFD.2.02.1206032125320.1943@tux.localdomain> <4FCC7592.9030403@kernel.org> <20120604113811.GA4291@lizard> <4FCD14F1.1030105@gmail.com> <CAOJsxLGbX33TfGvMEzV4By=n8JojHcXV32FRueb3kmti38jBPQ@mail.gmail.com>
In-Reply-To: <CAOJsxLGbX33TfGvMEzV4By=n8JojHcXV32FRueb3kmti38jBPQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Anton Vorontsov <cbouatmailru@gmail.com>, Minchan Kim <minchan@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

(6/5/12 3:52 AM), Pekka Enberg wrote:
> On Mon, Jun 4, 2012 at 11:05 PM, KOSAKI Motohiro
> <kosaki.motohiro@gmail.com>  wrote:
>>> - On desktops, apps can drop their caches on demand if they want to
>>>    and can avoid swap activity?
>>
>> In this case, fallocate(VOLATILE) is work more better.
>
> For some cases, yes, but probably not for all.
>
> For example, if userspace doesn't know about "about to swap real soon"
> condition, it can continue to grow its caches making
> fallocate(VOLATILE) pretty much useless.

Fair enough. But, Please consider your scenario don't need vmevent(2),
cat /proc/meminfo works enough. Only dropping activity need a quick work
and just in time notification. cache growing limitation don't need.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
