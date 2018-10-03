Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 237826B0010
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 19:23:47 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id m1-v6so4080909ywd.17
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 16:23:47 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id r17-v6si620241ybj.631.2018.10.03.16.23.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 16:23:46 -0700 (PDT)
Subject: Re: [PATCH 2/4] mm: introduce put_user_page(), placeholder version
References: <20180928053949.5381-1-jhubbard@nvidia.com>
 <20180928053949.5381-4-jhubbard@nvidia.com>
 <20181003162237.GH24030@quack2.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <6178c173-ffbf-700b-f140-e4b184a5767e@nvidia.com>
Date: Wed, 3 Oct 2018 16:23:44 -0700
MIME-Version: 1.0
In-Reply-To: <20181003162237.GH24030@quack2.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On 10/3/18 9:22 AM, Jan Kara wrote:
> On Thu 27-09-18 22:39:48, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
>>
>> Introduces put_user_page(), which simply calls put_page().
>> This provides a way to update all get_user_pages*() callers,
>> so that they call put_user_page(), instead of put_page().
>>
>> Also adds release_user_pages(), a drop-in replacement for
>> release_pages(). This is intended to be easily grep-able,
>> for later performance improvements, since release_user_pages
>> is not batched like release_pages() is, and is significantly
>> slower.
> 
> A small nit but can we maybe call this put_user_pages() for symmetry with
> put_user_page()? I don't really care too much but it would look natural to
> me.
> 

Sure. It started out as "make it a drop-in replacement for release_pages()",
but now it's not quite a drop-in replacement anymore. And in any case it's an 
opportunity to make the name more intuitive, so that seems like a good
idea.

If anyone hates put_user_pages() and wants to campaign relentlessly for
release_pages*(), then now is the time! :)


thanks,
-- 
John Hubbard
NVIDIA
