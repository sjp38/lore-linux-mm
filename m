Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 917C56B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 10:07:50 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <f54214e7-cee4-4cbf-aad1-6c1f91867879@default>
Date: Mon, 6 Aug 2012 07:07:23 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC/PATCH] zcache/ramster rewrite and promotion
References: <c31aaed4-9d50-4cdf-b794-367fc5850483@default>
 <CAOJsxLEhW=b3En737d5751xufW2BLehPc2ZGGG1NEtRVSo3=jg@mail.gmail.com>
 <b9bee363-321e-409a-bc8e-65ffed8a1dc5@default>
 <CAOJsxLHe6egmMWdEAGj7DGHHX-hqYMhVWDggny9CsT0H-DOL-g@mail.gmail.com>
In-Reply-To: <CAOJsxLHe6egmMWdEAGj7DGHHX-hqYMhVWDggny9CsT0H-DOL-g@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> From: Pekka Enberg [mailto:penberg@kernel.org]
> Subject: Re: [RFC/PATCH] zcache/ramster rewrite and promotion
>=20
> Hi Dan,
>=20
> On Wed, Aug 1, 2012 at 12:13 AM, Dan Magenheimer
> <dan.magenheimer@oracle.com> wrote:
> > Ramster does the same thing but manages it peer-to-peer across
> > multiple systems using kernel sockets.  One could argue that
> > the dependency on sockets makes it more of a driver than "mm"
> > but ramster is "memory management" too, just a bit more exotic.
>=20
> How do you configure it?

Hi Pekka --

It looks like the build/configuration how-to at
https://oss.oracle.com/projects/tmem/dist/files/RAMster/HOWTO-v5-120214=20
is out-of-date and I need to fix some things in it.  I'll post
a link to it after I update it.

> Can we move parts of the network protocol under
> net/ramster or something?

Ramster is built on top of kernel sockets.  Both that networking
part and the configuration part of the ramster code are heavily
leveraged from ocfs2 and I suspect there is a lot of similarity
to gfs code as well.  In the code for both of those filesystems
I think the network and configuration code lives in the same
directory with the file system, so that was the model I was following.

I'm OK with placing it wherever kernel developers want to put
it, as long as the reason is not NIMBY-ness. [1]  My preference
is to keep all the parts together, at least for the review phase,
but if there is a consensus that it belongs someplace else,
I will be happy to move it.

Dan

[1] http://en.wikipedia.org/wiki/NIMBY

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
