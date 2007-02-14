Date: Wed, 14 Feb 2007 07:31:13 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] build error: allnoconfig fails on mincore/swapper_space
In-Reply-To: <45D266E3.4050905@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0702140727180.4224@blonde.wat.veritas.com>
References: <20070212145040.c3aea56e.randy.dunlap@oracle.com>
 <20070212150802.f240e94f.akpm@linux-foundation.org> <45D12715.4070408@yahoo.com.au>
 <20070213121217.0f4e9f3a.randy.dunlap@oracle.com>
 <Pine.LNX.4.64.0702132224280.3729@blonde.wat.veritas.com>
 <20070213144909.70943de2.randy.dunlap@oracle.com>
 <Pine.LNX.4.64.0702140009320.21315@blonde.wat.veritas.com>
 <45D266E3.4050905@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, tony.luck@gmail.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 14 Feb 2007, Nick Piggin wrote:
> 
> Can't you have migration without swap?

Yes: but then the only swap entry it can find (short of page
table corruption, which isn't really the focus of mincore)
is a migration entry, isn't it?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
