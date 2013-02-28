Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 9BFD46B0005
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 13:13:47 -0500 (EST)
MIME-Version: 1.0
Message-ID: <42ac68b3-cb1f-48da-bd5e-a368ed62826f@default>
Date: Thu, 28 Feb 2013 10:13:28 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCHv6 4/8] zswap: add to mm/
References: <<1361397888-14863-1-git-send-email-sjenning@linux.vnet.ibm.com>>
 <<1361397888-14863-5-git-send-email-sjenning@linux.vnet.ibm.com>>
In-Reply-To: <<1361397888-14863-5-git-send-email-sjenning@linux.vnet.ibm.com>>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: [PATCHv6 4/8] zswap: add to mm/
>=20
> +/*
> + * Maximum compression ratio, as as percentage, for an acceptable
> + * compressed page. Any pages that do not compress by at least
> + * this ratio will be rejected.
> +*/
> +static unsigned int zswap_max_compression_ratio =3D 80;
> +module_param_named(max_compression_ratio,
> +=09=09=09zswap_max_compression_ratio, uint, 0644);

Unless this is a complete coincidence, I believe that
the default value "80" is actually:

(100 * (1L >> ZS_MAX_ZSPAGE_ORDER)) /
        ((1L >> ZS_MAX_ZSPAGE_ORDER)) + 1)

(though the constant ZS_MAX_ZSPAGE_ORDER is not currently
defined outside of zsmalloc.c) because pages that compress
less efficiently than this always require a full pageframe
in zsmalloc.  True?

If this change were made, is there any real reason for this
to be a user-selectable parameter, i.e. given the compression
internals knowledge necessary to understand what value should
be selected, would any mortal sysadmin ever want to change it
or know what would be a reasonable value to change it to?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
