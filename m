Date: Thu, 23 Jun 2005 23:05:25 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc5 5/10] mm: manual page migration-rc3 -- sys_migrate_pages-mempolicy-migration-rc3.patch
Message-ID: <20050623210524.GN14251@wotan.suse.de>
References: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com> <20050622163941.25515.38103.92916@tomahawk.engr.sgi.com> <20050623015121.GI14251@wotan.suse.de> <42BB22C3.7070602@engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42BB22C3.7070602@engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@engr.sgi.com>
Cc: Andi Kleen <ak@suse.de>, Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Christoph Hellwig <hch@infradead.org>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, lhms-devel@lists.sourceforge.net, Paul Jackson <pj@sgi.com>, Nathan Scott <nathans@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 23, 2005 at 03:59:47PM -0500, Ray Bryant wrote:
> No, it looks like I dropped the ball there.  I thought that the
> vma->vm_policy field was used in that case as well, but it appears
> that the policy is looked up in the tree every time it is used.
> (Can that be right?)  If so, I need to do something else.

Yes, it's like this. I had it originally in vm_policy in this case,
but there were too many corner cases to handle when changing policies
(splitting VMAs of remote processes when a policy is changedetc.), so I 
eventually settled on this.

On the other hand tmpfs is not really memory belonging to a single
process only so it is not clear if process migration should touch
should a shared resource.

> A simple solution to this would be to delete that BUG_ON().  :-)
> (Is this required?  It looks almost like a debugging statement.)

Yes, removing it would be fine.

> I don't see any other BUG() calls that could be tripped by changing
> the node mask underneath a process that is actively allocating
> storage, at least not in mempolicy.c.  Am I overlooking something?

Don't think so.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
