Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4D7336B0005
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:30:45 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id z11so2688720plo.21
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:30:45 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y96-v6si106963plh.796.2018.02.16.10.30.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 16 Feb 2018 10:30:44 -0800 (PST)
Date: Fri, 16 Feb 2018 10:30:32 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v21 1/5] xbitmap: Introduce xbitmap
Message-ID: <20180216183032.GA7439@bombadil.infradead.org>
References: <1515496262-7533-1-git-send-email-wei.w.wang@intel.com>
 <1515496262-7533-2-git-send-email-wei.w.wang@intel.com>
 <CAHp75Ve-1-TOVJUZ4anhwkkeq-RhpSg3EmN3N0r09rj6sFrQZQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHp75Ve-1-TOVJUZ4anhwkkeq-RhpSg3EmN3N0r09rj6sFrQZQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Wei Wang <wei.w.wang@intel.com>, virtio-dev@lists.oasis-open.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm <linux-mm@kvack.org>, "Michael S. Tsirkin" <mst@redhat.com>, mhocko@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, david@redhat.com, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, Paolo Bonzini <pbonzini@redhat.com>, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

On Fri, Feb 16, 2018 at 07:44:50PM +0200, Andy Shevchenko wrote:
> On Tue, Jan 9, 2018 at 1:10 PM, Wei Wang <wei.w.wang@intel.com> wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> >
> > The eXtensible Bitmap is a sparse bitmap representation which is
> > efficient for set bits which tend to cluster. It supports up to
> > 'unsigned long' worth of bits.
> 
> >  lib/xbitmap.c                            | 444 +++++++++++++++++++++++++++++++
> 
> Please, split tests to a separate module.

Hah, I just did this two days ago!  I didn't publish it yet, but I also made
it compile both in userspace and as a kernel module.  

It's the top two commits here:

http://git.infradead.org/users/willy/linux-dax.git/shortlog/refs/heads/xarray-2018-02-12

Note this is a complete rewrite compared to the version presented here; it
sits on top of the XArray and no longer has a preload interface.  It has a
superset of the IDA functionality.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
