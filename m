Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 01A836B006E
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 03:28:07 -0500 (EST)
Received: by mail-ee0-f42.google.com with SMTP id b47so1478663eek.29
        for <linux-mm@kvack.org>; Mon, 14 Jan 2013 00:28:06 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v2 2/2] Enhance read_block of page_owner.c
In-Reply-To: <20130114023338.GB18097@blaptop>
References: <1357871401-7075-1-git-send-email-minchan@kernel.org> <1357871401-7075-2-git-send-email-minchan@kernel.org> <xa1t8v7zbteu.fsf@mina86.com> <20130114023338.GB18097@blaptop>
Date: Mon, 14 Jan 2013 09:27:57 +0100
Message-ID: <xa1t6230p3si.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andy Whitcroft <apw@shadowen.org>, Alexander Nyberg <alexn@dsv.su.se>, Randy Dunlap <rdunlap@infradead.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Mon, Jan 14 2013, Minchan Kim <minchan@kernel.org> wrote:
> I'm not familar with Python but I can see the point of the program.
> It's very short and good for maintainace but I have a concern about the s=
ize.
> For working it in embedded side, we have to port python in that
> machine. :(  [...]
> In case of that, just small C program when we release product would be
> good choice.

But is this program intended to be used as is? Or rather to serve as an
example?  If the former, than I think it should be in tools/ rather than
in Documentation/.  If the latter, than I think it does not really
matter whether it's C or some scripting language, since the purpose is
to show how /proc/page_owner can be used, and in fact showing the
general idea may be simpler with a shorter program which does not have
to deal with memory management.

And if Python is not your fancy, you can always use some shell: ;)

	awk -vRS=3D '{ gsub("\n", "\\n"); print $0 }' |sort |uniq -c

> But I'm not strong aginst on your simple python program. If it is merged,
> we will just continue to use C program instead of python's one.
> If you have a strong opinion, send it to akpm as separate patch.

Not at all.  I'm just throwing ideas.

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--
--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJQ88GOAAoJECBgQBJQdR/0vBAP/3tMBO+KCy5wCcPUSzHoyzhH
hVSM08dGFqas5Vn7UlhzcQX6PIbps7Hle508r5iIdoo9QcHkykUm4q6+2RLRe3oV
uSb/zjPE6x7gkAl8AvkLaHlsUVMbURGVzj2F4+nbtf/CBxJjMsAJq7cXYnP8wiOH
NKRlHwNS2JHcwyRtYS2lotsoObzgaZ7mpb5iAb9ChNhC/DI+NJmDrc9AXywxuTfb
LldhtXv7bMs5n9nKhiu++93B+zdaqzWc99BDREtYesFXXNb21d9PJNypCKGQOaGl
5UK16cgoBTTekxD7MpZdMhr0dV6oZ1p7XnZrZjkOZGuZbp1ZeifYnc2hqxxJ1h8S
zZxxRh6rXYqPYBSLRVsTH+CyN3FIi/jNn0aopHi2Xx+/GL5QXk1uN0kk7vl67ra/
oGQz5Nuo3htJNhSDXFhj8nuvFqzTPQeldDMlGkPrJQYuJ80qi6ymWbJ9f/5eSzMU
nqr/U/NYU6YyP9DJr9pRacDV3Zjc2KJVq9w8LCQSrhDEUOFNUok1QMs5k04G4uEo
yscnWfIr4vcD0HFVo+xf/mitMFR2t330z9AFM+0VNx7b3yyDmjOY/MNsw1ce8lQY
KLn7mS1LrDLPQgdkMyjexGyxJFsAqkhK0sVstE0Th9H3gQkzx/gIR5aTpEA83XsQ
BmTTsZXY+aMtX2PEdS4O
=9ZHj
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
