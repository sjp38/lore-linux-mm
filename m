Date: Fri, 23 May 2008 16:29:56 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch 17/18] x86: add hugepagesz option on 64-bit
Message-ID: <20080523142956.GI31727@one.firstfloor.org>
References: <20080423015302.745723000@nick.local0.net> <20080423015431.462123000@nick.local0.net> <20080430204841.GD6903@us.ibm.com> <20080523054133.GO13071@wotan.suse.de> <20080523104327.GG31727@one.firstfloor.org> <20080523123436.GA25172@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080523123436.GA25172@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, Nishanth Aravamudan <nacc@us.ibm.com>, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

> Oh, maybe you misunderstand what I meant: I think the multiple hugepages
> stuff is nice, and definitely should go in. But I think that if there is
> any more disagreement over the userspace APIs, then we should just merge

What disagreement was there? (sorry didn't notice it)

AFAIK the patchkit does not change any user interfaces except for adding
a few numbers to one line of /proc/meminfo and a few other sysctls which seems 
hardly like a big change
(and calling that a "API" would be making a mountain out of a molehill)

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
