Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id DEF6F6B006E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 02:54:16 -0400 (EDT)
Received: by ggm4 with SMTP id 4so1364209ggm.14
        for <linux-mm@kvack.org>; Thu, 07 Jun 2012 23:54:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FD177BD.1070004@gmail.com>
References: <20120507121527.GA19526@lizard>
	<4FA82056.2070706@gmail.com>
	<CAOJsxLHQcDZSHJZg+zbptqmT9YY0VTkPd+gG_zgMzs+HaV_cyA@mail.gmail.com>
	<CAHGf_=q1nbu=3cnfJ4qXwmngMPB-539kg-DFN2FJGig8+dRaNw@mail.gmail.com>
	<CAOJsxLFAavdDbiLnYRwe+QiuEHSD62+Sz6LJTk+c3J9gnLVQ_w@mail.gmail.com>
	<CAHGf_=pSLfAue6AR5gi5RQ7xvgTxpZckA=Ja1fO1AkoO1o_DeA@mail.gmail.com>
	<CAOJsxLG1+zhOKgi2Rg1eSoXSCU8QGvHVED_EefOOLP-6JbMDkg@mail.gmail.com>
	<20120601122118.GA6128@lizard>
	<alpine.LFD.2.02.1206032125320.1943@tux.localdomain>
	<4FCC7592.9030403@kernel.org>
	<20120604113811.GA4291@lizard>
	<4FCD14F1.1030105@gmail.com>
	<CAOJsxLGbX33TfGvMEzV4By=n8JojHcXV32FRueb3kmti38jBPQ@mail.gmail.com>
	<4FD177BD.1070004@gmail.com>
Date: Fri, 8 Jun 2012 09:54:15 +0300
Message-ID: <CAOJsxLGHDF_QnRSA_CckdTDGxNkOFvRNZoFoW0iGDjGvTCK=2A@mail.gmail.com>
Subject: Re: [PATCH 0/5] Some vmevent fixes...
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Anton Vorontsov <cbouatmailru@gmail.com>, Minchan Kim <minchan@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Fri, Jun 8, 2012 at 6:55 AM, KOSAKI Motohiro
<kosaki.motohiro@gmail.com> wrote:
>> For some cases, yes, but probably not for all.
>>
>> For example, if userspace doesn't know about "about to swap real soon"
>> condition, it can continue to grow its caches making
>> fallocate(VOLATILE) pretty much useless.
>
> Fair enough. But, Please consider your scenario don't need vmevent(2),
> cat /proc/meminfo works enough. Only dropping activity need a quick work
> and just in time notification. cache growing limitation don't need.

Why do you keep bringing this up? Yes, you might get away with polling
/proc/meminfo or /proc/vmstat for some specific cases. It does not
make it a proper generic solution to the problem "vmevent" ABI tries
to address.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
