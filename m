Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4CD746B0005
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 04:29:18 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id i64-v6so13456091ywa.22
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 01:29:18 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id l123-v6si18103405ywg.238.2018.11.01.01.29.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 01:29:16 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.1 \(3445.101.1\))
Subject: Re: [PATCH] mm/gup_benchmark: prevent integer overflow in ioctl
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20181101071613.7x3smxwz5wo57n2m@mwanda>
Date: Thu, 1 Nov 2018 02:28:55 -0600
Content-Transfer-Encoding: 7bit
Message-Id: <E7641C0F-C619-4054-BD14-685E8D448F49@oracle.com>
References: <20181025061546.hnhkv33diogf2uis@kili.mountain>
 <CF4F3932-68A1-4D92-9E4F-6DCD3A3A0447@oracle.com>
 <20181101071613.7x3smxwz5wo57n2m@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Keith Busch <keith.busch@intel.com>, "Michael S. Tsirkin" <mst@redhat.com>, Kees Cook <keescook@chromium.org>, YueHaibing <yuehaibing@huawei.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org



> On Nov 1, 2018, at 1:16 AM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> 
> My patch lets people allocate 4MB.  (U32_MAX / 4096 * sizeof(void *)).
> Surely, that's enough?  I liked my check because it avoids the divide so
> it's faster and it is a no-op on 64bit systems.

It should be enough, and you're right, it does avoid extra math.

However, in that case I'd like to see a comment added so that anyone looking
at the code in the future knows why you limited the allocation to ULONG_MAX
bytes.

Thanks,
    William Kucharski
