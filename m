Subject: Re: [PATCH] guard mm->rss with page_table_lock (241p11) 
In-Reply-To: Message from Rasmus Andersen <rasmus@jaquet.dk>
   of "Mon, 29 Jan 2001 22:43:11 +0100." <20010129224311.H603@jaquet.dk>
Date: Tue, 30 Jan 2001 08:18:56 +0000
Message-ID: <13240.980842736@warthog.cambridge.redhat.com>
From: David Howells <dhowells@cambridge.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rasmus Andersen <rasmus@jaquet.dk>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>...
> +	spin_lock(&mm->page_table_lock);
>  	mm->rss++;
> +	spin_unlock(&mm->page_table_lock);
>...

Would it not be better to use some sort of atomic add/subtract/clear operation
rather than a spinlock? (Which would also give you fewer atomic memory access
cycles).

David
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
