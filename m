Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 780746B005C
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 08:23:15 -0400 (EDT)
Received: by dakp5 with SMTP id p5so7376671dak.14
        for <linux-mm@kvack.org>; Mon, 04 Jun 2012 05:23:14 -0700 (PDT)
Date: Mon, 4 Jun 2012 21:23:04 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/5] Some vmevent fixes...
Message-ID: <20120604122304.GB2768@barrios>
References: <4FA82056.2070706@gmail.com>
 <CAOJsxLHQcDZSHJZg+zbptqmT9YY0VTkPd+gG_zgMzs+HaV_cyA@mail.gmail.com>
 <CAHGf_=q1nbu=3cnfJ4qXwmngMPB-539kg-DFN2FJGig8+dRaNw@mail.gmail.com>
 <CAOJsxLFAavdDbiLnYRwe+QiuEHSD62+Sz6LJTk+c3J9gnLVQ_w@mail.gmail.com>
 <CAHGf_=pSLfAue6AR5gi5RQ7xvgTxpZckA=Ja1fO1AkoO1o_DeA@mail.gmail.com>
 <CAOJsxLG1+zhOKgi2Rg1eSoXSCU8QGvHVED_EefOOLP-6JbMDkg@mail.gmail.com>
 <20120601122118.GA6128@lizard>
 <alpine.LFD.2.02.1206032125320.1943@tux.localdomain>
 <4FCC7592.9030403@kernel.org>
 <CAOJsxLEH5UZNuo6VQRH+5YHaxpv8C1rBOGi7dp6hJ9MMU3jidQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOJsxLEH5UZNuo6VQRH+5YHaxpv8C1rBOGi7dp6hJ9MMU3jidQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Anton Vorontsov <cbouatmailru@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Mon, Jun 04, 2012 at 12:20:18PM +0300, Pekka Enberg wrote:
> On Mon, Jun 4, 2012 at 11:45 AM, Minchan Kim <minchan@kernel.org> wrote:
> > KOSAKI, AFAIRC, you are a person who hates android low memory killer.
> > Why do you hate it? If it solve problems I mentioned, do you have a concern, still?
> > If so, please, list up.
> >
> > Android low memory killer is proved solution for a long time, at least embedded
> > area(So many android phone already have used it) so I think improving it makes
> > sense to me rather than inventing new wheel.
> 
> VM events started out as *ABI cleanup* of Nokia's N9 Linux lowmem
> notifier. That's not reinventing the wheel.
> 
> On Mon, Jun 4, 2012 at 11:45 AM, Minchan Kim <minchan@kernel.org> wrote:
> > Frankly speaking, I don't know vmevent's other use cases except low memory
> > notification and didn't see any agreement about that with other guys.
> 
> I think you are missing the point. "vmevent" is an ABI for delivering
> VM events to userspace. I started it because different userspaces do
> not agree what "low memory" means - for obvious reasons.

The part I dislike vmevent is to expose raw vmstat itself.

VMEVENT_ATTR_NR_SWAP_PAGES
VMEVENT_ATTR_NR_FREE_PAGES
VMEVENT_ATTR_NR_AVAIL_PAGES

And some calculation based on raw vmstat.
We need more abstraction based on vmscan heuristic.

> 
> As for use cases, it'd be useful for VMs to be notified of "about to
> swap your pages soon" so that they can aggressively GC before entering

How do you detect it? It's a policy which is most important part on vmevent.

> GC-swapstorm hell. I also hear that something similar would be useful
> for KVM/QEMU but I don't know the details.
> 
> I really don't see how Android's "low memory killer" will be useful as
> a generic solution.

Yes. we can't do it by current android LMK.
I'm not big fan of androild LMK but we can improve it much by my suggestions
and yours smart ideas, I believe.

> 
>                         Pekka
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
