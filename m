Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7AC6B0035
	for <linux-mm@kvack.org>; Mon,  4 Aug 2014 06:44:40 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so9792371pad.39
        for <linux-mm@kvack.org>; Mon, 04 Aug 2014 03:44:40 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id kw4si17218805pab.162.2014.08.04.03.44.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Aug 2014 03:44:38 -0700 (PDT)
Date: Mon, 4 Aug 2014 12:44:26 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v3 1/2] timer: provide an api for deferrable timeout
Message-ID: <20140804104426.GP19379@twins.programming.kicks-ass.net>
References: <1406793591-26793-2-git-send-email-cpandya@codeaurora.org>
 <53DF51D2.4090002@codeaurora.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="P031Sa4wWaDYwbKN"
Content-Disposition: inline
In-Reply-To: <53DF51D2.4090002@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, John Stultz <john.stultz@linaro.org>, Ingo Molnar <mingo@redhat.com>, Hugh Dickins <hughd@google.com>


--P031Sa4wWaDYwbKN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Aug 04, 2014 at 02:56:42PM +0530, Chintan Pandya wrote:
> Ping !! Anything open for me to do here ?

Give Thomas a moment to have a look, he is the maintainer after all, do
consider he's busy, and he extra busy because the merge window just
opened.

--P031Sa4wWaDYwbKN
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJT32QKAAoJEHZH4aRLwOS6lcMP/AlFRyGvHguMpbKmCNx3EPgc
DWwmwBbXfpsc3XM4UjP4VpNcRzBrux7HC+twa4amoQEhwHp1H7GhGOywtwH64u7q
/X5lP1vTNqOEgBahlxiC1nihOytHu26sAoV5Fq7QtlIoEXzbcQnK5CHszL4uT7f2
l4okrKe9LFzq1e+d6KAPvJuDqdLoWgIQSMZa95wi4mLur1k012vRP7un+8+aDrrJ
yM43CTJ1Af931yIZXUmlLhuIYhrVQrT6HGvVT1KQ0D6e0kJiOtVfgxC0XZweBU1l
5izb245HtrA76hWIC2nKMduhGnowbOM28cR67U5yhe02skZVEBwvo2dsF4k7H3IQ
ncTZAOpJ3o5dnwQiOhhSeMicU9e7aVI5hSC8Cm0Q3oMle0f0se0DHYBKjoCwAZRI
ghezObPl6qLE8+QX1Cr9d5aBCSlLw/A00p5shZIMvw5aLwc8TWF+5FWtyolQQMT9
p2tkiPAGNjAD87rpWdl5VDD+WrCuP2Qu+PpokOT/9+3gp7sJziwvb5ky8ZtUqAW9
/eJrUtBGIJe68vU1iIMVO0jQM4kH7HhV0q1q0cSxAKwC3sA+wfYDxO79qfxRZk8r
gWcci4TMEFjZNc05SZPm8opUm3iVy+9ZVcVGxPn6ulehYgd0EHVhSO6h8kYXjTo4
Orfyb3v/Kv7DFahBz5s4
=861Q
-----END PGP SIGNATURE-----

--P031Sa4wWaDYwbKN--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
