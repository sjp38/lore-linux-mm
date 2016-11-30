Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id CB0446B0267
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 11:04:47 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id g12so43728891lfe.5
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 08:04:47 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b188si7759458wme.154.2016.11.30.08.04.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 08:04:44 -0800 (PST)
Date: Wed, 30 Nov 2016 10:59:44 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/6] mm: Invalidate DAX radix tree entries only if
 appropriate
Message-ID: <20161130155944.GA12630@cmpxchg.org>
References: <1479980796-26161-1-git-send-email-jack@suse.cz>
 <1479980796-26161-3-git-send-email-jack@suse.cz>
 <20161129193403.GA12396@cmpxchg.org>
 <20161130080841.GD16667@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161130080841.GD16667@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Wed, Nov 30, 2016 at 09:08:41AM +0100, Jan Kara wrote:
> > The naming situation with truncate, invalidate, invalidate2 worries me
> > a bit. They aren't great names to begin with, but now DAX uses yet
> > another terminology for what state prevents a page from being dropped.
> > Can we switch to truncate, invalidate, and invalidate_sync throughout
> > truncate.c and then have DAX follow that naming too? Or maybe you can
> > think of better names. But neither invalidate2 and invalidate_clean
> > don't seem to capture it quite right ;)
> 
> Yeah, the naming is confusing. I like the invalidate_sync proposal however
> renaming invalidate_inode_pages2() to invalidate_inode_pages_sync() is a
> larger undertaking - grep shows 51 places need to be changed. So I don't
> want to do it in this patch set. I can call the function
> dax_invalidate_mapping_entry_sync() if it makes you happier and do the rest
> later... OK?

Yep, that sounds reasonable on both counts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
