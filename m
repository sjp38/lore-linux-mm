Date: Wed, 31 Jan 2007 11:30:01 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch] not to disturb page LRU state when unmapping memory
 range
In-Reply-To: <45C0EAB7.5040903@in.ibm.com>
Message-ID: <Pine.LNX.4.64.0701311126580.16788@schroedinger.engr.sgi.com>
References: <b040c32a0701302041j2a99e2b6p91b0b4bfa065444a@mail.gmail.com>
 <1170246396.9516.39.camel@twins> <45C0EAB7.5040903@in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@in.ibm.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ken Chen <kenchen@google.com>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 1 Feb 2007, Balbir Singh wrote:

> Does it make sense to do this only for shared mapped pages?
> 
> if (pte_young(ptent) && (page_mapcount(page) > 1))
> 	SetPageReferenced(page);

If the page is only mapped by the process releasing the memory then it may 
be considered less likely that the page is reused. But the basic issue 
that Huge mentioned remains.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
