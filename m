Date: Tue, 30 Jan 2001 09:31:59 +0100
From: Rasmus Andersen <rasmus@jaquet.dk>
Subject: Re: [PATCH] guard mm->rss with page_table_lock (241p11)
Message-ID: <20010130093159.A3298@jaquet.dk>
References: <rasmus@jaquet.dk> <13240.980842736@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <13240.980842736@warthog.cambridge.redhat.com>; from dhowells@cambridge.redhat.com on Tue, Jan 30, 2001 at 08:18:56AM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@cambridge.redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 30, 2001 at 08:18:56AM +0000, David Howells wrote:
> >...
> > +	spin_lock(&mm->page_table_lock);
> >  	mm->rss++;
> > +	spin_unlock(&mm->page_table_lock);
> >...
> 
> Would it not be better to use some sort of atomic add/subtract/clear operation
> rather than a spinlock? (Which would also give you fewer atomic memory access
> cycles).

This will unfortunately not do for all platforms. Please read
http://marc.theaimsgroup.com/?t=97630768100003&w=2&r=1 for the
last discussion of this.

Regards,
  Rasmus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
