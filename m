Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D64CC6B0011
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 10:49:50 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: James Bottomley <James.Bottomley@suse.de>
In-Reply-To: <1303993705-sup-5213@think>
References: <1303920553.2583.7.camel@mulgrave.site>
	 <1303921583-sup-4021@think> <1303923000.2583.8.camel@mulgrave.site>
	 <1303923177-sup-2603@think> <1303924902.2583.13.camel@mulgrave.site>
	 <1303925374-sup-7968@think> <1303926637.2583.17.camel@mulgrave.site>
	 <1303934716.2583.22.camel@mulgrave.site> <1303990590.2081.9.camel@lenovo>
	 <1303993705-sup-5213@think>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Apr 2011 09:49:43 -0500
Message-ID: <1304002183.2598.1.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: Colin Ian King <colin.king.lkml@gmail.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Thu, 2011-04-28 at 08:29 -0400, Chris Mason wrote:
> Excerpts from Colin Ian King's message of 2011-04-28 07:36:30 -0400:
> > One more data point to add, I've been looking at an identical issue when
> > copying large amounts of data.  I bisected this - and the lockups occur
> > with commit 
> > 3e7d344970673c5334cf7b5bb27c8c0942b06126 - before that I don't see the
> > issue. With this commit, my file copy test locks up after ~8-10
> > iterations, before this commit I can copy > 100 times and don't see the
> > lockup.
> 
> Well, that's really interesting.  I tried with compaction on here and
> couldn't trigger it, but this (very very lightly) tested patch might
> help.
> 
> It moves the writeout throttle before the goto restart, and also makes
> sure we do at least one cond_resched before we loop.

It seems to take longer, but with a PREEMPT kernel, kswapd eventually
shoots up to 99% during the tar.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
