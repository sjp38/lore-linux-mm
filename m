Message-ID: <48F83078.8020408@davidnewall.com>
Date: Fri, 17 Oct 2008 16:58:08 +1030
From: David Newall <davidn@davidnewall.com>
MIME-Version: 1.0
Subject: Re: no way to swapoff a deleted swap file?
References: <20081015202141.GX26067@cordes.ca> <1224145684.28131.25.camel@twins> <Pine.LNX.4.64.0810162313570.26758@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0810162313570.26758@blonde.site>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Peter Cordes <peter@cordes.ca>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Thu, 16 Oct 2008, Peter Zijlstra wrote:
>   
>> On Wed, 2008-10-15 at 17:21 -0300, Peter Cordes wrote:
>>     
>>> I unlinked a swapfile without realizing I was still swapping on it.
>>>       
>> I see your problem and it makes sense to look for a nice solution.
>>     
>
> although I'll willingly admit it's a
> lacuna, I don't think it's one worth bloating the kernel for.

Me too.  The kernel shouldn't protect the administrator against all
possible mistakes; and this mistake is one of them.  Besides, who's to
say it's always a mistake?  Somebody might want their swap file to have
zero links.


Do nothing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
