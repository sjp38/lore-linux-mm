Date: Thu, 14 Nov 2002 14:13:10 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch] remove hugetlb syscalls
Message-ID: <20021114141310.A25747@infradead.org>
References: <Pine.LNX.4.44L.0211132239370.3817-100000@imladris.surriel.com> <08a601c28bbb$2f6182a0$760010ac@edumazet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <08a601c28bbb$2f6182a0$760010ac@edumazet>; from dada1@cosmosbay.com on Thu, Nov 14, 2002 at 09:52:33AM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: dada1 <dada1@cosmosbay.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Benjamin LaHaise <bcrl@redhat.com>, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 14, 2002 at 09:52:33AM +0100, dada1 wrote:
> I beg to differ.
> 
> I already use the syscalls.

For what?

> How one is supposed to use hugetlbfs ? That's not documented.

mount -t hugetlbfs whocares /huge

fd = open("/huge/nose", ..)

mmap(.., fd, ..)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
