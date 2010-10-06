Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 347466B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 17:44:54 -0400 (EDT)
Date: Wed, 6 Oct 2010 16:44:51 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] HWPOISON: Attempt directed shrinking of slabs
In-Reply-To: <20101006214200.GA10386@gargoyle.ger.corp.intel.com>
Message-ID: <alpine.DEB.2.00.1010061643200.8083@router.home>
References: <1286398930-11956-1-git-send-email-andi@firstfloor.org> <1286398930-11956-3-git-send-email-andi@firstfloor.org> <alpine.DEB.2.00.1010061618470.8083@router.home> <20101006214200.GA10386@gargoyle.ger.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <ak@linux.intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, penberg@cs.helsinki.fi, mpm@selenic.com, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Wed, 6 Oct 2010, Andi Kleen wrote:

> We currently call the shrinking in a loop, similar to other users.

Obviously. There is already a function that does that called drop_slab()
which lives in fs/drop_caches.c



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
