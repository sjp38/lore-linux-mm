Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B10786B01C4
	for <linux-mm@kvack.org>; Mon, 31 May 2010 13:15:24 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <a38d5a97-1517-46c4-9b2f-27e16aba58f2@default>
Date: Mon, 31 May 2010 10:14:07 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V2 0/4] Frontswap (was Transcendent Memory): overview
References: <20100528174020.GA28150@ca-server1.us.oracle.com
 4C02AB5A.5000706@vflare.org>
In-Reply-To: <4C02AB5A.5000706@vflare.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com, avi@redhat.com, pavel@ucw.cz, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

> On 05/28/2010 11:10 PM, Dan Magenheimer wrote:
> > [PATCH V2 0/4] Frontswap (was Transcendent Memory): overview
> >
> > Changes since V1:
> > - Rebased to 2.6.34 (no functional changes)
> > - Convert to sane types (per Al Viro comment in cleancache thread)
> > - Define some raw constants (Konrad Wilk)
> > - Performance analysis shows significant advantage for frontswap's
> >   synchronous page-at-a-time design (vs batched asynchronous
> speculated
> >   as an alternative design).  See http://lkml.org/lkml/2010/5/20/314
> >
>=20
> I think zram (http://lwn.net/Articles/388889/) is a more generic
> solution
> and can also achieve swap-to-hypervisor as a special case.
>=20
> zram is a generic in-memory compressed block device. To get frontswap
> functionality, such a device (/dev/zram0) can be exposed to a VM as
> a 'raw disk'. Such a disk can be used for _any_ purpose by the guest,
> including use as a swap disk.

Hi Nitin --

Though I agree zram is cool inside Linux, I don't see that it can
be used to get the critical value of frontswap functionality in a
virtual environment, specifically the 100% dynamic control by the
hypervisor of every single page attempted to be "put" to frontswap.
This is the key to the "intelligent overcommit" discussed in the
previous long thread about frontswap.

Further, by doing "guest-side compression" you are eliminating
possibilities for KSM-style sharing, right?

So while zram may be a great feature, it is NOT a more generic
solution than frontswap, just a different solution that has a
different set of objectives.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
