Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id B5E1082F66
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 15:37:33 -0500 (EST)
Received: by wmec201 with SMTP id c201so183767305wme.0
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 12:37:33 -0800 (PST)
Received: from thejh.net (thejh.net. [2a03:4000:2:1b9::1])
        by mx.google.com with ESMTP id 7si399049wmp.86.2015.12.07.12.37.32
        for <linux-mm@kvack.org>;
        Mon, 07 Dec 2015 12:37:32 -0800 (PST)
Date: Mon, 7 Dec 2015 21:38:24 +0100
From: Jann Horn <jann@thejh.net>
Subject: Re: [PATCH] ptrace: use fsuid, fsgid, effective creds for fs access
 checks
Message-ID: <20151207203824.GA27364@pc.thejh.net>
References: <20151109131902.db961a5fe7b7fcbeb14f72fc@linux-foundation.org>
 <1449367476-15673-1-git-send-email-jann@thejh.net>
 <CAGXu5jJKOnWWSuLO5zWZ9=7Nhv0hWvJ0wEVJ3n+URY7-q_BCJw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZGiS0Q5IWpPtfppv"
Content-Disposition: inline
In-Reply-To: <CAGXu5jJKOnWWSuLO5zWZ9=7Nhv0hWvJ0wEVJ3n+URY7-q_BCJw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge.hallyn@ubuntu.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, "Eric W. Biederman" <ebiederm@xmission.com>, Joe Perches <joe@perches.com>, Thomas Gleixner <tglx@linutronix.de>, Michael Kerrisk <mtk.manpages@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-security-module <linux-security-module@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, "security@kernel.org" <security@kernel.org>, Willy Tarreau <w@1wt.eu>


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 07, 2015 at 12:32:06PM -0800, Kees Cook wrote:
> On Sat, Dec 5, 2015 at 6:04 PM, Jann Horn <jann@thejh.net> wrote:
[...]
> > -       if (ptrace_may_access(task, PTRACE_MODE_READ)) {
> > +       if (ptrace_may_access(task, PTRACE_MODE_READ | PTRACE_MODE_FSCR=
EDS)) {
>=20
> This should maybe use the PTRACE_MODE_READ_FSCREDS macro?

Oh, yes. I don't know how I missed that. :/


> >                 error =3D ns_get_path(&ns_path, task, ns_ops);
> >                 if (!error)
> >                         nd_jump_link(&ns_path);
> > @@ -63,7 +63,7 @@ static int proc_ns_readlink(struct dentry *dentry, ch=
ar __user *buffer, int bufl
> >         if (!task)
> >                 return res;
> >
> > -       if (ptrace_may_access(task, PTRACE_MODE_READ)) {
> > +       if (ptrace_may_access(task, PTRACE_MODE_READ | PTRACE_MODE_FSCR=
EDS)) {
>=20
> same here?

Yes.
--ZGiS0Q5IWpPtfppv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJWZe5AAAoJED4KNFJOeCOocOIQAIPkjimgJ/9cn9hzTXLsNyNA
eDdTVMa/MRT4ySXOUlu7FeC+i/FVi+f7SneiX5MPczQDO6t3lbr4LmiT1dpQrzca
/uvP+y5bCvzAERBKuBUvKs3dBoonMrMzkGr4oYHjkLiWzzO0oWlQQpiE8It5KdY5
fHeqje5hXihSYKD7YqUavdjJFFU0khkiKr1M5jlO6cUB/OwEJ83G9BpeH2VY31mn
3feLpC1+w1FOozbCYww0LteIXKWyR8cTRPTRrKsvxlj3OaxrAJBQaU0AWkBtZjEr
yNHtagE1EBoiPjwcRwAMwWzGUlsUc3lHyq/r5xA8jYHOixM1O6zZ7izYWXlzRx7d
NCVg4OVLj1rAkgSlgzFS+dYtVse91+nLA+8vqasXbhtFlDIEA1pTqZ6k+L6y2qL9
Iu60QmrmQjLoZ3OQlQIqaf+rYwCLX835Vw4FlyhEKtAsAcWk2b3Wm0dfEOILlIBz
qkK1S8G9nOIPHzFLWEvi8HWmL5qVT6ArnB4yADcNhvTFpahEKpJCxUW4A/m7vYB2
ztwxH68iW2PJHLuBEng6qGyqtZa/IaNmVRd6Kax6mqR7KDoZiubP/FXP8AhDyb/2
6KpC4upUwZ8IByn6q8kkuZm+YjvVIv7Jqu8dhJ9Nfh+o0JWbClCmkwZR0O3SPnxF
PUq8xAWIX3hmbpOFcE82
=+R/c
-----END PGP SIGNATURE-----

--ZGiS0Q5IWpPtfppv--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
