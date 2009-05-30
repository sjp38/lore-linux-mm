Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4C7F26B0092
	for <linux-mm@kvack.org>; Sat, 30 May 2009 02:52:21 -0400 (EDT)
Date: Fri, 29 May 2009 23:53:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: More thoughts about hwpoison and pageflags compression
Message-Id: <20090529235302.ccf58d88.akpm@linux-foundation.org>
In-Reply-To: <20090530063710.GI1065@one.firstfloor.org>
References: <200905291135.124267638@firstfloor.org>
	<20090529225202.0c61a4b3@lxorguk.ukuu.org.uk>
	<20090530063710.GI1065@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Sat, 30 May 2009 08:37:10 +0200 Andi Kleen <andi@firstfloor.org> wrote:

> So using a separate bit is a sensible choice imho.

Could you make the feature 64-bit-only and use one of bits 32-63?

Did you consider making the poison tag external to the pageframe?  Some
hash(page*) into a bitmap or something?  If suitably designed, such
infrastructure could perhaps be reused to reclaim some existing page
flags.  Dave Hansen had such a patch a few years back.  Or maybe it
was Andy Whitcroft.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
