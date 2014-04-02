Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id A69A56B00F0
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 15:24:49 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id v10so616563pde.39
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 12:24:49 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id nm5si1789209pbc.466.2014.04.02.12.24.48
        for <linux-mm@kvack.org>;
        Wed, 02 Apr 2014 12:24:48 -0700 (PDT)
Date: Wed, 2 Apr 2014 15:24:46 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v7 03/22] axonram: Fix bug in direct_access
Message-ID: <20140402192446.GC27299@linux.intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <e3ede380dd37d3cae604ee20198e568c9eb4fa00.1395591795.git.matthew.r.wilcox@intel.com>
 <20140329162216.GC1211@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140329162216.GC1211@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Mar 29, 2014 at 05:22:16PM +0100, Jan Kara wrote:
> On Sun 23-03-14 15:08:29, Matthew Wilcox wrote:
> > The 'pfn' returned by axonram was completely bogus, and has been since
> > 2008.
>   Maybe time to drop the driver instead? When noone noticed for 6 years, it
> seems pretty much dead... Or is there some possibility the driver can get
> reused for new HW?

It may be in use, just not with the -o xip option to ext2 ... I can't
find out which of the various vendors on the internet that are called
'Axon' that this device was originally supposed to support.  I suspect
it's dead, since it's DDR-2, but *shrug*, it costs little to fix it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
