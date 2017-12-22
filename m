Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A83046B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 08:36:41 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id y62so20262861pfd.3
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 05:36:41 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id x4si16296541plw.539.2017.12.22.05.36.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Dec 2017 05:36:39 -0800 (PST)
Date: Fri, 22 Dec 2017 05:36:34 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/2] Introduce __cond_lock_err
Message-ID: <20171222133634.GE6401@bombadil.infradead.org>
References: <20171219165823.24243-1-willy@infradead.org>
 <20171219165823.24243-2-willy@infradead.org>
 <20171221214810.GC9087@linux.intel.com>
 <20171222011000.GB23624@bombadil.infradead.org>
 <20171222042120.GA18036@localhost>
 <20171222123112.GA6401@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171222123112.GA6401@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>

On Fri, Dec 22, 2017 at 04:31:12AM -0800, Matthew Wilcox wrote:
> On Thu, Dec 21, 2017 at 08:21:20PM -0800, Josh Triplett wrote:
> > On Thu, Dec 21, 2017 at 05:10:00PM -0800, Matthew Wilcox wrote:
> > > Yes, but this define is only #if __CHECKER__, so it doesn't matter what we
> > > return as this code will never run.
> > 
> > It does matter slightly, as Sparse does some (very limited) value-based
> > analyses. Let's future-proof it.
> > 
> > > That said, if sparse supports the GNU syntax of ?: then I have no
> > > objection to doing that.
> > 
> > Sparse does support that syntax.
> 
> Great, I'll fix that and resubmit.

Except the context imbalance warning comes back if I do.  This is sparse
0.5.1 (Debian's 0.5.1-2 package).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
