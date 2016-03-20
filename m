Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 378A66B007E
	for <linux-mm@kvack.org>; Sat, 19 Mar 2016 21:15:03 -0400 (EDT)
Received: by mail-qg0-f53.google.com with SMTP id w104so130418367qge.1
        for <linux-mm@kvack.org>; Sat, 19 Mar 2016 18:15:03 -0700 (PDT)
Received: from omr1.cc.vt.edu (omr1.cc.ipv6.vt.edu. [2607:b400:92:8300:0:c6:2117:b0e])
        by mx.google.com with ESMTPS id f123si3709773qhe.43.2016.03.19.18.15.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Mar 2016 18:15:02 -0700 (PDT)
Subject: Re: KASAN overhead?
From: Valdis.Kletnieks@vt.edu
In-Reply-To: <CAG_fn=WKjdcUSi5JoiAPrmRCLEL-SWyGHCOYOZiZQ_fnFDvydQ@mail.gmail.com>
References: <7300.1458333684@turing-police.cc.vt.edu>
 <CAG_fn=WKjdcUSi5JoiAPrmRCLEL-SWyGHCOYOZiZQ_fnFDvydQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1458436494_2490P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Sat, 19 Mar 2016 21:14:54 -0400
Message-ID: <15565.1458436494@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>

--==_Exmh_1458436494_2490P
Content-Type: text/plain; charset=us-ascii

On Sat, 19 Mar 2016 13:13:59 +0100, Alexander Potapenko said:

> Which GCC version were you using? Are you sure it didn't accidentally
> enable the outline instrumentation (e.g. if the compiler is too old)?

 gcc --version
gcc (GCC) 6.0.0 20160311 (Red Hat 6.0.0-0.16)

* Fri Mar 11 2016 Jakub Jelinek <jakub@redhat.com> 6.0.0-0.15
- update from the trunk

Doesn't get much newer than that.. :) (Hmm.. possibly *too* new?)

> > and saw an *amazing* slowdown.
> Have you tried earlier KASAN versions? Is this a recent regression?

First time I'd tried it, so no comparison point..

> Was KASAN reporting anything between these lines? Sometimes a recurring
> warning slows everything down.

Nope, it didn't report a single thing.

> How did it behave after the startup? Was it still slow?

After seeing how long it took to get to a single-user prompt, I didn't
investigate further. It took 126 seconds to get here:

[  126.937247] audit: type=1327 audit(1458268293.617:100): proctitle="/usr/sbin/sulogin"

compared to the more usual:

[   29.249260] audit: type=1327 audit(1458326938.276:100): proctitle="/usr/sbin/sulogin"

(In both cases, there's a 10-12 second pause for entering a LUKS
passphrase, so we're looking at about 110 seconds with KASAN versus
about 17-18 without.)

> Which machine were you using? Was it a real device or a VM?

Running native on a Dell Latitude laptop....

(Based on the fact that you're asking questions rather than just saying
it's expected behavior, I'm guessing I've once again managed to find
a corner case of some sort.  I'm more than happy to troubleshoot, if
you can provide hints of what to try...)

--==_Exmh_1458436494_2490P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVu35jgdmEQWDXROgAQI8pA/+IRjIh3dGH0JVXeA7jTPz9GPvEsRYbH09
tz8zed8JR6NOu2XzpCfxTC2rAPInKekwEtviXaDrqAqmQm7rj5ckc1EpPviX9XlO
8PrqXWTLmZUB4daTgJrUxep0F1dCO05z1+61skgL2LGk4ke398GY94/oPoUHr08M
n/NEFm8g6SU1xWaUwfQPTR6xTzbP6//ZzYQJkhl+NWw/9OtmYKP1lOhLRSsfPsl/
vxpmxRAASzVyN5m6+/uMDmgTVRojyMQKqjh9wKtukvJrwRGTHSL/3Hpz++d3aPwT
ErtEg9/L9xtNW8f9XQl+3UPCcfg6VMKrnBl8emQET+2EWzO6xQFkg6thrwrBFKfo
rEeLrjzwV3kV/6Hf5DTBTVui4OaXmlCOaLar+dE9Q0cqUDgEnfKsH1/dNxK2sUHe
kuIKWbwps61ANqVZD4O4oYPq8w6TFOlMA/shnBPy6xkaGMRm20q2FTLlhxNR9EIf
FHc16xGPnqn40fS3rn3I63KZOEdCiOvQ8RwVul0r+uUIuwljxE+VKg+ehysu/ZbT
X8iXyRwNdgB/CwgcZvNQDjJE6eGNN7r/aUTQEXAJylOZjK2mHkcXdFd95nhCyZTn
Yjx2rA1BxruaK+ozInnYEd5nwmTzPVcfldkwq9jtyAhlGe4wMCrsBmReOi38tgBQ
yE7+gXRlCVc=
=zssr
-----END PGP SIGNATURE-----

--==_Exmh_1458436494_2490P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
