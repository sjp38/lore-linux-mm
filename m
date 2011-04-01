Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8D8488D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 11:19:49 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1301290355-8980-1-git-send-email-lliubbo@gmail.com>
References: <1301290355-8980-1-git-send-email-lliubbo@gmail.com>
Subject: Re: [PATCH] ramfs: fix memleak on no-mmu arch
Date: Fri, 01 Apr 2011 16:19:10 +0100
Message-ID: <7980.1301671150@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: dhowells@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, hughd@google.com, viro@zeniv.linux.org.uk, hch@lst.de, npiggin@kernel.dk, tj@kernel.org, lethal@linux-sh.org, magnus.damm@gmail.com

Bob Liu <lliubbo@gmail.com> wrote:

> On no-mmu arch, there is a memleak duirng shmem test.
> The cause of this memleak is ramfs_nommu_expand_for_mapping() added page
> refcount to 2 which makes iput() can't free that pages.

Sorry I haven't got around to looking at this yet; it's going to have to wait
till I get back from the US in just over a week.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
