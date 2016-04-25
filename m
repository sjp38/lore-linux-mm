Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 33E6F6B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 11:32:13 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id n83so279180378qkn.0
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 08:32:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c70si5759321qka.36.2016.04.25.08.32.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 08:32:12 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
References: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
	<1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
	<x49twj26edj.fsf@segfault.boston.devel.redhat.com>
	<20160420205923.GA24797@infradead.org>
	<1461434916.3695.7.camel@intel.com>
	<20160425083114.GA27556@infradead.org>
Date: Mon, 25 Apr 2016 11:32:08 -0400
In-Reply-To: <20160425083114.GA27556@infradead.org> (hch@infradead.org's
	message of "Mon, 25 Apr 2016 01:31:14 -0700")
Message-ID: <x49r3dt7lhj.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "hch@infradead.org" <hch@infradead.org>
Cc: "Verma, Vishal L" <vishal.l.verma@intel.com>, "axboe@fb.com" <axboe@fb.com>, "jack@suse.cz" <jack@suse.cz>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "david@fromorbit.com" <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>

"hch@infradead.org" <hch@infradead.org> writes:

> On Sat, Apr 23, 2016 at 06:08:37PM +0000, Verma, Vishal L wrote:
>> direct_IO might fail with -EINVAL due to misalignment, or -ENOMEM due
>> to some allocation failing, and I thought we should return the original
>> -EIO in such cases so that the application doesn't lose the information
>> that the bad block is actually causing the error.
>
> EINVAL is a concern here.  Not due to the right error reported, but
> because it means your current scheme is fundamentally broken - we
> need to support I/O at any alignment for DAX I/O, and not fail due to
> alignbment concernes for a highly specific degraded case.
>
> I think this whole series need to go back to the drawing board as I
> don't think it can actually rely on using direct I/O as the EIO
> fallback.

The only callers of dax_do_io are direct_IO methods.

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
