Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 40BC16B01FD
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 15:43:11 -0400 (EDT)
Date: Tue, 6 Apr 2010 12:39:17 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] radix_tree_tag_get() is not as safe as the docs make
 out
In-Reply-To: <20100406193134.26429.78585.stgit@warthog.procyon.org.uk>
Message-ID: <alpine.LFD.2.00.1004061236290.3487@i5.linux-foundation.org>
References: <20100406193134.26429.78585.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: akpm@linux-foundation.org, npiggin@suse.de, paulmck@linux.vnet.ibm.com, corbet@lwn.net, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Tue, 6 Apr 2010, David Howells wrote:
>
> radix_tree_tag_get() is not safe to use concurrently with radix_tree_tag_set()
> or radix_tree_tag_clear().  The problem is that the double tag_get() in
> radix_tree_tag_get():
 [ snip snip ]

Looks like a reasonable patch, but the one thing you didn't say is whether 
there is any code that relies on the incorrectly documented behavior?

How did you find this? Do we need to fix actual code too? The only user 
seems to be your fscache/page.c thing, and I'm not seeing any locking 
except for the rcu locking that is apparently not sufficient.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
