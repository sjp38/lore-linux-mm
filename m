Date: Wed, 25 Aug 2004 13:53:08 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bug 3268] New: Lowmemory exhaustion problem with v2.6.8.1-mm4
 16gb
Message-Id: <20040825135308.2dae6a5d.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.44.0408252104540.2664-100000@localhost.localdomain>
References: <1093460701.5677.1881.camel@knk>
	<Pine.LNX.4.44.0408252104540.2664-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: kmannth@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins <hugh@veritas.com> wrote:
>
> (hmm, does lowmem shortage exert
>  any pressure on highmem cache these days, I wonder?);

It does, indirectly - when we reclaim an unused inode we also shoot down
all that inode's pagecache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
