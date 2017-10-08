Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id A0A666B025E
	for <linux-mm@kvack.org>; Sun,  8 Oct 2017 11:49:35 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id s185so10544351oif.3
        for <linux-mm@kvack.org>; Sun, 08 Oct 2017 08:49:35 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e19sor1690128otj.185.2017.10.08.08.49.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 08 Oct 2017 08:49:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201710081447.sQSonloO%fengguang.wu@intel.com>
References: <150743537023.13602.3520782942682280917.stgit@dwillia2-desk3.amr.corp.intel.com>
 <201710081447.sQSonloO%fengguang.wu@intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 8 Oct 2017 08:49:33 -0700
Message-ID: <CAPcyv4iJTkDDNHsAyZCyh5E2X_68RsYkOKP3bXtEzgUrvLh2ew@mail.gmail.com>
Subject: Re: [PATCH v8 2/2] IB/core: use MAP_DIRECT to fix / enable RDMA to
 DAX mappings
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Sean Hefty <sean.hefty@intel.com>, linux-xfs@vger.kernel.org, Jan Kara <jack@suse.cz>, Ashok Raj <ashok.raj@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, linux-rdma@vger.kernel.org, Linux API <linux-api@vger.kernel.org>, Joerg Roedel <joro@8bytes.org>, Dave Chinner <david@fromorbit.com>, Jeff Moyer <jmoyer@redhat.com>, iommu@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>, Linux MM <linux-mm@kvack.org>, Doug Ledford <dledford@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jeff Layton <jlayton@poochiereds.net>, David Woodhouse <dwmw2@infradead.org>, Hal Rosenstock <hal.rosenstock@gmail.com>

On Sat, Oct 7, 2017 at 11:45 PM, kbuild test robot <lkp@intel.com> wrote:
> Hi Dan,
>
> [auto build test ERROR on rdma/master]
> [also build test ERROR on v4.14-rc3 next-20170929]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

This was a fixed up resend of patch [v7 11/12]. It's not clear how to
teach the kbuild robot to be aware of patch-replies to individual
patches in the series. I.e. reworked patches without resending the
complete series?

> url:    https://github.com/0day-ci/linux/commits/Dan-Williams/iommu-up-level-sg_num_pages-from-amd-iommu/20171008-133505
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/dledford/rdma.git master
> config: i386-randconfig-n0-201741 (attached as .config)
> compiler: gcc-4.8 (Debian 4.8.4-1) 4.8.4
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386
>
> All errors (new ones prefixed by >>):
>
>>> drivers/infiniband/core/umem.c:39:29: fatal error: linux/mapdirect.h: No such file or directory
>     #include <linux/mapdirect.h>

mapdirect.h indeed does not exist when missing the earlier patches in
the series. It would be slick if the 0day-robot read the the
"in-reply-to" header and auto replaced a patch in a series, but that
would be a feature approaching magic.

>    compilation terminated.
>
> vim +39 drivers/infiniband/core/umem.c
>
>   > 39  #include <linux/mapdirect.h>
>     40  #include <linux/export.h>
>     41  #include <linux/hugetlb.h>
>     42  #include <linux/slab.h>
>     43  #include <rdma/ib_umem_odp.h>
>     44
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
