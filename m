From: "David S. Miller" <davem@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14966.32188.408789.239466@pizda.ninka.net>
Date: Tue, 30 Jan 2001 00:39:24 -0800 (PST)
Subject: Re: [PATCH] guard mm->rss with page_table_lock (241p11) 
In-Reply-To: <13240.980842736@warthog.cambridge.redhat.com>
References: <rasmus@jaquet.dk>
	<20010129224311.H603@jaquet.dk>
	<13240.980842736@warthog.cambridge.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Rasmus Andersen <rasmus@jaquet.dk>, Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Howells writes:
 > Would it not be better to use some sort of atomic add/subtract/clear operation
 > rather than a spinlock? (Which would also give you fewer atomic memory access
 > cycles).

Please see older threads about this, it has been discussed to death
already (hint: sizeof(atomic_t), sizeof(unsigned long)).

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
