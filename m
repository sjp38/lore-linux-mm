Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 355F06B0006
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 01:55:59 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id w74-v6so18156614qka.4
        for <linux-mm@kvack.org>; Sun, 01 Jul 2018 22:55:59 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 88-v6si441507qta.172.2018.07.01.22.55.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jul 2018 22:55:58 -0700 (PDT)
Subject: Re: [PATCH v2 0/6] mm/fs: gup: don't unmap or drop filesystem buffers
References: <20180702005654.20369-1-jhubbard@nvidia.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <011e8d10-1851-a4e2-991c-1f428317a963@nvidia.com>
Date: Sun, 1 Jul 2018 22:54:55 -0700
MIME-Version: 1.0
In-Reply-To: <20180702005654.20369-1-jhubbard@nvidia.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On 07/01/2018 05:56 PM, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 

There were some typos in patches #4 and #5, which I've fixed locally.
Let me know if anyone would like me to repost with those right away, otherwise
I'll wait for other review besides the kbuild test robot.

Meanwhile, for convenience, you can pull down the latest version of the
patchset from:

    git@github.com:johnhubbard/linux (branch: gup_dma_next)


thanks,
-- 
John Hubbard
NVIDIA
