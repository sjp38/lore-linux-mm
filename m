Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 531D96B004D
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 15:46:08 -0500 (EST)
MIME-Version: 1.0
Message-ID: <98bc4ff9-07bd-44ab-bb25-156c04d8f1e1@default>
Date: Tue, 27 Dec 2011 12:34:37 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V2 1/6] drivers/staging/ramster: cluster/messaging
 foundation
References: <20111222155050.GA21405@ca-server1.us.oracle.com>
 <20111222173129.GB28856@kroah.com>
 <1f76c37d-15d4-4c62-8c64-8293d3382b4a@default>
 <20111222224059.GA16558@kroah.com>
In-Reply-To: <20111222224059.GA16558@kroah.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, Kurt Hackel <kurt.hackel@oracle.com>, sjenning@linux.vnet.ibm.com, Chris Mason <chris.mason@oracle.com>

> From: Greg KH [mailto:greg@kroah.com]
>=20
> Ok, that makes sense.
>=20
> Can you ensure that the TODO file in this driver's directory says that
> you will remove the duplicated code from it before it can be merged into
> the main part of the kernel tree?
>=20
> That, and fix up the other things mentioned and resend it and I'll be
> glad to queue it up.

Done and reposted, but....

ARGH! Greg, somehow I left your direct email address off of the To list
for the repost!  Will you be able to get them from the drivers (or mm
or lkml) list, or will you need me to re-post them (just to you or
also again to the same To list?)

Sorry,
Dan

P.S. V3 starts with: https://lkml.org/lkml/2011/12/27/158 or
http://driverdev.linuxdriverproject.org/pipermail/devel/2011-December/02373=
6.html=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
