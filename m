Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 94A0E6B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 09:24:50 -0400 (EDT)
Date: Fri, 26 Aug 2011 21:24:45 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110826132445.GA8219@localhost>
References: <20110824001257.GA6349@localhost>
 <1314202378.6925.48.camel@twins>
 <20110826001846.GA6118@localhost>
 <1314349469.26922.24.camel@twins>
 <20110826100428.GA7996@localhost>
 <20110826112637.GA17785@localhost>
 <1314360710.11049.1.camel@twins>
 <20110826122057.GA32711@localhost>
 <20110826131341.GA7114@localhost>
 <1314364701.12445.0.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1314364701.12445.0.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Vivek Goyal <vgoyal@redhat.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Aug 26, 2011 at 09:18:21PM +0800, Peter Zijlstra wrote:
> On Fri, 2011-08-26 at 21:13 +0800, Wu Fengguang wrote:
> > We got similar result as in the read disturber case, even though one
> > disturbs N and the other impacts writeout bandwith.  The original
> > patchset is consistently performing much better :) 
> 
> It does indeed, and I figure on these timescales it makes sense to
> assumes N is a constant. Fair enough, thanks!

Thank you! Glad that we finally reaches some consensus :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
