Date: Tue, 07 Oct 2008 14:06:45 -0700 (PDT)
Message-Id: <20081007.140645.119998645.davem@davemloft.net>
Subject: Re: [patch][rfc] ddds: "dynamic dynamic data structure" algorithm,
 for adaptive dcache hash table sizing (resend)
From: David Miller <davem@davemloft.net>
In-Reply-To: <20081007075309.GA16143@wotan.suse.de>
References: <20081007070225.GB5959@wotan.suse.de>
	<20081007071827.GB5010@infradead.org>
	<20081007075309.GA16143@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <npiggin@suse.de>
Date: Tue, 7 Oct 2008 09:53:09 +0200
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

> Dcache lookup is partially a tree lookup, but also how do you look up
> entries in a given directory? That is not naturally a tree lookup. Could
> be a per directory tree, though, or a hash, or trie.
> 
> Anyway, I don't volunteer to change that just yet ;)

Historically speaking, the original dcache by Thomas Schoebel-Theuer
(circa 1997) was in fact implemented as a per-directory hash table.

This has all kinds of recursion and other issues, which is why Linus
eventually changed it to use a global hash table scheme.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
