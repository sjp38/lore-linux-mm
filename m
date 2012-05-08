Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 183FF6B00F0
	for <linux-mm@kvack.org>; Tue,  8 May 2012 02:59:56 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so9769824pbb.14
        for <linux-mm@kvack.org>; Mon, 07 May 2012 23:59:55 -0700 (PDT)
Date: Mon, 7 May 2012 23:58:29 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [PATCH 3/3] vmevent: Implement special low-memory attribute
Message-ID: <20120508065829.GA13357@lizard>
References: <20120501132409.GA22894@lizard>
 <20120501132620.GC24226@lizard>
 <4FA35A85.4070804@kernel.org>
 <20120504073810.GA25175@lizard>
 <CAOJsxLH_7mMMe+2DvUxBW1i5nbUfkbfRE3iEhLQV9F_MM7=eiw@mail.gmail.com>
 <CAHGf_=qcGfuG1g15SdE0SDxiuhCyVN025pQB+sQNuNba4Q4jcA@mail.gmail.com>
 <20120507121527.GA19526@lizard>
 <4FA82056.2070706@gmail.com>
 <CAOJsxLHQcDZSHJZg+zbptqmT9YY0VTkPd+gG_zgMzs+HaV_cyA@mail.gmail.com>
 <CAHGf_=q1nbu=3cnfJ4qXwmngMPB-539kg-DFN2FJGig8+dRaNw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAHGf_=q1nbu=3cnfJ4qXwmngMPB-539kg-DFN2FJGig8+dRaNw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Minchan Kim <minchan@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Tue, May 08, 2012 at 01:42:05AM -0400, KOSAKI Motohiro wrote:
[...]
> > Well, yeah, if we are to report _number of pages_, the numbers better
> > be meaningful.
> >
> > That said, I think you are being unfair to Anton who's one of the few
> > that's actually taking the time to implement this properly instead of
> > settling for an out-of-tree hack.
> 
> Unfair? But only I can talk about technical comment. To be honest, I
> really dislike
> I need say the same explanation again and again. A lot of people don't read
> past discussion. And as far as the patches take the same mistake, I must say
> the same thing. It is just PITA.

Note that just telling people that something is PITA doesn't help solve
things (so people will come back to you with stupid questions over and
over again). You can call people morons, idiots and dumbasses (that's
all fine) but still finding a way to be productive. :-)

You could just give a link to a previous discussion, in which you think
you explained all your concerns regarding cache handling issues, or
memory notifications/statistics in general.

So, feel free to call me an idiot, but please expand your points a
little bit or give a link to the discussion you're referring to?

Thanks,

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
