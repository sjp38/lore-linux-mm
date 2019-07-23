Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B03BC7618F
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 00:52:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B714621E6B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 00:52:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="qldAgseH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B714621E6B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C2376B0003; Mon, 22 Jul 2019 20:52:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44BAE6B0005; Mon, 22 Jul 2019 20:52:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C6328E0001; Mon, 22 Jul 2019 20:52:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id ECE2A6B0003
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 20:52:32 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id t19so24794270pgh.6
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 17:52:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nMe5o1gVo+TcKWoiQivW9FMbfNfMFM1Y8FWTB2iT39c=;
        b=IU3tamwD/vgHVv2luOtvAd5zPp8V0KAAknHp/60vPRWGMiqUsU4JLDlRCZkWqNTv8D
         Mc7RMXBqkGcT6gSFeNAAOQUXYxd1a9dDoc3aZFEq87nL/9dMTMIsSRZxd/5pdGVI7eNK
         HJ8Gz24IEkeWepsmnU3ygTFw58NXI8WX6c2VR2CF2Z4KIArnpGpoEoOr4ef5foYbDMbs
         S+W0XLZsFlHrNay6p+hBLZ1Dh9wiAXWcNecVtwyZtpCgnww2o2jcIUXcF9rCSgXD7fQ5
         U7bAr2qf6iwz+O5uaiRpSrbMMX4EaMUyH/0DX4j7YEIQwCaRr9GA+RTuARvq7BHPSJBL
         9psA==
X-Gm-Message-State: APjAAAX0Bl4ppRK0p/GODBD9zOj6edPV0yDZKs3vc8DB+LVhFRVmnFi7
	t6rxr8EPPpb+aBG2f10uZM1j17PI3bS7x4T4L4Unl6meLO/I4WYYbkNoflXMqAgGdIx3fVkUtU0
	kBI0Kfm7MJqrjJqBNOmmwsfrxTV77xLD8PCfglbHXDZYICEI0Rq1Ik6vMARdAB+wrng==
X-Received: by 2002:a17:902:d90a:: with SMTP id c10mr76307325plz.208.1563843152572;
        Mon, 22 Jul 2019 17:52:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx83+gRt299N6i/JOfMrzZ6A4wSIZu1f7P/TcbWHKMG/+P+5yt2mQPXY23jp4tK2ITS8IQz
X-Received: by 2002:a17:902:d90a:: with SMTP id c10mr76307304plz.208.1563843151954;
        Mon, 22 Jul 2019 17:52:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563843151; cv=none;
        d=google.com; s=arc-20160816;
        b=zvlWEhJii4KliD6zQWD9SEG8Zmectc7lV17h58wFSyFJDpvE7fbXbPSRXMBMP0jen0
         409sQuMQjDB2Zm1pG8hOgUB5C4TF+0GvqpwxhGjuJupehw7V6qMI5yx8cyHlTCyb2CtM
         6MWMf2bi4lgpYBxLV7jrq11gKwNMeTTfM4pmEcGZS1X3LfoLr+W0dx3/6FhR1wysLxkd
         x8pyEXtwnTBsvJhXzYxvpBjaDXIb4mR6hhxSwi7cNmoKvHXcrIaXFJCoTB7McKB9nMe1
         baYItMT8oKM/mrUa8Pr9pyHDNGzunFokY5FK1Vce4bODnohEWLJseBhN5HiS0XUH0YtN
         u+pA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=nMe5o1gVo+TcKWoiQivW9FMbfNfMFM1Y8FWTB2iT39c=;
        b=GOn0LoxM/PocLZQ5GIUd+13L0cgyM0wZtiSBhOuzPn5T6PpKX8WhTHnHnjMmXhddXV
         KlJ3i1J1W4Bk+i5CDX9KMN3xXR9ekQQoa7zenOA5XxE8HCkaTnYW6CSYhOZgaKrOILKX
         T9i+gjuTkk8CkavbGXiQjNKCUu0a3QJFFh7jx9eTAlouTtVLsjmWGxvtPW3Dba9afaXc
         uqU3EoCbmzCugJErJJTnjyzSG+DQCuX+N47aPeuNc1T4SmguG4Uoaa2aiKBulhDtMWqS
         Q8BtU8fVyleAoVa+6VRz1/lKoEwoGczNVBT2iq3tOaw7y4q/QyQZxAjg/on8Kxhqz19L
         f/lA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=qldAgseH;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l10si13747254pgp.411.2019.07.22.17.52.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 17:52:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=qldAgseH;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 47D7B2199C;
	Tue, 23 Jul 2019 00:52:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563843151;
	bh=QoDXFktQWBBjpdyHJklib+lJgS4BW2A6BFE+HFerPWQ=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=qldAgseHrPTRQybgwoDYuxEyG8jbKlaOwXXZCKp00RlNMoCOAGqSm4bAf+McROJz/
	 mfL6Is692vmHZ+Bag8epiebNzp9yZjUrQw5ExCZEV6QC2Eng/d11n0S42hba7gjy8G
	 myaupLK4kQRgZBzodyvJKQEr/bHTIZpHrw5upEQ0=
Date: Mon, 22 Jul 2019 17:52:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo
 <tj@kernel.org>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner
 <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Jan Kara
 <jack@suse.cz>
Subject: Re: [PATCH 1/2] mm/filemap: don't initiate writeback if mapping has
 no dirty pages
Message-Id: <20190722175230.d357d52c3e86dc87efbd4243@linux-foundation.org>
In-Reply-To: <156378816804.1087.8607636317907921438.stgit@buzz>
References: <156378816804.1087.8607636317907921438.stgit@buzz>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


(cc linux-fsdevel and Jan)

On Mon, 22 Jul 2019 12:36:08 +0300 Konstantin Khlebnikov <khlebnikov@yandex-team.ru> wrote:

> Functions like filemap_write_and_wait_range() should do nothing if inode
> has no dirty pages or pages currently under writeback. But they anyway
> construct struct writeback_control and this does some atomic operations
> if CONFIG_CGROUP_WRITEBACK=y - on fast path it locks inode->i_lock and
> updates state of writeback ownership, on slow path might be more work.
> Current this path is safely avoided only when inode mapping has no pages.
> 
> For example generic_file_read_iter() calls filemap_write_and_wait_range()
> at each O_DIRECT read - pretty hot path.
> 
> This patch skips starting new writeback if mapping has no dirty tags set.
> If writeback is already in progress filemap_write_and_wait_range() will
> wait for it.
> 
> ...
>
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -408,7 +408,8 @@ int __filemap_fdatawrite_range(struct address_space *mapping, loff_t start,
>  		.range_end = end,
>  	};
>  
> -	if (!mapping_cap_writeback_dirty(mapping))
> +	if (!mapping_cap_writeback_dirty(mapping) ||
> +	    !mapping_tagged(mapping, PAGECACHE_TAG_DIRTY))
>  		return 0;
>  
>  	wbc_attach_fdatawrite_inode(&wbc, mapping->host);

How does this play with tagged_writepages?  We assume that no tagging
has been performed by any __filemap_fdatawrite_range() caller?

