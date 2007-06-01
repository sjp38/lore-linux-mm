Date: Fri, 1 Jun 2007 14:34:04 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] sparsemem: Shut up unused symbol compiler warnings.
Message-ID: <20070601053404.GA8841@linux-sh.org>
References: <20070601042515.GA8628@linux-sh.org> <20070601142124.91F8.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070601142124.91F8.Y-GOTO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 01, 2007 at 02:26:17PM +0900, Yasunori Goto wrote:
> I think this issue is fixed by
> move-three-functions-that-are-only-needed-for.patch in current -mm tree.
> Is it not enough?
> 
That's possible, I hadn't checked -mm. This was simply against current
git. If there's already a fix in -mm, then this can simply be ignored.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
