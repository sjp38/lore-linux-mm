Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E5BEF6B027C
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 11:06:40 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s24-v6so2947853plp.12
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 08:06:40 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y34-v6si3222520plb.46.2018.10.02.08.06.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Oct 2018 08:06:35 -0700 (PDT)
Date: Tue, 2 Oct 2018 08:06:34 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Message-ID: <20181002150634.GA22209@infradead.org>
References: <20181002100531.GC4135@quack2.suse.cz>
 <20181002121039.GA3274@linux-x5ow.site>
 <20181002142010.GB4963@linux-x5ow.site>
 <20181002144547.GA26735@infradead.org>
 <20181002150123.GD4963@linux-x5ow.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181002150123.GD4963@linux-x5ow.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Thumshirn <jthumshirn@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, mhocko@suse.cz, Dan Williams <dan.j.williams@intel.com>

On Tue, Oct 02, 2018 at 05:01:24PM +0200, Johannes Thumshirn wrote:
> On Tue, Oct 02, 2018 at 07:45:47AM -0700, Christoph Hellwig wrote:
> > How does an application "make use of DAX"?  What actual user visible
> > semantics are associated with a file that has this flag set?
> 
> There may not be any user visible semantics of DAX, but there are
> promises we gave to application developers praising DAX as _the_
> method to map data on persistent memory and get around "the penalty of
> the page cache" (however big this is).

Who is "we"?  As someone involved with DAX code I think it is a steaming
pile of *****, and we are still looking for cases where it actually
works without bugs.  That's why the experimental tag still is on it
for example.

> As I said in another mail to this thread, applications have started to
> poke in procfs to see whether they can use DAX or not.

And what are they actually doing with that?

> 
> Party A has promised party B

We have never promised anyone anything.

> So technically e1fb4a086495 is a user visible regression and in the
> past we have reverted patches introducing these, even if the patch is
> generally correct and poking in /proc/self/smaps is a bad idea.

What actually stops working here and why?  If some stupid app doesn't work
without mixedmap and we want to apply the don't break userspace mantra
hard we should just always expose it.

> I just wanted to give them a documented way to check for this
> promise. Being neutral if this promise is right or wrong, good or bad,
> or whatever. That's not my call, but I prefer not having angry users,
> yelling at me because of broken applications.

There is no promise, sorry.
