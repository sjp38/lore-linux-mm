Date: Wed, 31 Jan 2001 00:17:37 +1300
From: Chris Wedgwood <cw@f00f.org>
Subject: Re: [PATCH] guard mm->rss with page_table_lock (241p11)
Message-ID: <20010131001737.C6620@metastasis.f00f.org>
References: <rasmus@jaquet.dk> <20010129224311.H603@jaquet.dk> <13240.980842736@warthog.cambridge.redhat.com> <14966.32188.408789.239466@pizda.ninka.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <14966.32188.408789.239466@pizda.ninka.net>; from davem@redhat.com on Tue, Jan 30, 2001 at 12:39:24AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: David Howells <dhowells@redhat.com>, Rasmus Andersen <rasmus@jaquet.dk>, Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 30, 2001 at 12:39:24AM -0800, David S. Miller wrote:

    Please see older threads about this, it has been discussed to
    death already (hint: sizeof(atomic_t), sizeof(unsigned long)).

can we not define a macro so architectures that can do do atomically
inc/dec with unsigned long will? otherwise it uses the spinlock?


  --cw
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
