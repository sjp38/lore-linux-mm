Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E21C46B0003
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 16:53:46 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 202so2689334pgb.13
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 13:53:46 -0800 (PST)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0104.outbound.protection.outlook.com. [104.47.41.104])
        by mx.google.com with ESMTPS id k6-v6si645982pla.333.2018.02.22.13.53.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 22 Feb 2018 13:53:45 -0800 (PST)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [RFC 1/2] Protect larger order pages from breaking up
Date: Thu, 22 Feb 2018 16:53:25 -0500
Message-ID: <E4FA7972-B97C-4D63-8473-C6F1F4FAB7A0@cs.rutgers.edu>
In-Reply-To: <68050f0f-14ca-d974-9cf4-19694a2244b9@schoebel-theuer.de>
References: <20180216160110.641666320@linux.com>
 <20180216160121.519788537@linux.com>
 <20180219101935.cb3gnkbjimn5hbud@techsingularity.net>
 <68050f0f-14ca-d974-9cf4-19694a2244b9@schoebel-theuer.de>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_6EB96056-C7FF-4289-8A72-7260F5164555_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Schoebel-Theuer <tst@schoebel-theuer.de>
Cc: Mel Gorman <mgorman@techsingularity.net>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_6EB96056-C7FF-4289-8A72-7260F5164555_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 22 Feb 2018, at 16:19, Thomas Schoebel-Theuer wrote:

<snip>
>
> No need for a deep understanding of the theory of the memory fragmentat=
ion problem.
>
> Also no need for adding anything to the boot commandline. Fragmentation=
 will typically occur only after some days or weeks or months of operatio=
n, at least in all of the practical cases I have personally seen at 1&1 d=
atacenters and their workloads.
>
> Please notice that fragmentation can be a very serious problem for oper=
ations if you are hurt by it. It can seriously harm your business. And it=
 is _extremely_ specific to the actual workload, and to the hardware / ch=
ipset / etc. This is addressed by the above method of determining the rig=
ht values from _actual_ operations (not from speculation) and then memoiz=
ing them.
>
> The attached patchset tries to be very simple, but in my practical expe=
rience it is a very effective practical solution.
>
> When requested, I can post the mathematical theory behind the patch, or=
 I could give a presentation at some of the next conferences if I would b=
e invited (or better give a practical explanation instead). But probably =
nobody on these lists wants to deal with any theories.

Hi Thomas,

I am very interested in the theory behind your patch. Do you mind sharing=
 it? Is there
any required math background before reading it? Is there any related pape=
rs/articles I could
also read?

Thanks.

--
Best Regards
Yan Zi

--=_MailMate_6EB96056-C7FF-4289-8A72-7260F5164555_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJajzvVAAoJEEGLLxGcTqbMQ5QIALByhPmY9zak09Mprwb9H+Zk
E/OT27Tw2DGTVGr3B88uuDL/SH6RxbawclIPhgxoQXA3iN+RJQ/jNK4/jf22mOx3
Og9pV3Vm2vMaZDRSMd6UyqsP3VAfVi5WNmayh57thwsjuk14vzLNGon8c7/mZTiS
3CIchF8yaymo24c0vf4l/y8yZbEkb/MMXDjnFPub6sm7ZFWW3tas+qjf6JKeWDom
E9CW+oKHDMHATVn1IR9HYtn4t/3iwbjmBqEbMqD2vMGUQe1l8wbpvs/6bJnlL5tF
dt+B4GixBDpQcGsYvHkRSCpGL4vPCWfhoeHmPXWftsdlohWExO86gXwFwwg4Jqk=
=qRLg
-----END PGP SIGNATURE-----

--=_MailMate_6EB96056-C7FF-4289-8A72-7260F5164555_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
