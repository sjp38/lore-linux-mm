Message-ID: <41E61479.5040704@yahoo.com.au>
Date: Thu, 13 Jan 2005 17:26:01 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Odd kswapd behaviour after suspending in 2.6.11-rc1
References: <20050113061401.GA7404@blackham.com.au>
In-Reply-To: <20050113061401.GA7404@blackham.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bernard Blackham <bernard@blackham.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Bernard Blackham wrote:

> I reverted the changes to mm/vmscan.c between 2.6.10 and 2.6.11-rc1
> with the attached patch (applies forwards over the top of
> 2.6.11-rc1), and I no longer get any kswapd weirdness.  Is there
> something in here misbehaving?
> 

Hmm, it is likely to be the higher order watermarks change.

Can you get a couple of Alt+SysRq+M traces during the time when
kswapd is going crazy please?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
