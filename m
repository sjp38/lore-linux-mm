Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CA8C76B0085
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 09:27:06 -0400 (EDT)
Date: Fri, 22 Oct 2010 15:27:03 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: shrinkers: Add node to indicate where to target shrinking
Message-ID: <20101022132703.GH10456@basil.fritz.box>
References: <alpine.DEB.2.00.1010211255570.24115@router.home>
 <alpine.DEB.2.00.1010211259360.24115@router.home>
 <alpine.DEB.2.00.1010211353540.17944@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1010211353540.17944@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, akpm@linux-foundation.org, npiggin@kernel.dk, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

> This sets us up for node-targeted shrinking, but nothing is currently 
> using it.  Do you have a patch (perhaps from Andi?) that can immediately 
> use it?  That would be a compelling reason to merge this.

Not sure I understand your comment? Christoph's patch already 
modifies hwpoison to use it. There are no other changes needed.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
