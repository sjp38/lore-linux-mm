Date: Fri, 23 Mar 2007 08:30:06 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [patch] rfc: introduce /dev/hugetlb
Message-ID: <20070323153006.GW2986@holomorphy.com>
References: <b040c32a0703230144r635d7902g2c36ecd7f412be31@mail.gmail.com> <Pine.LNX.4.64.0703231457360.4133@skynet.skynet.ie> <20070323150924.GV2986@holomorphy.com> <Pine.LNX.4.64.0703231514370.4133@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703231514370.4133@skynet.skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Ken Chen <kenchen@google.com>, Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 23 Mar 2007, William Lee Irwin III wrote:
>> Lack of compiletesting beyond x86-64 in all probability.

On Fri, Mar 23, 2007 at 03:15:55PM +0000, Mel Gorman wrote:
> Ok, this will go kablamo on Power then even if it compiles. I don't 
> consider it a fundamental problem though. For the purposes of an RFC, it's 
> grand and something that can be worked with.

He needs to un-#ifdef the prototype (which he already does), but he
needs to leave the definition under #ifdef while removing the static
qualifier. A relatively minor fixup.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
