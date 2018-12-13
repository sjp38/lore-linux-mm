Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id C92CD8E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 05:25:06 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id y83so1275737qka.7
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 02:25:06 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a2si830774qkj.36.2018.12.13.02.25.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 02:25:06 -0800 (PST)
Date: Thu, 13 Dec 2018 18:24:57 +0800
From: Peter Xu <peterx@redhat.com>
Subject: Re: [PATCH v3] mm: thp: fix flags for pmd migration when split
Message-ID: <20181213102457.GA22285@xz-x1>
References: <20181213051510.20306-1-peterx@redhat.com>
 <20181213095942.3y7lfdwndek6sja4@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181213095942.3y7lfdwndek6sja4@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Dave Jiang <dave.jiang@intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Souptick Joarder <jrdr.linux@gmail.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Zi Yan <zi.yan@cs.rutgers.edu>, linux-mm@kvack.org, stable@vger.kernel.org

On Thu, Dec 13, 2018 at 12:59:42PM +0300, Kirill A. Shutemov wrote:
> On Thu, Dec 13, 2018 at 01:15:10PM +0800, Peter Xu wrote:
> > When splitting a huge migrating PMD, we'll transfer all the existing
> > PMD bits and apply them again onto the small PTEs.  However we are
> > fetching the bits unconditionally via pmd_soft_dirty(), pmd_write()
> > or pmd_yound() while actually they don't make sense at all when it's
> > a migration entry.  Fix them up.  Since at it, drop the ifdef together
> > as not needed.
> > 
> > Note that if my understanding is correct about the problem then if
> > without the patch there is chance to lose some of the dirty bits in
> > the migrating pmd pages (on x86_64 we're fetching bit 11 which is part
> > of swap offset instead of bit 2) and it could potentially corrupt the
> > memory of an userspace program which depends on the dirty bit.
> > 
> > CC: Andrea Arcangeli <aarcange@redhat.com>
> > CC: Andrew Morton <akpm@linux-foundation.org>
> > CC: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > CC: Matthew Wilcox <willy@infradead.org>
> > CC: Michal Hocko <mhocko@suse.com>
> > CC: Dave Jiang <dave.jiang@intel.com>
> > CC: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> > CC: Souptick Joarder <jrdr.linux@gmail.com>
> > CC: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> > CC: Zi Yan <zi.yan@cs.rutgers.edu>
> > CC: linux-mm@kvack.org
> > CC: linux-kernel@vger.kernel.org
> > Signed-off-by: Peter Xu <peterx@redhat.com>
> 
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> Stable?

Sorry I missed the reply from Zi.  I think it should be:

CC: linux-stable <stable@vger.kernel.org> # 4.14+

Thanks,

-- 
Peter Xu
