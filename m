Date: Fri, 7 Jan 2005 10:48:38 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] per thread page reservation patch
Message-Id: <20050107104838.0eacd301.akpm@osdl.org>
In-Reply-To: <1105118217.3616.171.camel@tribesman.namesys.com>
References: <20050103011113.6f6c8f44.akpm@osdl.org>
	<20050103114854.GA18408@infradead.org>
	<41DC2386.9010701@namesys.com>
	<1105019521.7074.79.camel@tribesman.namesys.com>
	<20050107144644.GA9606@infradead.org>
	<1105118217.3616.171.camel@tribesman.namesys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vladimir Saveliev <vs@namesys.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hch@infradead.org
List-ID: <linux-mm.kvack.org>

Vladimir Saveliev <vs@namesys.com> wrote:
>
> +int perthread_pages_reserve(int nrpages, int gfp)
>  +{
>  +	int i;
>  +	struct list_head  accumulator;
>  +	struct list_head *per_thread;
>  +
>  +	per_thread = get_per_thread_pages();
>  +	INIT_LIST_HEAD(&accumulator);
>  +	list_splice_init(per_thread, &accumulator);
>  +	for (i = 0; i < nrpages; ++i) {

This will end up reserving more pages than were asked for, if
current->private_pages_count is non-zero.  Deliberate?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
