Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 982206B0006
	for <linux-mm@kvack.org>; Mon, 21 May 2018 09:59:02 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id y127-v6so15371272qka.5
        for <linux-mm@kvack.org>; Mon, 21 May 2018 06:59:02 -0700 (PDT)
Received: from a9-54.smtp-out.amazonses.com (a9-54.smtp-out.amazonses.com. [54.240.9.54])
        by mx.google.com with ESMTPS id j6-v6si4031419qkk.241.2018.05.21.06.59.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 May 2018 06:59:01 -0700 (PDT)
Date: Mon, 21 May 2018 13:59:01 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [LSFMM] RDMA data corruption potential during FS writeback
In-Reply-To: <c8861cbb-5b2e-d6e2-9c89-66c5c92181e6@nvidia.com>
Message-ID: <0100016382ff04b5-3b884d8b-33c5-471e-b7fa-b1c19a3106fe-000000@email.amazonses.com>
References: <0100016373af827b-e6164b8d-f12e-4938-bf1f-2f85ec830bc0-000000@email.amazonses.com> <20180518154945.GC15611@ziepe.ca> <0100016374267882-16b274b1-d6f6-4c13-94bb-8e78a51e9091-000000@email.amazonses.com> <20180518173637.GF15611@ziepe.ca>
 <CAPcyv4i_W94iXCyOd8gSSU6kWscncz5KUqnuzZ_RdVW9UT2U3w@mail.gmail.com> <c8861cbb-5b2e-d6e2-9c89-66c5c92181e6@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Jason Gunthorpe <jgg@ziepe.ca>, linux-rdma <linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>

On Fri, 18 May 2018, John Hubbard wrote:

> > In other words, get_user_pages_longterm() is just a short term
> > band-aid for RDMA until we can get that infrastructure built. We don't
> > need to go down any mmu-notifier rabbit holes.
> >
>
> git grep claims that break_layouts is so far an XFS-only feature, though.
> Were there plans to fix this for all filesystems?

break_layouts? This sounds from my perspective like a mmu notifier
callback with slightly different semantics. Maybe add another callback to
generalize that functionality?
