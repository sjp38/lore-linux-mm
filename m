Message-ID: <48AC3789.3030305@linux-foundation.org>
Date: Wed, 20 Aug 2008 10:26:01 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/2] Quicklist is slighly problematic.
References: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>	 <48AC25E7.4090005@linux-foundation.org> <2f11576a0808200749x956cc3fsef5d0eeace243410@mail.gmail.com>
In-Reply-To: <2f11576a0808200749x956cc3fsef5d0eeace243410@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, tokunaga.keiich@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:

> So, if possible, I'd like to make short term solution.
> I believe nobody oppose quicklist reducing. it is defenitly too fat.

Correct.

>> Good fixup but I would think that some more radical rework is needed.
>> Maybe some of this needs to vanish into the TLB handling logic?
> 
> What do you think wrong TLB handing?
> pure performance issue?

The generic TLB code could be made to do allow the allocation, the batching
and freeing of the pages. Would remove the need for quicklists for some uses.

>
> Do you have any page allocator enhancement plan?
> Can I help it?

A simple approach would be to use the queueing method used in quicklists in
the page allocator hotpath. But the devil is in the details .... There are
numerous checks for the type of page that are done by the page allocator and
not for the quicklists. Somehow we need to work around these.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
