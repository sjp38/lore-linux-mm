Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 46B876B0069
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 23:14:37 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id g23so19096835wme.4
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 20:14:37 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id eb8si40292156wjd.281.2016.11.24.20.14.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Nov 2016 20:14:36 -0800 (PST)
Date: Fri, 25 Nov 2016 04:14:19 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 3/6] dax: add tracepoint infrastructure, PMD tracing
Message-ID: <20161125041419.GT1555@ZenIV.linux.org.uk>
References: <1479926662-21718-1-git-send-email-ross.zwisler@linux.intel.com>
 <1479926662-21718-4-git-send-email-ross.zwisler@linux.intel.com>
 <20161124173220.GR1555@ZenIV.linux.org.uk>
 <20161125024918.GX31101@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161125024918.GX31101@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, Linus Torvalds <torvalds@linux-foundation.org>

[Linus Cc'd]

On Fri, Nov 25, 2016 at 01:49:18PM +1100, Dave Chinner wrote:
> > they have become parts of stable userland ABI and are to be maintained
> > indefinitely.  Don't expect "tracepoints are special case" to prevent that.
> 
> I call bullshit just like I always do when someone spouts this
> "tracepoints are stable ABI" garbage.

> Quite frankly, anyone that wants to stop us from
> adding/removing/changing tracepoints or the code that they are
> reporting information about "because ABI" can go take a long walk
> off a short cliff.  Diagnostic tracepoints are not part of the
> stable ABI. End of story.

Tell that to Linus.  You had been in the room, IIRC, when that had been
brought up this year in Santa Fe.  "End of story" is not going to be
yours (or mine, for that matter) to declare - Linus is the only one who
can do that.  If he says "if userland code relies upon it, so that
userland code needs to be fixed" - I'm very happy (and everyone involved
can count upon quite a few free drinks from me at the next summit).  If
it's "that userland code really shouldn't have relied upon it, and it's
real unfortunate that it does, but we still get to keep it working" -
too bad, "because ABI" is the reality and we will be the ones to take
that long walk.

What I heard from Linus sounded a lot closer to the second variant.
_IF_ I have misinterpreted that, I'd love to hear that.  Linus?

PS: I'm dead serious about large amounts of booze of choice at LSFS 2017.
Bribery or shared celebration - call it whatever you like; I really,
really want to have tracepoints free from ABIfication concerns.  They
certainly are useful for debugging purposes - no arguments here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
