Date: Fri, 23 May 2008 12:40:41 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch 08/18] hugetlb: multi hstate sysctls
Message-ID: <20080523104041.GF31727@one.firstfloor.org>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.487393000@nick.local0.net> <20080425233536.GA31226@us.ibm.com> <20080523052856.GI13071@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080523052856.GI13071@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

> > Could this same condition be added to the overcommit handler, please?
> 
> Sure thing.

I left that out intentionally because it didn't seem useful to me.

-Andi

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
