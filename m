Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 8F7386B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 12:22:46 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <be1daa96-d246-46de-a178-b14b3a862eca@default>
Date: Mon, 6 Aug 2012 09:21:22 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 0/4] promote zcache from staging
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <b95aec06-5a10-4f83-bdfd-e7f6adabd9df@default>
 <20120727205932.GA12650@localhost.localdomain>
 <d4656ba5-d6d1-4c36-a6c8-f6ecd193b31d@default>
 <5016DE4E.5050300@linux.vnet.ibm.com>
 <f47a6d86-785f-498c-8ee5-0d2df1b2616c@default>
 <20120731155843.GP4789@phenom.dumpdata.com> <20120731161916.GA4941@kroah.com>
 <20120731175142.GE29533@phenom.dumpdata.com> <20120806003816.GA11375@bbox>
 <041cb4ce-48ae-4600-9f11-d722bc03b9cc@default>
 <CAOJsxLHDcgxxu146QWXw0ZhMHMhFOquEFXhF55HK2mCjHzk7hw@mail.gmail.com>
In-Reply-To: <CAOJsxLHDcgxxu146QWXw0ZhMHMhFOquEFXhF55HK2mCjHzk7hw@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad@darnok.org>, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

> From: Pekka Enberg [mailto:penberg@kernel.org]
> Subject: Re: [PATCH 0/4] promote zcache from staging
>=20
> On Mon, Aug 6, 2012 at 6:24 PM, Dan Magenheimer
> <dan.magenheimer@oracle.com> wrote:
> > IMHO, the fastest way to get the best zcache into the kernel and
> > to distros and users is to throw away the "demo" version, move forward
> > to a new solid well-designed zcache code base, and work together to
> > build on it.  There's still a lot to do so I hope we can work together.
>=20
> I'm not convinced it's the _fastest way_.

<grin> I guess I meant "optimal", combining "fast" and "best".

> You're effectively
> invalidating all the work done under drivers/staging so you might end up
> in review limbo with your shiny new code...

Fixing the fundamental design flaws will sooner or later invalidate
most (or all) of the previous testing/work anyway, won't it?  Since
any kernel built with staging is "tainted" already, I feel like now
is a better time to make a major design transition.

I suppose:

 (E) replace "demo" zcache with new code base and keep it
     in staging for another cycle

is another alternative, but I think gregkh has said no to that.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
