Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C6E356B0038
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 18:47:42 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id m18so3646376wrm.11
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 15:47:42 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h77si8918706wma.152.2017.10.02.15.47.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 15:47:41 -0700 (PDT)
Date: Mon, 2 Oct 2017 15:47:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 0/4] dax: require 'struct page' and other fixups
Message-Id: <20171002154739.81f24874d93a336890851442@linux-foundation.org>
In-Reply-To: <CAPcyv4id1u=DH733rE0AiVDL0q5-53Hs5GRCnEEJNN_Svs0-WQ@mail.gmail.com>
References: <150664806143.36094.11882924009668860273.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20171001075701.GB11554@lst.de>
	<CAPcyv4gKYOdDP_jYJvPaozaOBkuVa-cf8x6TGEbEhzNfxaxhGw@mail.gmail.com>
	<20171001211147.GE15067@dastard>
	<CAPcyv4hLgGb0sO1=qGxt83zumKt82RA8dUr=_1Gaqew7hxajXg@mail.gmail.com>
	<20171001215959.GF15067@dastard>
	<CAPcyv4id1u=DH733rE0AiVDL0q5-53Hs5GRCnEEJNN_Svs0-WQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Sun, 1 Oct 2017 16:15:06 -0700 Dan Williams <dan.j.williams@intel.com> wrote:

> On Sun, Oct 1, 2017 at 2:59 PM, Dave Chinner <david@fromorbit.com> wrote:
> [..]
> > The "capacity tax" had nothing to do with it - the major problem
> > with self hosting struct pages was that page locks can be hot and
> > contention on them will rapidly burn through write cycles on the
> > pmem. That's still a problem, yes?
> 
> It was an early concern we had, but it has not born out in practice,
> and stopped worrying about it 2 years ago when the ZONE_DEVICE
> infrastructure was merged.

These are weighty matters and should have been covered in the
changelogs, please.  Could you send along a few paragraphs which
summarise these thoughts and I'll add them in?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
