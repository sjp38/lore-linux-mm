Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 177DF6B0032
	for <linux-mm@kvack.org>; Wed, 15 May 2013 16:56:11 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <25f0f975-d9aa-4e00-bc34-acfd9b86b6bd@default>
Date: Wed, 15 May 2013 13:55:44 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCHv11 3/4] zswap: add to mm/
References: <1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1368448803-2089-4-git-send-email-sjenning@linux.vnet.ibm.com>
 <15c5b1da-132a-4c9e-9f24-bc272d3865d5@default>
 <20130514163541.GC4024@medulla>
 <f0272a06-141a-4d33-9976-ee99467f3aa2@default>
 <20130514225501.GA11956@cerebellum>
 <4d74f5db-11c1-4f58-97f4-8d96bbe601ac@default>
 <20130515185506.GA23342@phenom.dumpdata.com>
 <20130515200942.GA17724@cerebellum> <5193EEE7.80603@sr71.net>
In-Reply-To: <5193EEE7.80603@sr71.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Dave Hansen [mailto:dave@sr71.net]
> Sent: Wednesday, May 15, 2013 2:24 PM
> To: Seth Jennings
> Cc: Konrad Rzeszutek Wilk; Dan Magenheimer; Andrew Morton; Greg Kroah-Har=
tman; Nitin Gupta; Minchan
> Kim; Robert Jennings; Jenifer Hopper; Mel Gorman; Johannes Weiner; Rik va=
n Riel; Larry Woodman;
> Benjamin Herrenschmidt; Joe Perches; Joonsoo Kim; Cody P Schafer; Hugh Di=
ckens; Paul Mackerras; linux-
> mm@kvack.org; linux-kernel@vger.kernel.org; devel@driverdev.osuosl.org
> Subject: Re: [PATCHv11 3/4] zswap: add to mm/
>=20
> On 05/15/2013 01:09 PM, Seth Jennings wrote:
> > On Wed, May 15, 2013 at 02:55:06PM -0400, Konrad Rzeszutek Wilk wrote:
> >>> Sorry, but I don't think that's appropriate for a patch in the MM sub=
system.
> >>
> >> Perhaps a compromise can be reached where this code is merged as a dri=
ver
> >> not a core mm component. There is a high bar to be in the MM - it has =
to
> >> work with many many different configurations.
> >>
> >> And drivers don't have such a high bar. They just need to work on a sp=
ecific
> >> issue and that is it. If zswap ended up in say, drivers/mm that would =
make
> >> it more palpable I think.
>=20
> The issue is not whether it is a loadable module or a driver.  Nobody
> here is stupid enough to say, "hey, now it's a driver/module, all of the
> complex VM interactions are finally fixed!"
>=20
> If folks don't want this in their system, there's a way to turn it off,
> today, with the sysfs tunables.  We don't need _another_ way to turn it
> off at runtime (unloading the module/driver).

The issue is we KNOW the complex VM interactions are NOT fixed
and there has been very very little breadth testing (i.e.
across a wide range of workloads, and any attempts to show
how much harm can come from enabling it.)

That's (at least borderline) acceptable in a driver that can
be unloaded, but not in MM code IMHO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
