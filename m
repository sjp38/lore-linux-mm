Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id F27FA6B0003
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 12:40:48 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id 6so59103plf.6
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 09:40:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z19sor412162pff.145.2018.02.11.09.40.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Feb 2018 09:40:47 -0800 (PST)
From: Mark D Rustad <mrustad@gmail.com>
Message-Id: <6FB16384-7597-474E-91A1-1AF09201CEAC@gmail.com>
Content-Type: multipart/signed;
 boundary="Apple-Mail=_DCD15F6B-F8AE-4A90-959F-96DD4FD7056B";
 protocol="application/pgp-signature"; micalg=pgp-sha256
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH 00/31 v2] PTI support for x86_32
Date: Sun, 11 Feb 2018 09:40:41 -0800
In-Reply-To: <20180211105909.53bv5q363u7jgrsc@angband.pl>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <CALCETrUF61fqjXKG=kwf83JWpw=kgL16UvKowezDVwVA1=YVAw@mail.gmail.com>
 <20180209191112.55zyjf4njum75brd@suse.de>
 <20180210091543.ynypx4y3koz44g7y@angband.pl>
 <CA+55aFwdLZjDcfhj4Ps=dUfd7ifkoYxW0FoH_JKjhXJYzxUSZQ@mail.gmail.com>
 <20180211105909.53bv5q363u7jgrsc@angband.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Adam Borowski <kilobyte@angband.pl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Joerg Roedel <jroedel@suse.de>, Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>


--Apple-Mail=_DCD15F6B-F8AE-4A90-959F-96DD4FD7056B
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

> On Feb 11, 2018, at 2:59 AM, Adam Borowski <kilobyte@angband.pl> =
wrote:
>=20
>> Does Debian make it easy to upgrade to a 64-bit kernel if you have a
>> 32-bit install?
>=20
> Quite easy, yeah.  Crossgrading userspace is not for the faint of the =
heart,
> but changing just the kernel is fine.

ISTR that iscsi doesn't work when running a 64-bit kernel with a 32-bit =
userspace. I remember someone offered kernel patches to fix it, but I =
think they were rejected. I haven't messed with that stuff in many =
years, so perhaps the userspace side now has accommodation for it. It =
might be something to check on.

--
Mark Rustad, MRustad@gmail.com


--Apple-Mail=_DCD15F6B-F8AE-4A90-959F-96DD4FD7056B
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIzBAEBCAAdFiEE6ug8b0Wg+ULmnksNPA7/547j7m4FAlqAgBkACgkQPA7/547j
7m7WqQ//dL2W2MDxrxtXXgkVjhGojpNcHzpDqPCADZDc7qu0oTnN/po8Cel4KP2n
Wz+nuvnBAWjJdlyo+SAprxBqYRxxTa5u3laswYaouwWptmxvMn7B3KJu4tQWsZpd
bFDxlk8nY2gMnNqMGe4ScVHgXOXLUl2hlSA0OJ1GAp/lHUx/K33B542y4FiXeQ9G
oB5OPSJBGmPb8c+/XrSgDsFVo8bWili4Ubbk0Tdu4JNGaz1BD323u8NSJGh8S0ME
RIYu4hfDZtQJ5slnTU67cxt2R7fvMAzxRpCCeM4QG60aGvkN3CycmfGuxSk6y7K8
g0XsoIOsXwjLoSMtaroMFw7Mo8W+aK0VZ8+ZOC53qTaArVb0jb31SGEtb7C7cI1M
Vjn3ttS8YNDpUDMEBM3+khj6LNH3Ukf6GcoVg/Z+ZUU3IurTHrU93rV2JMplXLua
Qrza/Ei8t0EbgpcXc9qCY3bPOAL+reESKoBfBoxQsBJ2HGvsWVsKIdvZ2BhbnHPe
wiGlw+1s/230B7HRU17eihyftpDi+8CrK30jE6qP3hjpLYJYMJKpT9pxPXMnDujV
8jPmCbhP/DCMRDPKvdpzchAyUN2zIUf9xYsCuzzqXYN9b9dntAJKNrD/ynnbLybr
ntvdu1ByozCeHtyhJaNOSD+tUtF6MDskIy6ySTYJ/xaL88QXi/Q=
=VaGL
-----END PGP SIGNATURE-----

--Apple-Mail=_DCD15F6B-F8AE-4A90-959F-96DD4FD7056B--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
