Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C2FC16B0012
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 12:50:03 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <1303921583-sup-4021@think>
References: <1303920553.2583.7.camel@mulgrave.site>
	 <1303921583-sup-4021@think>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 27 Apr 2011 11:50:00 -0500
Message-ID: <1303923000.2583.8.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wed, 2011-04-27 at 12:33 -0400, Chris Mason wrote:
> Probably easier to debug with a sysrq-l and sysrq-w. 

Yes, just enabling them for the repro ... I didn't echo 1
> /proc/sys/kernel/sysrq first time around

>  If you get stuck
> on the filesystem, it is probably waiting on ram, which it probably
> can't get because kswapd is spinning.  Eventually everyone backs up
> waiting for the transaction that never ends.  If we're really lucky it
> is just GFP_KERNEL where it should NOFS.
> 
> Since you're often stuck in different spots inside shrink_slab, we're
> probably not stuck on a lock.  But, trying with lock debugging, lockdep
> enabled and preempt on is a good idea to rule out locking mistakes.
> 
> Does the fedora debug kernel enable preempt?

No ... I've taken the Fedora 15 kernel config directly from their
install CD for this (with a bit of munging to get it to work on -rc4)

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
