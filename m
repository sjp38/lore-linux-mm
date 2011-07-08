Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E0F249000C2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 20:08:09 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p68086cE014787
	for <linux-mm@kvack.org>; Thu, 7 Jul 2011 17:08:06 -0700
Received: from pvg18 (pvg18.prod.google.com [10.241.210.146])
	by wpaz1.hot.corp.google.com with ESMTP id p68084pr019499
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 7 Jul 2011 17:08:05 -0700
Received: by pvg18 with SMTP id 18so942836pvg.38
        for <linux-mm@kvack.org>; Thu, 07 Jul 2011 17:08:04 -0700 (PDT)
Date: Thu, 7 Jul 2011 17:07:47 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Hugepages for shm page cache (defrag)
In-Reply-To: <5be3df4081574f3d4e1e699f028549a7@rsmogura.net>
Message-ID: <alpine.LSU.2.00.1107071643370.10165@sister.anvils>
References: <201107062131.01717.mail@smogura.eu> <m2pqlmy7z8.fsf@firstfloor.org> <5be3df4081574f3d4e1e699f028549a7@rsmogura.net>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-2075155698-1310083679=:10165"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Radoslaw Smogura <mail@rsmogura.net>
Cc: Radislaw Smogura <mail@rsmogura.eu>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, aarcange@redhat.com

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-2075155698-1310083679=:10165
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 7 Jul 2011, mail@rsmogura.net wrote:
> On Wed, 06 Jul 2011 22:28:59 -0700, Andi Kleen wrote:
> > Rados=C5=82aw Smogura <mail@smogura.eu> writes:
> >=20
> > > Hello,
> > >=20
> > > This is may first try with Linux patch, so please do not blame me too
> > > much.
> > > Actually I started with small idea to add MAP_HUGTLB for /dev/shm but=
 it
> > > grew
> > > up in something more like support for huge pages in page cache, but
> > > according
> > > to documentation to submit alpha-work too, I decided to send this.
> >=20
> > Shouldn't this be rather integrated with the normal transparent huge
> > pages? It seems odd to develop parallel infrastructure.
> >=20
> > -Andi

Although Andi's sig says "Speaking for myself only",
he is very much speaking for me on this too ;)

There is definitely interest in extending Transparent Huge Pages to tmpfs;
though so far as I know, nobody has yet had time to think through just
what that will entail.

Correspondingly, I'm afraid there would be little interest in adding yet
another variant of hugepages into the kernel - enough ugliness already!

> It's not quite good to ask me about this, as I'm starting hacker, but I
> think it should be treated as counterpart for page cache, and actually I =
got
> few "collisions" with THP.
>=20
> High level design will probably be the same (e.g. I use defrag_, THP uses
> collapse_ for creating huge page), but in contrast I try to operate on pa=
ge
> cache, so in some way file system must be huge page aware (shm fs is not,=
 as
> it can move page from page cache to swap cache - it may silently fragment
> de-fragmented areas).
>=20
> I put some requirements for work, e. g. mapping file as huge should not
> affect previous or future, even fancy, non huge mappings, both callers
> should succeed and get this what they asked for.
>=20
> Of course I think how to make it more "transparent" without need of file
> system support, but I suppose it may be dead-corner.
>=20
> I still want to emphasise it's really alpha version.

I barely looked at it, but did notice that scripts/checkpatch.pl reports
127 errors and 111 warnings, plus it seems to be significantly incomplete
(an extern declaration of defragPageCache() but not the function itself).

And it serves no purpose without the pte work you mention (there
is no point to a shmem hugepage unless it is mapped in that way).

Sorry to be discouraging, but extending THP is likely to be the way to go.

Hugh
--8323584-2075155698-1310083679=:10165--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
