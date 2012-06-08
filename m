Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 4CF296B0071
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 04:08:46 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2493171dak.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 01:08:45 -0700 (PDT)
Date: Fri, 8 Jun 2012 01:07:05 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [PATCH 2/5] vmevent: Convert from deferred timer to deferred work
Message-ID: <20120608080704.GB6362@lizard>
References: <20120601122118.GA6128@lizard>
 <1338553446-22292-2-git-send-email-anton.vorontsov@linaro.org>
 <4FD170AA.10705@gmail.com>
 <20120608065828.GA1515@lizard>
 <CAOJsxLEOsTC9mLo12dEpeatkgKq0xHjZXhGcO7Z99JHs3-D=9w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAOJsxLEOsTC9mLo12dEpeatkgKq0xHjZXhGcO7Z99JHs3-D=9w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Fri, Jun 08, 2012 at 10:03:24AM +0300, Pekka Enberg wrote:
> On Fri, Jun 8, 2012 at 9:58 AM, Anton Vorontsov
> <anton.vorontsov@linaro.org> wrote:
> > If you're saying that we should set up a timer in the userland and
> > constantly read /proc/vmstat, then we will cause CPU wake up
> > every 100ms, which is not acceptable. Well, we can try to introduce
> > deferrable timers for the userspace. But then it would still add
> > a lot more overhead for our task, as this solution adds other two
> > context switches to read and parse /proc/vmstat. I guess this is
> > not a show-stopper though, so we can discuss this.
> >
> > Leonid, Pekka, what do you think about the idea?
> 
> That's exactly the kind of half-assed ABI that lead to people
> inventing out-of-tree lowmem notifiers in the first place.

:-)

Well, at least powersaving-wise, the solution w/ userland deferred
timers would be much better then just looping over /proc/vmstat each
100ms, and it is comparable to vmevent. Not pretty, but still would
work.

> I'd be more interested to know what people think of Minchan's that
> gets rid of vmstat sampling.

I answered to Minchan's post. The thing is that Minchan's idea
is not a substitution for vmevent. To me it seems like a shrinker w/
some pre-filter.

Thanks,

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
