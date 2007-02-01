Message-ID: <45C15AF0.4080406@redhat.com>
Date: Wed, 31 Jan 2007 22:13:52 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch] not to disturb page LRU state when unmapping memory	range
References: <b040c32a0701302041j2a99e2b6p91b0b4bfa065444a@mail.gmail.com>	 <Pine.LNX.4.64.0701311746230.6135@blonde.wat.veritas.com>	 <1170279811.10924.32.camel@lappy>  <20070131140450.09f174e9.akpm@osdl.org> <1170282300.10924.50.camel@lappy>
In-Reply-To: <1170282300.10924.50.camel@lappy>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:

> Yes, why would unmapping a range make the pages more likely to be used
> in the immediate future than otherwise indicated by their individual
> young bits?
> 
> Even the opposite was suggested, that unmapping a range makes it less
> likely to be used again.

I agree, the VM looks at the usage of individual pages and makes
decisions based on that.  We can only see how often individual
pages are referenced, and do not have much additional information
(except from the readahead code).

Making sweeping generalizations like "unmapping makes pages less
likely to be needed again" is bound to cause trouble for some
workloads.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
