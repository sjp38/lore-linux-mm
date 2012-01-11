Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 00E8B6B006E
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 13:51:38 -0500 (EST)
Date: Wed, 11 Jan 2012 12:51:34 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Several bugs in latest kernel
In-Reply-To: <4F0DCFFC.5040805@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.00.1201111249510.31239@router.home>
References: <4F0DCFFC.5040805@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: mgorman@suse.de, Al Viro <viro@ZenIV.linux.org.uk>, Tejun Heo <tj@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "mingo@elte.hu" <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Wed, 11 Jan 2012, Srivatsa S. Bhat wrote:

> [ 7314.427769] kernel BUG at mm/slab.c:3111!

A typical case of memory corruption. Enable object debugging in the slab
allocator to figure out what. CONFIG_SLUB=y CONFIG_SLUB_DEBUG_ON=y will
get you to a config where you would likely get detailed reports on what is
corrupted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
