Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3FC646B00F9
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 16:00:07 -0500 (EST)
Subject: Re: [patch][rfc] mm: new address space calls
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <20090225104839.GG22785@wotan.suse.de>
References: <20090225104839.GG22785@wotan.suse.de>
Content-Type: text/plain
Date: Wed, 25 Feb 2009 15:59:57 -0500
Message-Id: <1235595597.32346.77.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2009-02-25 at 11:48 +0100, Nick Piggin wrote:
> This is about the last change to generic code I need for fsblock.
> Comments?
> 

Thanks for doing this.

We've got releasepage, invalidatepage, and now release, all with
slightly different semantics and some complex interactions with the rest
of the VM.

One problem I have with the btrfs extent state code is that I might
choose to release the extent state in releasepage, but the VM might not
choose to free the page.  So I've got an up to date page without any of
the rest of my state.

Which of these ops covers that? ;)  I'd love to help better document the
requirements for these callbacks, I find it confusing every time.

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
