Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A1F376B002D
	for <linux-mm@kvack.org>; Fri,  4 Nov 2011 04:49:10 -0400 (EDT)
Message-Id: <4EB3B52E020000780005EF43@nat28.tlf.novell.com>
Date: Fri, 04 Nov 2011 08:49:34 +0000
From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <4EB2D427020000780005ED64@nat28.tlf.novell.com>
 <20111103175410.b15efb8c.akpm@linux-foundation.org>
In-Reply-To: <20111103175410.b15efb8c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Neo Jia <cyclonusj@gmail.com>, levinsasha928@gmail.com, JeremyFitzhardinge <jeremy@goop.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Chris Mason <chris.mason@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, ngupta@vflare.org, LKML <linux-kernel@vger.kernel.org>

>>> On 04.11.11 at 01:54, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Thu, 03 Nov 2011 16:49:27 +0000 "Jan Beulich" <JBeulich@suse.com> =
wrote:
>=20
>> >>> On 27.10.11 at 20:52, Dan Magenheimer <dan.magenheimer@oracle.com> =
wrote:
>> > Hi Linus --
>> >=20
>> > Frontswap now has FOUR users: Two already merged in-tree (zcache
>> > and Xen) and two still in development but in public git trees
>> > (RAMster and KVM).  Frontswap is part 2 of 2 of the core kernel
>> > changes required to support transcendent memory; part 1 was cleancache=

>> > which you merged at 3.0 (and which now has FIVE users).
>> >=20
>> > Frontswap patches have been in linux-next since June 3 (with zero
>> > changes since Sep 22).  First posted to lkml in June 2009, =
frontswap=20
>> > is now at version 11 and has incorporated feedback from a wide range
>> > of kernel developers.  For a good overview, see
>> >    http://lwn.net/Articles/454795.
>> > If further rationale is needed, please see the end of this email
>> > for more info.
>> >=20
>> > SO... Please pull:
>> >=20
>> > git://oss.oracle.com/git/djm/tmem.git #tmem
>> >=20
>> >...
>> > Linux kernel distros incorporating frontswap:
>> > - Oracle UEK 2.6.39 Beta:
>> >    http://oss.oracle.com/git/?p=3Dlinux-2.6-unbreakable-beta.git;a=3Ds=
ummary=20
>> > - OpenSuSE since 11.2 (2009) [see mm/tmem-xen.c]
>> >    http://kernel.opensuse.org/cgit/kernel/=20
>>=20
>> I've been away so I am too far behind to read this entire
>> very long thread, but wanted to confirm that we've been
>> carrying an earlier version of this code as indicated above
>> and it would simplify our kernel maintenance if frontswap
>> got merged.  So please count me as supporting frontswap.
>=20
> Are you able to tell use *why* you're carrying it, and what benefit it
> is providing to your users?

Because we're supporting/using Xen, where this (within the general
tmem picture) allows for better overall memory utilization.

Jan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
