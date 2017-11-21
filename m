Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id C20616B0038
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 18:26:27 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id f28so7660638otd.12
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 15:26:27 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w79sor4889053oiw.296.2017.11.21.15.26.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Nov 2017 15:26:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171121150501.d4d811a66444cb5c9cb85bf2@linux-foundation.org>
References: <151068938905.7446.12333914805308312313.stgit@dwillia2-desk3.amr.corp.intel.com>
 <151068939435.7446.13560129395419350737.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171121150501.d4d811a66444cb5c9cb85bf2@linux-foundation.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 21 Nov 2017 15:26:26 -0800
Message-ID: <CAPcyv4jRqkwdVZrRnMcvAq1OJ0+DpHFQ6yhXhgN-ts1HMF1Nfw@mail.gmail.com>
Subject: Re: [PATCH v2 1/4] mm: introduce get_user_pages_longterm
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Tue, Nov 21, 2017 at 3:05 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> On Tue, 14 Nov 2017 11:56:34 -0800 Dan Williams <dan.j.williams@intel.com> wrote:
>
> > Until there is a solution to the dma-to-dax vs truncate problem it is
> > not safe to allow long standing memory registrations against
> > filesytem-dax vmas. Device-dax vmas do not have this problem and are
> > explicitly allowed.
> >
> > This is temporary until a "memory registration with layout-lease"
> > mechanism can be implemented for the affected sub-systems (RDMA and
> > V4L2).
>
> Sounds like that will be unpleasant.  Do we really need it to be that
> complex?  Can we get away with simply failing the get_user_pages()
> request?  Or are there significant usecases for RDMA and V4L to play
> with DAX memory?

V4L plus DAX is indeed dubious, but RDMA to persistent memory is
something the RDMA community is interested in supporting [1].

[1]: http://www.snia.org/sites/default/files/SDC15_presentations/persistant_mem/ChetDouglas_RDMA_with_PM.pdf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
