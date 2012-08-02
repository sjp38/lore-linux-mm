Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id D8C7C6B0068
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 18:41:14 -0400 (EDT)
Message-ID: <1343947273.10710.4.camel@joe2Laptop>
Subject: Re: [PATCH v2 9/9] rbtree: remove prior augmented rbtree
 implementation
From: Joe Perches <joe@perches.com>
Date: Thu, 02 Aug 2012 15:41:13 -0700
In-Reply-To: <1343946858-8170-10-git-send-email-walken@google.com>
References: <1343946858-8170-1-git-send-email-walken@google.com>
	 <1343946858-8170-10-git-send-email-walken@google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Thu, 2012-08-02 at 15:34 -0700, Michel Lespinasse wrote:
> convert arch/x86/mm/pat_rbtree.c to the proposed augmented rbtree api
> and remove the old augmented rbtree implementation.

style trivia:

> +static u64 compute_subtree_max_end(struct memtype *data)
>  {
> -	struct memtype *data;
> -	u64 max_end, child_max_end;
> -
> -	if (!node)
> -		return;
> -
> -	data = container_of(node, struct memtype, rb);
> -	max_end = data->end;
> +	u64 max_end = data->end, child_max_end;
>  
> -	child_max_end = get_subtree_max_end(node->rb_right);
> +	child_max_end = get_subtree_max_end(data->rb.rb_right);

I think this reads better as:

	u64 max_end = data->end;
	u64 child_max_end = get_subtree_max_end(node->rb.rb_right);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
