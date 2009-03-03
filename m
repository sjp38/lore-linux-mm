Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9A0336B0095
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 10:58:37 -0500 (EST)
Date: Tue, 3 Mar 2009 10:58:35 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 1/2] mm: page_mkwrite change prototype to match fault
Message-ID: <20090303155835.GA28851@infradead.org>
References: <20090303103838.GC17042@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090303103838.GC17042@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 03, 2009 at 11:38:38AM +0100, Nick Piggin wrote:
> 
> Change the page_mkwrite prototype to take a struct vm_fault, and return
> VM_FAULT_xxx flags. Same as ->fault handler. Should be no change in
> behaviour.

How about just merging it into ->fault?

> This is required for a subsequent fix. And will also make it easier to
> merge page_mkwrite() with fault() in future.

Ah, I should read until the end :)  Any reason not to do the merge just
yet?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
