Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EBD246B0069
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 21:49:23 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j128so89092282pfg.4
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 18:49:23 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id q187si30060945pfb.256.2016.11.24.18.49.21
        for <linux-mm@kvack.org>;
        Thu, 24 Nov 2016 18:49:22 -0800 (PST)
Date: Fri, 25 Nov 2016 13:49:18 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/6] dax: add tracepoint infrastructure, PMD tracing
Message-ID: <20161125024918.GX31101@dastard>
References: <1479926662-21718-1-git-send-email-ross.zwisler@linux.intel.com>
 <1479926662-21718-4-git-send-email-ross.zwisler@linux.intel.com>
 <20161124173220.GR1555@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161124173220.GR1555@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Thu, Nov 24, 2016 at 05:32:20PM +0000, Al Viro wrote:
> On Wed, Nov 23, 2016 at 11:44:19AM -0700, Ross Zwisler wrote:
> > Tracepoints are the standard way to capture debugging and tracing
> > information in many parts of the kernel, including the XFS and ext4
> > filesystems.  Create a tracepoint header for FS DAX and add the first DAX
> > tracepoints to the PMD fault handler.  This allows the tracing for DAX to
> > be done in the same way as the filesystem tracing so that developers can
> > look at them together and get a coherent idea of what the system is doing.
> 
> 	It also has one hell of potential for becoming a massive nuisance.
> Keep in mind that if any userland code becomes dependent on those - that's it,
> they have become parts of stable userland ABI and are to be maintained
> indefinitely.  Don't expect "tracepoints are special case" to prevent that.

I call bullshit just like I always do when someone spouts this
"tracepoints are stable ABI" garbage.

If we want to provide stable tracepoints, then we need to /create a
stable tracepoint API/ and convert all the tracepoints that /need
to be stable/ to use it. Then developers only need to be careful
about modifying code around the /explicitly stable/ tracepoints and
we avoid retrospectively locking the kernel implementation into a
KABI so tight we can't do anything anymore....

Quite frankly, anyone that wants to stop us from
adding/removing/changing tracepoints or the code that they are
reporting information about "because ABI" can go take a long walk
off a short cliff.  Diagnostic tracepoints are not part of the
stable ABI. End of story.

> 	So treat anything you add in that manner as potential stable ABI
> you might have to keep around forever.  It's *not* a glorified debugging
> printk.

trace_printk() is the glorified debugging printk for tracing, not
trace events.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
