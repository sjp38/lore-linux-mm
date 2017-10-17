Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BBD446B0253
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 06:59:28 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m18so1245820pgd.13
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 03:59:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v9si4516034pgt.770.2017.10.17.03.59.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 03:59:27 -0700 (PDT)
Date: Tue, 17 Oct 2017 12:59:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
Message-ID: <20171017105921.4w7rba2day3k4g4p@dhcp22.suse.cz>
References: <20171013152801.nbpk6nluotgbmfrs@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131040570.4247@nuc-kabylake>
 <20171013154747.2jv7rtfqyyagiodn@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131053450.4400@nuc-kabylake>
 <20171013161736.htumyr4cskfrjq64@dhcp22.suse.cz>
 <752b49eb-55c6-5a34-ab41-6e91dd93ea70@mellanox.com>
 <20171016082456.no6ux63uy2rmj4fe@dhcp22.suse.cz>
 <0e238c56-c59d-f648-95fc-c8cb56c3652e@mellanox.com>
 <20171016123248.csntl6luxgafst6q@dhcp22.suse.cz>
 <AM6PR0502MB378375AF8B569DBCCFE20D7DBD4C0@AM6PR0502MB3783.eurprd05.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AM6PR0502MB378375AF8B569DBCCFE20D7DBD4C0@AM6PR0502MB3783.eurprd05.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guy Shattah <sguy@mellanox.com>
Cc: Christopher Lameter <cl@linux.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

On Tue 17-10-17 10:50:02, Guy Shattah wrote:
[...]
> > Well, we can provide a generic library functions for your driver to use so that
> > you do not have to care about implementation details but I do not think
> > exposing this API to the userspace in a generic fashion is a good idea.
> > Especially when the only usecase that has been thought through so far seems
> > to be a very special HW optimiztion.
> 
> Are you going to be OK with kernel API which implements contiguous
> memory allocation?

We already do have alloc_contig_range. It is a dumb allocator so it is
not very suitable for short term allocations.

> Possibly with mmap style?  Many drivers could utilize it instead of
> having their own weird and possibly non-standard way to allocate
> contiguous memory.  Such API won't be available for user space.

Yes, an mmap helper which performs and enforces some accounting would be a
good start.

> We can begin with implementing kernel API and postpone the userspace
> api discussion for a future date. if it is sufficient. We might not
> have to discuss it at all.

Yeah, that was my thinking as well.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
