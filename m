Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E2AAD5F0001
	for <linux-mm@kvack.org>; Thu, 16 Apr 2009 04:51:17 -0400 (EDT)
Subject: Re: [patch 1/5] slqb: irq section fix
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20090414164439.GA14873@wotan.suse.de>
References: <20090414164439.GA14873@wotan.suse.de>
Date: Thu, 16 Apr 2009 11:51:59 +0300
Message-Id: <1239871920.15377.6.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-04-14 at 18:44 +0200, Nick Piggin wrote:
> slqb: irq section fix
> 
> flush_free_list can be called with interrupts enabled, from
> kmem_cache_destroy. Fix this.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>

The series has been applied! Thanks.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
