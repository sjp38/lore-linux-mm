Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B857A5F0001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 09:24:39 -0500 (EST)
Subject: Re: [patch 1/2] slqb: fix small zero size alloc bug
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20090203135559.GA8723@wotan.suse.de>
References: <20090203135559.GA8723@wotan.suse.de>
Date: Tue, 03 Feb 2009 16:24:36 +0200
Message-Id: <1233671076.22926.56.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-02-03 at 14:55 +0100, Nick Piggin wrote:
> Fix a problem where SLQB did not correctly return ZERO_SIZE_PTR for a
> zero sized allocation.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
