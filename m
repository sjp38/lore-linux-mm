Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 756A56B00CE
	for <linux-mm@kvack.org>; Wed, 27 May 2009 17:13:58 -0400 (EDT)
Date: Wed, 27 May 2009 22:15:10 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] [1/16] HWPOISON: Add page flag for poisoned pages
Message-ID: <20090527221510.5e418e97@lxorguk.ukuu.org.uk>
In-Reply-To: <20090527201226.CCCBB1D028F@basil.firstfloor.org>
References: <200905271012.668777061@firstfloor.org>
	<20090527201226.CCCBB1D028F@basil.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

On Wed, 27 May 2009 22:12:26 +0200 (CEST)
Andi Kleen <andi@firstfloor.org> wrote:

> 
> Hardware poisoned pages need special handling in the VM and shouldn't be 
> touched again. This requires a new page flag. Define it here.

Why can't you use PG_reserved ? That already indicates the page may not
even be present (which is effectively your situation at that point).
Given lots of other hardware platforms we support bus error, machine
check, explode or do random undefined fun things when you touch pages
that don't exist I'm not sure I see why poisoned is different here ?

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
