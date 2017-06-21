Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id B84106B0279
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 15:48:03 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id e186so85490791ybb.0
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 12:48:03 -0700 (PDT)
Received: from g9t5008.houston.hpe.com (g9t5008.houston.hpe.com. [15.241.48.72])
        by mx.google.com with ESMTPS id f15si4494173ybh.261.2017.06.21.12.48.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 12:48:02 -0700 (PDT)
From: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>
Subject: RE: [PATCH] mm/hwpoison: Clear PRESENT bit for kernel 1:1 mappings of
 poison pages
Date: Wed, 21 Jun 2017 19:47:57 +0000
Message-ID: <AT5PR84MB0082AF4EDEB05999494CA62FABDA0@AT5PR84MB0082.NAMPRD84.PROD.OUTLOOK.COM>
References: <20170616190200.6210-1-tony.luck@intel.com>
 <20170621021226.GA18024@hori1.linux.bs1.fc.nec.co.jp>
 <20170621175403.n5kssz32e2oizl7k@intel.com>
In-Reply-To: <20170621175403.n5kssz32e2oizl7k@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Borislav Petkov <bp@suse.de>, Dave Hansen <dave.hansen@intel.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "'dan.j.williams@intel.com'" <dan.j.williams@intel.com>, "Kani, Toshimitsu" <toshi.kani@hpe.com>, "Vaden, Tom (HPE Server OS Architecture)" <tom.vaden@hpe.com>


> -----Original Message-----
> From: linux-kernel-owner@vger.kernel.org [mailto:linux-kernel-
> owner@vger.kernel.org] On Behalf Of Luck, Tony
> Sent: Wednesday, June 21, 2017 12:54 PM
> To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Borislav Petkov <bp@suse.de>; Dave Hansen <dave.hansen@intel.com>;
> x86@kernel.org; linux-mm@kvack.org; linux-kernel@vger.kernel.org

(adding linux-nvdimm list in this reply)

> Subject: Re: [PATCH] mm/hwpoison: Clear PRESENT bit for kernel 1:1
> mappings of poison pages
>=20
> On Wed, Jun 21, 2017 at 02:12:27AM +0000, Naoya Horiguchi wrote:
>=20
> > We had better have a reverse operation of this to cancel the unmapping
> > when unpoisoning?
>=20
> When we have unpoisoning, we can add something.  We don't seem to have
> an inverse function for "set_memory_np" to just flip the _PRESENT bit
> back on again. But it would be trivial to write a set_memory_pp().
>=20
> Since we'd be doing this after the poison has been cleared, we wouldn't
> need to play games with the address.  We'd just use:
>=20
> 	set_memory_pp((unsigned long)pfn_to_kaddr(pfn), 1);
>=20
> -Tony

Persistent memory does have unpoisoning and would require this inverse
operation - see drivers/nvdimm/pmem.c pmem_clear_poison() and core.c
nvdimm_clear_poison().

---
Robert Elliott, HPE Persistent Memory




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
