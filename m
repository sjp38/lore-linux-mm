Date: Tue, 1 May 2007 13:31:59 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: cache-pipe-buf-page-address-for-non-highmem-arch.patch
Message-ID: <20070501113159.GV25929@bingen.suse.de>
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <20070501085431.GD14364@infradead.org> <20070501020441.10b6a003.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070501020441.10b6a003.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kenchen@google.com, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

> Andi, what are the prospects of speeding any of that up?

Good, see my original replies. Also there are Christoph's vmemmap patches
which also promised some speedup.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
