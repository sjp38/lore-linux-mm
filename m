Message-ID: <47D17C4E.9000302@oracle.com>
Date: Fri, 07 Mar 2008 09:33:02 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] [6/13] Core maskable allocator
References: <200803071007.493903088@firstfloor.org> <20080307090716.9D3E91B419C@basil.firstfloor.org> <20080307090517.b6b27987.randy.dunlap@oracle.com> <20080307173146.GI7365@one.firstfloor.org>
In-Reply-To: <20080307173146.GI7365@one.firstfloor.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
>>> +	maskzone=size[MG] Set size of maskable DMA zone to size.
>>> +		 force	Always allocate from the mask zone (for testing)
>>                  ^^^^^^^^^^^^^ ??
> 
> What is your question?

That line seems odd.  Is it correct?
Why 2 spaces between force and Always?  Why is Always capitalized?
Could one of those words be dropped?  They seem a bit redundant.

-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
