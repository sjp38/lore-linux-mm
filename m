Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 15AD16B0072
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 03:53:43 -0400 (EDT)
Received: by yhr47 with SMTP id 47so4723371yhr.14
        for <linux-mm@kvack.org>; Tue, 05 Jun 2012 00:53:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120604133527.GA13650@lizard>
References: <CAOJsxLHQcDZSHJZg+zbptqmT9YY0VTkPd+gG_zgMzs+HaV_cyA@mail.gmail.com>
	<CAHGf_=q1nbu=3cnfJ4qXwmngMPB-539kg-DFN2FJGig8+dRaNw@mail.gmail.com>
	<CAOJsxLFAavdDbiLnYRwe+QiuEHSD62+Sz6LJTk+c3J9gnLVQ_w@mail.gmail.com>
	<CAHGf_=pSLfAue6AR5gi5RQ7xvgTxpZckA=Ja1fO1AkoO1o_DeA@mail.gmail.com>
	<CAOJsxLG1+zhOKgi2Rg1eSoXSCU8QGvHVED_EefOOLP-6JbMDkg@mail.gmail.com>
	<20120601122118.GA6128@lizard>
	<alpine.LFD.2.02.1206032125320.1943@tux.localdomain>
	<4FCC7592.9030403@kernel.org>
	<20120604113811.GA4291@lizard>
	<20120604121722.GA2768@barrios>
	<20120604133527.GA13650@lizard>
Date: Tue, 5 Jun 2012 10:53:41 +0300
Message-ID: <CAOJsxLHkzubReaR0utB4xdage0Omb4r=jhXCLwXQ8XOSct4LGg@mail.gmail.com>
Subject: Re: [PATCH 0/5] Some vmevent fixes...
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <cbouatmailru@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Mon, Jun 4, 2012 at 4:35 PM, Anton Vorontsov <cbouatmailru@gmail.com> wrote:
>> I don't mean VMEVENT_ATTR_LOWMEM_PAGES but following as,
>>
>> VMEVENT_ATTR_NR_FREE_PAGES
>> VMEVENT_ATTR_NR_SWAP_PAGES
>> VMEVENT_ATTR_NR_AVAIL_PAGES
>>
>> I'm not sure how it is useful.
>
> Yep, these raw values are mostly useless, and personally I don't use
> these plain attributes. I use heuristics, i.e. "blended" attributes.
> If we can come up with levels-based approach w/o using vmstat, well..
> OK then.

That's what Nokia's lowmem notifier uses. We can probably drop them
once we have something else they could use.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
