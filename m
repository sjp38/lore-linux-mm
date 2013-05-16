Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 7F5666B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 12:46:21 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <b12c2e22-f41c-490d-9d74-c85aa397e017@default>
Date: Thu, 16 May 2013 09:45:43 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCHv11 3/4] zswap: add to mm/
References: <1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1368448803-2089-4-git-send-email-sjenning@linux.vnet.ibm.com>
 <15c5b1da-132a-4c9e-9f24-bc272d3865d5@default>
 <20130514163541.GC4024@medulla>
 <f0272a06-141a-4d33-9976-ee99467f3aa2@default> <519408D6.10903@redhat.com>
In-Reply-To: <519408D6.10903@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, Jonathan Corbet <corbet@lwn.net>

> From: Rik van Riel [mailto:riel@redhat.com]
> Sent: Wednesday, May 15, 2013 4:15 PM
> To: Dan Magenheimer
> Cc: Seth Jennings; Andrew Morton; Greg Kroah-Hartman; Nitin Gupta; Mincha=
n Kim; Konrad Wilk; Robert
> Jennings; Jenifer Hopper; Mel Gorman; Johannes Weiner; Larry Woodman; Ben=
jamin Herrenschmidt; Dave
> Hansen; Joe Perches; Joonsoo Kim; Cody P Schafer; Hugh Dickens; Paul Mack=
erras; linux-mm@kvack.org;
> linux-kernel@vger.kernel.org; devel@driverdev.osuosl.org
> Subject: Re: [PATCHv11 3/4] zswap: add to mm/
>=20
> On 05/14/2013 04:18 PM, Dan Magenheimer wrote:
>=20
> > It's unfortunate that my proposed topic for LSFMM was pre-empted
> > by the zsmalloc vs zbud discussion and zswap vs zcache, because
> > I think the real challenge of zswap (or zcache) and the value to
> > distros and end users requires us to get this right BEFORE users
> > start filing bugs about performance weirdness.  After which most
> > users and distros will simply default to 0% (i.e. turn zswap off)
> > because zswap unpredictably sometimes sucks.
>=20
> I'm not sure we can get it right before people actually start
> using it for real world setups, instead of just running benchmarks
> on it.
>=20
> The sooner we get the code out there, where users can play with
> it (even if it is disabled by default and needs a sysfs or
> sysctl config option to enable it), the sooner we will know how
> well it works, and what needs to be changed.

/me sets stage of first Star Wars (1977)

/me envisions self as Obi-Wan Kenobi, old and tired of fighting,
in lightsaber battle with protege Darth Vader / Anakin Skywalker

/me sadly turns off lightsaber, holds useless handle at waist,
takes a deep breath, and promptly gets sliced into oblivion.

Time for A New Hope(tm).

(/me cc's Jon Corbet for a longshot last chance of making LWN's
Kernel Development Quotes of the Week.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
