Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 607926B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 02:20:49 -0400 (EDT)
Date: Mon, 15 Jun 2009 08:29:34 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 21/22] HWPOISON: send uevent to report memory corruption
Message-ID: <20090615062934.GB31969@one.firstfloor.org>
References: <20090615024520.786814520@intel.com> <20090615031255.278184860@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090615031255.278184860@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 15, 2009 at 10:45:41AM +0800, Wu Fengguang wrote:
> This allows the user space to do some flexible policies.
> For example, it may either do emergency sync/shutdown
> or to schedule reboot at some convenient time, depending
> on the severeness of the corruption.
> 

I don't think it's a good idea to export that much detailed information.
That would become a stable ABI, but might not be possible to keep
all these details stable. e.g. map count or reference count are
internal implementation details that shouldn't be exposed.
And what is an user space application to do with the inode? Run
find -inum? 

Also we already report the event using low level logging mechanism.
in a relatively stable form.

It's also unclear to me what an application would do with that much
detail.

I would suggest to drop this part and the earlier flags move.

Please only bug fixes are this stage.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
