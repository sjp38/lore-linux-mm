Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id AE1906B0003
	for <linux-mm@kvack.org>; Thu, 14 Jun 2018 15:37:12 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id z83-v6so4405088oiz.23
        for <linux-mm@kvack.org>; Thu, 14 Jun 2018 12:37:12 -0700 (PDT)
Received: from g2t2353.austin.hpe.com (g2t2353.austin.hpe.com. [15.233.44.26])
        by mx.google.com with ESMTPS id 4-v6si1883430oid.397.2018.06.14.12.37.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jun 2018 12:37:11 -0700 (PDT)
From: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>
Subject: RE: [PATCH] mm: disallow mapping that conflict for
 devm_memremap_pages()
Date: Thu, 14 Jun 2018 19:37:08 +0000
Message-ID: <AT5PR8401MB11698094C482D26E172B8E41AB7D0@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
References: <152900070339.49084.2958083852988708457.stgit@djiang5-desk3.ch.intel.com>
In-Reply-To: <152900070339.49084.2958083852988708457.stgit@djiang5-desk3.ch.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Dave Jiang' <dave.jiang@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>



> -----Original Message-----
> From: Linux-nvdimm [mailto:linux-nvdimm-bounces@lists.01.org] On Behalf O=
f
> Dave Jiang
> Sent: Thursday, June 14, 2018 1:25 PM
> Subject: [PATCH] mm: disallow mapping that conflict for
> devm_memremap_pages()
...
> +	conflict_pgmap =3D get_dev_pagemap(PHYS_PFN(align_start), NULL);
> +	if (conflict_pgmap) {
> +		dev_warn(dev, "Conflicting mapping in same section\n");
> +		put_dev_pagemap(conflict_pgmap);
> +		return ERR_PTR(-ENOMEM);
> +	}
> +
> +	conflict_pgmap =3D get_dev_pagemap(PHYS_PFN(align_end), NULL);
> +	if (conflict_pgmap) {
> +		dev_warn(dev, "Conflicting mapping in same section\n");
> +		put_dev_pagemap(conflict_pgmap);
> +		return ERR_PTR(-ENOMEM);
> +	}

Unique warning messages would help narrow down the problem.

dev_WARN is one way to make them unique, if a backtrace is also appropriate=
.


---
Robert Elliott, HPE Persistent Memory
