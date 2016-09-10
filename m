Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 527296B0069
	for <linux-mm@kvack.org>; Sat, 10 Sep 2016 03:31:58 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x24so233894526pfa.0
        for <linux-mm@kvack.org>; Sat, 10 Sep 2016 00:31:58 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id xi3si8348536pab.203.2016.09.10.00.31.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Sep 2016 00:31:57 -0700 (PDT)
Date: Sat, 10 Sep 2016 00:31:51 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 2/9] ext2: tell DAX the size of allocation holes
Message-ID: <20160910073151.GB5295@infradead.org>
References: <20160823220419.11717-1-ross.zwisler@linux.intel.com>
 <20160823220419.11717-3-ross.zwisler@linux.intel.com>
 <20160825075728.GA11235@infradead.org>
 <20160826212934.GA11265@linux.intel.com>
 <20160829074116.GA16491@infradead.org>
 <20160829125741.cdnbb2uaditcmnw2@thunk.org>
 <20160909164808.GC18554@linux.intel.com>
 <DM2PR21MB0089BCA980B67D8C53B25A1BCBFA0@DM2PR21MB0089.namprd21.prod.outlook.com>
 <CAPcyv4hjna08+Yw23w_V2f-RbBE6ar220+YGCuBVA-TACKWNug@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hjna08+Yw23w_V2f-RbBE6ar220+YGCuBVA-TACKWNug@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, Dave Chinner <david@fromorbit.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

On Fri, Sep 09, 2016 at 03:34:43PM -0700, Dan Williams wrote:
> I agree with you that continuing to touch ext2 is not a good idea, but
> I'm not yet convinced that now is the time to go do dax-2.0 when we
> haven't finished shipping dax-1.0.

I've mentioned this before, but I'd like to repeat it.  With all the
work reqwuired in the file system I would prefer to drop DAX support
in ext2 (and if people really cry for it reinstate the trivial old xip
support).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
