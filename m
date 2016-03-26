Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f174.google.com (mail-pf0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id D67996B007E
	for <linux-mm@kvack.org>; Sat, 26 Mar 2016 12:54:08 -0400 (EDT)
Received: by mail-pf0-f174.google.com with SMTP id 4so104253469pfd.0
        for <linux-mm@kvack.org>; Sat, 26 Mar 2016 09:54:08 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id 12si4782503pfm.92.2016.03.26.09.54.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Mar 2016 09:54:07 -0700 (PDT)
Date: Sat, 26 Mar 2016 09:53:59 -0700
From: "hch@infradead.org" <hch@infradead.org>
Subject: Re: [PATCH 5/5] dax: handle media errors in dax_do_io
Message-ID: <20160326165359.GA11387@infradead.org>
References: <1458861450-17705-1-git-send-email-vishal.l.verma@intel.com>
 <1458861450-17705-6-git-send-email-vishal.l.verma@intel.com>
 <20160325104549.GB10525@infradead.org>
 <1458939566.5501.5.camel@intel.com>
 <CAPcyv4jFPYYP=eL72V6MmW2fcXFP3PfQfcO+zYV4NN7rdu1ksg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jFPYYP=eL72V6MmW2fcXFP3PfQfcO+zYV4NN7rdu1ksg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "Verma, Vishal L" <vishal.l.verma@intel.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "jack@suse.cz" <jack@suse.cz>, "axboe@fb.com" <axboe@fb.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "hch@infradead.org" <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>

On Fri, Mar 25, 2016 at 02:42:37PM -0700, Dan Williams wrote:
> That's their prerogative otherwise you are precluding an alternate
> handling of a dax_do_io() failure.  Maybe a fs or upper layer can
> recover in a different manner than re-submit the I/O to the
> __blockdev_direct_IO path.

Let's keep the interface separate because they are, well separate.
There is a reason direct I/O falls back to buffered I/O by returning
and error if it can't handle it instead of handling all the magic.

I also really want to get rid of get_block as soon as possible for
DAX and direct I/O.  For DAX that should actually be possible
really quickly, while direct I/O might take some time and will
be have to be gradual.  So tighter integration of the two interface is
not just bad design, but actively harmful at this point in time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
