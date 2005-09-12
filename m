Date: Sun, 11 Sep 2005 23:16:36 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: VM balancing issues on 2.6.13: dentry cache not getting shrunk enough
Message-ID: <20050912031636.GB16758@thunk.org>
References: <20050911105709.GA16369@thunk.org> <20050911120045.GA4477@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050911120045.GA4477@in.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dipankar Sarma <dipankar@in.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Bharata B. Rao" <bharata@in.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sun, Sep 11, 2005 at 05:30:46PM +0530, Dipankar Sarma wrote:
> Do you have the /proc/sys/fs/dentry-state output when such lowmem
> shortage happens ?

Not yet, but the situation occurs on my laptop about 2 or 3 times
(when I'm not travelling and so it doesn't get rebooted).  So
reproducing it isn't utterly trivial, but it's does happen often
enough that it should be possible to get the necessary data.

> This is a problem that Bharata has been investigating at the moment.
> But he hasn't seen anything that can't be cured by a small memory
> pressure - IOW, dentries do get freed under memory pressure. So
> your case might be very useful. Bharata is maintaing an instrumentation
> patch to collect more information and an alternative dentry aging patch 
> (using rbtree). Perhaps you could try with those.

Send it to me, and I'd be happy to try either the instrumentation
patch or the dentry aging patch.

Thanks, regards,

							- Ted
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
