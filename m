Date: Thu, 18 Aug 2005 02:35:49 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 0/4] Demand faunting for huge pages
Message-ID: <20050818003548.GV3996@wotan.suse.de>
References: <1124304966.3139.37.camel@localhost.localdomain> <20050817210431.GR3996@wotan.suse.de> <20050818003302.GE7103@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050818003302.GE7103@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Gibson <david@gibson.dropbear.id.au>
Cc: Andi Kleen <ak@suse.de>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org, christoph@lameter.com, kenneth.w.chen@intel.com
List-ID: <linux-mm.kvack.org>

On Thu, Aug 18, 2005 at 10:33:02AM +1000, David Gibson wrote:
> On Wed, Aug 17, 2005 at 11:04:32PM +0200, Andi Kleen wrote:
> > 
> > What about the overcommit issue Ken noted? It needs to be solved
> > in some way at least, either with the full check or the lazy simple
> > check.
> 
> Hrm... I'm not 100% convinced that just allowing overcommit isn't the
> right thing to do.  Overcommit has some unfortunate consequences, but
> the semantics are clearly defined and trivial to implement.

I disagree. With Linux's primitive hugepage allocation scheme (static
pool that is usually too small) at least simple overcommit check
is absolutely essential.

> Strict accounting leads to nicer behaviour in some cases - you'll tend
> to die early rather than late - but it seems an awful lot of work for
> a fairly small improvement in behaviour.

Strict is a lot of work, but a simple "right in 99% of all cases, but racy" 
check is quite easy.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
