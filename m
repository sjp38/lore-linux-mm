Date: Tue, 17 Feb 2004 16:19:29 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-Id: <20040217161929.7e6b2a61.akpm@osdl.org>
In-Reply-To: <20040217124001.GA1267@us.ibm.com>
References: <20040216190927.GA2969@us.ibm.com>
	<20040217073522.A25921@infradead.org>
	<20040217124001.GA1267@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: paulmck@us.ibm.com
Cc: hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Paul E. McKenney" <paulmck@us.ibm.com> wrote:
>
> IBM shipped the promised SAN Filesystem some months ago.

Neat, but it's hard to see the relevance of this to your patch.

I don't see any licensing issues with the patch because the filesystem
which needs it clearly meets Linus's "this is not a derived work" criteria.

And I don't see a technical problem with the export: given that we export
truncate_inode_pages() it makes sense to also export the corresponding
pagetable shootdown function.

Yes, this is a sensitive issue.  Can we please evaluate it strictly
according to technical and licensing considerations?

Having said that, what concerns issues remain with Paul's patch?

Thanks.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
