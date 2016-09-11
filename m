Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 909B86B0038
	for <linux-mm@kvack.org>; Sat, 10 Sep 2016 20:42:15 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id l64so161597879oif.3
        for <linux-mm@kvack.org>; Sat, 10 Sep 2016 17:42:15 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0124.outbound.protection.outlook.com. [104.47.32.124])
        by mx.google.com with ESMTPS id n1si6757226otb.246.2016.09.10.17.42.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 10 Sep 2016 17:42:14 -0700 (PDT)
From: Matthew Wilcox <mawilcox@microsoft.com>
Subject: RE: [PATCH v2 2/9] ext2: tell DAX the size of allocation holes
Date: Sun, 11 Sep 2016 00:42:09 +0000
Message-ID: <DM2PR21MB0089779C095E9945B4C51346CBFC0@DM2PR21MB0089.namprd21.prod.outlook.com>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
 <20160823220419.11717-3-ross.zwisler@linux.intel.com>
 <20160825075728.GA11235@infradead.org>
 <20160826212934.GA11265@linux.intel.com>
 <20160829074116.GA16491@infradead.org>
 <20160829125741.cdnbb2uaditcmnw2@thunk.org>
 <20160909164808.GC18554@linux.intel.com>
 <DM2PR21MB0089BCA980B67D8C53B25A1BCBFA0@DM2PR21MB0089.namprd21.prod.outlook.com>
 <CAPcyv4hjna08+Yw23w_V2f-RbBE6ar220+YGCuBVA-TACKWNug@mail.gmail.com>
 <20160910073151.GB5295@infradead.org>
 <20160910174910.yyirb7smiob7evt5@thunk.org>
In-Reply-To: <20160910174910.yyirb7smiob7evt5@thunk.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Christoph Hellwig <hch@infradead.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, Dave Chinner <david@fromorbit.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andreas
 Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

From: Theodore Ts'o [mailto:tytso@mit.edu]
> On Sat, Sep 10, 2016 at 12:31:51AM -0700, Christoph Hellwig wrote:
> > I've mentioned this before, but I'd like to repeat it.  With all the
> > work reqwuired in the file system I would prefer to drop DAX support
> > in ext2 (and if people really cry for it reinstate the trivial old xip
> > support).
>=20
> Why is so much work required to support the new DAX interfaces in
> ext2?  Is that unique to ext2, or is adding DAX support just going to
> be painful for all file systems?  Hopefully it's not the latter,
> right?

It's always been my goal to make supporting DAX as easy as possible
for the filesystem.  Hence the sharing of the DIO locking, and the (it
turned out) premature reliance on helper functions.  It's more complex
than I wanted it to be right now, and I hope we get to simplify it again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
