Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 415A96B0253
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 02:59:50 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id q42so360228wrb.3
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 23:59:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 76si6380842wml.118.2017.10.16.23.59.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Oct 2017 23:59:48 -0700 (PDT)
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
References: <f4a46a19-5f71-ebcc-3098-a35728fbfd03@oracle.com>
 <20171013084054.me3kxhgbxzgm2lpr@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131015420.3949@nuc-kabylake>
 <20171013152801.nbpk6nluotgbmfrs@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131040570.4247@nuc-kabylake>
 <20171013154747.2jv7rtfqyyagiodn@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131053450.4400@nuc-kabylake>
 <20171013161736.htumyr4cskfrjq64@dhcp22.suse.cz>
 <752b49eb-55c6-5a34-ab41-6e91dd93ea70@mellanox.com>
 <aff6b405-6a06-f84d-c9b1-c6fb166dff81@oracle.com>
 <20171016180749.2y2v4ucchb33xnde@dhcp22.suse.cz>
 <e8cf6227-003d-8a82-8b4d-07176b43810c@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <704611ff-2fb0-9b99-6edb-b050e3d1e850@suse.cz>
Date: Tue, 17 Oct 2017 08:59:41 +0200
MIME-Version: 1.0
In-Reply-To: <e8cf6227-003d-8a82-8b4d-07176b43810c@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Michal Hocko <mhocko@kernel.org>
Cc: Guy Shattah <sguy@mellanox.com>, Christopher Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>

On 10/16/2017 10:32 PM, Mike Kravetz wrote:
> Agree.  I only wanted to point out the similarities.
> But, it does make me wonder how much of a benefit hugetlb 1G pages would
> make in the the RDMA performance comparison.  The table in the presentation
> show a average speedup of something like 27% (or so) for contiguous allocation
> which I assume are 2GB in size.  Certainly, using hugetlb is not the ideal
> case, just wondering if it does help and how much.

Good point. If somebody cares about performance benefits of contiguous
memory wrt device access, they would probably want also the TLB
performance benefits of huge pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
