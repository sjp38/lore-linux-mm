Date: Thu, 14 Nov 2002 12:36:48 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [patch] remove hugetlb syscalls
Message-ID: <20021114203648.GL23425@holomorphy.com>
References: <Pine.LNX.4.44L.0211132239370.3817-100000@imladris.surriel.com> <08a601c28bbb$2f6182a0$760010ac@edumazet> <20021114141310.A25747@infradead.org> <002b01c28bf0$751a3960$760010ac@edumazet> <20021114103147.A17468@redhat.com> <3DD40374.9050001@unix-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3DD40374.9050001@unix-os.sc.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rohit Seth <rseth@unix-os.sc.intel.com>
Cc: Benjamin LaHaise <bcrl@redhat.com>, rohit.seth@intel.com, dada1 <dada1@cosmosbay.com>, Christoph Hellwig <hch@infradead.org>, Rik van Riel <riel@conectiva.com.br>, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 14, 2002 at 12:11:32PM -0800, Rohit Seth wrote:
> This is not the problem with MAP_SHARED.  It is the lack of  (arch 
> specific) hugepage aligned function support in the kernel. You can use 
> the mmap on hugetlbfs using only MAP_FIXED with properly aligned 
> addresses (but then this also is only a hint to kernel).  With addr == 
> NULL in mmap, the function is bound to fail almost all the times.

There's very little standing in the way of automatic placement. If in
your opinion it should be implemented, I'll add that feature today.

IIRC you mentioned you would like to export the arch-specific
hugepage-aligned vma placement functions; once these are available,
it should be trivial to reuse them.


Thanks,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
