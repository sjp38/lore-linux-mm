Message-ID: <4395261C.8000907@yahoo.com.au>
Date: Tue, 06 Dec 2005 16:48:12 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] lockless radix tree readside
References: <4394EC28.8050304@yahoo.com.au> <20051205.191153.19905732.davem@davemloft.net>
In-Reply-To: <20051205.191153.19905732.davem@davemloft.net>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: Linux-Kernel@Vger.Kernel.ORG, linux-mm@kvack.org, paul.mckenney@us.ibm.com, wfg@mail.ustc.edu.cn
List-ID: <linux-mm.kvack.org>

David S. Miller wrote:
> From: Nick Piggin <nickpiggin@yahoo.com.au>
> Date: Tue, 06 Dec 2005 12:40:56 +1100
> 
> 
>>I realise that radix-tree.c isn't a trivial bit of code so I don't
>>expect reviews to be forthcoming, but if anyone had some spare time
>>to glance over it that would be great.
> 
> 
> I went over this a few times and didn't find any obvious
> problems with the RCU aspect of this.
> 

Thanks!

> 
>>Is my given detail of the implementation clear? Sufficient? Would
>>diagrams be helpful?
> 
> 
> If I were to suggest an ascii diagram for a comment, it would be
> one which would show the height invariant this patch takes advantage
> of.
> 

I'll see if I can make something reasonably descriptive. And possibly
another diagram to show the node insertion concurrency cases vs lookup.
These things are the main concepts to understand, so I agree diagrams
might be helpful.

Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
