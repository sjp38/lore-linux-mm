Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C5FCB6B004A
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 10:32:17 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <871d7dbc-041f-411f-b91a-cbc5aeb9db98@default>
Date: Fri, 1 Jul 2011 07:31:54 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH v2] staging: zcache: support multiple clients, prep for
 KVM and RAMster
References: <1d15f28a-56df-4cf4-9dd9-1032f211c0d0@default20110630224019.GC2544@shale.localdomain>
 <3b67511f-bad9-4c41-915b-1f6e196f4d43@default
 20110701083850.GE2544@shale.localdomain>
In-Reply-To: <20110701083850.GE2544@shale.localdomain>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <error27@gmail.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Marcus Klemm <marcus.klemm@googlemail.com>, kvm@vger.kernel.org, Konrad Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, devel@linuxdriverproject.org

> From: Dan Carpenter [mailto:error27@gmail.com]
>=20
> On Thu, Jun 30, 2011 at 04:28:14PM -0700, Dan Magenheimer wrote:
> > Hi Dan --
> >
> > Thanks for the careful review.  You're right... some
> > of this was leftover from debugging an off-by-one error,
> > though the code as is still works.
> >
> > OTOH, there's a good chance that much of this sysfs
> > code will disappear before zcache would get promoted
> > out of staging, since it is to help those experimenting
> > with zcache to get more insight into what the underlying
> > compression/accept-reject algorithms are doing.
> >
> > So I hope you (and GregKH) are OK that another version is
> > not necessary at this time to fix these.
>=20
> Off by one errors are kind of insidious.  People cut and paste them
> and they spread.  If someone adds a new list of chunks then there
> are now two examples that are correct and two which have an extra
> element, so it's 50/50 that he'll copy the right one.

True, but these are NOT off-by-one errors... they are
correct-but-slightly-ugly code snippets.  (To clarify, I said
the *ugliness* arose when debugging an off-by-one error.)

Patches always welcome, and I agree that these should be
fixed eventually, assuming the code doesn't go away completely
first.. I'm simply stating the position
that going through another test/submit cycling to fix
correct-but-slightly-ugly code which is present only to
surface information for experiments is not high on my priority
list right now... unless GregKH says he won't accept the patch.
=20
> Btw, looking at it again, this seems like maybe a similar issue in
> zbud_evict_zbpg():
>=20
>    516          for (i =3D 0; i < MAX_CHUNK; i++) {
>    517  retry_unbud_list_i:
>=20
>=20
> MAX_CHUNKS is NCHUNKS - 1.  Shouldn't that be i < NCHUNKS so that we
> reach the last element in the list?

No, the last element in that list is unused.  There is a comment
to that effect someplace in the code.  (These lists are keeping
track of pages with "chunks" of available space and the last
entry would have no available space so is always empty.)

Thanks again for your interest... are you using zcache?

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
