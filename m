Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id B2EC36B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 09:37:16 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id j11-v6so8387297ywi.6
        for <linux-mm@kvack.org>; Mon, 21 May 2018 06:37:16 -0700 (PDT)
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id s129-v6si3395022ywb.183.2018.05.21.06.37.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 May 2018 06:37:15 -0700 (PDT)
Date: Mon, 21 May 2018 13:37:14 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [LSFMM] RDMA data corruption potential during FS writeback
In-Reply-To: <20180519032400.GA12517@ziepe.ca>
Message-ID: <0100016382eb15e3-ce5d246f-1f88-401b-8a19-9a59f9707fe5-000000@email.amazonses.com>
References: <0100016373af827b-e6164b8d-f12e-4938-bf1f-2f85ec830bc0-000000@email.amazonses.com> <20180518154945.GC15611@ziepe.ca> <0100016374267882-16b274b1-d6f6-4c13-94bb-8e78a51e9091-000000@email.amazonses.com> <20180518173637.GF15611@ziepe.ca>
 <CAPcyv4i_W94iXCyOd8gSSU6kWscncz5KUqnuzZ_RdVW9UT2U3w@mail.gmail.com> <c8861cbb-5b2e-d6e2-9c89-66c5c92181e6@nvidia.com> <20180519032400.GA12517@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, linux-rdma <linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>

On Fri, 18 May 2018, Jason Gunthorpe wrote:

> Ummm, RDMA has done essentially that since 2005, since when did it
> become wrong? Do you have some references? Is there some alternative?

It was wrong from the start. It became much more evident with widespread
use of RDMA. The inability to scale processor performance at this point
but the huge increase in network bandwidth available forces users into
RDMA solution. Thus they will try to do RDMA to file backed mappings where
in the past we only used anonymous memory for RDMA.
