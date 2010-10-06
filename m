Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A05176B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 17:53:25 -0400 (EDT)
Date: Wed, 6 Oct 2010 23:55:50 +0200
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 2/2] HWPOISON: Attempt directed shrinking of slabs
Message-ID: <20101006215550.GC10386@gargoyle.ger.corp.intel.com>
References: <1286398930-11956-1-git-send-email-andi@firstfloor.org> <1286398930-11956-3-git-send-email-andi@firstfloor.org> <alpine.DEB.2.00.1010061618470.8083@router.home> <20101006214200.GA10386@gargoyle.ger.corp.intel.com> <alpine.DEB.2.00.1010061643200.8083@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1010061643200.8083@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, penberg@cs.helsinki.fi, mpm@selenic.com, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Wed, Oct 06, 2010 at 04:44:51PM -0500, Christoph Lameter wrote:
> On Wed, 6 Oct 2010, Andi Kleen wrote:
> 
> > We currently call the shrinking in a loop, similar to other users.
> 
> Obviously. There is already a function that does that called drop_slab()
> which lives in fs/drop_caches.c

Well it's three lines and hwpoison had an own copy for a long time.
I don't see a big urge to share.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
