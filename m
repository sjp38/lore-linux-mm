Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 76FAA6B0260
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 12:02:15 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id g186so8056556pfb.11
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 09:02:15 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id k7si3069825pgq.759.2018.01.18.09.02.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 18 Jan 2018 09:02:14 -0800 (PST)
Date: Thu, 18 Jan 2018 09:02:11 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v6 00/99] XArray version 6
Message-ID: <20180118170211.GB23800@bombadil.infradead.org>
References: <20180117202203.19756-1-willy@infradead.org>
 <20180118160749.GP13726@twin.jikos.cz>
 <20180118164843.GA23800@bombadil.infradead.org>
 <20180118165612.GS13726@twin.jikos.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180118165612.GS13726@twin.jikos.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dsterba@suse.cz, linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

On Thu, Jan 18, 2018 at 05:56:12PM +0100, David Sterba wrote:
> On Thu, Jan 18, 2018 at 08:48:43AM -0800, Matthew Wilcox wrote:
> > Thank you!  I shall attempt to debug.  Was this with a btrfs root
> > filesystem?  I'm most suspicious of those patches right now, since they've
> > received next to no testing.  I'm going to put together a smaller patchset
> > which just does the page cache conversion and nothing else in the hope
> > that we can get that merged this year.
> 
> No, the root is ext3 and there was no btrfs filesytem mounted at the
> time.

Found it; I was missing a prerequisite patch.  New (smaller) patch series
coming soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
