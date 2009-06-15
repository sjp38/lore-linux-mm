Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B706A6B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 10:03:53 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20090615123658.GC4721@jukie.net>
References: <20090615123658.GC4721@jukie.net> <20090613182721.GA24072@jukie.net> <25357.1245068384@redhat.com>
Subject: Re: [v2.6.30 nfs+fscache] kswapd1: blocked for more than 120 seconds
Date: Mon, 15 Jun 2009 15:03:47 +0100
Message-ID: <25124.1245074627@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Bart Trojanowski <bart@jukie.net>
Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org, linux-cachefs@redhat.com, linux-nfs@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Bart Trojanowski <bart@jukie.net> wrote:

> Sure, I'll create a new lvm volume with ext3 on it and give it a try.
> Can I just shutdown cachefilesd, relocate the cahce, and restart the
> daemon without remounting the nfs volumes?

Yes...  But it won't begin caching any files that are already in the inode
cache in memory until they're discarded from the icache and are iget'd
again...  Which is something else I need to look at.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
