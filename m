Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 4570D6B005C
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 05:20:19 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so4619853ghr.14
        for <linux-mm@kvack.org>; Mon, 04 Jun 2012 02:20:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FCC7592.9030403@kernel.org>
References: <20120504073810.GA25175@lizard>
	<CAOJsxLH_7mMMe+2DvUxBW1i5nbUfkbfRE3iEhLQV9F_MM7=eiw@mail.gmail.com>
	<CAHGf_=qcGfuG1g15SdE0SDxiuhCyVN025pQB+sQNuNba4Q4jcA@mail.gmail.com>
	<20120507121527.GA19526@lizard>
	<4FA82056.2070706@gmail.com>
	<CAOJsxLHQcDZSHJZg+zbptqmT9YY0VTkPd+gG_zgMzs+HaV_cyA@mail.gmail.com>
	<CAHGf_=q1nbu=3cnfJ4qXwmngMPB-539kg-DFN2FJGig8+dRaNw@mail.gmail.com>
	<CAOJsxLFAavdDbiLnYRwe+QiuEHSD62+Sz6LJTk+c3J9gnLVQ_w@mail.gmail.com>
	<CAHGf_=pSLfAue6AR5gi5RQ7xvgTxpZckA=Ja1fO1AkoO1o_DeA@mail.gmail.com>
	<CAOJsxLG1+zhOKgi2Rg1eSoXSCU8QGvHVED_EefOOLP-6JbMDkg@mail.gmail.com>
	<20120601122118.GA6128@lizard>
	<alpine.LFD.2.02.1206032125320.1943@tux.localdomain>
	<4FCC7592.9030403@kernel.org>
Date: Mon, 4 Jun 2012 12:20:18 +0300
Message-ID: <CAOJsxLEH5UZNuo6VQRH+5YHaxpv8C1rBOGi7dp6hJ9MMU3jidQ@mail.gmail.com>
Subject: Re: [PATCH 0/5] Some vmevent fixes...
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Anton Vorontsov <cbouatmailru@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Mon, Jun 4, 2012 at 11:45 AM, Minchan Kim <minchan@kernel.org> wrote:
> KOSAKI, AFAIRC, you are a person who hates android low memory killer.
> Why do you hate it? If it solve problems I mentioned, do you have a concern, still?
> If so, please, list up.
>
> Android low memory killer is proved solution for a long time, at least embedded
> area(So many android phone already have used it) so I think improving it makes
> sense to me rather than inventing new wheel.

VM events started out as *ABI cleanup* of Nokia's N9 Linux lowmem
notifier. That's not reinventing the wheel.

On Mon, Jun 4, 2012 at 11:45 AM, Minchan Kim <minchan@kernel.org> wrote:
> Frankly speaking, I don't know vmevent's other use cases except low memory
> notification and didn't see any agreement about that with other guys.

I think you are missing the point. "vmevent" is an ABI for delivering
VM events to userspace. I started it because different userspaces do
not agree what "low memory" means - for obvious reasons.

As for use cases, it'd be useful for VMs to be notified of "about to
swap your pages soon" so that they can aggressively GC before entering
GC-swapstorm hell. I also hear that something similar would be useful
for KVM/QEMU but I don't know the details.

I really don't see how Android's "low memory killer" will be useful as
a generic solution.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
