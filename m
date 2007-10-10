Subject: Re: [PATCH 6/6] Use one zonelist that is filtered by nodemask
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20071009154052.GC12632@skynet.ie>
References: <20070928142326.16783.98817.sendpatchset@skynet.skynet.ie>
	 <20070928142526.16783.97067.sendpatchset@skynet.skynet.ie>
	 <20071009011143.GC14670@us.ibm.com>  <20071009154052.GC12632@skynet.ie>
Content-Type: text/plain
Date: Wed, 10 Oct 2007 11:53:40 -0400
Message-Id: <1192031620.5617.39.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, 2007-10-09 at 16:40 +0100, Mel Gorman wrote:
<snip>
> ====
> Subject: Use specified node ID with GFP_THISNODE if available
> 
> It had been assumed that __GFP_THISNODE meant allocating from the local
> node and only the local node. However, users of alloc_pages_node() may also
> specify GFP_THISNODE. In this case, only the specified node should be used.
> This patch will allocate pages only from the requested node when GFP_THISNODE
> is used with alloc_pages_node().
> 
> [nacc@us.ibm.com: Detailed analysis of problem]
> Found-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
<snip>

Mel:  I applied this patch [to your v8 series--the most recent, I
think?] and it does fix the problem.  However, now I'm tripping over
this warning in __alloc_pages_nodemask:

	/* Specifying both __GFP_THISNODE and nodemask is stupid. Warn user */
	WARN_ON(gfp_mask & __GFP_THISNODE);

for each huge page allocated.  Rather slow as my console is a virtual
serial line and the warning includes the stack traceback.

I think we want to just drop this warning, but maybe you have a tighter
condition that you want to warn about?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
