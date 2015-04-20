Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 730686B0032
	for <linux-mm@kvack.org>; Mon, 20 Apr 2015 13:56:32 -0400 (EDT)
Received: by qcpm10 with SMTP id m10so62788949qcp.3
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 10:56:32 -0700 (PDT)
Received: from mail-qg0-x236.google.com (mail-qg0-x236.google.com. [2607:f8b0:400d:c04::236])
        by mx.google.com with ESMTPS id b138si20222186qka.116.2015.04.20.10.56.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Apr 2015 10:56:31 -0700 (PDT)
Received: by qgej70 with SMTP id j70so56506509qge.2
        for <linux-mm@kvack.org>; Mon, 20 Apr 2015 10:56:30 -0700 (PDT)
Date: Mon, 20 Apr 2015 13:56:26 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 12/49] writeback: move backing_dev_info->bdi_stat[] into
 bdi_writeback
Message-ID: <20150420175626.GB4206@htj.duckdns.org>
References: <1428350318-8215-1-git-send-email-tj@kernel.org>
 <1428350318-8215-13-git-send-email-tj@kernel.org>
 <20150420150231.GA17020@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150420150231.GA17020@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Miklos Szeredi <miklos@szeredi.hu>, Trond Myklebust <trond.myklebust@primarydata.com>

On Mon, Apr 20, 2015 at 05:02:31PM +0200, Jan Kara wrote:
>   Maybe bdi_wb_destroy() would be somewhat more descriptive than
> bdi_wb_exit()? Otherwise the patch looks good to me. You can add:
> Reviewed-by: Jan Kara <jack@suse.cz>

Hmmm... maybe, I don't know.  I feel weird matching up destroy with
init instead of create.  Why is exit weird?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
