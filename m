Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id B8AD09000BD
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 22:33:22 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p5S2XIFJ005815
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 19:33:18 -0700
Received: from yib12 (yib12.prod.google.com [10.243.65.76])
	by wpaz37.hot.corp.google.com with ESMTP id p5S2Wmne010090
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 19:33:17 -0700
Received: by yib12 with SMTP id 12so2869128yib.16
        for <linux-mm@kvack.org>; Mon, 27 Jun 2011 19:33:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <532cc290-4b9c-4eb2-91d4-aa66c01bb3a0@glegroupsg2000goo.googlegroups.com>
References: <fa.fHPNPTsllvyE/7DxrKwiwgVbVww@ifi.uio.no>
	<532cc290-4b9c-4eb2-91d4-aa66c01bb3a0@glegroupsg2000goo.googlegroups.com>
Date: Mon, 27 Jun 2011 19:33:12 -0700
Message-ID: <BANLkTik3mEJGXLrf_XtssfdRypm3NxBKvkhcnUpK=YXV6ux=Ag@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
From: Craig Bergstrom <craigb@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: fa.linux.kernel@googlegroups.com
Cc: "H. Peter Anvin" <hpa@zytor.com>, Stefan Assmann <sassmann@kpanic.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <andi@firstfloor.org>, "mingo@elte.hu" <mingo@elte.hu>, "rick@vanrein.org" <rick@vanrein.org>, "rdunlap@xenotime.net" <rdunlap@xenotime.net>, Nancy Yuen <yuenn@google.com>, Michael Ditto <mditto@google.com>

Hi All,

Just a quick update regarding the outstanding request for the
submission of Google's BadRAM patch.

I'm still making some final changes to Google's e820-based BadRAM
patch and plan to send it as an RFC patch to LKML soon (most likely
tomorrow).

Some folks had mentioned that they're interested in details about what
we've learned about bad ram from our fleet of machines.  I suspect
that you need ACM portal access to read this, but for those folks an
interesting read can be found at the link shown below.  My sincere
apologies that I cannot post a world-readable copy.

http://portal.acm.org/citation.cfm?id=3D1555372

Cheers,
CraigB

On Fri, Jun 24, 2011 at 2:10 PM, Shane Nay <snay@google.com> wrote:
>
>> > For those with a lot of ranges,
>> > like Google, the command line is insufficient.
>>
>> Not if you recognise that there is a pattern :-)
>>
>> Google does not seem to have realised that, and is simply listing
>> the pages that are defected. =A0IMHO, but being the BadRAM author I
>> can hardly be called objective, this is the added value of BadRAM,
>> that it understands the nature of the problem and solves it with
>> an elegant concept at the right level of abstraction.
>
> No, we have realized patterns when there is one. =A0It depends on the spe=
cific defect that is at play. =A0There are several different defect types, =
and incidence rate with respect to the defect being observed. =A0We do obse=
rve "classic" failures of the type you are describing, where with the physi=
cal addressing information (bank, row, column), we can reproducibly cause e=
rrors to occur along that path.
>
> One problem is that badram syntax doesn't cleanly mesh with all modern sy=
stems. =A0For instance, not all chipsets have power-of-two bank interleave.=
 =A0Holes in addressing also create trouble on some systems.
>
> Other defects look like white noise, these are typically indicative of ma=
nufacturing process defects.
>
> When we find a crisp-pattern in the data, it's not always the entirety of=
 that bit-maskable pattern which is effected. =A0There can be interleaved s=
ubtractions from the underlying pattern orthogonal to interleave.
>
> IMHO, badram is a good tool for it's intended purpose. =A0They aren't rea=
lly mutually exclusive anyway. =A0We're cleaning up our existing patches to=
 send out early next week. =A0However, we had at one time had a way of inse=
rting badram syntax generated e820's from command line along with passed in=
 e820's, and extended versions. =A0That bit isn't in our tree right now, bu=
t it's possible, and we're looking to see if we can make it work with the e=
xisting code.
>
>
>> s (and
>> living by them) for failing memory pages. =A0One property of BadRAM,
>> namely that it does not slow down your system (you have less
>> pages on hand, but that's all) may or may not apply to an e820-based
>> approach. =A0I don't know if e820 is ever consulted after boot?
>>
>> > How common are nontrivial patterns on real hardware? =A0This would be
>> > interesting to hear from Google or another large user.
>>
>> Yes. =A0And "non-trivial" would mean that the patterns waste more space
>> than fair, *because of* the generalisation to patterns.
>>
>> If you plug 10 DIMMs into your machine, and each has a faulty row
>> somewhere, then you will get into trouble if you stick to 5 patterns.
>> But if you happen to run into a faulty DIMM from time to time, the
>> patterns should be your way out.
>>
>> > I have to say I think Google's point that truncating the list is
>> > unacceptable...
>>
>> Of course, that is true. =A0This is why memmap=3D... does not work.
>> It has nothing to do with BadRAM however, there will never be more
>> than 5 patterns.
>>
>> > that would mean running in a known-bad configuration,
>> > and even a hard crash would be better.
>>
>> ..which is so sensible that it was of course taken into account in
>> the BadRAM design!
>>
>>
>> Cheers,
>> =A0-Rick
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" =
in
>> the body of a message to majo...@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at =A0http://www.tux.org/lkml/
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
