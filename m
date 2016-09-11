Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id F19C56B0038
	for <linux-mm@kvack.org>; Sun, 11 Sep 2016 08:47:47 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x24so297188875pfa.0
        for <linux-mm@kvack.org>; Sun, 11 Sep 2016 05:47:47 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id f24si12919078pfe.131.2016.09.11.05.47.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 11 Sep 2016 05:47:47 -0700 (PDT)
Date: Sun, 11 Sep 2016 05:47:41 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v2 2/9] ext2: tell DAX the size of allocation holes
Message-ID: <20160911124741.GA746@infradead.org>
References: <20160825075728.GA11235@infradead.org>
 <20160826212934.GA11265@linux.intel.com>
 <20160829074116.GA16491@infradead.org>
 <20160829125741.cdnbb2uaditcmnw2@thunk.org>
 <20160909164808.GC18554@linux.intel.com>
 <DM2PR21MB0089BCA980B67D8C53B25A1BCBFA0@DM2PR21MB0089.namprd21.prod.outlook.com>
 <20160910073012.GA5295@infradead.org>
 <DM2PR21MB0089FDEE0F0939010189EB99CBFD0@DM2PR21MB0089.namprd21.prod.outlook.com>
 <20160910074228.GA23749@infradead.org>
 <DM2PR21MB0089C20EF469AA91A916867CCBFD0@DM2PR21MB0089.namprd21.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <DM2PR21MB0089C20EF469AA91A916867CCBFD0@DM2PR21MB0089.namprd21.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Christoph Hellwig <hch@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, Dave Chinner <david@fromorbit.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andreas Dilger <adilger.kernel@dilger.ca>, Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

On Sat, Sep 10, 2016 at 07:52:53AM +0000, Matthew Wilcox wrote:
> DAX code over to using iomap requires converting all of ext2 away from
> buffer_head; are you saying he's wrong?

Not sure if he's really saying that, but it's wrong for sure.  Just
to prove that I came up with a working ext2 iomap DAX implementation
in a few hours today.  I'll take a stab at ext4 and the block device
as well and will post the updated series early next week - I'll need
to take care of a few high priority todo list items first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
