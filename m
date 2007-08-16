Subject: Re: [PATCH] Use MPOL_PREFERRED for system default policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0708161133250.16816@schroedinger.engr.sgi.com>
References: <1187120671.6281.67.camel@localhost>
	 <Pine.LNX.4.64.0708141250200.30703@schroedinger.engr.sgi.com>
	 <1187122156.6281.77.camel@localhost>  <1187122945.6281.92.camel@localhost>
	 <1187274221.5900.27.camel@localhost>
	 <Pine.LNX.4.64.0708161133250.16816@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 16 Aug 2007 15:06:59 -0400
Message-Id: <1187291219.5900.36.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-08-16 at 11:34 -0700, Christoph Lameter wrote:
> On Thu, 16 Aug 2007, Lee Schermerhorn wrote:
> 
> > Given that the mem policy does the right thing with this patch, can we
> > merge it?  I think it cleans up the mem policy concepts to have
> > MPOL_DEFAULT mean "use default policy for this context/scope" rather
> > than have an additional allocation behavior of its own.
> 
> I still have not gotten my head around this one. Lets wait awhile.

Well, it doesn't get much additional testing just sitting in my tree.

I have placed WARN_ON_ONCE() and a fall back to local in the 'default:'
switch cases where I've removed the MPOL_DEFAULT cases.  So, it'll still
have the same behavior while warning us that an MPOL_DEFAULT has snuck
into a struct mempolicy.  There shouldn't be any occurrences of this in
the kernel, once system default policy is changed to MPOL_PREFERRED w/
preferred_node == -1.  I'd sure like to have more testing exposure,
tho'.

Still, if you need more time, please do look at what mpol_new() returns
for MPOL_DEFAULT and how that result gets used.  From my investigations,
system default policy is the only place where MPOL_DEFAULT occurs in a
struct mempolicy.  Well, that and when we return a mempolicy to the kmem
cache--we null out the policy member with MPOL_DEFAULT.  I've "fixed"
that, too.

Later,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
