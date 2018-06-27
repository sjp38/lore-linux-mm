Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C308B6B000A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 07:59:30 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id j11-v6so1246350edr.15
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 04:59:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o10-v6si2040516edh.451.2018.06.27.04.59.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jun 2018 04:59:29 -0700 (PDT)
Date: Wed, 27 Jun 2018 13:59:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
Message-ID: <20180627115927.GQ32348@dhcp22.suse.cz>
References: <311eba48-60f1-b6cc-d001-5cc3ed4d76a9@nvidia.com>
 <20180618081258.GB16991@lst.de>
 <d4817192-6db0-2f3f-7c67-6078b69686d3@nvidia.com>
 <CAPcyv4iacHYxGmyWokFrVsmxvLj7=phqp2i0tv8z6AT-mYuEEA@mail.gmail.com>
 <3898ef6b-2fa0-e852-a9ac-d904b47320d5@nvidia.com>
 <CAPcyv4iRBzmwWn_9zDvqdfVmTZL_Gn7uA_26A1T-kJib=84tvA@mail.gmail.com>
 <20180626134757.GY28965@dhcp22.suse.cz>
 <20180626164825.fz4m2lv6hydbdrds@quack2.suse.cz>
 <20180627113221.GO32348@dhcp22.suse.cz>
 <20180627115349.cu2k3ainqqdrrepz@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180627115349.cu2k3ainqqdrrepz@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>, John Hubbard <jhubbard@nvidia.com>, Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@ziepe.ca>, John Hubbard <john.hubbard@gmail.com>, Matthew Wilcox <willy@infradead.org>, Christopher Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>

On Wed 27-06-18 13:53:49, Jan Kara wrote:
> On Wed 27-06-18 13:32:21, Michal Hocko wrote:
[...]
> > Appart from that, do we really care about 32b here? Big DIO, IB users
> > seem to be 64b only AFAIU.
> 
> IMO it is a bad habit to leave unpriviledged-user-triggerable oops in the
> kernel even for uncommon platforms...

Absolutely agreed! I didn't mean to keep the blow up for 32b. I just
wanted to say that we can stay with a simple solution for 32b. I thought
the g-u-p-longterm has plugged the most obvious breakage already. But
maybe I just misunderstood.
-- 
Michal Hocko
SUSE Labs
