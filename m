Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A11276B004F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 07:12:46 -0400 (EDT)
Date: Wed, 5 Aug 2009 07:12:31 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] [16/19] HWPOISON: Enable .remove_error_page for
	migration aware file systems
Message-ID: <20090805111231.GA19532@infradead.org>
References: <200908051136.682859934@firstfloor.org> <20090805093643.E0C00B15D8@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090805093643.E0C00B15D8@basil.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: tytso@mit.edu, hch@infradead.org, mfasheh@suse.com, aia21@cantab.net, hugh.dickins@tiscali.co.uk, swhiteho@redhat.com, akpm@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, hidehiro.kawai.ez@hitachi.com
List-ID: <linux-mm.kvack.org>

On Wed, Aug 05, 2009 at 11:36:43AM +0200, Andi Kleen wrote:
> 
> Enable removing of corrupted pages through truncation
> for a bunch of file systems: ext*, xfs, gfs2, ocfs2, ntfs
> These should cover most server needs.
> 
> I chose the set of migration aware file systems for this
> for now, assuming they have been especially audited.
> But in general it should be safe for all file systems
> on the data area that support read/write and truncate.
> 
> Caveat: the hardware error handler does not take i_mutex
> for now before calling the truncate function. Is that ok?

It will probably need locking, e.g. the iolock in XFS.  I'll
need to take a look at the actual implementation of
generic_error_remove_page to make sense of this.

Is there any way for us to test this functionality without introducing
real hardware problems?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
