Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id C202C6B0253
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 01:16:59 -0500 (EST)
Received: by igcph11 with SMTP id ph11so9609294igc.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 22:16:59 -0800 (PST)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id m5si3201920igx.59.2015.11.12.22.16.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 22:16:59 -0800 (PST)
Received: by igbhv6 with SMTP id hv6so8843823igb.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 22:16:59 -0800 (PST)
Subject: Re: [PATCH v3 01/17] mm: support madvise(MADV_FREE)
References: <1447302793-5376-1-git-send-email-minchan@kernel.org>
 <1447302793-5376-2-git-send-email-minchan@kernel.org>
 <CALCETrWA6aZC_3LPM3niN+2HFjGEm_65m9hiEdpBtEZMn0JhwQ@mail.gmail.com>
 <564421DA.9060809@gmail.com> <20151113061511.GB5235@bbox>
From: Daniel Micay <danielmicay@gmail.com>
Message-ID: <56458056.8020105@gmail.com>
Date: Fri, 13 Nov 2015 01:16:54 -0500
MIME-Version: 1.0
In-Reply-To: <20151113061511.GB5235@bbox>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="xUQjHnNorMAP2CtbNRgGKI9eOOJ95DwwN"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin wang <yalin.wang2010@gmail.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--xUQjHnNorMAP2CtbNRgGKI9eOOJ95DwwN
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 13/11/15 01:15 AM, Minchan Kim wrote:
> On Thu, Nov 12, 2015 at 12:21:30AM -0500, Daniel Micay wrote:
>>> I also think that the kernel should commit to either zeroing the page=

>>> or leaving it unchanged in response to MADV_FREE (even if the decisio=
n
>>> of which to do is made later on).  I think that your patch series doe=
s
>>> this, but only after a few of the patches are applied (the swap entry=

>>> freeing), and I think that it should be a real guaranteed part of the=

>>> semantics and maybe have a test case.
>>
>> This would be a good thing to test because it would be required to add=

>> MADV_FREE_UNDO down the road. It would mean the same semantics as the
>> MEM_RESET and MEM_RESET_UNDO features on Windows, and there's probably=

>> value in that for the sake of migrating existing software too.
>=20
> So, do you mean that we could implement MADV_FREE_UNDO with "read"
> opearation("just access bit marking) easily in future?
>=20
> If so, it would be good reason to change MADV_FREE from dirty bit to
> access bit. Okay, I will look at that.

I just meant testing that the data is either zero or the old data if
it's read before it's written to. Not having it stay around once there
is a read. Not sure if that's what Andy meant.


--xUQjHnNorMAP2CtbNRgGKI9eOOJ95DwwN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIbBAEBCAAGBQJWRYBWAAoJEPnnEuWa9fIq2pwP9RHoHe0xE9qYJgj0eNxnEKwY
8RZdxpMNZ3TeYcxqKPMY1gFj8eVbT4ey6QfwyZcatqPcktBlmPPnrPj76HDkAX9v
nnL0WafLaKkrKP1EHCvQMzIy374JOCLLwN3jMl8UAa/a7dcgDFewwrMwLuu8K026
YDuGEmdz1j4TpsvhOTNbZZBbzt82Jtx3ZYCnqNUqGgJY36Gmhzhaj6ipPuCOc1v2
eDZPkaRSdQ3QrhRNQo/KOu0g95xpco61soMtfPqp+wyCHJOkAmd+1kQHcDscvLNm
SjgdEzjdYZt+n+Fs2AiNksyV9Vd+sekDK5j6L31EmDgPZwBkJ0zQsuNQpyMlmK1q
2TdObDpw9bEXs+nxo+FXjcjTjVtw3RaB2Foqf/ztctjIXs0EGc/1yaqbHtGXjl13
S58GFMrSH6HxoPph1650FoeK4cb6UDuyVmp0vLecT8GJJDevavVwh2610JwLJ2NH
jZNzE05efPGn7dnZmYMYjOscmuMCg0PdxCNKOcstbyFvicfLaVMiUX/r7kWcJi4Q
CYDuUMi02cuSFHWIh/8GKwaACp9/EqAHRox39fGk4xC5gEvZEM2JtNDhd7B3UCYe
vpXRxV2hS+ZohUd5E6h1swy4XPCDkrTPVJsF4+bxDq7ffm75BfCg9x4OjKn2x9dJ
zCKEJ2q3b8Ldwe2mTaw=
=jOqT
-----END PGP SIGNATURE-----

--xUQjHnNorMAP2CtbNRgGKI9eOOJ95DwwN--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
