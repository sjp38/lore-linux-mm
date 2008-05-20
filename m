Date: Tue, 20 May 2008 14:08:55 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/2] panics booting NUMA SPARSEMEM on x86_32 NUMA
Message-ID: <20080520120855.GA10080@elte.hu>
References: <exportbomb.1211277639@pinky>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <exportbomb.1211277639@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Yinghai Lu <yhlu.kernel@gmail.com>
List-ID: <linux-mm.kvack.org>

* Andy Whitcroft <apw@shadowen.org> wrote:

> We have been seeing panics booting NUMA SPARSEMEM kernels on x86_32 
> hardware, while trying to allocate node local memory in early boot. 
> These are caused by a miss-allocation of the node pgdat structures 
> when numa remap is disabled.
> 
> Following this email are two patches, the first reenables numa remap 
> for SPARSEMEM as the underlying bug has now been fixed.  The second 
> hardens the pgdat allocation in the face of there being no numa remap 
> for a particular node (which may still occur).

applied to -tip, thanks Andy.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
