Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id D39AD6B0005
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 13:51:21 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id c3-v6so15436729qkb.2
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 10:51:21 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id n10-v6si15088047qtn.198.2018.06.18.10.51.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 10:51:21 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: set PG_dma_pinned on get_user_pages*()
References: <20180617012510.20139-1-jhubbard@nvidia.com>
 <20180617012510.20139-3-jhubbard@nvidia.com>
 <CAPcyv4i=eky-QrPcLUEqjsASuRUrFEWqf79hWe0mU8xtz6Jk-w@mail.gmail.com>
 <20180617200432.krw36wrcwidb25cj@ziepe.ca>
 <CAPcyv4gayKk_zHDYAvntware12qMXWjnnL_FDJNUQsJS_zNfDw@mail.gmail.com>
 <311eba48-60f1-b6cc-d001-5cc3ed4d76a9@nvidia.com>
 <20180618081258.GB16991@lst.de>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <d4817192-6db0-2f3f-7c67-6078b69686d3@nvidia.com>
Date: Mon, 18 Jun 2018 10:50:57 -0700
MIME-Version: 1.0
In-Reply-To: <20180618081258.GB16991@lst.de>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>, Jason Gunthorpe <jgg@ziepe.ca>, john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jan Kara <jack@suse.cz>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>

On 06/18/2018 01:12 AM, Christoph Hellwig wrote:
> On Sun, Jun 17, 2018 at 01:28:18PM -0700, John Hubbard wrote:
>> Yes. However, my thinking was: get_user_pages() can become a way to indicate that 
>> these pages are going to be treated specially. In particular, the caller
>> does not really want or need to support certain file operations, while the
>> page is flagged this way.
>>
>> If necessary, we could add a new API call.
> 
> That API call is called get_user_pages_longterm.

OK...I had the impression that this was just semi-temporary API for dax, but
given that it's an exported symbol, I guess it really is here to stay.

Anyway, are you thinking that we could set the new page flag here? Or just pointing
out that the other get_user_pages* variants are the wrong place?
