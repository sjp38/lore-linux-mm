Date: Wed, 30 Mar 2005 12:14:39 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Pageset Localization V2
Message-ID: <20050330111439.GA13110@infradead.org>
References: <Pine.LNX.4.58.0503292147200.32571@server.graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0503292147200.32571@server.graphe.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: Manfred Spraul <manfred@colorfullife.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mm@kvack.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

> +#define MAKE_LIST(list, nlist)  \
> +	do {    \
> +		if(list_empty(&list))      \
> +			INIT_LIST_HEAD(nlist);          \
> +		else {  nlist->next->prev = nlist;      \
> +			nlist->prev->next = nlist;      \
> +		}                                       \
> +	}while(0)

This is horrible.  Where are the nlist pointers supposed to point to?
What's so magic you need the INIT_LIST_HEAD only conditionally?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
