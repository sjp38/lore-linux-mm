Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 67BA46B00B9
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 09:45:14 -0400 (EDT)
Date: Mon, 15 Mar 2010 08:45:05 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: PROBLEM: <Kernel panic - not syncing: Cannot create slab
 posix_timer_cache>
In-Reply-To: <62cd4c2f1003130715r621eb81vdc327b99b7402fc5@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1003150843030.5723@router.home>
References: <62cd4c2f1003130715r621eb81vdc327b99b7402fc5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Yiming Zhao <yimingdream@gmail.com>
Cc: penberg@cs.helsinki.fi, mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 13 Mar 2010, Yiming Zhao wrote:

> *[1.]  One line summary of the problem:*
> Kernel panic - not syncing: Cannot create slab posix_timers_cache

Could you provide all the boot messages up to the failure?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
