Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F4976B0545
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 13:44:54 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id u14-v6so15580355ybi.3
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 10:44:54 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 124-v6si8930772ywb.158.2018.11.15.10.44.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 10:44:53 -0800 (PST)
Subject: Re: [PATCH] iomap: get/put the page in iomap_page_create/release()
References: <20181115003000.1358007-1-pjaroszynski@nvidia.com>
 <20181115093045.GA14847@lst.de>
From: Piotr Jaroszynski <pjaroszynski@nvidia.com>
Message-ID: <c9f77d5d-bace-a0e4-777c-51ab2ed6107e@nvidia.com>
Date: Thu, 15 Nov 2018 10:44:51 -0800
MIME-Version: 1.0
In-Reply-To: <20181115093045.GA14847@lst.de>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, p.jaroszynski@gmail.com
Cc: Michal Hocko <mhocko@suse.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 11/15/18 1:30 AM, Christoph Hellwig wrote:
>> Fixes: 82cb14175e7d ("xfs: add support for sub-pagesize writeback
>>                       without buffer_heads")
> 
> I've never seen line breaks in Fixes tags, is this really a valid format?

Probably not, fixed in v2.

> 
>> +	/*
>> +	 * At least migrate_page_move_mapping() assumes that pages with private
>> +	 * data have their count elevated by 1.
>> +	 */
> 
> I'd drop the "At least".

Fixed in v2.

> 
> Otherwise this looks fine to me:
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> 

Thanks!

Thanks,
Piotr
