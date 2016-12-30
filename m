Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0E1B46B0038
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 11:52:37 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w13so68079097wmw.0
        for <linux-mm@kvack.org>; Fri, 30 Dec 2016 08:52:37 -0800 (PST)
Received: from tschil.ethgen.ch (tschil.ethgen.ch. [5.9.7.51])
        by mx.google.com with ESMTPS id bv17si48200823wjb.0.2016.12.30.08.52.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Dec 2016 08:52:35 -0800 (PST)
Date: Fri, 30 Dec 2016 17:52:30 +0100
From: Klaus Ethgen <Klaus+lkml@ethgen.de>
Subject: Re: [KERNEL] Re: Bug 4.9 and memorymanagement
Message-ID: <20161230165230.th274as75pzjlzkk@ikki.ethgen.ch>
References: <20161225205251.nny6k5wol2s4ufq7@ikki.ethgen.ch>
 <20161226110053.GA16042@dhcp22.suse.cz>
 <20161227112844.GG1308@dhcp22.suse.cz>
 <20161230111135.GG13301@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; x-action=pgp-signed
In-Reply-To: <20161230111135.GG13301@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Sorry, did reply only you..

Am Fr den 30. Dez 2016 um 12:11 schrieb Michal Hocko:
> > If this turns out to be memory cgroup related then the patch from
> > http://lkml.kernel.org/r/20161226124839.GB20715@dhcp22.suse.cz might
> > help.
>
> Did you get chance to test the above patch? I would like to send it for
> merging and having it tested on another system would be really helpeful
> and much appreciated.

Sorry, no, I was a bit busy when coming back from X-mass. ;-)

Maybe I can do so today.

The only think is, how can I find out if the bug is fixed? Is 7 days
enough? Or is there a change to force the bug to happen (or not)...?

Am Fr den 30. Dez 2016 um 12:11 schrieb Michal Hocko:
> > If this turns out to be memory cgroup related then the patch from
> > http://lkml.kernel.org/r/20161226124839.GB20715@dhcp22.suse.cz might
> > help.

Which of the 3 patches is the one? All 3 or just one.

Regards
   Klaus
- -- 
Klaus Ethgen                                       http://www.ethgen.ch/
pub  4096R/4E20AF1C 2011-05-16            Klaus Ethgen <Klaus@Ethgen.ch>
Fingerprint: 85D4 CA42 952C 949B 1753  62B3 79D0 B06F 4E20 AF1C
-----BEGIN PGP SIGNATURE-----
Comment: Charset: ISO-8859-1

iQGzBAEBCgAdFiEEMWF28vh4/UMJJLQEpnwKsYAZ9qwFAlhmkM4ACgkQpnwKsYAZ
9qz18QwAtNNESyhqkpYaOss2Q6Ko1o+9eygil3X9MtAPWY/UP/d7MJ7q8lBrjQT7
wetFM4yZtfS4lk2wnUXUDHT8r41QT/39YmZefZemdHjMwbPk+NpeX3J7Y+Agu117
7x0NtWEpMM2mimSUcLpKxZjScx1lci572trlWVy8v8yPxTAeyPTxJ2Zun/W7vqS2
so3o2OA9eMSv7s0zWvE/9X3UZowcWaZtNIx2EvIPdghg2zazYwFydNFFGqn6tPtR
wlLj9Oxw3NTwKvFvHCGXz/xodw0t8Y1ZQa4yc5fYRzEy8PNJnxo6LNoboiycdcIw
E8FgybmJM2eFshiwRuFp8pgrI+HU6Mubp2aUPaNKYUUhfc58T59fSfh+qEkEkgym
kYCTiUA1f9SCSYVSkZrCaV1TuPnEmXANOTvQS5k4We7/kMbmk67UyWpSRCRSRYSX
Ofr/rblMVQ+dqQIQTVNoufSZgAOmCJdSbCQO/RduVjhSPgM47lLajIcRM/EYizE/
fBfHXomC
=T2Gd
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
