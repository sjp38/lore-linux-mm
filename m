Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 702D26B02C7
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 06:39:26 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l124so28448086wml.4
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 03:39:26 -0700 (PDT)
Received: from thejh.net (thejh.net. [37.221.195.125])
        by mx.google.com with ESMTPS id gc7si8140739wjb.277.2016.11.03.03.39.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 03:39:25 -0700 (PDT)
Date: Thu, 3 Nov 2016 11:39:23 +0100
From: Jann Horn <jann@thejh.net>
Subject: Re: [PATCH 2/3] mm: add LSM hook for writes to readonly memory
Message-ID: <20161103103922.GD13748@pc.thejh.net>
References: <1478142286-18427-1-git-send-email-jann@thejh.net>
 <1478142286-18427-2-git-send-email-jann@thejh.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UfEAyuTBtIjiZzX6"
Content-Disposition: inline
In-Reply-To: <1478142286-18427-2-git-send-email-jann@thejh.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: security@kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@parisplace.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, mchong@google.com, Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Nick Kralevich <nnk@google.com>, Janis Danisevskis <jdanis@google.com>
Cc: linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--UfEAyuTBtIjiZzX6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 03, 2016 at 04:04:42AM +0100, Jann Horn wrote:
> SELinux attempts to make it possible to whitelist trustworthy sources of
> code that may be mapped into memory, and Android makes use of this featur=
e.
> To prevent an attacker from bypassing this by modifying R+X memory through
> /proc/$pid/mem, PTRACE_POKETEXT or DMA, it is necessary to call a security
> hook in check_vma_flags().
>=20
> PTRACE_POKETEXT can also be mitigated by blocking ptrace access, and
> /proc/$pid/mem can also be blocked at the VFS layer, but DMA is harder to
> deal with: Some driver functions (e.g. videobuf_dma_init_user_locked)
> write to user-specified DMA mappings even if those mappings are readonly
> or R+X.
>=20
> The new security hook security_forced_write() takes three arguments:
>=20
>  - The modified VMA, so the security check can e.g. test for executabilit=
y.
>  - The subject performing the access. For remote accesses, this may be
>    different from the target of the access. This can e.g. be used to crea=
te
>    a security policy that permits a privileged debugger to set software
>    breakpoints in the address space of a sandboxed process.
>  - The target of the access. This is useful if only a subset of the
>    processes on the system should be prevented from executing arbitrary
>    code, as is the case on Android.
>=20
> changed in v2:
>  - fix comment (Janis Danisevsk)
>  - simplify code a bit (Janis Danisevsk)
>=20
> changed in v3:
>  - rebase
>  - no need to pass in creds in populate_vma_page_range()
>  - reword check_vma_flags() comment (Ingo Molnar)
>  - use helper struct gup_creds (Ingo Molnar)

I introduced some bugs here again, as the kernel test robot points out.

--UfEAyuTBtIjiZzX6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJYGxPaAAoJED4KNFJOeCOo2igQAJVj0RGJ4EaUQ2lLewI+QaKP
9fL9XVChcpzRj0hlyAT5jdoUXTe+w2jX6/JetAcXvuo49GszxHRoxg5iNRKlCVaQ
zsm5UDMUMhnMUGjA4rVnh2vyZdQWiarLXgkirVBAeno74X0dbc1vtgaD6VjmAil/
JwZT5vj3lUuMhrHKKktTbGwwz7EUYbj7fHy9LXQUJvPNYJ/n37AI5PBgoBRZ9E+3
EL3GSk6zqThN1YnokPT3HoDaJ5B4SSHWn0BRp0XpPPFU6THleiKIawTqXsHnuZwn
0TS2cBok/cET7ykJkp/YaLCVEYM1ViDlFVfjX0DE7UIAXanFA86cKQOTA5S4eVMS
OPuknSgAxGkw7IbpvUbHAPaM0DXFqifINL8GgbNadfS0pFD4ezeuVX2l5fUJ0Pi2
nPFTRxHg46s1Lvb2CC2QuDPyEnvN/w/iKCwdqRaGCoJKVJIa0dTd4WBmFnGnk0H5
qSMREqael0yQgZ7lV7V+5aaKKMuYP92PWC1lYMIUfhBcO401HEQl4u+e6aEgUpgw
i+2a1v3zqoeCDvjJFJNKsHMK0RbpK5V+yW5miGuxToQVol7cM0WJM/nf6UTotmE/
KyKVzqQq7lOu76GMD7H08iXqbHjrPOey+QmtoM6lojjSihX2JU7wT2DmQvin/KZS
nPF49NY1Vt3ByJsktTt7
=vGPU
-----END PGP SIGNATURE-----

--UfEAyuTBtIjiZzX6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
