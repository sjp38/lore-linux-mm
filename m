Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B454D6B0069
	for <linux-mm@kvack.org>; Sun, 15 Oct 2017 17:59:08 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q132so7714038wmd.22
        for <linux-mm@kvack.org>; Sun, 15 Oct 2017 14:59:08 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id n16si4822953wrb.385.2017.10.15.14.59.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Oct 2017 14:59:07 -0700 (PDT)
Date: Sun, 15 Oct 2017 08:58:56 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
Message-ID: <20171015065856.GC3916@xo-6d-61-c0.localdomain>
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com>
 <20171012014611.18725-1-mike.kravetz@oracle.com>
 <20171012014611.18725-4-mike.kravetz@oracle.com>
 <20171012143756.p5bv4zx476qkmqhh@dhcp22.suse.cz>
 <f4a46a19-5f71-ebcc-3098-a35728fbfd03@oracle.com>
 <20171013084054.me3kxhgbxzgm2lpr@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131015420.3949@nuc-kabylake>
 <20171013152801.nbpk6nluotgbmfrs@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131040570.4247@nuc-kabylake>
 <20171013154747.2jv7rtfqyyagiodn@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171013154747.2jv7rtfqyyagiodn@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christopher Lameter <cl@linux.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

Hi!

> Yes you wrote that already and my counter argument was that this generic
> posix interface shouldn't bypass virtual memory abstraction.
> 
> > > > The contiguous allocations are particularly useful for the RDMA API which
> > > > allows registering user space memory with devices.
> > >
> > > then make those devices expose an implementation of an mmap which does
> > > that. You would get both a proper access control (via fd), accounting
> > > and others.
> > 
> > There are numerous RDMA devices that would all need the mmap
> > implementation. And this covers only the needs of one subsystem. There are
> > other use cases.
> 
> That doesn't prevent providing a library function which could be reused
> by all those drivers. Nothing really too much different from
> remap_pfn_range.

So you'd suggest using ioctl() for allocating memory?

That sounds quite ugly to me... mmap(MAP_CONTIG) is not nice, either, but better than
each driver inventing custom interface...
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
