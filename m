Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E24CF6B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 03:15:35 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id hb5so114501433wjc.2
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 00:15:35 -0800 (PST)
Received: from tschil.ethgen.ch (tschil.ethgen.ch. [5.9.7.51])
        by mx.google.com with ESMTPS id n13si76829100wmg.164.2017.01.04.00.15.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 00:15:34 -0800 (PST)
Date: Wed, 4 Jan 2017 09:15:27 +0100
From: Klaus Ethgen <Klaus+lkml@ethgen.de>
Subject: Re: [KERNEL] Re: [KERNEL] Re: Bug 4.9 and memorymanagement
Message-ID: <20170104081527.hq5q4ngevcl3c7k6@ikki.ethgen.ch>
References: <20161225205251.nny6k5wol2s4ufq7@ikki.ethgen.ch>
 <20161226110053.GA16042@dhcp22.suse.cz>
 <20161227112844.GG1308@dhcp22.suse.cz>
 <20161230111135.GG13301@dhcp22.suse.cz>
 <20161230165230.th274as75pzjlzkk@ikki.ethgen.ch>
 <20161230172358.GA4266@dhcp22.suse.cz>
 <20170104080639.GB25453@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; x-action=pgp-signed
In-Reply-To: <20170104080639.GB25453@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Hi Michal,

Am Mi den  4. Jan 2017 um  9:06 schrieb Michal Hocko:

> > Just try to run with the patch and do what you do normally. If you do
> > not see any OOMs in few days it should be sufficient evidence. From your
> > previous logs it seems you hit the problem quite early after few hours
> > as far as I remember.
> 
> Did you have chance to run with the patch? I would like to post it for
> inclusion and feedback from you is really useful.

Yes. It runs since 2017-01-01 and without problems until today.

I think it looks good but that is just my feeling. I don't know if it is
to early to say that.

I also did some heavy git repository actions to big repositories. The
system is in swap and still no OOMs.

Regards
   Klaus
- -- 
Klaus Ethgen                                       http://www.ethgen.ch/
pub  4096R/4E20AF1C 2011-05-16            Klaus Ethgen <Klaus@Ethgen.ch>
Fingerprint: 85D4 CA42 952C 949B 1753  62B3 79D0 B06F 4E20 AF1C
-----BEGIN PGP SIGNATURE-----
Comment: Charset: ISO-8859-1

iQGzBAEBCgAdFiEEMWF28vh4/UMJJLQEpnwKsYAZ9qwFAlhsrxoACgkQpnwKsYAZ
9qz1CQv/YLYqrABY+8HfYmRoUEPMgPbmWeSeIRiIgiBoN6XmHQ0hCBLecl6mmGoP
P9RgR62mU9LEtEqvrgFbX+/MXsdVefWozf0C+b3gs5Sym4VHoHvMWm9q1sdY845R
1sbhACXFLzgYYZ+uXwMg+pwYb3ZW70N1GQcUdbEOBWdWzlWcoKVGwIj6awNfX7RH
gOFP3KsXsdPKaIMHmF3+0VamGY1xfbL0kvm4nzqqfrD5YmIbGaZoRqv8lF8yz1b/
JH6SEc6X9gcknvvTCj7EZgq4nmrDW5KYE935CcS85khUdvp80aXe+y5YgBhjfjOx
BYcTxejHgSfEEKEqvhlQ7Pmi49QpYcwxyLU2UTwrXFcxPKY7xm9iPO6Pn/NHSsMF
YCCphIfMv0Rgy/QOATOdECXFhJWzChNEAQTYIl3UrzBT0PAfnr30E0B13dgpfISU
TZPcWYjXsokiHLzqDDjN0VIcXaPfR+RCNQUcCwHUJYRCBY+upuZogLnM6lOHhZWN
aUzVem/l
=kiM7
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
