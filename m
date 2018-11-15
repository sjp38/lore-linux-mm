Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id AE4056B0008
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 04:30:47 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id s17-v6so13138823wrt.9
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 01:30:47 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id m10-v6si18328022wrv.286.2018.11.15.01.30.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 01:30:46 -0800 (PST)
Date: Thu, 15 Nov 2018 10:30:45 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] iomap: get/put the page in iomap_page_create/release()
Message-ID: <20181115093045.GA14847@lst.de>
References: <20181115003000.1358007-1-pjaroszynski@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115003000.1358007-1-pjaroszynski@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: p.jaroszynski@gmail.com
Cc: Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Piotr Jaroszynski <pjaroszynski@nvidia.com>

> Fixes: 82cb14175e7d ("xfs: add support for sub-pagesize writeback
>                       without buffer_heads")

I've never seen line breaks in Fixes tags, is this really a valid format?

> +	/*
> +	 * At least migrate_page_move_mapping() assumes that pages with private
> +	 * data have their count elevated by 1.
> +	 */

I'd drop the "At least".

Otherwise this looks fine to me:

Reviewed-by: Christoph Hellwig <hch@lst.de>
