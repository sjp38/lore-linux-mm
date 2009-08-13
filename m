Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5A7276B004F
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 02:53:21 -0400 (EDT)
Subject: Re: [PATCH] swap: send callback when swap slot is freed
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <4A837AAF.4050103@vflare.org>
References: <200908122007.43522.ngupta@vflare.org>
	 <Pine.LNX.4.64.0908122312380.25501@sister.anvils>
	 <4A837AAF.4050103@vflare.org>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Thu, 13 Aug 2009 08:53:00 +0200
Message-Id: <1250146380.10001.47.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Matthew Wilcox <willy@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2009-08-13 at 08:00 +0530, Nitin Gupta wrote:
> > I don't share Peter's view that it should be using a more general
> > notifier interface (but I certainly agree with his EXPORT_SYMBOL_GPL).
> 
> Considering that the callback is made under swap_lock, we should not 
> have an array of callbacks to do. But what if this callback finds other 
> users too? I think we should leave it in its current state till it finds 
> more users and probably add BUG() to make sure callback is not already set.
> 
> I will make it EXPORT_SYMBOL_GPL.

If its such a tightly coupled system, then why is compcache a module?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
