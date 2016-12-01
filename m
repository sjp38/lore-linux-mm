Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C331128025A
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 10:26:21 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id g186so101805591pgc.2
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 07:26:21 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id l81si574689pfi.32.2016.12.01.07.26.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 07:26:21 -0800 (PST)
Date: Thu, 1 Dec 2016 08:26:19 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 2/6] dax: remove leading space from labels
Message-ID: <20161201152619.GA5160@linux.intel.com>
References: <1480549533-29038-1-git-send-email-ross.zwisler@linux.intel.com>
 <1480549533-29038-3-git-send-email-ross.zwisler@linux.intel.com>
 <20161201081144.GC12804@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161201081144.GC12804@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Thu, Dec 01, 2016 at 09:11:44AM +0100, Jan Kara wrote:
> On Wed 30-11-16 16:45:29, Ross Zwisler wrote:
> > No functional change.
> > 
> > As of this commit:
> > 
> > commit 218dd85887da (".gitattributes: set git diff driver for C source code
> > files")
> > 
> > git-diff and git-format-patch both generate diffs whose hunks are correctly
> > prefixed by function names instead of labels, even if those labels aren't
> > indented with spaces.
> > 
> > Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> 
> Didn't we agree do leave this for a bit later?

Sorry, I thought you just asked to not have to edit your "Page invalidation
fixes" series because of this change.  This series is based on a tree that
already includes your page invalidation work, so it shouldn't cause you any
thrash.

I'll pull it out of the next version of this series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
