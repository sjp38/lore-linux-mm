Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A74396B0047
	for <linux-mm@kvack.org>; Fri,  5 Feb 2010 14:20:01 -0500 (EST)
Date: Fri, 5 Feb 2010 13:19:48 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] [0/4] SLAB: Fix a couple of slab memory hotadd issues
In-Reply-To: <201002031039.710275915@firstfloor.org>
Message-ID: <alpine.DEB.2.00.1002051316350.25989@router.home>
References: <201002031039.710275915@firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: submit@firstfloor.org, linux-kernel@vger.kernel.org, haicheng.li@intel.com, penberg@cs.helsinki.fi, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Feb 2010, Andi Kleen wrote:

> This fixes various problems in slab found during memory hotadd testing.

It changes the bootstrap semantics. The requirement was so far that slab
initialization must be complete before slab operations can be used.

This patchset allows such use before bootstrap on a node is complete and
also allows the running of cache reaper before bootstrap is done.

I have a bad feeling that this could be the result of Pekka's changes to
the bootstrap.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
