Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C59356B0003
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 10:57:25 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id b4-v6so1303622wrp.19
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 07:57:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 69-v6sor1552591wmr.63.2018.06.27.07.57.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Jun 2018 07:57:24 -0700 (PDT)
Date: Wed, 27 Jun 2018 08:57:18 -0600
From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
Message-ID: <20180627145718.GB20171@ziepe.ca>
References: <d4817192-6db0-2f3f-7c67-6078b69686d3@nvidia.com>
 <CAPcyv4iacHYxGmyWokFrVsmxvLj7=phqp2i0tv8z6AT-mYuEEA@mail.gmail.com>
 <3898ef6b-2fa0-e852-a9ac-d904b47320d5@nvidia.com>
 <CAPcyv4iRBzmwWn_9zDvqdfVmTZL_Gn7uA_26A1T-kJib=84tvA@mail.gmail.com>
 <20180626134757.GY28965@dhcp22.suse.cz>
 <20180626164825.fz4m2lv6hydbdrds@quack2.suse.cz>
 <20180627113221.GO32348@dhcp22.suse.cz>
 <20180627115349.cu2k3ainqqdrrepz@quack2.suse.cz>
 <20180627115927.GQ32348@dhcp22.suse.cz>
 <20180627124255.np2a6rxy6rb6v7mm@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180627124255.np2a6rxy6rb6v7mm@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <jhubbard@nvidia.com>, Christoph Hellwig <hch@lst.de>, John Hubbard <john.hubbard@gmail.com>, Matthew Wilcox <willy@infradead.org>, Christopher Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>

On Wed, Jun 27, 2018 at 02:42:55PM +0200, Jan Kara wrote:
> On Wed 27-06-18 13:59:27, Michal Hocko wrote:
> > On Wed 27-06-18 13:53:49, Jan Kara wrote:
> > > On Wed 27-06-18 13:32:21, Michal Hocko wrote:
> > [...]
> > > > Appart from that, do we really care about 32b here? Big DIO, IB users
> > > > seem to be 64b only AFAIU.
> > > 
> > > IMO it is a bad habit to leave unpriviledged-user-triggerable oops in the
> > > kernel even for uncommon platforms...
> > 
> > Absolutely agreed! I didn't mean to keep the blow up for 32b. I just
> > wanted to say that we can stay with a simple solution for 32b. I thought
> > the g-u-p-longterm has plugged the most obvious breakage already. But
> > maybe I just misunderstood.
> 
> Most yes, but if you try hard enough, you can still trigger the oops e.g.
> with appropriately set up direct IO when racing with writeback / reclaim.

gup longterm is only different from normal gup if you have DAX and few
people do, which really means it doesn't help at all.. AFAIK??

Jason
