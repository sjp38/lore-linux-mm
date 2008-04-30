Date: Wed, 30 Apr 2008 22:19:32 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch 17/18] x86: add hugepagesz option on 64-bit
Message-ID: <20080430201932.GH20451@one.firstfloor.org>
References: <20080423015302.745723000@nick.local0.net> <20080423015431.462123000@nick.local0.net> <20080430193416.GE8597@us.ibm.com> <20080430195237.GE20451@one.firstfloor.org> <20080430200249.GA6903@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080430200249.GA6903@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

> Then let's just merge whatever we'd like all the time? Why have review
> at all?

Looking for bugs and problems is good, but to be honest many of your comments 
like more like
"nit picking until it looks exactly what I would have written" 
and that is not the purpose of a review.

> 
> To quote Nick from a separate discussion on similar future-proofing:
> 
> "Let's really try to put some thought into new sysfs locations. Not just
> will it work, but is it logical and will it work tomorrow..."

ABIs are different from code, they have to be more future proof because
changing them has more impact (although that seems to be commonly ignored in 
sysfs)

> infrastructure we have in place, where it claims to be generic and

The hugetlbfs code actually doesn't claim that.

> usable by architectures (as has been my impression from the discussions
> so far -- that it is extensible to other architectures), I want to be
> sure that is really the case.

It is with some future changes, but there is no need to do them for 
the initial merge, but they can be done as additional architectures
are added.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
