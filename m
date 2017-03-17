Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 55BC06B038D
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 21:47:47 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x63so113105922pfx.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 18:47:47 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id n63si4962923pfg.110.2017.03.16.18.47.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 18:47:46 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id x63so7392606pfx.2
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 18:47:46 -0700 (PDT)
Date: Fri, 17 Mar 2017 09:47:43 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: + mm-sparse-refine-usemap_size-a-little.patch added to -mm tree
Message-ID: <20170317014743.GA44593@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <58c32b92.qgOCFj/bIjx+ym6m%akpm@linux-foundation.org>
 <20170316091718.GA30508@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="vtzGhvizbBRQ85DL"
Content-Disposition: inline
In-Reply-To: <20170316091718.GA30508@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, richard.weiyang@gmail.com, tj@kernel.org, mm-commits@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Mar 16, 2017 at 10:17:18AM +0100, Michal Hocko wrote:
>[CC Mel]
>
>On Fri 10-03-17 14:41:22, Andrew Morton wrote:
>> From: Wei Yang <richard.weiyang@gmail.com>
>> Subject: mm/sparse: refine usemap_size() a little
>>=20
>> Current implementation calculates usemap_size in two steps:
>>     * calculate number of bytes to cover these bits
>>     * calculate number of "unsigned long" to cover these bytes
>>=20
>> It would be more clear by:
>>     * calculate number of "unsigned long" to cover these bits
>>     * multiple it with sizeof(unsigned long)
>>=20
>> This patch refine usemap_size() a little to make it more easy to
>> understand.
>
>I haven't checked deeply yet but reading through 5c0e3066474b ("Fix
>corruption of memmap on IA64 SPARSEMEM when mem_section is not a power
>of 2") made me ask whether the case described in the commit message
>still applies after this change or whether it has been considered at
>all.
>

Hi, Michal

Thanks for your comment.

By looking into the commit 5c0e3066474b, I think it does two things:
1. Recalculate the SECTION_BLOCKFLAGS_BITS
2. Move pageblock_flags out mem_section to make the structure power of 2 in
size.

When we look at the original data structure, pageblock_flags originally is
defined as a bitmap:

    DECLARE_BITMAP(pageblock_flags, SECTION_BLOCKFLAGS_BITS);

Which in turn is:

    #define DECLARE_BITMAP(pageblock_flags,SECTION_BLOCKFLAGS_BITS) \
        unsigned long pageblock_flags[BITS_TO_LONGS(SECTION_BLOCKFLAGS_BITS=
)]

My patch is using BITS_TO_LONGS() to simplify the code and obviously has the
same effect.

Does this resolve your concern?

--=20
Wei Yang
Help you, Help me

--vtzGhvizbBRQ85DL
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJYy0A/AAoJEKcLNpZP5cTd2PAP/34zA2ZK2XACT+J9dd6AJL93
qg6YNb05y+r0uoDsfazm8Qb9iRtQwPJ8EoeRN0bh/NbjS8SAz0gygL2HBjnuE1Jb
X1q1ELhl2yfqAwxxPVXo/atSdUwGJ0Gj8723z/j87VtI9hT+cuKK2Em2LdobjXXK
7RkU+mFfCEUJ6nmmJtOYJyIEx9vlnUR9ERb0CVO0reLNaT9i7Cd6g8TcinkDBSb3
lkpydT3zNk2bgRWzhCVyv6LLNg0e4iy6F0WR0QnYrws5PhKDtCLvOUuBbje6LEIf
Hzb/1Vhv5C74YAQKqm/E9XxSeuaVkqboB8W2j9dIBQawphZG2+tvEJIGaoxLiqtK
NYxjJlwW1x0uIoBPPzZrdKN1S/8gVECNQD770qrmU6kzPaZKAr6KmgSTwRvkYETP
LiFtHdbKbUz0QyU7zP/Z4Ufh+9K1IRT+B6qnzmK5ENbXH9uPHrs7HLOz2mjgLN3m
xEbqLt4rKSeSdsn9OX1lwNzvypicfIVe064O83TucEjctpZ+Gp/Ig/wHlRSrGHle
xt+wcm0MImMTXPrqy6lBirGpNb9IKa7xPh7aUIETpFluvZA176MBCDz6KV0Kpc8e
Wtm7aDiGgpKqghWxrlhDUKK966SbwOBn0KUEMnmymLNU8nSnj/ZciKxxW0jfOB3y
VFOrqE6T2VEyWsWKh3dG
=ogww
-----END PGP SIGNATURE-----

--vtzGhvizbBRQ85DL--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
