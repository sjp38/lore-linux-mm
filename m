Message-ID: <4424398F.2040300@yahoo.com.au>
Date: Sat, 25 Mar 2006 05:25:19 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH][5/8] proc: export mlocked pages info through "/proc/meminfo:
 Wired"
References: <bc56f2f0603200537i7b2492a6p@mail.gmail.com>  <441FEFC7.5030109@yahoo.com.au> <bc56f2f0603210733vc3ce132p@mail.gmail.com> <442098B6.5000607@yahoo.com.au> <Pine.LNX.4.63.0603241133550.30426@cuia.boston.redhat.com> <442420A2.80807@yahoo.com.au> <Pine.LNX.4.63.0603241319130.30426@cuia.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.63.0603241319130.30426@cuia.boston.redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Stone Wang <pwstone@gmail.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> On Sat, 25 Mar 2006, Nick Piggin wrote:
> 
>>Rik van Riel wrote:
>>
>>>On Wed, 22 Mar 2006, Nick Piggin wrote:
>>>
>>>
>>>>Why would you want to ever do something like that though? I don't think
>>>>you should use this name "just in case", unless you have some really good
>>>>potential usage in mind.
>>>
>>>ramfs
>>
>>Why would ramfs want its pages in this wired list? (I'm not so
>>familiar with it but I can't think of a reason).
> 
> 
> Because ramfs pages cannot be paged out, which makes them locked
> into memory the same way mlocked pages are.
> 

I don't understand why they need to be on any list though,
that isn't an internal ramfs specific structure (ie. not
the just-in-case wired list).

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
