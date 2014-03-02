Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id 908296B0035
	for <linux-mm@kvack.org>; Sun,  2 Mar 2014 03:22:04 -0500 (EST)
Received: by mail-ee0-f52.google.com with SMTP id c41so3300146eek.11
        for <linux-mm@kvack.org>; Sun, 02 Mar 2014 00:22:03 -0800 (PST)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id 46si13429232eem.130.2014.03.02.00.22.01
        for <linux-mm@kvack.org>;
        Sun, 02 Mar 2014 00:22:01 -0800 (PST)
Date: Sun, 2 Mar 2014 09:22:00 +0100
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v6 00/22] Support ext4 on NV-DIMMs
Message-ID: <20140302082159.GA27716@amd.pavel.ucw.cz>
References: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1393337918-28265-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, willy@linux.intel.com

On Tue 2014-02-25 09:18:16, Matthew Wilcox wrote:
> One of the primary uses for NV-DIMMs is to expose them as a block device
> and use a filesystem to store files on the NV-DIMM.  While that works,
> it currently wastes memory and CPU time buffering the files in the page
> cache.  We have support in ext2 for bypassing the page cache, but it
> has some races which are unfixable in the current design.  This series
> of patches rewrite the underlying support, and add support for direct
> access to ext4.
> 
> This iteration of the patchset renames the "XIP" support to "DAX".
> This fixes the confusion between kernel XIP and filesystem XIP.  It's not
> really about executing in-place; it's about direct access to memory-like
> storage, bypassing the page cache.  DAX is TLA-compliant, retains the
> exciting X, is pronouncable ("Dacks") and is not used elsewhere in
> the kernel.  The only major use of DAX outside the kernel is the German
> stock exchange, and I think that's pretty unlikely to cause
> confusion.

It is TLA compliant, but not widely understood, and probably not
googleable. Could we perhaps use some longer name for a while?

>  create mode 100644 Documentation/filesystems/dax.txt

Its not like filename can't be longer than 3.3, you see?

									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
