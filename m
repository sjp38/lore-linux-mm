From: Sascha Silbe <x-linux@infra-silbe.de>
Subject: Re: [v3,6/9] mm/page_owner: use stackdepot to store stacktrace
Date: Fri, 23 Dec 2016 00:37:18 +0100
Message-ID: <toebmw3o7rl.fsf@twin.sascha.silbe.org>
References: <1466150259-27727-7-git-send-email-iamjoonsoo.kim@lge.com> <toe60ofdzuq.fsf@twin.sascha.silbe.org> <20161027001715.GA5655@js1304-P5Q-DELUXE>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha512; protocol="application/pgp-signature"
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161027001715.GA5655@js1304-P5Q-DELUXE>
Sender: linux-kernel-owner@vger.kernel.org
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>
List-Id: linux-mm.kvack.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Dear Joonsoo,

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> Anyway, I find that there is an issue in early boot phase in
> !CONFIG_SPARSEMEM. Could you try following one?
> (It's an completely untested patch, even I don't try to compile it.)

Finally got JTAG to work just enough to dive into this. Turned out to be
another case of the FDT clashing with the BSS area. Your patch caused
BSS to grow by > 4 MiB so that it now collides with the (old) default
FDT location on this board. There's nothing wrong with your patch, just
the usual black magic of placing initramfs and FDT in RAM on ARM.

Sascha
=2D-=20
Softwareentwicklung Sascha Silbe, Niederhofenstra=C3=9Fe 5/1, 71229 Leonberg
https://se-silbe.de/
USt-IdNr.: DE281696641

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJYXGOvAAoJEMGPauiBMO2X8lUQAJtAlhDRA66b9bC1c/4Up0xE
78NF7UFhPozZQFu7jGhCyWuXYAaKzLytV8oqK3y9DA80EX0b9ZuYPVaPxg9Y/q+v
c6M4fWVRbcMyGHxL5Ck6IqFaYJFUr8QSW7ldjphQeENRgMdppKyvFtufkdyPHBtQ
4gk0fdxakiLo3w9bw1pd9OoQLJWG/1/E982646AYlBCm7s6N603zJuIEZrtPzqDw
xzuE5psDdox25qZDLczSBc9kh/h3CKnxChdBEiYDV8nfRQYzpJW1bQjGRmof3hN5
gVB0jtS4o22LxRYY0lJd4wDesQ8jdnAOq/nw0dy9OZLeqP2Loo24gEkRTJR3OS67
58sKhWsepwhnW75fF3rma17x8/qVSU1i3JG95fgIgKVsEHNb4RMnuh/QBUoFS8EC
qBIk4tMYi0+VUjrwoEr++mLURjoU37l4qhInWyzq2RcmMZUPSsZElPP9BEC2NqOv
7RgA8PYN2GPVlAlAKL0HrzBsUCPbdfydrqihBTMYI46Or0MuHjNz24fZobNhR+wZ
SYFLDivSKF6W3pjZcM2Fn1M4TrXGMznpVQy1rUxCvaiB29lJF0OWitG7aSTfhVij
tUbpgFaexRoePzGZVa3QZtRngTgi1q9hoqTJz7j6mm3M/IY9PR3MUyEDWdX+48yq
mwDn31rSVVAXBTA4y2Kq
=aWEY
-----END PGP SIGNATURE-----
--=-=-=--
