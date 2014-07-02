Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id D7E586B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 21:29:13 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id t60so10558745wes.4
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 18:29:13 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ku4si11809485wjb.157.2014.07.01.18.29.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 18:29:12 -0700 (PDT)
Date: Wed, 2 Jul 2014 11:28:58 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH] SCHED: remove proliferation of wait_on_bit action
 functions.
Message-ID: <20140702112858.12c8a504@notabene.brown>
In-Reply-To: <20140606060419.GA3737@gmail.com>
References: <20140501123738.3e64b2d2@notabene.brown>
	<20140522090502.GB30094@gmail.com>
	<20140522195056.445f2dcb@notabene.brown>
	<20140605124509.GA1975@gmail.com>
	<20140606102303.09ef9fb3@notabene.brown>
	<20140606060419.GA3737@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/=QYeP+QY288.xRlZtBKJOUE"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>, David Howells <dhowells@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, dm-devel@redhat.com, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, Steve French <sfrench@samba.org>, Theodore Ts'o <tytso@mit.edu>, Trond Myklebust <trond.myklebust@primarydata.com>, Ingo Molnar <mingo@redhat.com>, Roland McGrath <roland@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

--Sig_/=QYeP+QY288.xRlZtBKJOUE
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 6 Jun 2014 08:04:19 +0200 Ingo Molnar <mingo@kernel.org> wrote:

>=20
> * NeilBrown <neilb@suse.de> wrote:
>=20
> > On Thu, 5 Jun 2014 14:45:09 +0200 Ingo Molnar <mingo@kernel.org> wrote:
> >=20
> > >=20
> > > * NeilBrown <neilb@suse.de> wrote:
> > >=20
> > > > On Thu, 22 May 2014 11:05:02 +0200 Ingo Molnar <mingo@kernel.org> w=
rote:
> > > >=20
> > > > >=20
> > > > > * NeilBrown <neilb@suse.de> wrote:
> > > > >=20
> > > > > > [[ get_maintainer.pl suggested 61 email address for this patch.
> > > > > >    I've trimmed that list somewhat.  Hope I didn't miss anyone
> > > > > >    important...
> > > > > >    I'm hoping it will go in through the scheduler tree, but wou=
ld
> > > > > >    particularly like an Acked-by for the fscache parts.  Other =
acks
> > > > > >    welcome.
> > > > > > ]]
> > > > > >=20
> > > > > > The current "wait_on_bit" interface requires an 'action' functi=
on
> > > > > > to be provided which does the actual waiting.
> > > > > > There are over 20 such functions, many of them identical.
> > > > > > Most cases can be satisfied by one of just two functions, one
> > > > > > which uses io_schedule() and one which just uses schedule().
> > > > > >=20
> > > > > > So:
> > > > > >  Rename wait_on_bit and        wait_on_bit_lock to
> > > > > >         wait_on_bit_action and wait_on_bit_lock_action
> > > > > >  to make it explicit that they need an action function.
> > > > > >=20
> > > > > >  Introduce new wait_on_bit{,_lock} and wait_on_bit{,_lock}_io
> > > > > >  which are *not* given an action function but implicitly use
> > > > > >  a standard one.
> > > > > >  The decision to error-out if a signal is pending is now made
> > > > > >  based on the 'mode' argument rather than being encoded in the =
action
> > > > > >  function.
> > > > >=20
> > > > > this patch fails to build on x86-32 allyesconfigs.
> > > >=20
> > > > Could you share the build errors?
> > >=20
> > > Sure, find it attached below.
> >=20
> > Thanks.
> >=20
> > It looks like this is a wait_on_bit usage that was added after I create=
d the
> > patch.
> >=20
> > How about you drop my patch for now, we wait for -rc1 to come out, then=
 I
> > submit a new version against -rc1 and we get that into -rc2.
> > That should minimise such conflicts.
> >=20
> > Does that work for you?
>=20
> Sure, that sounds like a good approach, if Linus doesn't object.
>=20

Hi Ingo,
 I re-posted these patches based on -rc2 (I missed -rc1, it was too fast) a=
nd
 have not heard anything over a week later.  Did I misunderstand?  Did you
 want me to send them direct to Linus?
 Or are you on a summer break and I should just be patient?

Thanks,
NeilBrown


--Sig_/=QYeP+QY288.xRlZtBKJOUE
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU7NgWjnsnt1WYoG5AQII1w//VComARvqt3VvWrvmnDLA0VuceV4ZipH/
bJ/z5WegEkvgo3YXg6TuiU5149NOrCV3ccqGyQAqzOamXzUbFIMYxQbSMNPpNcAq
aOj24ngtnFlRttn6x4KiyF3iZCj553+nazZ423XBCn74K8doav66M/iuHu1KDzuu
oV9zgkzwefx3+/bfsX4SIoHelgjM2b5oiIiAYbvlF35dJgHDfHWYERbURCegbb4l
jNSCdyu7hYQ9hv0JZUGHjziG4WAf4eEJMXOnOHtcz6Ud/pnCc1IhJGJjyDUImPXp
VPYo+C8T/zd6+OnAgxQ0xZhDLMw8BS8xfc9U8/BvypxeVoDVPYfBDwL0WsdyVrfj
3O5+8p3Tlh78AhXAuU5IoXD0X5ADvObXrAqoPa3N1ZmzbdKDy23WPqsC0nIOw6p1
LIviOly29b9/DZLr+fUZ6Q3fKvY4QKVM3Y301oEHpFOwdhDl0gUJ+rk2602Oj56f
N+lJLkUYsfeFs+RcU7elzNM+RYXHCUuVk8Jf5sRek7D8jq86+y4W/nRZ+h4G6vmt
KRnS+ZP7tfD+hfH6nc2gg1ntKBz5siYkQNumgei2w8mgwFymA7Q932qhfL3lI3vJ
UbqMTlHq3vujWJ6bNPxpwC8GzCToce6ufjS4Yx2oI+AK6SrGP5yKZazQymDtxtuR
ONcujyX/idg=
=bvEK
-----END PGP SIGNATURE-----

--Sig_/=QYeP+QY288.xRlZtBKJOUE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
