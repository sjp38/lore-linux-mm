Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id EE27A280254
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 11:33:45 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id hb5so39982663wjc.2
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 08:33:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id op6si863157wjc.85.2016.12.01.08.33.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Dec 2016 08:33:44 -0800 (PST)
Date: Thu, 1 Dec 2016 17:33:40 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 2/6] dax: remove leading space from labels
Message-ID: <20161201163340.GA18212@quack2.suse.cz>
References: <1480549533-29038-1-git-send-email-ross.zwisler@linux.intel.com>
 <1480549533-29038-3-git-send-email-ross.zwisler@linux.intel.com>
 <20161201081144.GC12804@quack2.suse.cz>
 <20161201152619.GA5160@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161201152619.GA5160@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Thu 01-12-16 08:26:19, Ross Zwisler wrote:
> On Thu, Dec 01, 2016 at 09:11:44AM +0100, Jan Kara wrote:
> > On Wed 30-11-16 16:45:29, Ross Zwisler wrote:
> > > No functional change.
> > > 
> > > As of this commit:
> > > 
> > > commit 218dd85887da (".gitattributes: set git diff driver for C source code
> > > files")
> > > 
> > > git-diff and git-format-patch both generate diffs whose hunks are correctly
> > > prefixed by function names instead of labels, even if those labels aren't
> > > indented with spaces.
> > > 
> > > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > 
> > Didn't we agree do leave this for a bit later?
> 
> Sorry, I thought you just asked to not have to edit your "Page invalidation
> fixes" series because of this change.  This series is based on a tree that
> already includes your page invalidation work, so it shouldn't cause you any
> thrash.

Ah, I see, I didn't notice. Then it's fine :). Thanks.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
