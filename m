Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1C40C6B004A
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 19:28:37 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <3b67511f-bad9-4c41-915b-1f6e196f4d43@default>
Date: Thu, 30 Jun 2011 16:28:14 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH v2] staging: zcache: support multiple clients, prep for
 KVM and RAMster
References: <1d15f28a-56df-4cf4-9dd9-1032f211c0d0@default
 20110630224019.GC2544@shale.localdomain>
In-Reply-To: <20110630224019.GC2544@shale.localdomain>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <error27@gmail.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Marcus Klemm <marcus.klemm@googlemail.com>, kvm@vger.kernel.org, Konrad Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, devel@linuxdriverproject.org

> > +=09for (i =3D 0; i <=3D NCHUNKS - 1; i++) {
>=20
> It's more common to write the condition as:  i < NCHUNKS.
>=20
> > +=09=09n =3D zv_curr_dist_counts[i];
>=20
> zv_curr_dist_counts has NCHUNKS + 1 elements so we never print
> display the final element.  I don't know this coe, so I could be
> wrong but I think that we could make zv_curr_dist_counts only hold
> NCHUNKS elements.
>=20
> > +=09for (i =3D 0; i <=3D NCHUNKS - 1; i++) {
>=20
> Same situation.

Hi Dan --

Thanks for the careful review.  You're right... some
of this was leftover from debugging an off-by-one error,
though the code as is still works.

OTOH, there's a good chance that much of this sysfs
code will disappear before zcache would get promoted
out of staging, since it is to help those experimenting
with zcache to get more insight into what the underlying
compression/accept-reject algorithms are doing.

So I hope you (and GregKH) are OK that another version is
not necessary at this time to fix these.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
