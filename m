Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id D8F736B02FD
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 06:07:22 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g71so10281477wmg.13
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 03:07:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t109si4176029wrc.548.2017.07.26.03.07.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 26 Jul 2017 03:07:21 -0700 (PDT)
Date: Wed, 26 Jul 2017 12:07:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/3] mm: shm: Use new hugetlb size encoding
 definitions
Message-ID: <20170726100718.GG2981@dhcp22.suse.cz>
References: <20170328175408.GD7838@bombadil.infradead.org>
 <1500330481-28476-1-git-send-email-mike.kravetz@oracle.com>
 <1500330481-28476-4-git-send-email-mike.kravetz@oracle.com>
 <20170726095338.GF2981@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170726095338.GF2981@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, akpm@linux-foundation.org, ak@linux.intel.com, mtk.manpages@gmail.com, Davidlohr Bueso <dbueso@suse.de>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com

On Wed 26-07-17 11:53:38, Michal Hocko wrote:
> On Mon 17-07-17 15:28:01, Mike Kravetz wrote:
> > Use the common definitions from hugetlb_encode.h header file for
> > encoding hugetlb size definitions in shmget system call flags.  In
> > addition, move these definitions to the from the internal to user
> > (uapi) header file.
> 
> s@to the from@from@
> 
> > 
> > Suggested-by: Matthew Wilcox <willy@infradead.org>
> > Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> 
> with s@HUGETLB_FLAG_ENCODE__16GB@HUGETLB_FLAG_ENCODE_16GB@
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Btw. man page mentions only 2MB and 1GB, we should document others and
note that each arch might support only subset of them

> > +#define MAP_HUGE_512KB	HUGETLB_FLAG_ENCODE_512KB
> > +#define MAP_HUGE_1MB	HUGETLB_FLAG_ENCODE_1MB
> > +#define MAP_HUGE_2MB	HUGETLB_FLAG_ENCODE_2MB
> > +#define MAP_HUGE_8MB	HUGETLB_FLAG_ENCODE_8MB
> > +#define MAP_HUGE_16MB	HUGETLB_FLAG_ENCODE_16MB
> > +#define MAP_HUGE_1GB	HUGETLB_FLAG_ENCODE_1GB
> > +#define MAP_HUGE_16GB	HUGETLB_FLAG_ENCODE__16GB
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
