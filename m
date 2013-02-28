Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 0CB1C6B0002
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 14:51:17 -0500 (EST)
MIME-Version: 1.0
Message-ID: <175ae3a0-2760-4ec7-869f-46a634ce321d@default>
Date: Thu, 28 Feb 2013 11:50:58 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCHv6 4/8] zswap: add to mm/
References: <<1361397888-14863-1-git-send-email-sjenning@linux.vnet.ibm.com>>
 <<1361397888-14863-5-git-send-email-sjenning@linux.vnet.ibm.com>>
 <42ac68b3-cb1f-48da-bd5e-a368ed62826f@default>
In-Reply-To: <42ac68b3-cb1f-48da-bd5e-a368ed62826f@default>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Dan Magenheimer
> Sent: Thursday, February 28, 2013 11:13 AM
> To: Seth Jennings; Andrew Morton
> Cc: Greg Kroah-Hartman; Nitin Gupta; Minchan Kim; Konrad Rzeszutek Wilk; =
Dan Magenheimer; Robert
> Jennings; Jenifer Hopper; Mel Gorman; Johannes Weiner; Rik van Riel; Larr=
y Woodman; Benjamin
> Herrenschmidt; Dave Hansen; Joe Perches; Joonsoo Kim; Cody P Schafer; lin=
ux-mm@kvack.org; linux-
> kernel@vger.kernel.org; devel@driverdev.osuosl.org
> Subject: RE: [PATCHv6 4/8] zswap: add to mm/
>=20
> > From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> > Subject: [PATCHv6 4/8] zswap: add to mm/
> >
> > +/*
> > + * Maximum compression ratio, as as percentage, for an acceptable
> > + * compressed page. Any pages that do not compress by at least
> > + * this ratio will be rejected.
> > +*/
> > +static unsigned int zswap_max_compression_ratio =3D 80;
> > +module_param_named(max_compression_ratio,
> > +=09=09=09zswap_max_compression_ratio, uint, 0644);
>=20
> Unless this is a complete coincidence, I believe that
> the default value "80" is actually:
>=20
> (100 * (1L >> ZS_MAX_ZSPAGE_ORDER)) /
>         ((1L >> ZS_MAX_ZSPAGE_ORDER)) + 1)

Doh! If it wasn't obvious, those should be left
shift operators, not right shift.  So....

(100 * (1L << ZS_MAX_ZSPAGE_ORDER)) /
        ((1L << ZS_MAX_ZSPAGE_ORDER)) + 1)

Sorry for that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
