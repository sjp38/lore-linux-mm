Subject: Re: [ckrm-tech] [RFC][PATCH 5/5] RSS accounting at the page level
Message-Id: <20061215133131.ECFEF1B6A7@openx4.frec.bull.fr>
Date: Fri, 15 Dec 2006 14:31:31 +0100 (CET)
From: Patrick.Le-Dot@bull.net (Patrick.Le-Dot)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@in.ibm.com
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
>>> ...
>>> This would limit the numbers to groups to the word size on the machine.
>> 
>> yes, this should be the bigger disadvantage of this implementation...
>> But may be acceptable for a prototype, at least to explain the concept ?
>> 
> 
> I think we need to find a more efficient mechanism to track shared pages

To clarify, bitmap is just an idea to avoid the rmap walk when the number
of groups is not too large and then kswapd can use a very fast check for
each page...


> ...
> Is there any way to print out the shared pages, I think it should
> easy to track shared pages per container as an accountable parameter.

May be "private pages per container" is more representative ?
I have to think about that...

Patrick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
