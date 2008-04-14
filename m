Subject: Re: [PATCH 9/15] Mempolicy: Use MPOL_PREFERRED for system-wide
	default policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080414102321.c737314a.randy.dunlap@oracle.com>
References: <20080404145944.5442.2684.sendpatchset@localhost>
	 <20080404150040.5442.49132.sendpatchset@localhost>
	 <20080414102321.c737314a.randy.dunlap@oracle.com>
Content-Type: text/plain
Date: Mon, 14 Apr 2008 16:05:20 -0400
Message-Id: <1208203520.5453.8.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-numa@vger.kernel.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Mon, 2008-04-14 at 10:23 -0700, Randy Dunlap wrote:
> On Fri, 04 Apr 2008 11:00:40 -0400 Lee Schermerhorn wrote:
> 
> > PATCH 09/15 Mempolicy:  Use MPOL_PREFERRED for system-wide default policy
> > 
> > Against:  2.6.25-rc8-mm1
> > 
> > Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
> > 
> >  Documentation/vm/numa_memory_policy.txt |   52 ++++++++----------------
> >  mm/mempolicy.c                          |   68 +++++++++++++++++++-------------
> >  2 files changed, 59 insertions(+), 61 deletions(-)
> > 
> > Index: linux-2.6.25-rc8-mm1/Documentation/vm/numa_memory_policy.txt
> > ===================================================================
> > --- linux-2.6.25-rc8-mm1.orig/Documentation/vm/numa_memory_policy.txt	2008-04-02 17:47:26.000000000 -0400
> > +++ linux-2.6.25-rc8-mm1/Documentation/vm/numa_memory_policy.txt	2008-04-02 17:47:37.000000000 -0400
> 
> > @@ -187,19 +170,18 @@ Components of Memory Policies
> >  
> >  	MPOL_PREFERRED:  This mode specifies that the allocation should be
> >  	attempted from the single node specified in the policy.  If that
> > -	allocation fails, the kernel will search other nodes, exactly as
> > -	it would for a local allocation that started at the preferred node
> > -	in increasing distance from the preferred node.  "Local" allocation
> > -	policy can be viewed as a Preferred policy that starts at the node
> > +	allocation fails, the kernel will search other nodes, in order of
> > +	increasing distance from the preferred node based on information
> > +	provided by the platform firmware.
> >  	containing the cpu where the allocation takes place.
> 
> Something in the patch lines above seems to be foobarred.
> I.e., the sentences/lines don't flow correctly.

Looks like I forgot to delete the line starting with 'containing ...'.
I'll fix it, along with the 'expecially' in patch 8. [That's not a word,
huh? :)]

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
