Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 6300D6B0071
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 04:47:42 -0400 (EDT)
Date: Thu, 25 Oct 2012 17:53:09 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC v2 0/2] vmevent: A bit reworked pressure attribute + docs +
 man page
Message-ID: <20121025085309.GC15767@bbox>
References: <20121022111928.GA12396@lizard>
 <20121025064009.GA15767@bbox>
 <CAOJsxLGsjTe13WjY_Q=BLBELwQXOjuwo7PiEKwONHUfR4mQmig@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOJsxLGsjTe13WjY_Q=BLBELwQXOjuwo7PiEKwONHUfR4mQmig@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org

Hi Pekka,

On Thu, Oct 25, 2012 at 09:44:52AM +0300, Pekka Enberg wrote:
> On Thu, Oct 25, 2012 at 9:40 AM, Minchan Kim <minchan@kernel.org> wrote:
> > Your description doesn't include why we need new vmevent_fd(2).
> > Of course, it's very flexible and potential to add new VM knob easily but
> > the thing we is about to use now is only VMEVENT_ATTR_PRESSURE.
> > Is there any other use cases for swap or free? or potential user?
> > Adding vmevent_fd without them is rather overkill.
> 
> What ABI would you use instead?

I thought /dev/some_knob like mem_notify and epoll is enough but please keep in mind
that I'm not against vmevent_fd strongly. My point is that description should include
explain about why other candidate is not good or why vmevent_fd is better.
(But at least, I don't like vmevent timer polling still and I hope we use it
as last resort once we can find another)

> 
> On Thu, Oct 25, 2012 at 9:40 AM, Minchan Kim <minchan@kernel.org> wrote:
> > I don't object but we need rationale for adding new system call which should
> > be maintained forever once we add it.
> 
> Agreed.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
