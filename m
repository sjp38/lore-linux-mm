Date: Wed, 12 Oct 2005 08:25:56 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 2/3] hugetlb: Demand fault handler
In-Reply-To: <20051012060934.GA14943@localhost.localdomain>
Message-ID: <Pine.LNX.4.61.0510120824320.4681@goblin.wat.veritas.com>
References: <1129055057.22182.8.camel@localhost.localdomain>
 <1129055559.22182.12.camel@localhost.localdomain> <20051012060934.GA14943@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Gibson <david@gibson.dropbear.id.au>
Cc: Adam Litke <agl@us.ibm.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, 12 Oct 2005, David Gibson wrote:
> 
> I'm not sure this does fully deal with truncation, I'm afraid - it
> will deal with a truncation well before the fault, but not a
> concurrent truncate().  We'll need the truncate_count/retry logic from
> do_no_page, I think.  Andi/Hugh, can you confirm that's correct?

Very likely you're right, but I already explained to Adam privately
that I won't get to look at all this before tomorrow - sorry.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
