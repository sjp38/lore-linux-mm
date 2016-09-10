Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4ABDA6B0069
	for <linux-mm@kvack.org>; Sat, 10 Sep 2016 03:52:56 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 128so7711347pfb.2
        for <linux-mm@kvack.org>; Sat, 10 Sep 2016 00:52:56 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0108.outbound.protection.outlook.com. [104.47.41.108])
        by mx.google.com with ESMTPS id x9si8474437pff.84.2016.09.10.00.52.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 10 Sep 2016 00:52:55 -0700 (PDT)
From: Matthew Wilcox <mawilcox@microsoft.com>
Subject: RE: [PATCH v2 2/9] ext2: tell DAX the size of allocation holes
Date: Sat, 10 Sep 2016 07:52:53 +0000
Message-ID: <DM2PR21MB0089C20EF469AA91A916867CCBFD0@DM2PR21MB0089.namprd21.prod.outlook.com>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
 <20160823220419.11717-3-ross.zwisler@linux.intel.com>
 <20160825075728.GA11235@infradead.org>
 <20160826212934.GA11265@linux.intel.com>
 <20160829074116.GA16491@infradead.org>
 <20160829125741.cdnbb2uaditcmnw2@thunk.org>
 <20160909164808.GC18554@linux.intel.com>
 <DM2PR21MB0089BCA980B67D8C53B25A1BCBFA0@DM2PR21MB0089.namprd21.prod.outlook.com>
 <20160910073012.GA5295@infradead.org>
 <DM2PR21MB0089FDEE0F0939010189EB99CBFD0@DM2PR21MB0089.namprd21.prod.outlook.com>
 <20160910074228.GA23749@infradead.org>
In-Reply-To: <20160910074228.GA23749@infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, Dave Chinner <david@fromorbit.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andreas
 Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

From: Christoph Hellwig [mailto:hch@infradead.org]
> On Sat, Sep 10, 2016 at 07:33:18AM +0000, Matthew Wilcox wrote:
> > > caller specific is unaceptable.  That being said your idea doesn't
> > > sounds unreasonable, but will require a bit more work and has no
> > > real short-term need.
> >
> > So your proposal is to remove buffer_heads from ext2?
>=20
> No, the proposal is to remove buffer_heads from XFS first, then GFS2 and =
then
> maybe others like ext4.  I'd like to remove buffer_heads from the DAX pat=
h for
> ext2 and ext4 entitrely for sure (and direct I/O next).

That's ... what I propose.  The only use of buffer_head in my proposal is t=
o
communicate a single extent from the filesystem to the DAX core, and that
can equally well use an iomap.  Ross seems to think that converting the cur=
rent
DAX code over to using iomap requires converting all of ext2 away from
buffer_head; are you saying he's wrong?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
