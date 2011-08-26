Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C62D96B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 08:21:01 -0400 (EDT)
Date: Fri, 26 Aug 2011 20:20:57 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/5] writeback: dirty position control
Message-ID: <20110826122057.GA32711@localhost>
References: <1314093660.8002.24.camel@twins>
 <20110823141504.GA15949@localhost>
 <20110823174757.GC15820@redhat.com>
 <20110824001257.GA6349@localhost>
 <1314202378.6925.48.camel@twins>
 <20110826001846.GA6118@localhost>
 <1314349469.26922.24.camel@twins>
 <20110826100428.GA7996@localhost>
 <20110826112637.GA17785@localhost>
 <1314360710.11049.1.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1314360710.11049.1.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Vivek Goyal <vgoyal@redhat.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Aug 26, 2011 at 08:11:50PM +0800, Peter Zijlstra wrote:
> On Fri, 2011-08-26 at 19:26 +0800, Wu Fengguang wrote:
> > Now I get 3 figures. Test case is: run 1 dd write task for 300s, with
> > a "disturber" dd read task during roughly 120-130s. 
> 
> Ah, but ideally the disturber task should run in bursts of 100ms
> (<feedback period), otherwise your N is indeed mostly constant.

Ah yeah, the disturber task should be a dd writer! Then we get

- 120s: N=1 => N=2
- 130s: N=2 => N=1

I'll try it right away.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
