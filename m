Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 46EA46B004D
	for <linux-mm@kvack.org>; Tue, 24 Jul 2012 09:52:22 -0400 (EDT)
Message-ID: <1343137938.7412.95.camel@marge.simpson.net>
Subject: Re: [PATCH 00/34] Memory management performance backports for
 -stable V2
From: Mike Galbraith <efault@gmx.de>
Date: Tue, 24 Jul 2012 15:52:18 +0200
In-Reply-To: <CAJd=RBC835W52nsXCqhM_4KR3CuLF9zijh3416LiJLybTuR_YA@mail.gmail.com>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
	 <1343109531.7412.47.camel@marge.simpson.net>
	 <CAJd=RBC835W52nsXCqhM_4KR3CuLF9zijh3416LiJLybTuR_YA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Stable <stable@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 2012-07-24 at 21:18 +0800, Hillf Danton wrote: 
> On Tue, Jul 24, 2012 at 1:58 PM, Mike Galbraith <efault@gmx.de> wrote:
> > FWIW, I'm all for performance backports.  They do have a downside though
> > (other than the risk of bugs slipping in, or triggering latent bugs).
> >
> > When the next enterprise kernel is built, marketeers ask for numbers to
> > make potential customers drool over, and you _can't produce any_ because
> > you wedged all the spiffy performance stuff into the crusty old kernel.
> >
> Well do your job please.
> 
> 	Suse 11 SP1 kernel panic on HP hardware
> 	https://lkml.org/lkml/2012/7/24/136

Last time I looked, handling SUSE support issues on LKML was not in my
job description.  I don't recall seeing anything about taking direction
from random LKML subscribers either.

-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
