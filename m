Message-ID: <405184F7.1050100@cyberone.com.au>
Date: Fri, 12 Mar 2004 20:37:59 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] 2.6.4-rc2-mm1: vm-split-active-lists
References: <404FACF4.3030601@cyberone.com.au>	<200403111825.22674@WOLK>	<40517E47.3010909@cyberone.com.au> <20040312012703.69f2bb9b.akpm@osdl.org>
In-Reply-To: <20040312012703.69f2bb9b.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: m.c.p@wolk-project.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mfedyk@matchmail.com, plate@gmx.tm
List-ID: <linux-mm.kvack.org>


Andrew Morton wrote:

>Nick Piggin <piggin@cyberone.com.au> wrote:
>
>>Hmm... I guess it is still smooth because it is swapping out only
>> inactive pages. If the standard VM isn't being pushed very hard it
>> doesn't scan mapped pages at all which is why it isn't swapping.
>>
>> I have a preference for allowing it to scan some mapped pages though.
>>
>
>I haven't looked at the code but if, as I assume, it is always scanning
>mapped pages, although at a reduced rate then the effect will be the same
>as setting swappiness to 100, except it will take longer.
>
>

Yep

>That effect is to cause the whole world to be swapped out when people
>return to their machines in the morning.  Once they're swapped back in the
>first thing they do it send bitchy emails to you know who.
>
>>From a performance perspective it's the right thing to do, but nobody likes
>it.
>
>

Yeah. I wonder if there is a way to be smarter about dropping these
used once pages without putting pressure on more permanent pages...
I guess all heuristics will fall down somewhere or other.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
