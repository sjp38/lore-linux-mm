Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0D55482F99
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 19:28:54 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id bx1so58416281obb.0
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 16:28:54 -0800 (PST)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id h5si31672727obe.20.2015.12.23.16.28.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Dec 2015 16:28:53 -0800 (PST)
From: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>
Subject: RE: [PATCH v6 3/7] mm: add find_get_entries_tag()
Date: Thu, 24 Dec 2015 00:28:24 +0000
Message-ID: <94D0CD8314A33A4D9D801C0FE68B40295BEC9A58@G9W0745.americas.hpqcorp.net>
References: <1450899560-26708-1-git-send-email-ross.zwisler@linux.intel.com>
 <1450899560-26708-4-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1450899560-26708-4-git-send-email-ross.zwisler@linux.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, "J. Bruce Fields" <bfields@fieldses.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andreas Dilger <adilger.kernel@dilger.ca>, "H. Peter Anvin" <hpa@zytor.com>, Jeff Layton <jlayton@poochiereds.net>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "x86@kernel.org" <x86@kernel.org>, Ingo Molnar <mingo@redhat.com>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

> -----Original Message-----
> From: Linux-nvdimm [mailto:linux-nvdimm-bounces@lists.01.org] On Behalf O=
f
> Ross Zwisler
> Sent: Wednesday, December 23, 2015 1:39 PM
> Subject: [PATCH v6 3/7] mm: add find_get_entries_tag()
>=20
...
> diff --git a/mm/filemap.c b/mm/filemap.c
...
> +unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t sta=
rt,
> +			int tag, unsigned int nr_entries,
> +			struct page **entries, pgoff_t *indices)
> +{
> +	void **slot;
> +	unsigned int ret =3D 0;
...
> +	radix_tree_for_each_tagged(slot, &mapping->page_tree,
> +				   &iter, start, tag) {
...
> +		indices[ret] =3D iter.index;
> +		entries[ret] =3D page;
> +		if (++ret =3D=3D nr_entries)
> +			break;
> +	}

Using >=3D would provide more safety from buffer overflow
problems in case ret ever jumped ahead by more than one.
---
Robert Elliott, HPE Persistent Memory

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
