Message-ID: <442097EE.2000601@yahoo.com.au>
Date: Wed, 22 Mar 2006 11:18:54 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH][8/8] mm: lru interface change
References: <bc56f2f0603200538g3d6aa712i@mail.gmail.com>	 <441FF007.6020901@yahoo.com.au> <bc56f2f0603210753k758ebf6dq@mail.gmail.com>
In-Reply-To: <bc56f2f0603210753k758ebf6dq@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stone Wang <pwstone@gmail.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stone Wang wrote:
>>I may have missed something very trivial, but... why are they on a
>>list at all if they don't get scanned
> 
> 
> Get the locked pages on a list is necessary for page management,
> scatter the locked pages around isnt a good idea.
> 

This doesn't make sense. Whether or not they're on a list does not
change the fact that they may be "scattered".

> Also, we could add some kinds of scan to the locked pages,
> if we find that it's necessary.
> 

This is a valid reason. But at present you don't scan them, do you?
So you should add them to a list in patch 9 where you add the
machanism to scan them as well, right?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
