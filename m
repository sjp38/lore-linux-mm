Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 90C3F6B0101
	for <linux-mm@kvack.org>; Tue,  8 May 2012 04:14:32 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so9891036pbb.14
        for <linux-mm@kvack.org>; Tue, 08 May 2012 01:14:31 -0700 (PDT)
Date: Tue, 8 May 2012 01:13:06 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [PATCH 3/3] vmevent: Implement special low-memory attribute
Message-ID: <20120508081305.GA20574@lizard>
References: <4FA35A85.4070804@kernel.org>
 <20120504073810.GA25175@lizard>
 <CAOJsxLH_7mMMe+2DvUxBW1i5nbUfkbfRE3iEhLQV9F_MM7=eiw@mail.gmail.com>
 <CAHGf_=qcGfuG1g15SdE0SDxiuhCyVN025pQB+sQNuNba4Q4jcA@mail.gmail.com>
 <20120507121527.GA19526@lizard>
 <4FA82056.2070706@gmail.com>
 <CAOJsxLHQcDZSHJZg+zbptqmT9YY0VTkPd+gG_zgMzs+HaV_cyA@mail.gmail.com>
 <CAHGf_=q1nbu=3cnfJ4qXwmngMPB-539kg-DFN2FJGig8+dRaNw@mail.gmail.com>
 <20120508065829.GA13357@lizard>
 <4FA8C86B.8010205@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <4FA8C86B.8010205@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Minchan Kim <minchan@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Tue, May 08, 2012 at 03:16:59AM -0400, KOSAKI Motohiro wrote:
[...]
> >So, feel free to call me an idiot, but please expand your points a
> >little bit or give a link to the discussion you're referring to?
> 
> I don't think you are idiot. But I hope you test your patch before submitting.
> That just don't work especially on x86. Because of, all x86 box have multiple zone
> and summarized statistics (i.e. global_page_state() thing) don't work and can't
> prevent oom nor swapping.

Now I think I understand you: we don't take into account that e.g. DMA
zone is not usable by the normal allocations, and so if we're basing our
calculations on summarized stats, it is indeed possible to get an OOM
in such a case. On Android kernels nobody noticed the issue as it is
used mainly on ARM targets, which might have CONFIG_ZONE_DMA=n.

So, this particular issue makes sense now.

Thanks!

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
