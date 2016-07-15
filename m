Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id DBDC86B0262
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 15:01:20 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id l125so217429634ywb.2
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 12:01:20 -0700 (PDT)
Received: from mail-qk0-x232.google.com (mail-qk0-x232.google.com. [2607:f8b0:400d:c09::232])
        by mx.google.com with ESMTPS id g69si6180301qkh.335.2016.07.15.12.01.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 12:01:20 -0700 (PDT)
Received: by mail-qk0-x232.google.com with SMTP id p74so109810826qka.0
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 12:01:20 -0700 (PDT)
Message-ID: <1468609254.32683.34.camel@gmail.com>
Subject: Re: [kernel-hardening] Re: [PATCH v2 02/11] mm: Hardened usercopy
From: Daniel Micay <danielmicay@gmail.com>
Date: Fri, 15 Jul 2016 15:00:54 -0400
In-Reply-To: <CAGXu5jKzD_rCMNJQU1bB5KDfKTsb+AaidZwe=FAfGMqt_FkfqQ@mail.gmail.com>
References: <1468446964-22213-1-git-send-email-keescook@chromium.org>
	 <1468446964-22213-3-git-send-email-keescook@chromium.org>
	 <20160714232019.GA28254@350D>
	 <CAGXu5jKzD_rCMNJQU1bB5KDfKTsb+AaidZwe=FAfGMqt_FkfqQ@mail.gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-iJ67bgEOqJPCpsbunZkk"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com, bsingharora@gmail.com
Cc: LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, "x86@kernel.org" <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>


--=-iJ67bgEOqJPCpsbunZkk
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

> This could be a BUG, but I'd rather not panic the entire kernel.

It seems unlikely that it will panic without panic_on_oops and that's
an explicit opt-in to taking down the system on kernel logic errors
exactly like this. In grsecurity, it calls the kernel exploit handling
logic (panic if root, otherwise kill all process of that user and ban
them until reboot) but that same logic is also called for BUG via oops
handling so there's only really a distinction with panic_on_oops=3D1.

Does it make sense to be less fatal for a fatal assertion that's more
likely to be security-related? Maybe you're worried about having some
false positives for the whitelisting portion, but I don't think those
will lurk around very long with the way this works.
--=-iJ67bgEOqJPCpsbunZkk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIzBAABCAAdBQJXiTLmFhxkYW5pZWxtaWNheUBnbWFpbC5jb20ACgkQ+ecS5Zr1
8ipfHQ/9GuB4gHqH46EsTlmQ5fcWXnwNJB5FATNyKhlxyXfCcEGojs2+G059y/C5
iIp7FmOqCknF/Aj7c/owNO28BFPBdpetDI4a2HTto0zFCtD69qpGjJ4wWmgYBkUb
he2J5Lok020qi4ffWmNy1fgjkyfkUU4cGDaosxKbXcOe1mgmhi7ghnsXcqeEU4ii
HCNFvYgV0hVKQHvrWIUW51r3j1fWWR22bghGy0wHLWrFeOhX1d5WK9TfzfSUZdTz
/g+4Wji0OKpI+75VYJc2P35LxTsSN0JT8XDicnus4+4l8MGc6TW4Z9AZBK7lZEK5
nhFWXS926xNGc1c5NPQzkEtgUKoeEbAeMcdyFd8k/JfOLas0WAF+iqVGAP/DlxHm
WTFcfvOpTArS7MMdfB6v3yj7ZOsVPCJAakuJdVCvXCKLAISy86p2EZT43vggz2q2
FJORgUNfHfmGiZy9r+MHTBtwAS+Gn9Z77gmQcMb0pVdHVj4l+QkEcSkdliOcVJ4c
6ITvBCD0F+1CiNTUIJ9oYlW92iqUX9M2QweDrlQ1PbWQVjyZU7NWh1VWmAsnhFBO
OE0GVO34OySR+FpVyqH7keEbb5e0P4ECC1e0UwxMfUZIpqMPT+g/9WAIJay6gVLk
6JVsWwkgg2nYyVFwvmP7gnUCeQB4ckhH08Ki7gjt0BidNywxfkU=
=PaWF
-----END PGP SIGNATURE-----

--=-iJ67bgEOqJPCpsbunZkk--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
