Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1CFDB6B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 14:12:37 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id m22so11451082pfg.15
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 11:12:37 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0097.outbound.protection.outlook.com. [104.47.32.97])
        by mx.google.com with ESMTPS id v31-v6si640724plg.804.2018.01.30.11.12.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 11:12:35 -0800 (PST)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH] Lock mmap_sem when calling migrate_pages() in
 do_move_pages_to_node()
Date: Tue, 30 Jan 2018 14:12:28 -0500
Message-ID: <F3D5C6AC-78B6-4443-9BE1-575831F238E2@cs.rutgers.edu>
In-Reply-To: <20180130161025.GH21609@dhcp22.suse.cz>
References: <20180130030011.4310-1-zi.yan@sent.com>
 <20180130081415.GO21609@dhcp22.suse.cz> <5A7094DA.4000804@cs.rutgers.edu>
 <20180130161025.GH21609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_932B6DEC-4598-4B7A-9293-DFD1740C5BF5_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_932B6DEC-4598-4B7A-9293-DFD1740C5BF5_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 30 Jan 2018, at 11:10, Michal Hocko wrote:

> On Tue 30-01-18 10:52:58, Zi Yan wrote:
>>
>>
>> Michal Hocko wrote:
>>> On Mon 29-01-18 22:00:11, Zi Yan wrote:
>>>> From: Zi Yan <zi.yan@cs.rutgers.edu>
>>>>
>>>> migrate_pages() requires at least down_read(mmap_sem) to protect
>>>> related page tables and VMAs from changing. Let's do it in
>>>> do_page_moves() for both do_move_pages_to_node() and
>>>> add_page_for_migration().
>>>>
>>>> Also add this lock requirement in the comment of migrate_pages().
>>>
>>> This doesn't make much sense to me, to be honest. We are holding
>>> mmap_sem for _read_ so we allow parallel updates like page faults
>>> or unmaps. Therefore we are isolating pages prior to the migration.
>>>
>>> The sole purpose of the mmap_sem in add_page_for_migration is to prot=
ect
>>> from vma going away _while_ need it to get the proper page.
>>
>> Then, I am wondering why we are holding mmap_sem when calling
>> migrate_pages() in existing code.
>> https://na01.safelinks.protection.outlook.com/?url=3Dhttp%3A%2F%2Felix=
ir.free-electrons.com%2Flinux%2Flatest%2Fsource%2Fmm%2Fmigrate.c%23L1576&=
data=3D02%7C01%7Czi.yan%40cs.rutgers.edu%7C855d86d83cff4669d25f08d567fbfb=
8d%7Cb92d2b234d35447093ff69aca6632ffe%7C1%7C0%7C636529254319323899&sdata=3D=
Ba8F7IHIjxDRV%2FeGg7883wlRBmDHQW6pbZubAWZDNLs%3D&reserved=3D0
>
> You mean in the original code? I strongly suspect this was to not take
> it for each page.

Right. The original code gathers 169 pages, whose information (struct pag=
e_to_node, 24bytes)
fits into a 4KB page, then migrates them at a time. So mmap_sem is not he=
ld for long
in the original code, because of this design.

I think the question is whether we need to hold mmap_sem for migrate_page=
s(). Hugh
also agrees it is not necessary on a separate email. But it is held in th=
e original code.

--
Best Regards
Yan Zi

--=_MailMate_932B6DEC-4598-4B7A-9293-DFD1740C5BF5_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJacMOdAAoJEEGLLxGcTqbM1YIH/iv7+2aqTWmpTb2mKhI7ntYW
cpg8gYQ7d4xd+hu0LYloy6nC2qU94op3T30W3sN7HYLuQFPGDdM2R3s1AdbEG7nC
PKEVb7GqmhseDSsKPMc2oHIod3nKgasiwMn/S9C8j/53+5y2dNeN9ss3g4JTdRSq
MFbTKf6XhGJ+HUcCz2iRSd6RBeF9S/O16FlSXGwI/asGHDZPX3yTzyoyKGEtUhbR
VHUF5wluLUsRcyLpiPX3s/xFh8DvJbPxgaFBY7xFQklWBge+ktAadWbUuNlRPi/C
68wJrk5igVp0Bte3TXKOhQfavdjTUWvmsDFIB/ukffnx2+QxlF3bxb053DlCT3A=
=yPR7
-----END PGP SIGNATURE-----

--=_MailMate_932B6DEC-4598-4B7A-9293-DFD1740C5BF5_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
