Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id E7DA86B031C
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 21:27:16 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id w191so848274iof.11
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 18:27:16 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id j10si1034381ioi.258.2017.12.05.18.27.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 18:27:15 -0800 (PST)
Date: Tue, 5 Dec 2017 18:27:13 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 00/73] XArray version 4
Message-ID: <20171206022713.GN26021@bombadil.infradead.org>
References: <20171206004159.3755-1-willy@infradead.org>
 <20171206014536.GA4094@dastard>
 <20171206015108.GB4094@dastard>
 <MWHPR21MB0845A83B9E89E4A9499AEC2FCB320@MWHPR21MB0845.namprd21.prod.outlook.com>
 <20171206021752.GC4094@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171206021752.GC4094@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-f2fs-devel@lists.sourceforge.net" <linux-f2fs-devel@lists.sourceforge.net>, "linux-nilfs@vger.kernel.org" <linux-nilfs@vger.kernel.org>, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>, "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Dec 06, 2017 at 01:17:52PM +1100, Dave Chinner wrote:
> On Wed, Dec 06, 2017 at 01:53:41AM +0000, Matthew Wilcox wrote:
> > Huh, you've caught a couple of problems that 0day hasn't sent me yet.  Try turning on DAX or TRANSPARENT_HUGEPAGE.  Thanks!
> 
> Dax is turned on, CONFIG_TRANSPARENT_HUGEPAGE is not.
> 
> Looks like nothing is setting CONFIG_RADIX_TREE_MULTIORDER, which is
> what xas_set_order() is hidden under.
> 
> Ah, CONFIG_ZONE_DEVICE turns it on, not CONFIG_DAX/CONFIG_FS_DAX.
> 
> Hmmmm.  That seems wrong if it's used in fs/dax.c...

Yes, it's my mistake for not making xas_set_order available in the
!MULTIORDER case.  I'm working on a fix now.

> What a godawful mess Kconfig has turned into.

I'm not going to argue with that ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
