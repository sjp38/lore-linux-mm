Date: Tue, 1 May 2007 09:54:31 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: cache-pipe-buf-page-address-for-non-highmem-arch.patch
Message-ID: <20070501085431.GD14364@infradead.org>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070430162007.ad46e153.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kenchen@google.com
List-ID: <linux-mm.kvack.org>

>  cache-pipe-buf-page-address-for-non-highmem-arch.patch

I still don't like this one at all.  If page_address on x86_64 is too
slow we should fix the root cause.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
