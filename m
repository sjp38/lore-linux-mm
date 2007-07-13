Date: Fri, 13 Jul 2007 14:47:54 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 5/5] [hugetlb] Try to grow pool for MAP_SHARED mappings
In-Reply-To: <b040c32a0707131438q64b7f526x6805ec3ee1d0c190@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0707131445010.25594@schroedinger.engr.sgi.com>
References: <20070713151621.17750.58171.stgit@kernel>
 <20070713151717.17750.44865.stgit@kernel>  <20070713130508.6f5b9bbb.pj@sgi.com>
  <1184360742.16671.55.camel@localhost.localdomain>
 <Pine.LNX.4.64.0707131427140.25414@schroedinger.engr.sgi.com>
 <b040c32a0707131438q64b7f526x6805ec3ee1d0c190@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Adam Litke <agl@us.ibm.com>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, mel@skynet.ie, apw@shadowen.org, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jul 2007, Ken Chen wrote:

> > since it requires the serialization of the hugetlb faults. Could we please
> > get this straigthened out? This serialization somehow snuck in when I was
> > not looking and it screws up multiple things.
> 
> Sadly, global serialization has some nice property.  It is now used in
> three paths that I'm aware of:
> (1) shared mapping reservation count
> (2) linked list protection in unmap_hugepage_range
> (3) shared page table on hugetlb mapping.
> 
> i suppose (2) and (3) can be moved into per-inode lock?

Could we just leave the reservation system off and just enable it when 
something like DB2 runs that needs it?

We should be using standard locking conventions for regular 
pages as much as possible.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
