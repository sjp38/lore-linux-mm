Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E941C6B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 14:59:56 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r16so204289922pfg.4
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 11:59:56 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id uj2si26699203pab.206.2016.10.17.11.59.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 11:59:56 -0700 (PDT)
Date: Mon, 17 Oct 2016 12:59:55 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 0/20 v3] dax: Clear dirty bits after flushing caches
Message-ID: <20161017185955.GA13782@linux.intel.com>
References: <1474992504-20133-1-git-send-email-jack@suse.cz>
 <20160930091418.GC24352@infradead.org>
 <20161003075902.GG6457@quack2.suse.cz>
 <20161003080337.GA13688@infradead.org>
 <20161003081549.GH6457@quack2.suse.cz>
 <20161003093248.GA27720@infradead.org>
 <20161003111358.GQ6457@quack2.suse.cz>
 <20161013203434.GD26922@linux.intel.com>
 <20161017084732.GD3359@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161017084732.GD3359@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-nvdimm@ml01.01.org, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Oct 17, 2016 at 10:47:32AM +0200, Jan Kara wrote:

> This week I plan to rebase both series on top of rc1 + your THP patches so
> that we can move on with merging the stuff.

Yea...so how are we going to coordinate merging of these series for the v4.10
merge window?  My series mostly changes DAX, but it also changes XFS, ext2 and
ext4.  I think the plan right now is to have Dave Chinner take it through his
XFS tree.

Your first series is mostly mm changes with some DAX sprinkled in, and your
second series touches dax, mm and all 3 DAX filesystems.  

What is the best way to handle all this?  Have it go through one central tree
(-MM?), even though the changes touch code that exists outside of that trees
normal domain (like the FS code)?  Have my series go through the XFS tree and
yours through -MM, and give Linus a merge resolution patch?  Something else?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
