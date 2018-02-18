Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 99AFE6B0003
	for <linux-mm@kvack.org>; Sun, 18 Feb 2018 04:00:08 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c5so1558477pfn.17
        for <linux-mm@kvack.org>; Sun, 18 Feb 2018 01:00:08 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0052.outbound.protection.outlook.com. [104.47.0.52])
        by mx.google.com with ESMTPS id n129si2083733pga.260.2018.02.18.01.00.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 18 Feb 2018 01:00:06 -0800 (PST)
From: Guy Shattah <sguy@mellanox.com>
Subject: RE: [RFC 1/2] Protect larger order pages from breaking up
Date: Sun, 18 Feb 2018 09:00:00 +0000
Message-ID: <DB6PR05MB335259492C780BA8B5BF8959BDC90@DB6PR05MB3352.eurprd05.prod.outlook.com>
References: <20180216160110.641666320@linux.com>
 <20180216160121.519788537@linux.com>
 <5108eb20-2b20-bd48-903e-bce312e96974@oracle.com>
 <alpine.DEB.2.20.1802161411440.11934@nuc-kabylake>
In-Reply-To: <alpine.DEB.2.20.1802161411440.11934@nuc-kabylake>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Mel Gorman <mel@skynet.ie>, Matthew Wilcox <willy@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, "andi@firstfloor.org" <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura
 Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>

>=20
> Yup it has a pool for everyone. Question is how to divide the loot ;-)
>=20
> > IIRC, Guy Shattah's use case was for allocations greater than MAX_ORDER=
.
> > This would not directly address that.  A huge contiguous area (2GB) is
> > the sweet spot' for best performance in his case.  However, I think he
> > could still benefit from using a set of larger (such as 2MB) size
> > allocations which this scheme could help with.
>=20
> MAX_ORDER can be increased to allow for larger allocations. IA64 has f.e.
> a much larger MAX_ORDER size. So does powerpc. And then the reservation
> scheme will work.
>=20

MAX_ORDER can be increased only if kernel is recompiled.=20
It won't work for code running for the general case / typical user.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
