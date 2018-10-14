Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D26646B026B
	for <linux-mm@kvack.org>; Sun, 14 Oct 2018 13:41:11 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id e3-v6so13667434pld.13
        for <linux-mm@kvack.org>; Sun, 14 Oct 2018 10:41:11 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d28-v6si8229809pgn.203.2018.10.14.10.41.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 14 Oct 2018 10:41:10 -0700 (PDT)
Date: Sun, 14 Oct 2018 10:41:08 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 22/25] ocfs2: support partial clone range and dedupe range
Message-ID: <20181014174108.GB6400@infradead.org>
References: <153938912912.8361.13446310416406388958.stgit@magnolia>
 <153938929813.8361.16702022670128567518.stgit@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153938929813.8361.16702022670128567518.stgit@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

> @@ -2531,14 +2531,11 @@ static loff_t ocfs2_remap_file_range(struct file *file_in, loff_t pos_in,
>  				     struct file *file_out, loff_t pos_out,
>  				     loff_t len, unsigned int remap_flags)
>  {
> -	int ret;
> -
>  	if (!remap_check_flags(remap_flags, RFR_SAME_DATA))
>  		return -EINVAL;
>  
> -	ret = ocfs2_reflink_remap_range(file_in, pos_in, file_out, pos_out,
> -					len, remap_flags);
> -	return ret < 0 ? ret : len;
> +	return ocfs2_reflink_remap_range(file_in, pos_in, file_out, pos_out,
> +			len, remap_flags);

Seems like ocfs2_remap_file_range and ocfs2_reflink_remap_range should
be merged now.
