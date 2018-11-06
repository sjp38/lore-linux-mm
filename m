Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3B86B02A3
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 21:20:45 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id w17-v6so705726ybe.13
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 18:20:45 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id f79-v6si26264767yba.188.2018.11.05.18.20.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 18:20:44 -0800 (PST)
Date: Mon, 5 Nov 2018 18:20:24 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [RFC PATCH v4 00/13] ktask: multithread CPU-intensive kernel work
Message-ID: <20181106022024.ndn377ze6xljsxkb@ca-dmjordan1.us.oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <FC2EB02D-3D05-4A13-A92E-4171B37B15BA@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <FC2EB02D-3D05-4A13-A92E-4171B37B15BA@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

Hi Zi,

On Mon, Nov 05, 2018 at 01:49:14PM -0500, Zi Yan wrote:
> On 5 Nov 2018, at 11:55, Daniel Jordan wrote:
>
> Do you think if it makes sense to use ktask for huge page migration (the data
> copy part)?

It certainly could.

> I did some experiments back in 2016[1], which showed that migrating one 2MB page
> with 8 threads could achieve 2.8x throughput of the existing single-threaded method.
> The problem with my parallel page migration patchset at that time was that it
> has no CPU-utilization awareness, which is solved by your patches now.

Did you run with fewer than 8 threads?  I'd want a bigger speedup than 2.8x for
8, and a smaller thread count might improve thread utilization.

It would be nice to multithread at a higher granularity than 2M, too: a range
of THPs might also perform better than a single page.

Thanks for your comments.

> [1]https://lkml.org/lkml/2016/11/22/457
