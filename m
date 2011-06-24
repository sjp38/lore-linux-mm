Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8544190023D
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 17:10:54 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p5OLApYV032547
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 14:10:51 -0700
Received: from pva18 (pva18.prod.google.com [10.241.209.18])
	by wpaz5.hot.corp.google.com with ESMTP id p5OLAj7F025182
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 14:10:50 -0700
Received: by pva18 with SMTP id 18so1741958pva.23
        for <linux-mm@kvack.org>; Fri, 24 Jun 2011 14:10:45 -0700 (PDT)
Date: Fri, 24 Jun 2011 14:10:45 -0700 (PDT)
In-Reply-To: <fa.fHPNPTsllvyE/7DxrKwiwgVbVww@ifi.uio.no>
Reply-To: fa.linux.kernel@googlegroups.com
MIME-Version: 1.0
Message-ID: <532cc290-4b9c-4eb2-91d4-aa66c01bb3a0@glegroupsg2000goo.googlegroups.com>
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
From: Shane Nay <snay@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: fa.linux.kernel@googlegroups.com
Cc: "H. Peter Anvin" <hpa@zytor.com>, Stefan Assmann <sassmann@kpanic.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, rick@vanrein.org, rdunlap@xenotime.net, Nancy Yuen <yuenn@google.com>, Michael Ditto <mditto@google.com>


> > For those with a lot of ranges,
> > like Google, the command line is insufficient.
>=20
> Not if you recognise that there is a pattern :-)
>=20
> Google does not seem to have realised that, and is simply listing
> the pages that are defected.  IMHO, but being the BadRAM author I
> can hardly be called objective, this is the added value of BadRAM,
> that it understands the nature of the problem and solves it with
> an elegant concept at the right level of abstraction.

No, we have realized patterns when there is one.  It depends on the specifi=
c defect that is at play.  There are several different defect types, and in=
cidence rate with respect to the defect being observed.  We do observe "cla=
ssic" failures of the type you are describing, where with the physical addr=
essing information (bank, row, column), we can reproducibly cause errors to=
 occur along that path.

One problem is that badram syntax doesn't cleanly mesh with all modern syst=
ems.  For instance, not all chipsets have power-of-two bank interleave.  Ho=
les in addressing also create trouble on some systems.

Other defects look like white noise, these are typically indicative of manu=
facturing process defects.

When we find a crisp-pattern in the data, it's not always the entirety of t=
hat bit-maskable pattern which is effected.  There can be interleaved subtr=
actions from the underlying pattern orthogonal to interleave.

IMHO, badram is a good tool for it's intended purpose.  They aren't really =
mutually exclusive anyway.  We're cleaning up our existing patches to send =
out early next week.  However, we had at one time had a way of inserting ba=
dram syntax generated e820's from command line along with passed in e820's,=
 and extended versions.  That bit isn't in our tree right now, but it's pos=
sible, and we're looking to see if we can make it work with the existing co=
de.


> s (and
> living by them) for failing memory pages.  One property of BadRAM,
> namely that it does not slow down your system (you have less
> pages on hand, but that's all) may or may not apply to an e820-based
> approach.  I don't know if e820 is ever consulted after boot?
>=20
> > How common are nontrivial patterns on real hardware?  This would be
> > interesting to hear from Google or another large user.
>=20
> Yes.  And "non-trivial" would mean that the patterns waste more space
> than fair, *because of* the generalisation to patterns.
>=20
> If you plug 10 DIMMs into your machine, and each has a faulty row
> somewhere, then you will get into trouble if you stick to 5 patterns.
> But if you happen to run into a faulty DIMM from time to time, the
> patterns should be your way out.
>=20
> > I have to say I think Google's point that truncating the list is
> > unacceptable...
>=20
> Of course, that is true.  This is why memmap=3D... does not work.
> It has nothing to do with BadRAM however, there will never be more
> than 5 patterns.
>=20
> > that would mean running in a known-bad configuration,
> > and even a hard crash would be better.
>=20
> ..which is so sensible that it was of course taken into account in
> the BadRAM design!
>=20
>=20
> Cheers,
>  -Rick
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majo...@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
