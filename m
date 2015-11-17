Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 590686B0257
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 12:52:46 -0500 (EST)
Received: by padhx2 with SMTP id hx2so15387561pad.1
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 09:52:46 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id i9si2059911pbq.207.2015.11.17.09.52.45
        for <linux-mm@kvack.org>;
        Tue, 17 Nov 2015 09:52:45 -0800 (PST)
Date: Tue, 17 Nov 2015 10:52:43 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 02/11] mm: add pmd_mkclean()
Message-ID: <20151117175243.GA28024@linux.intel.com>
References: <1447459610-14259-1-git-send-email-ross.zwisler@linux.intel.com>
 <1447459610-14259-3-git-send-email-ross.zwisler@linux.intel.com>
 <56468838.6010506@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56468838.6010506@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

On Fri, Nov 13, 2015 at 05:02:48PM -0800, Dave Hansen wrote:
> On 11/13/2015 04:06 PM, Ross Zwisler wrote:
> > +static inline pmd_t pmd_mkclean(pmd_t pmd)
> > +{
> > +	return pmd_clear_flags(pmd, _PAGE_DIRTY | _PAGE_SOFT_DIRTY);
> > +}
> 
> pte_mkclean() doesn't clear _PAGE_SOFT_DIRTY.  What the thought behind
> doing it here?

I just wrote it to undo the work done by pmd_mkdirty() - you're right, it
should mirror the work done by pte_mkclean() and not clear _PAGE_SOFT_DIRTY.
I'll fix this for v3, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
