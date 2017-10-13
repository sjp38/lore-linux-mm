Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E7B816B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 11:28:07 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id h191so6202993wmd.15
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 08:28:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w18si1006484wra.552.2017.10.13.08.28.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Oct 2017 08:28:05 -0700 (PDT)
Date: Fri, 13 Oct 2017 17:28:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
Message-ID: <20171013152801.nbpk6nluotgbmfrs@dhcp22.suse.cz>
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com>
 <20171012014611.18725-1-mike.kravetz@oracle.com>
 <20171012014611.18725-4-mike.kravetz@oracle.com>
 <20171012143756.p5bv4zx476qkmqhh@dhcp22.suse.cz>
 <f4a46a19-5f71-ebcc-3098-a35728fbfd03@oracle.com>
 <20171013084054.me3kxhgbxzgm2lpr@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131015420.3949@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1710131015420.3949@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

On Fri 13-10-17 10:20:06, Cristopher Lameter wrote:
> On Fri, 13 Oct 2017, Michal Hocko wrote:
[...]
> > I am not really convinced this is a good interface. You are basically
> > trying to bypass virtual memory abstraction and that is quite
> > contradicting the mmap API to me.
> 
> This is a standardized posix interface as described in our presentation at
> the plumbers conference. See the presentation on contiguous allocations.

Are you trying to desing a generic interface with a very specific and HW
dependent usecase in mind?
 
> The contiguous allocations are particularly useful for the RDMA API which
> allows registering user space memory with devices.

then make those devices expose an implementation of an mmap which does
that. You would get both a proper access control (via fd), accounting
and others.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
