Message-ID: <41E8ED89.8090306@yahoo.com.au>
Date: Sat, 15 Jan 2005 21:16:41 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Odd kswapd behaviour after suspending in 2.6.11-rc1
References: <20050113061401.GA7404@blackham.com.au> <41E61479.5040704@yahoo.com.au> <20050113085626.GA5374@blackham.com.au> <20050113101426.GA4883@blackham.com.au>
In-Reply-To: <20050113101426.GA4883@blackham.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bernard Blackham <bernard@blackham.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Bernard Blackham wrote:
> On Thu, Jan 13, 2005 at 04:56:27PM +0800, Bernard Blackham wrote:
> 
>>>Can you get a couple of Alt+SysRq+M traces during the time when
>>>kswapd is going crazy please?
>>
>>Embarrasingly, I can't reproduce it at the moment.
> 
> 
> Actually I lied - It is still completely reproduceable if I hadn't
> confused myself with reversing reversed patches.. :/
> 
> Attached are a couple of Alt+Sysrq+M and Alt+Sysrq+T outputs when
> kswapd goes crazy, with the last pair when things are back to
> normal.
> 

OK I think the problem is due to swsusp allocating a very large
chunk of memory before suspending. After resuming, kswapd is more
or less in the same state and tries a bit too hard to free things.

And it goes crazy mainly because the kswapd "higher order awareness"
stuff not having quite enough smarts. It needs to be a bit more
aware of "classzone" allocation issues rather than just individual
zones.

Thanks for the report... I'll come up with something for you to try
in the next day or so.

Thanks,
Nick


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
