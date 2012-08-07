Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id F0F056B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 20:42:39 -0400 (EDT)
Date: Tue, 7 Aug 2012 09:44:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/4] promote zcache from staging
Message-ID: <20120807004405.GA19515@bbox>
References: <d4656ba5-d6d1-4c36-a6c8-f6ecd193b31d@default>
 <5016DE4E.5050300@linux.vnet.ibm.com>
 <f47a6d86-785f-498c-8ee5-0d2df1b2616c@default>
 <20120731155843.GP4789@phenom.dumpdata.com>
 <20120731161916.GA4941@kroah.com>
 <20120731175142.GE29533@phenom.dumpdata.com>
 <20120806003816.GA11375@bbox>
 <041cb4ce-48ae-4600-9f11-d722bc03b9cc@default>
 <CAOJsxLHDcgxxu146QWXw0ZhMHMhFOquEFXhF55HK2mCjHzk7hw@mail.gmail.com>
 <be1daa96-d246-46de-a178-b14b3a862eca@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <be1daa96-d246-46de-a178-b14b3a862eca@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Pekka Enberg <penberg@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad@darnok.org>, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

Hi Dan,

On Mon, Aug 06, 2012 at 09:21:22AM -0700, Dan Magenheimer wrote:
> > From: Pekka Enberg [mailto:penberg@kernel.org]
> > Subject: Re: [PATCH 0/4] promote zcache from staging
> > 
> > On Mon, Aug 6, 2012 at 6:24 PM, Dan Magenheimer
> > <dan.magenheimer@oracle.com> wrote:
> > > IMHO, the fastest way to get the best zcache into the kernel and
> > > to distros and users is to throw away the "demo" version, move forward
> > > to a new solid well-designed zcache code base, and work together to
> > > build on it.  There's still a lot to do so I hope we can work together.
> > 
> > I'm not convinced it's the _fastest way_.
> 
> <grin> I guess I meant "optimal", combining "fast" and "best".
> 
> > You're effectively
> > invalidating all the work done under drivers/staging so you might end up
> > in review limbo with your shiny new code...
> 
> Fixing the fundamental design flaws will sooner or later invalidate
> most (or all) of the previous testing/work anyway, won't it?  Since
> any kernel built with staging is "tainted" already, I feel like now
> is a better time to make a major design transition.
> 
> I suppose:
> 
>  (E) replace "demo" zcache with new code base and keep it
>      in staging for another cycle

I go for (E). Please send your refactoring code as formal patch.
Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
