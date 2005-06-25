Message-ID: <42BCE792.5090507@engr.sgi.com>
Date: Sat, 25 Jun 2005 00:11:46 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc5 5/10] mm: manual page migration-rc3
 -- sys_migrate_pages-mempolicy-migration-rc3.patch
References: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com> <20050622163941.25515.38103.92916@tomahawk.engr.sgi.com> <20050623015121.GI14251@wotan.suse.de> <42BB22C3.7070602@engr.sgi.com> <20050623210524.GN14251@wotan.suse.de>
In-Reply-To: <20050623210524.GN14251@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Christoph Hellwig <hch@infradead.org>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, lhms-devel@lists.sourceforge.net, Paul Jackson <pj@sgi.com>, Nathan Scott <nathans@sgi.com>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:

> 
> On the other hand tmpfs is not really memory belonging to a single
> process only so it is not clear if process migration should touch
> should a shared resource.
> 

I think the way this should work is as follows:  if a VMA maps a
shared object, and it meets the criterion for being a migratable
VMA (e. g. vm_write is set), then we migrate the data and the
policy.

This isn't perfect, since pages in the shared object that are not
mapped won't be migrated.  Perhaps we need a utility to fix that
up after the fact.


-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
