Message-ID: <42837A84.5070307@engr.sgi.com>
Date: Thu, 12 May 2005 10:47:16 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc3 1/8] mm: manual page migration-rc2
 -- xfs-extended-attributes-rc2.patch
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com> <20050511043802.10876.60521.51027@jackhammer.engr.sgi.com> <20050511071538.GA23090@infradead.org> <4281F650.2020807@engr.sgi.com> <20050511195003.GA2468@infradead.org> <4282798F.8060005@engr.sgi.com> <20050512095535.GA14409@infradead.org>
In-Reply-To: <20050512095535.GA14409@infradead.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Jes Sorensen <jes@sgi.com>
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:

> 
> When you talk about files you're already in the special casing business.
> Only few vmas are file-backed and it makes lots of sense to mark an
> anonymous vma non-migratable.
> 
> 

I disagree.  Here's a couple of random cases:

(1)  /bin/bash.  /proc/pid maps shows it has 39 vmas.  30 of them are file
      backed.

(2)  blastwaves (a sample CFD code).  /proc/pid maps shows 49 vmas.  33 of
      them are file backed.

So, it seems to me that most vmas you encounter (by count) are mapped files.
On the other hand, based on size, most pages would be mapped by anonymous vmas 
with the obvious exception being large mapped files.

In all the thinking we've done about page migration, we have never once
come across a case where anonymous vmas shouldn't be migrated.  Can you
describe to me an example where it would be useful to not migrate an
anonymous vma?

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
