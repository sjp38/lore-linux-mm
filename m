Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 59CC46B0204
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 17:19:04 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20100406194843.GJ5288@laptop>
References: <20100406194843.GJ5288@laptop> <20100406193134.26429.78585.stgit@warthog.procyon.org.uk>
Subject: Re: [PATCH] radix_tree_tag_get() is not as safe as the docs make out
Date: Tue, 06 Apr 2010 22:18:58 +0100
Message-ID: <27834.1270588738@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: dhowells@redhat.com, torvalds@osdl.org, akpm@linux-foundation.org, paulmck@linux.vnet.ibm.com, corbet@lwn.net, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin <npiggin@suse.de> wrote:

> Nack, just drop the BUG_ON.

I can do that.

> I don't know what you mean by "untrustworthy answer".

I was thinking that the answer you get from radix_tree_tag_get() may be invalid
if the tag chain is being modified as you read it.  So if you do:

	rcu_read_lock()
	...
	x = radix_tree_tag_get(r, i, t);
	...
	y = radix_tree_tag_get(r, i, t);
	...
	rcu_read_unlock()

Then you can't guarantee that x == y, even though you were holding the RCU read
lock.

As you suggested, I'll try and come up with a comment modification to this
effect.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
