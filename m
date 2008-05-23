Date: Fri, 23 May 2008 12:43:27 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch 17/18] x86: add hugepagesz option on 64-bit
Message-ID: <20080523104327.GG31727@one.firstfloor.org>
References: <20080423015302.745723000@nick.local0.net> <20080423015431.462123000@nick.local0.net> <20080430204841.GD6903@us.ibm.com> <20080523054133.GO13071@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080523054133.GO13071@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

> For that matter, I'm almost inclined to submit the patchset with
> only allow one active hstate specified on the command line, and no
> changes to any sysctls... just to get the core code merged sooner ;)

If you do that you don't really need to bother with the patchset.
I had an earlier patch for GB pages in hugetlbfs that only supported
a single page size and it was much much simpler. All the work just came
from supporting multiple page sizes for binary compatibility.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
