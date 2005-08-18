Date: Thu, 18 Aug 2005 10:33:02 +1000
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH 0/4] Demand faunting for huge pages
Message-ID: <20050818003302.GE7103@localhost.localdomain>
References: <1124304966.3139.37.camel@localhost.localdomain> <20050817210431.GR3996@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050817210431.GR3996@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org, christoph@lameter.com, kenneth.w.chen@intel.com
List-ID: <linux-mm.kvack.org>

On Wed, Aug 17, 2005 at 11:04:32PM +0200, Andi Kleen wrote:
> 
> What about the overcommit issue Ken noted? It needs to be solved
> in some way at least, either with the full check or the lazy simple
> check.

Hrm... I'm not 100% convinced that just allowing overcommit isn't the
right thing to do.  Overcommit has some unfortunate consequences, but
the semantics are clearly defined and trivial to implement.

Strict accounting leads to nicer behaviour in some cases - you'll tend
to die early rather than late - but it seems an awful lot of work for
a fairly small improvement in behaviour.

If we add copy-on-write for hugepages (i.e. MAP_PRIVATE support)
strict accounting is even harder to implement, and has clearly-wrong
behaviour in some circumstances: a process using most of the system's
hugepages, mapped MAP_PRIVATE couldn't fork()/exec() a trivial helper
program.

> Also I still think your get_user_pages approach is questionable.
> 
> -Andi
> 

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/people/dgibson
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
