Subject: Re: [PATCH] smaps: account swap entries
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <1206545304.8514.494.camel@twins>
References: <1206545304.8514.494.camel@twins>
Content-Type: text/plain
Date: Wed, 26 Mar 2008 10:32:43 -0500
Message-Id: <1206545563.3527.79.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-03-26 at 16:28 +0100, Peter Zijlstra wrote:
> Subject: smaps: account swap entries
> 
> Show the amount of swap for each vma. This can be used to see where all the
> swap goes.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

Looks great to me.

Acked-by: Matt Mackall <mpm@selenic.com>

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
