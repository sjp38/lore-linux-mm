Date: Sat, 23 Feb 2008 00:06:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 09/28] mm: __GFP_MEMALLOC
Message-Id: <20080223000601.d35912d4.akpm@linux-foundation.org>
In-Reply-To: <20080220150306.424308000@chello.nl>
References: <20080220144610.548202000@chello.nl>
	<20080220150306.424308000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008 15:46:19 +0100 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> __GFP_MEMALLOC will allow the allocation to disregard the watermarks, 
> much like PF_MEMALLOC.
> 

'twould be nice if the changelog had some explanation of the reason
for this change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
