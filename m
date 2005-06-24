Message-ID: <42BB6627.2080102@yahoo.com.au>
Date: Fri, 24 Jun 2005 11:47:19 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch][rfc] 5/5: core remove PageReserved
References: <42BA5F37.6070405@yahoo.com.au> <42BA5F5C.3080101@yahoo.com.au> <42BA5F7B.30904@yahoo.com.au> <42BA5FA8.7080905@yahoo.com.au> <42BA5FC8.9020501@yahoo.com.au> <42BA5FE8.2060207@yahoo.com.au> <20050623095153.GB3334@holomorphy.com> <42BA8FA5.2070407@yahoo.com.au> <20050623220812.GD3334@holomorphy.com> <42BB43FB.1060609@yahoo.com.au> <20050624005952.GE3334@holomorphy.com> <42BB5F29.6060802@yahoo.com.au>
In-Reply-To: <42BB5F29.6060802@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> William Lee Irwin III wrote:
> 

>> On Fri, Jun 24, 2005 at 09:21:31AM +1000, Nick Piggin wrote:
>>
>>> I'm sorry, I don't see how 'diddling' the core will create bugs.
>>> This is a fine way to do it, and "converting" users first (whatever
>>> that means)
>>
>>
>> [cut text included in full in the following quote block]
>>
>> This is going way too far. Someone please deal with this.
>>
> 
> No, just tell me how it might magically create bugs in drivers
> that didn't exist in the first place?


Sorry, I got a bit carried away. That remark wasn't helpful.

What I mean is: if you see an aspect of this change that will
cause breakage in previously correct drivers, please raise
your specific concerns with me.

I have tried to be careful about this, and put in bugs/warnings
where problems in already broken code are magnified.
Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
