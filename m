Date: Tue, 2 Mar 2004 19:15:39 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] Distributed mmap API
Message-Id: <20040302191539.6bffc687.akpm@osdl.org>
In-Reply-To: <200403022200.39633.phillips@arcor.de>
References: <20040216190927.GA2969@us.ibm.com>
	<200402251604.19040.phillips@arcor.de>
	<20040225140727.0cde826e.akpm@osdl.org>
	<200403022200.39633.phillips@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: paulmck@us.ibm.com, sct@redhat.com, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Daniel Phillips <phillips@arcor.de> wrote:
>
> Here is a rearranged zap_pte_range that avoids any operations for out-of-range
> pfns.

Please remind us why Linux needs this patch?

> +static void invalidate_mmap_range_list(struct list_head *head,
> +		 unsigned long const hba,  unsigned long const hlen, int all)
>  {

I forget what `all' does?  anon+swapcache as well as pagecache?

A bit of API documentation here would be appropriate.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
