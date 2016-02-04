Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id C4EEE4403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 10:51:59 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id o185so48788540pfb.1
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 07:51:59 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id s14si17462099pfa.120.2016.02.04.07.51.58
        for <linux-mm@kvack.org>;
        Thu, 04 Feb 2016 07:51:59 -0800 (PST)
Date: Thu, 4 Feb 2016 08:50:39 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH] dax: dirty inode only if required
Message-ID: <20160204155039.GA17818@linux.intel.com>
References: <87k2mkr2ud.fsf@openvz.org>
 <20160204143344.GA6895@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160204143344.GA6895@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dmitry Monakhov <dmonakhov@openvz.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, X86 ML <x86@kernel.org>, XFS Developers <xfs@oss.sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Thu, Feb 04, 2016 at 03:33:44PM +0100, Jan Kara wrote:
> On Thu 04-02-16 17:02:02, Dmitry Monakhov wrote:
> > 
> > Signed-off-by: Dmitry Monakhov <dmonakhov@openvz.org>
> 
> Makes sense. You can add:
> 
> Reviewed-by: Jan Kara <jack@suse.cz>

Looks good to me as well.

Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>

> 								Honza
> > ---
> >  fs/dax.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/dax.c b/fs/dax.c
> > index e0e9358..fc2e314 100644
> > --- a/fs/dax.c
> > +++ b/fs/dax.c
> > @@ -358,7 +358,8 @@ static int dax_radix_entry(struct address_space *mapping, pgoff_t index,
> >  	void *entry;
> >  
> >  	WARN_ON_ONCE(pmd_entry && !dirty);
> > -	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
> > +	if (dirty)
> > +		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
> >  
> >  	spin_lock_irq(&mapping->tree_lock);
> >  
> > -- 
> > 1.8.3.1
> > 
> -- 
> Jan Kara <jack@suse.com>
> SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
