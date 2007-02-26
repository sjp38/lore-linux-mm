Subject: Re: [RFC][PATCH] mm: balance_dirty_pages() vs
	throttle_vm_writeout() deadlock
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1172497438.6374.53.camel@twins>
References: <1171986565.23046.5.camel@twins>
	 <20070221160757.2183d23f.akpm@linux-foundation.org>
	 <1172497438.6374.53.camel@twins>
Content-Type: text/plain
Date: Mon, 26 Feb 2007 15:10:51 +0100
Message-Id: <1172499051.6374.56.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Trond Myklebust <Trond.Myklebust@netapp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-02-26 at 14:43 +0100, Peter Zijlstra wrote:

> It might, but I'm afraid that the NFS writeout path includes a
> GFP_ATOMIC allocation, in which case this would not suffice. 

Bollocks!, GFP_ATOMIC doesn't wait.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
