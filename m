Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 57CB96B0022
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 21:16:53 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id e126so3444285pfh.4
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 18:16:53 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0124.outbound.protection.outlook.com. [104.47.38.124])
        by mx.google.com with ESMTPS id m14si988011pff.156.2018.02.22.18.16.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 22 Feb 2018 18:16:52 -0800 (PST)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [RFC 1/2] Protect larger order pages from breaking up
Date: Thu, 22 Feb 2018 21:16:07 -0500
Message-ID: <1B85435E-A9FB-47E7-A2FE-FE21632778F0@cs.rutgers.edu>
In-Reply-To: <alpine.DEB.2.20.1802222000470.2221@nuc-kabylake>
References: <20180216160110.641666320@linux.com>
 <20180216160121.519788537@linux.com>
 <20180219101935.cb3gnkbjimn5hbud@techsingularity.net>
 <68050f0f-14ca-d974-9cf4-19694a2244b9@schoebel-theuer.de>
 <E4FA7972-B97C-4D63-8473-C6F1F4FAB7A0@cs.rutgers.edu>
 <alpine.DEB.2.20.1802222000470.2221@nuc-kabylake>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_25FC8291-A103-4243-9FB9-4D6E70C4853F_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_25FC8291-A103-4243-9FB9-4D6E70C4853F_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Yes. I saw the attached patches. I am definitely going to apply them and =
see how they work out.

In his last patch, there are a bunch of magic numbers used to reserve fre=
e page blocks
at different orders. I think that is the most interesting part. If Thomas=
 can share how
to determine these numbers with his theory based on workloads, hardware/c=
hipset, that would
be a great guideline for sysadmins to take advantage of the patches.

=E2=80=94
Best Regards,
Yan Zi

On 22 Feb 2018, at 21:01, Christopher Lameter wrote:

> On Thu, 22 Feb 2018, Zi Yan wrote:
>
>> I am very interested in the theory behind your patch. Do you mind shar=
ing it? Is there
>> any required math background before reading it? Is there any related p=
apers/articles I could
>> also read?
>
> His patches were attached to the email you responded to. Guess I should=

> update the patchset with the suggested changes and repost.

--=_MailMate_25FC8291-A103-4243-9FB9-4D6E70C4853F_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAlqPeWcWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzLd4CACMKJTGTIMRbpnMwABt9NYEDXEu
EaDO6Ugwp6H3Kb2xCCFHCW0+PTDKM+H9itRQuy3b4tqGmSSF0xFudf/lwC5ZItis
SxtgDXzzeCxulHXQWffQHfvigxi0ZFyKPnv3ebFusohzMf2u/BXziMbxBLl8t9kT
kZgLD2+steB5/kLj2MOXRG3CIttLzRVbqnLI80Goso43VIcIe2ZLpjDxXxuXFyxY
FEOz+prDhT3gmrVURn8nQGvMJMqt27tnHSKetmfCYqxrEVcJglSGS8FNObL50w7d
tkLnJCr3BryJ99Dvt4LM0UwICXGPCxRlhfxYKZU+j2272IRa+S85CNGzOn4h
=0Pgj
-----END PGP SIGNATURE-----

--=_MailMate_25FC8291-A103-4243-9FB9-4D6E70C4853F_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
