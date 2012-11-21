Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id A957D6B0081
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 03:39:40 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id lz20so8571518obb.14
        for <linux-mm@kvack.org>; Wed, 21 Nov 2012 00:39:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121120175647.GA23532@gmail.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
	<20121119162909.GL8218@suse.de>
	<20121119191339.GA11701@gmail.com>
	<20121119211804.GM8218@suse.de>
	<20121119223604.GA13470@gmail.com>
	<CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com>
	<20121120071704.GA14199@gmail.com>
	<20121120152933.GA17996@gmail.com>
	<20121120175647.GA23532@gmail.com>
Date: Wed, 21 Nov 2012 16:39:39 +0800
Message-ID: <CAGjg+kHKaQLcrnEftB+2mjeCjGUBiisSOpNCe+_9-4LDho9LpA@mail.gmail.com>
Subject: Re: numa/core regressions fixed - more testers wanted
From: Alex Shi <lkml.alex@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

>
> Those of you who would like to test all the latest patches are
> welcome to pick up latest bits at tip:master:
>
>    git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git master
>

I am wondering if it is a problem, but it still exists on HEAD: c418de93e39891
http://article.gmane.org/gmane.linux.kernel.mm/90131/match=compiled+with+name+pl+and+start+it+on+my

like when just start 4 pl tasks, often 3 were running on node 0, and 1
was running on node 1.
The old balance will average assign tasks to different node, different core.

Regards
Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
