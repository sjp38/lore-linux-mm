Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CD0198D0039
	for <linux-mm@kvack.org>; Wed,  2 Feb 2011 14:38:00 -0500 (EST)
Date: Wed, 2 Feb 2011 11:37:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] Allow GUP to fail instead of waiting on a page.
Message-Id: <20110202113750.367a6fda.akpm@linux-foundation.org>
In-Reply-To: <20110202133157.GI14984@redhat.com>
References: <1296559307-14637-1-git-send-email-gleb@redhat.com>
	<1296559307-14637-2-git-send-email-gleb@redhat.com>
	<20110201164240.9a5c06e9.akpm@linux-foundation.org>
	<20110202133157.GI14984@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@redhat.com>
Cc: avi@redhat.com, mtosatti@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Wed, 2 Feb 2011 15:31:57 +0200
Gleb Natapov <gleb@redhat.com> wrote:

> > This?
> > 
> Yes, this is better. Thanks you. I see that the patch below is in your queue
> already. Should I re-spin my patch with improved comment anyway?

Nope, that's OK - I fold fixup patches into the base patch before
sending them onwards.

There's always a risk that someone will get a hold of an earlier
version of the patch, but a) sending out a v2 doesn't eliminate that
risk and b) it's not very important anyway (in this case) and c)
because I separate the base patch from the fixup patches, I'll easily
notice if someone merges an earlier patch, because I'm left holding
stray fixup patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
