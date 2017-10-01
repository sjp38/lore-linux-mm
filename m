Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 393F96B0033
	for <linux-mm@kvack.org>; Sun,  1 Oct 2017 19:15:09 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id y64so4059597oia.3
        for <linux-mm@kvack.org>; Sun, 01 Oct 2017 16:15:09 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o36sor1856838ota.335.2017.10.01.16.15.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 01 Oct 2017 16:15:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171001215959.GF15067@dastard>
References: <150664806143.36094.11882924009668860273.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171001075701.GB11554@lst.de> <CAPcyv4gKYOdDP_jYJvPaozaOBkuVa-cf8x6TGEbEhzNfxaxhGw@mail.gmail.com>
 <20171001211147.GE15067@dastard> <CAPcyv4hLgGb0sO1=qGxt83zumKt82RA8dUr=_1Gaqew7hxajXg@mail.gmail.com>
 <20171001215959.GF15067@dastard>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 1 Oct 2017 16:15:06 -0700
Message-ID: <CAPcyv4id1u=DH733rE0AiVDL0q5-53Hs5GRCnEEJNN_Svs0-WQ@mail.gmail.com>
Subject: Re: [PATCH v2 0/4] dax: require 'struct page' and other fixups
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Sun, Oct 1, 2017 at 2:59 PM, Dave Chinner <david@fromorbit.com> wrote:
[..]
> The "capacity tax" had nothing to do with it - the major problem
> with self hosting struct pages was that page locks can be hot and
> contention on them will rapidly burn through write cycles on the
> pmem. That's still a problem, yes?

It was an early concern we had, but it has not born out in practice,
and stopped worrying about it 2 years ago when the ZONE_DEVICE
infrastructure was merged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
