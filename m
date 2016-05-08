Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C52256B0005
	for <linux-mm@kvack.org>; Sun,  8 May 2016 05:01:17 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b203so320157449pfb.1
        for <linux-mm@kvack.org>; Sun, 08 May 2016 02:01:17 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id 145si29846251pfy.175.2016.05.08.02.01.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 May 2016 02:01:17 -0700 (PDT)
Date: Sun, 8 May 2016 02:01:15 -0700
From: "hch@infradead.org" <hch@infradead.org>
Subject: Re: [PATCH v4 5/7] fs: prioritize and separate direct_io from dax_io
Message-ID: <20160508090115.GE15458@infradead.org>
References: <1461878218-3844-1-git-send-email-vishal.l.verma@intel.com>
 <1461878218-3844-6-git-send-email-vishal.l.verma@intel.com>
 <5727753F.6090104@plexistor.com>
 <20160505142433.GA4557@infradead.org>
 <CAPcyv4gdmo5m=Arf5sp5izJfNaaAkaaMbOzud8KRcBEC8RRu1Q@mail.gmail.com>
 <20160505152230.GA3994@infradead.org>
 <1462484695.29294.7.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462484695.29294.7.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Verma, Vishal L" <vishal.l.verma@intel.com>
Cc: "Williams, Dan J" <dan.j.williams@intel.com>, "hch@infradead.org" <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>, "matthew@wil.cx" <matthew@wil.cx>

On Thu, May 05, 2016 at 09:45:07PM +0000, Verma, Vishal L wrote:
> I'm not sure I completely understand how this will work? Can you explain
> a bit? Would we have to export rw_bytes up to layers above the pmem
> driver? Where does get_user_pages come in?

A DAX filesystem can directly use the nvdimm layer the same way btt
doe,s what's the problem?

Re get_user_pages my idea was to simply use that to lock down the user
pages so that we can call rw_bytes on it.  How else would you do it?  Do
a kmalloc, copy_from_user and then another memcpy?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
