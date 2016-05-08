Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id BFA1B6B007E
	for <linux-mm@kvack.org>; Sun,  8 May 2016 05:01:49 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id yl2so220983063pac.2
        for <linux-mm@kvack.org>; Sun, 08 May 2016 02:01:49 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.9])
        by mx.google.com with ESMTPS id n5si29887682pfn.212.2016.05.08.02.01.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 May 2016 02:01:49 -0700 (PDT)
Date: Sun, 8 May 2016 02:01:48 -0700
From: "hch@infradead.org" <hch@infradead.org>
Subject: Re: [PATCH v4 5/7] fs: prioritize and separate direct_io from dax_io
Message-ID: <20160508090148.GF15458@infradead.org>
References: <1461878218-3844-1-git-send-email-vishal.l.verma@intel.com>
 <1461878218-3844-6-git-send-email-vishal.l.verma@intel.com>
 <5727753F.6090104@plexistor.com>
 <20160505142433.GA4557@infradead.org>
 <1462484343.29294.1.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462484343.29294.1.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Verma, Vishal L" <vishal.l.verma@intel.com>
Cc: "hch@infradead.org" <hch@infradead.org>, "boaz@plexistor.com" <boaz@plexistor.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "axboe@fb.com" <axboe@fb.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>, "matthew@wil.cx" <matthew@wil.cx>

On Thu, May 05, 2016 at 09:39:14PM +0000, Verma, Vishal L wrote:
> How is it any 'less direct'? All it does now is follow the blockdev
> O_DIRECT path. There still isn't any page cache involved..

It's still more overhead than the play DAX I/O path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
