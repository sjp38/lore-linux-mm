Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 77AD16B0008
	for <linux-mm@kvack.org>; Mon,  7 May 2018 20:16:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 142so2140982wmt.1
        for <linux-mm@kvack.org>; Mon, 07 May 2018 17:16:53 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id f11-v6si1261912edn.256.2018.05.07.17.16.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 May 2018 17:16:52 -0700 (PDT)
Date: Mon, 7 May 2018 17:16:36 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH v9 0/9] dax: fix dma vs truncate/hole-punch
Message-ID: <20180508001636.GM4141@magnolia>
References: <152461278149.17530.2867511144531572045.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAPcyv4ihoGPJWA4X7V0h4BsX9_+4AXdHF=bmb==8iQMfc94YMQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4ihoGPJWA4X7V0h4BsX9_+4AXdHF=bmb==8iQMfc94YMQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Mike Snitzer <snitzer@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Linux MM <linux-mm@kvack.org>, Christoph Hellwig <hch@lst.de>, Thomas Meyer <thomas@m3y3r.de>, kbuild test robot <lkp@intel.com>, Alasdair Kergon <agk@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <mawilcox@microsoft.com>, stable <stable@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, May 03, 2018 at 04:53:18PM -0700, Dan Williams wrote:
> On Tue, Apr 24, 2018 at 4:33 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> > Changes since v8 [1]:
> > * Rebase on v4.17-rc2
> >
> > * Fix get_user_pages_fast() for ZONE_DEVICE pages to revalidate the pte,
> >   pmd, pud after taking references (Jan)
> >
> > * Kill dax_layout_lock(). With get_user_pages_fast() for ZONE_DEVICE
> >   fixed we can then rely on the {pte,pmd}_lock to synchronize
> >   dax_layout_busy_page() vs new page references (Jan)
> >
> > * Hold the iolock over repeated invocations of dax_layout_busy_page() to
> >   enable truncate/hole-punch to make forward progress in the presence of
> >   a constant stream of new direct-I/O requests (Jan).
> >
> > [1]: https://lists.01.org/pipermail/linux-nvdimm/2018-March/015058.html
> 
> I'll push this for soak time in -next if there are no further comments...

I don't have any. :D

--D
