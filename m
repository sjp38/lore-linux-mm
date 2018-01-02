Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 46A306B02AE
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 09:09:13 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c25so89974pfi.11
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 06:09:13 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id z14si6547937pgu.113.2018.01.02.06.09.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Jan 2018 06:09:11 -0800 (PST)
Date: Tue, 2 Jan 2018 06:09:06 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v20 3/7 RESEND] xbitmap: add more operations
Message-ID: <20180102140906.GC8222@bombadil.infradead.org>
References: <1513823406-43632-1-git-send-email-wei.w.wang@intel.com>
 <20171221210327.GB25009@bombadil.infradead.org>
 <5A3CC707.9070708@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A3CC707.9070708@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com, penguin-kernel@I-love.SAKURA.ne.jp

On Fri, Dec 22, 2017 at 04:49:11PM +0800, Wei Wang wrote:
> Thanks for the improvement. I also found a small bug in xb_zero. With the
> following changes, it has passed the current test cases and tested with the
> virtio-balloon usage without any issue.

Thanks; I applied the change.  Can you supply a test-case for testing
xb_zero please?

> > @@ -25,8 +26,11 @@ idr-test: idr-test.o $(CORE_OFILES)
> >   multiorder: multiorder.o $(CORE_OFILES)
> > +xbitmap: xbitmap.o $(CORE_OFILES)
> > +	$(CC) $(CFLAGS) $(LDFLAGS) $^ -o xbitmap
> > +
> 
> I think the "$(CC).." line should be removed, which will fix the build error
> when adding "xbitmap" to TARGET.

Not sure what build error you're talking about, but yes that CC line
should go.  Thanks, deleted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
