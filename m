Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 916686B025E
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 01:32:34 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id q92so111548375ioi.3
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 22:32:34 -0700 (PDT)
Received: from g2t2355.austin.hpe.com (g2t2355.austin.hpe.com. [15.233.44.28])
        by mx.google.com with ESMTPS id d30si26373789otb.112.2016.09.20.22.32.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 22:32:33 -0700 (PDT)
From: Juerg Haefliger <juerg.haefliger@hpe.com>
Subject: Re: [kernel-hardening] [RFC PATCH v2 2/3] xpfo: Only put previous
 userspace pages into the hot cache
References: <20160902113909.32631-1-juerg.haefliger@hpe.com>
 <20160914071901.8127-1-juerg.haefliger@hpe.com>
 <20160914071901.8127-3-juerg.haefliger@hpe.com> <57D95FA3.3030103@intel.com>
 <7badeb6c-e343-4327-29ed-f9c9c0b6654b@hpe.com> <57D9633A.2010702@intel.com>
Message-ID: <09d3ac8c-1111-b7aa-4720-b7a7b7c7798b@hpe.com>
Date: Wed, 21 Sep 2016 07:32:09 +0200
MIME-Version: 1.0
In-Reply-To: <57D9633A.2010702@intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="c2csM3GwGuAP6k4UUq4uQ3pOeC0oH3gwe"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-x86_64@vger.kernel.org
Cc: vpk@cs.columbia.edu

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--c2csM3GwGuAP6k4UUq4uQ3pOeC0oH3gwe
Content-Type: multipart/mixed; boundary="cp3KG1pRWNVkg2cUrE2FeqpfXPuIvKHFp";
 protected-headers="v1"
From: Juerg Haefliger <juerg.haefliger@hpe.com>
To: Dave Hansen <dave.hansen@intel.com>, kernel-hardening@lists.openwall.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-x86_64@vger.kernel.org
Cc: vpk@cs.columbia.edu
Message-ID: <09d3ac8c-1111-b7aa-4720-b7a7b7c7798b@hpe.com>
Subject: Re: [kernel-hardening] [RFC PATCH v2 2/3] xpfo: Only put previous
 userspace pages into the hot cache
References: <20160902113909.32631-1-juerg.haefliger@hpe.com>
 <20160914071901.8127-1-juerg.haefliger@hpe.com>
 <20160914071901.8127-3-juerg.haefliger@hpe.com> <57D95FA3.3030103@intel.com>
 <7badeb6c-e343-4327-29ed-f9c9c0b6654b@hpe.com> <57D9633A.2010702@intel.com>
In-Reply-To: <57D9633A.2010702@intel.com>

--cp3KG1pRWNVkg2cUrE2FeqpfXPuIvKHFp
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 09/14/2016 04:48 PM, Dave Hansen wrote:
>> On 09/02/2016 10:39 PM, Dave Hansen wrote:
>>> On 09/02/2016 04:39 AM, Juerg Haefliger wrote:
>>> Does this
>>> just mean that kernel allocations usually have to pay the penalty to
>>> convert a page?
>>
>> Only pages that are allocated for userspace (gfp & GFP_HIGHUSER =3D=3D=
 GFP_HIGHUSER) which were
>> previously allocated for the kernel (gfp & GFP_HIGHUSER !=3D GFP_HIGHU=
SER) have to pay the penalty.
>>
>>> So, what's the logic here?  You're assuming that order-0 kernel
>>> allocations are more rare than allocations for userspace?
>>
>> The logic is to put reclaimed kernel pages into the cold cache to
>> postpone their allocation as long as possible to minimize (potential)
>> TLB flushes.
>=20
> OK, but if we put them in the cold area but kernel allocations pull the=
m
> from the hot cache, aren't we virtually guaranteeing that kernel
> allocations will have to to TLB shootdown to convert a page?

No. Allocations for the kernel never require a TLB shootdown. Only alloca=
tions for userspace (and
only if the page was previously a kernel page).


> It seems like you also need to convert all kernel allocations to pull
> from the cold area.

Kernel allocations can continue to pull from the hot cache. Maybe introdu=
ce another cache for the
userspace pages? But I'm not sure what other implications this might have=
=2E

=2E..Juerg



--cp3KG1pRWNVkg2cUrE2FeqpfXPuIvKHFp--

--c2csM3GwGuAP6k4UUq4uQ3pOeC0oH3gwe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJX4httAAoJEHVMOpb5+LSMZ70P+wUBIgtKwmFUXkR1gRWJRVMx
qaebjDcW32Edkxrg0579JSX3QHbpdQ9FU/oA/2gAGWpBi+w1WzJM/RzRHPxEG+ef
e9vimmquTKzWdJSwEy1AqJSwF3QE39o0aJmsGBycvrc9mKQKb8rSSjpthSlOPCtb
S8a9IRL3zghpOAeQSkKuiWYhYTHcfmYQpSBcBrzP3cCuX17LNKNHIGeRb4uFdbMA
MMtSUCnXt8mkk5HgTXkAGv0UN+ox+bBIQ1hzHbdyTSahKzi6pIDlcufMaz9JSxHH
CVVdll/vzPBB2hAQ7nTa+4bOULe091bHMDM4ibI9O3e70E1HIdGwjyKHZFdTMQeT
Ft8GC4+LRQYphOlZi/UrhzLPaZMfew4PZAslo6EuPyixxZ+9B/hMy70O35p8y1zL
3RYb+oAPF8WGUQXQ71DHj3eOVaHxPwTxFXSF2rdRoGeicQEN1UP8J3X6ztbrUXR6
rPVoArezDHp1vaj7IzeLAK/HDUKGQvhMi4sur9AHgdu6GK0zKg59OYZEgUHcilOU
TvatAm5stL1IA127BzN1LBE4TZgIx78PxIqtTHXX5SR6n0x0WstcEgXuV5gR1YF+
vxHNnBNBlLWTI5ztKRu5fD5pJRlRdqdua9WZEJVjj94vR+WgkE0tD5yMr2YPGoDZ
9F1XnrIX6PCxw9lxJ8mq
=MRdI
-----END PGP SIGNATURE-----

--c2csM3GwGuAP6k4UUq4uQ3pOeC0oH3gwe--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
