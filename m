Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 431FE6B0038
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 17:06:17 -0400 (EDT)
Received: by qcay5 with SMTP id y5so27561406qca.1
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 14:06:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q36si2068988qkh.69.2015.03.27.14.06.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Mar 2015 14:06:16 -0700 (PDT)
Date: Fri, 27 Mar 2015 17:06:13 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 21/48] writeback: make backing_dev_info host
 cgroup-specific bdi_writebacks
Message-ID: <20150327210612.GA23840@redhat.com>
References: <1427086499-15657-1-git-send-email-tj@kernel.org>
 <1427086499-15657-22-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427086499-15657-22-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com

On Mon, Mar 23, 2015 at 12:54:32AM -0400, Tejun Heo wrote:

[..]
> +/**
> + * inode_attach_wb - associate an inode with its wb
> + * @inode: inode of interest
> + * @page: page being dirtied (may be NULL)
> + *
> + * If @inode doesn't have its wb, associate it with the wb matching the
> + * memcg of @page or, if @page is NULL, %current.  May be called w/ or w/o
> + * @inode->i_lock.
> + */
> +static inline void inode_attach_wb(struct inode *inode, struct page *page)
> +{
> +	if (!inode->i_wb)
> +		__inode_attach_wb(inode, page);
> +}

Hi Tejun,

I was curious to know that why do we need this "struct page *page" when
trying to attach a inode to a bdi_writeback. Is using current's cgroup
always not sufficient?

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
