Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 533AD6B0292
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 20:18:41 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id d191so43023068pga.15
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 17:18:41 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id d78si435574pfk.56.2017.06.27.17.18.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 17:18:40 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id u36so6059558pgn.3
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 17:18:40 -0700 (PDT)
Date: Wed, 28 Jun 2017 08:18:36 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [RFC PATCH 4/4] base/memory: pass start_section_nr to
 init_memory_block()
Message-ID: <20170628001836.GC66023@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170625025227.45665-1-richard.weiyang@gmail.com>
 <20170625025227.45665-5-richard.weiyang@gmail.com>
 <ac2b2750-d673-ce91-cd48-fc95e41ae6f7@nvidia.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="7gGkHNMELEOhSGF6"
Content-Disposition: inline
In-Reply-To: <ac2b2750-d673-ce91-cd48-fc95e41ae6f7@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, linux-mm@kvack.org


--7gGkHNMELEOhSGF6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jun 27, 2017 at 12:11:52AM -0700, John Hubbard wrote:
>On 06/24/2017 07:52 PM, Wei Yang wrote:
>> The second parameter of init_memory_block() is to calculate the
>> start_section_nr for the memory_block. While current implementation dose
>> some unnecessary transform between mem_sectioni and section_nr.
>
>Hi Wei,
>
>I am unable to find anything wrong with this patch (except of course
>that your top-level description in the "[PATCH 0/4" thread will need
>to be added somewhere).
>
>Here's a slight typo/grammar improvement for the patch
>description above, if you like:
>
>"The current implementation does some unnecessary conversions
>between mem_section and section_nr."
>

Thanks :-)

>thanks,
>john h
>

--=20
Wei Yang
Help you, Help me

--7gGkHNMELEOhSGF6
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZUvXcAAoJEKcLNpZP5cTdgOYP/1t98t61rknEkEbO4uy0Hyap
5oh2YeRtNyeYOONbaqRgrMxoFA32ycQ+XkYJxC4j0WiW0f+rIxvm7DPmWutBQ7n5
Db7am+tZ74KpotedhTk6IvJfpruIAr+2D6uvsQVLwtNlY/d4gKWaI2H+auh9JT7I
twqaTZSkFPs0YotUFp0RwWCIQhCR7oWI7+GWI/ltEusJhjNzKnDFrdbKpo/chXj7
tHM8iWxVg+6rG2FqwDX5i2uUa3SM/XdF7EfS/hcD+rv75dN9Ji9e/lcDlVOBUheD
4tXnxvKA61O+xKAX285Oix7ujdN4Catv1x2AUOByWbDyMCBerfFSe7PhUx7TXcTF
aDsMOtoxMB6tj5fMx8ZwUPOI2nMtWhVmJw2UpZIabPXUrrPHGS2Zi/CHqQXM3Trc
8INojrlCSs+Xk/y/urrRiW1OV14GWHciaBs3HMUewAcmVgV/5dKaoSMDV6wyk8Mh
b6gsx0Grcq9xqSCvKvcAAqPmliDC87UnggVb1TplVT4LjcTRF4MGmARLP7WupxjK
vJ9YnABtou3wKkrQHgCaPGkY7x4kTyBfuahNr1ju5zceOaMYhCIKT/ZVaqkQbYL2
DP4wsjrMQTrGBJs0LUtzVV85cdyXmrkKZuEQDV9WObmdF8JfEh+igwago/ZnuY5S
MEKvebqL3Bi8vE1LFgYw
=0hqZ
-----END PGP SIGNATURE-----

--7gGkHNMELEOhSGF6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
