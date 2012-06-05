Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id C7F146B0062
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 04:01:46 -0400 (EDT)
Received: by ggm4 with SMTP id 4so4859389ggm.14
        for <linux-mm@kvack.org>; Tue, 05 Jun 2012 01:01:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FCDBC8E.1000705@kernel.org>
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
	<CAOJsxLHkzubReaR0utB4xdage0Omb4r=jhXCLwXQ8XOSct4LGg@mail.gmail.com>
	<4FCDBC8E.1000705@kernel.org>
Date: Tue, 5 Jun 2012 11:01:45 +0300
Message-ID: <CAOJsxLHOdnQKSfLqFG4hdabhuwhHt+HqKGerP23YuNQc4TZS_g@mail.gmail.com>
Subject: Re: [PATCH 0/5] Some vmevent fixes...
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Anton Vorontsov <cbouatmailru@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Tue, Jun 5, 2012 at 11:00 AM, Minchan Kim <minchan@kernel.org> wrote:
>> That's what Nokia's lowmem notifier uses. We can probably drop them
>> once we have something else they could use.
>
> Next concern is that periodic timer of implementation.
> I think it would add direct hook in vmscan.c rather than peeking raw vmstat periodically by timer
> so we can control more fine-grained way without unnecessary overhead.

If the hooks are clean and it doesn't hurt the  !CONFIG_VMEVENT case,
I'm completely OK with that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
