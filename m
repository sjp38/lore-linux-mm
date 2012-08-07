Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 2AAB06B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 22:55:30 -0400 (EDT)
Date: Mon, 6 Aug 2012 19:55:20 -0700
From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [RFC v3 1/7] hashtable: introduce a small and naive hashtable
Message-ID: <20120807025520.GA3823@leaf>
References: <1344300317-23189-1-git-send-email-levinsasha928@gmail.com>
 <1344300317-23189-2-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1344300317-23189-2-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com

On Tue, Aug 07, 2012 at 02:45:10AM +0200, Sasha Levin wrote:
> +/**
> + * hash_add - add an object to a hashtable
> + * @hashtable: hashtable to add to
> + * @bits: bit count used for hashing
> + * @node: the &struct hlist_node of the object to be added
> + * @key: the key of the object to be added
> + */
> +#define hash_add(hashtable, bits, node, key)				\
> +	hlist_add_head(node, &hashtable[hash_min(key, bits)]);

Any particular reason to make this a macro rather than a static inline?

Also, even if you do make it a macro, don't include the semicolon.

> +/**
> + * hash_for_each_possible - iterate over all possible objects for a giver key

s/giver/given/

> + * @name: hashtable to iterate
> + * @obj: the type * to use as a loop cursor for each bucke

s/bucke/bucket/

- Josh Triplett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
