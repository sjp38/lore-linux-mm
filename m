Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 87D086B000C
	for <linux-mm@kvack.org>; Thu,  3 May 2018 19:53:20 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id h70-v6so11068649oib.21
        for <linux-mm@kvack.org>; Thu, 03 May 2018 16:53:20 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g7-v6sor3161943oia.229.2018.05.03.16.53.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 May 2018 16:53:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <152461278149.17530.2867511144531572045.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152461278149.17530.2867511144531572045.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 3 May 2018 16:53:18 -0700
Message-ID: <CAPcyv4ihoGPJWA4X7V0h4BsX9_+4AXdHF=bmb==8iQMfc94YMQ@mail.gmail.com>
Subject: Re: [PATCH v9 0/9] dax: fix dma vs truncate/hole-punch
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm <linux-nvdimm@lists.01.org>
Cc: Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Mike Snitzer <snitzer@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Linux MM <linux-mm@kvack.org>, Christoph Hellwig <hch@lst.de>, Thomas Meyer <thomas@m3y3r.de>, kbuild test robot <lkp@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Alasdair Kergon <agk@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <mawilcox@microsoft.com>, stable <stable@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Apr 24, 2018 at 4:33 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> Changes since v8 [1]:
> * Rebase on v4.17-rc2
>
> * Fix get_user_pages_fast() for ZONE_DEVICE pages to revalidate the pte,
>   pmd, pud after taking references (Jan)
>
> * Kill dax_layout_lock(). With get_user_pages_fast() for ZONE_DEVICE
>   fixed we can then rely on the {pte,pmd}_lock to synchronize
>   dax_layout_busy_page() vs new page references (Jan)
>
> * Hold the iolock over repeated invocations of dax_layout_busy_page() to
>   enable truncate/hole-punch to make forward progress in the presence of
>   a constant stream of new direct-I/O requests (Jan).
>
> [1]: https://lists.01.org/pipermail/linux-nvdimm/2018-March/015058.html

I'll push this for soak time in -next if there are no further comments...
