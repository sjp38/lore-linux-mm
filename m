Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 664076B13F0
	for <linux-mm@kvack.org>; Fri,  3 Feb 2012 09:08:50 -0500 (EST)
Date: Fri, 3 Feb 2012 09:08:34 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/2] mm: make do_writepages() use plugging
Message-ID: <20120203140834.GA15495@infradead.org>
References: <1328275626-5322-1-git-send-email-amit.sahrawat83@gmail.com>
 <20120203133823.GB17571@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120203133823.GB17571@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Amit Sahrawat <amit.sahrawat83@gmail.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>, Amit Sahrawat <a.sahrawat@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Feb 03, 2012 at 09:38:23PM +0800, Wu Fengguang wrote:
> On Fri, Feb 03, 2012 at 06:57:06PM +0530, Amit Sahrawat wrote:
> > This will cover all the invocations for writepages to be called with
> > plugging support.
>  
> Thanks.  I'll test it on the major filesystems. But would you
> name a few filesystems that are expected to benefit from it?
> It's not obvious because some FS ->writepages eventually calls
> generic_writepages() which already does plugging.

Ant that's exactly where it should stay instead of beeing sprinkled all
over the VM code.

NAK to the patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
