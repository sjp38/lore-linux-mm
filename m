Date: Sun, 1 Aug 2004 23:33:04 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] token based thrashing control
In-Reply-To: <410DAC89.4000002@kolivas.org>
Message-ID: <Pine.LNX.4.58.0408012332080.13053@dhcp030.home.surriel.com>
References: <Pine.LNX.4.58.0407301730440.9228@dhcp030.home.surriel.com>
 <Pine.LNX.4.58.0408010856240.13053@dhcp030.home.surriel.com>
 <20040801175618.711a3aac.akpm@osdl.org> <410DAC89.4000002@kolivas.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, sjiang@cs.wm.edu, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2 Aug 2004, Con Kolivas wrote:

> We have some results that need interpreting with contest.
> mem_load:
> Kernel    [runs]	Time	CPU%	Loads	LCPU%	Ratio
> 2.6.8-rc2      4	78	146.2	94.5	4.7	1.30
> 2.6.8-rc2t     4	318	40.9	95.2	1.3	5.13
> 
> The "load" with mem_load is basically trying to allocate 110% of free 
> ram, so the number of "loads" although similar is not a true indication 
> of how much ram was handed out to mem_load. What is interesting is that 
> since mem_load runs continuously and constantly asks for too much ram it 
> seems to be receiving the token most frequently in preference to the cc 
> processes which are short lived. I'd say it is quite hard to say 
> convincingly that this is bad because the point of this patch is to 
> prevent swap thrash.

It may be worth trying with a shorter token timeout
time - maybe even keeping the long ineligibility ?

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
