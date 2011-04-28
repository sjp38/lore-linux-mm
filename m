Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2651B6B0024
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 10:07:31 -0400 (EDT)
Date: Thu, 28 Apr 2011 15:07:25 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback related.
Message-ID: <20110428140725.GX4658@suse.de>
References: <1303920553.2583.7.camel@mulgrave.site>
 <1303921583-sup-4021@think>
 <1303923000.2583.8.camel@mulgrave.site>
 <1303923177-sup-2603@think>
 <1303924902.2583.13.camel@mulgrave.site>
 <1303925374-sup-7968@think>
 <1303926637.2583.17.camel@mulgrave.site>
 <1303934716.2583.22.camel@mulgrave.site>
 <1303990590.2081.9.camel@lenovo>
 <20110428135228.GC1696@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110428135228.GC1696@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: colin.king@canonical.com, James Bottomley <James.Bottomley@suse.de>, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, mgorman@novell.com

On Thu, Apr 28, 2011 at 03:52:28PM +0200, Jan Kara wrote:
> On Thu 28-04-11 12:36:30, Colin Ian King wrote:
> > One more data point to add, I've been looking at an identical issue when
> > copying large amounts of data.  I bisected this - and the lockups occur
> > with commit 
> > 3e7d344970673c5334cf7b5bb27c8c0942b06126 - before that I don't see the
> > issue. With this commit, my file copy test locks up after ~8-10
> > iterations, before this commit I can copy > 100 times and don't see the
> > lockup.
>   Adding Mel to CC, I guess he'll be interested. Mel, it seems this commit
> of yours causes kswapd on non-preempt kernels spin for a *long* time...
> 

I'm still thinking about the traces which do not point the finger
directly at compaction per-se but it's possible that the change means
kswapd is not reclaiming like it should be.

To test this theory, does applying
[d527caf2: mm: compaction: prevent kswapd compacting memory to reduce
CPU usage] help?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
