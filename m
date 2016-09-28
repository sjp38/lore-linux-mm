Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5391C28024C
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 19:44:07 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w84so55716089wmg.1
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 16:44:07 -0700 (PDT)
Received: from thejh.net (thejh.net. [2a03:4000:2:1b9::1])
        by mx.google.com with ESMTPS id u123si11950784wmf.146.2016.09.28.16.44.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 16:44:06 -0700 (PDT)
Date: Thu, 29 Sep 2016 01:44:04 +0200
From: Jann Horn <jann@thejh.net>
Subject: Re: [PATCH v2 2/3] mm: add LSM hook for writes to readonly memory
Message-ID: <20160928234404.GD2040@pc.thejh.net>
References: <1475103281-7989-1-git-send-email-jann@thejh.net>
 <1475103281-7989-3-git-send-email-jann@thejh.net>
 <CALCETrUc8VVyPKuGrS7PxBRHCsVhXbXaiEOmwjgHrzTRiXPT9Q@mail.gmail.com>
 <20160928233256.GB2040@pc.thejh.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UfEAyuTBtIjiZzX6"
Content-Disposition: inline
In-Reply-To: <20160928233256.GB2040@pc.thejh.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "security@kernel.org" <security@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@parisplace.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Nick Kralevich <nnk@google.com>, Janis Danisevskis <jdanis@google.com>, LSM List <linux-security-module@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


--UfEAyuTBtIjiZzX6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 29, 2016 at 01:32:56AM +0200, Jann Horn wrote:
> On Wed, Sep 28, 2016 at 04:22:53PM -0700, Andy Lutomirski wrote:
> > On Wed, Sep 28, 2016 at 3:54 PM, Jann Horn <jann@thejh.net> wrote:
> > > SELinux attempts to make it possible to whitelist trustworthy sources=
 of
> > > code that may be mapped into memory, and Android makes use of this fe=
ature.
> > > To prevent an attacker from bypassing this by modifying R+X memory th=
rough
> > > /proc/$pid/mem or PTRACE_POKETEXT, it is necessary to call a security=
 hook
> > > in check_vma_flags().
> >=20
> > If selinux policy allows PTRACE_POKETEXT, is it really so bad for that
> > to result in code execution?
>=20
> Have a look at __ptrace_may_access():
>=20
> 	/* Don't let security modules deny introspection */
> 	if (same_thread_group(task, current))
> 		return 0;
>=20
> This means thread A can attach to thread B and poke its memory, and SELin=
ux
> can't do anything about it.
>=20
> I guess another perspective on this would be that it's a problem that
> interfaces usable for poking user memory are subject to introspection rul=
es
> (as opposed to e.g. /proc/self/maps, where it is actually useful).

Ugh, I'm talking nonsense, ptrace() doesn't work on threads. (/proc/$pid/mem
works though). And then, ptrace-ish APIs aside, there are those weird
devices that do DMA with force=3D1.

--UfEAyuTBtIjiZzX6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX7FXEAAoJED4KNFJOeCOorA4QAMtUMaGhfHjIVSZxX/ExFBLZ
DKQ9OAfz/fTCqyH65717W3pcFgysIM2sy/Nf18VMk+Pqv4FIlCZUnLvw6DSr3bnv
fqAdYNYFdwKY4kWLU7CHs8fVDuL2gv0dSZ8KwCXVzLJAVlaPlmRt51VbzoSG6aoD
OKSJQ0sK5RKUQQDGyXh5BJk3ZAfVi13or+ehlZyUSCkPlRkBWwJipCFE3iRTrr75
OXypSYQfpOSxtLVhKGTGWm6Y2i0yGh/eFlu8qFPa8ewG2l3co3HRet+a858/uqZ9
J22htaDNXwG4AdFp7L1iK87mZVtDlkeRKf7UzVjdRIR0eRBPlrpK9JQzyhGjSZlp
iIlSSXNtpDuT+RPqwqn+q2R5bkDz+KLokCMiiUV/y4tqlSMYaOpiv5HOT5jTUNbY
F5Olu3pTWhzy+0oBDaSRq361tG5Cy47vs4okffKxbUn2mrUSWHzd/ITBeD1GsdqU
Z3MuREhWkbc9GO0eZZpTcx/iKLagX723qTU8pUa+Oq6Q4vFhM2IGBlGoPw1L7il8
G6NFjQ1uknDqhd+oldv73k0777DCn34EYUQ2/caLyNSVKum7R2nx7HAzoaAk71DO
cM2MPAiu6mxO0//Q29AObOg24coKuVoe30BrwS5rY0Hi2MsY/bEGOjMiln1WvHMG
L0HOE85KAd0XGoIxjveP
=bRqa
-----END PGP SIGNATURE-----

--UfEAyuTBtIjiZzX6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
