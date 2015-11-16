Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2A55A6B0038
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 18:57:27 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so193517017pab.0
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 15:57:26 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ff7si53303999pac.213.2015.11.16.15.57.26
        for <linux-mm@kvack.org>;
        Mon, 16 Nov 2015 15:57:26 -0800 (PST)
Date: Mon, 16 Nov 2015 16:57:24 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 03/11] pmem: enable REQ_FUA/REQ_FLUSH handling
Message-ID: <20151116235724.GA10256@linux.intel.com>
References: <1447459610-14259-1-git-send-email-ross.zwisler@linux.intel.com>
 <1447459610-14259-4-git-send-email-ross.zwisler@linux.intel.com>
 <CAPcyv4j4arHE+iAALn1WPDzSb_QSCDy8udtXU1FV=kYSZDfv8A@mail.gmail.com>
 <22E0F870-C1FB-431E-BF6C-B395A09A2B0D@dilger.ca>
 <CAPcyv4jwx3VzyRugcpH7KCOKM64kJ4Bq4wgY=iNJMvLTHrBv-Q@mail.gmail.com>
 <20151116133714.GB3443@quack.suse.cz>
 <20151116140526.GA6733@quack.suse.cz>
 <CAPcyv4jZjnkz2YYtGWmkA23KAUMT092kjRtFkJ3QrzgPfTucfA@mail.gmail.com>
 <20151116194846.GB32203@linux.intel.com>
 <CAPcyv4hU0HMBFy=MveUaECK0fVfgUFBjUUPTWA8HOP6MG5XEfQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hU0HMBFy=MveUaECK0fVfgUFBjUUPTWA8HOP6MG5XEfQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>, Andreas Dilger <adilger@dilger.ca>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, X86 ML <x86@kernel.org>, XFS Developers <xfs@oss.sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Mon, Nov 16, 2015 at 12:34:55PM -0800, Dan Williams wrote:
> On Mon, Nov 16, 2015 at 11:48 AM, Ross Zwisler
> <ross.zwisler@linux.intel.com> wrote:
> > On Mon, Nov 16, 2015 at 09:28:59AM -0800, Dan Williams wrote:
> >> On Mon, Nov 16, 2015 at 6:05 AM, Jan Kara <jack@suse.cz> wrote:
> >> > On Mon 16-11-15 14:37:14, Jan Kara wrote:
> [..]
> > Is there any reason why this wouldn't work or wouldn't be a good idea?
> 
> We don't have numbers to support the claim that pcommit is so
> expensive as to need be deferred, especially if the upper layers are
> already taking the hit on doing the flushes.
> 
> REQ_FLUSH, means flush your volatile write cache.  Currently all I/O
> through the driver never hits a volatile cache so there's no need to
> tell the block layer that we have a volatile write cache, especially
> when you have the core mm taking responsibility for doing cache
> maintenance for dax-mmap ranges.
> 
> We also don't have numbers on if/when wbinvd is a more performant solution.
> 
> tl;dr Now that we have a baseline implementation can we please use
> data to make future arch decisions?

Sure, fair enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
