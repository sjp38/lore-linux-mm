Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D22BC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 11:05:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C98442075E
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 11:04:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C98442075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48C9F6B0003; Thu, 20 Jun 2019 07:04:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43E488E0002; Thu, 20 Jun 2019 07:04:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 353B58E0001; Thu, 20 Jun 2019 07:04:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DB82D6B0003
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 07:04:58 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i44so3803759eda.3
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 04:04:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=GqOZaVFkuqZ5j0U1VWcGjmIZ5wg14/wghXIVdBHLMu8=;
        b=Ozu54DqJDVdH7sW11D3uLGAjRgFyIMXJNhcSAqgoA2cUMxwD4EfQUZ7qSzSEqXio5C
         i643rTDnWCqbFwxYUQNDEekHt/dmKty4K0p+WzBBD17/7y/mqMMBcp6OxV162w3sQzqK
         On+/Q83pp+vhwdoFq3s3PlA5Y9z7E+A65t9+bbz/o2iUyVrfOfNguBwvbC7HiG80kKfv
         7GauJ74gPhW1GRUOmKUn2UwIcO8k2F7FY9WXEqIoBmyKN7o4t8xisBrsP9fUb+AthHZk
         kjdWp4ILAFGQUIR7HQUS9iLhe3ObMnfopDJobF2RZeGxCz13jE+zwtMxUZabYZZEW3yu
         /e7Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAXC2Cv+93nkg44+D1nVMAgG2x+Q1oXjRrO6pfSju04ECMMie6ru
	QOT9qrccIpaaJAx3+o6irFAlzg/IBgdcFTdYs3Xf1Y5kUKehVuTUNhRfRdopZS7nN0bif1FiV+5
	2Ut/ryZstgPULyONinpaPEbXPdhoot5um9/EtYgwD/JZ3/ycGp8qaSi1crWY+vF6p/w==
X-Received: by 2002:a17:907:20ed:: with SMTP id rh13mr11503163ejb.34.1561028698455;
        Thu, 20 Jun 2019 04:04:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzE44/ri8h4eunTdWIM3irPv7DcSQjoa/w/gkrShOXLwXk65cRHUgpz3MMXGmLvz2gYBiuW
X-Received: by 2002:a17:907:20ed:: with SMTP id rh13mr11503089ejb.34.1561028697621;
        Thu, 20 Jun 2019 04:04:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561028697; cv=none;
        d=google.com; s=arc-20160816;
        b=lCDGTfwB7vJJF2UYL7ySsm/Jw2bI0v6NVGN9J0n9Wv20nIPBHDSKt2VL6ROzTicqsL
         /Cg1S/db8x89aikhq8K+cNdUr5ZwnQ0tS+kMla6i4Vz0904MpgknLmW3YLQvOrG6CIDJ
         xxy0vlTiLTtIVCw3cJvvggGsrdLnYqxcz/dkL0xo8c33lxR7+veClhayz4b2jtHUU+Ms
         MPBPgO6Fs7MPLZXvmufATYkW7BA+nPF+ObULsm12PWpT7mnWyKYVX0r81EXCik2l8XGh
         hVH41e5MmjkHj6MdQOHmpSTbG4pm93nw0hdG6CgvXBiv/A4M3QDLih+MQq6VPvlGT/D0
         MKbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=GqOZaVFkuqZ5j0U1VWcGjmIZ5wg14/wghXIVdBHLMu8=;
        b=FuU7rfqaOuuFvxSWTvAQfTj+7vMKuS0pQ0eh6NGCAHONlQ++c3q2oV1r6Ar1rQ5yRm
         0c8q5yI2xy0zdjX+3T3x584nSIZjcGURY3lj7RhsiUg5i6BMw3z5RehNzSchSnadkEuL
         FrV/rFHybh7V1EVCDx4PGVNRjrlGipXiuujPkACqzO7Gbkz0Gog7qkZa7iISDZd4lPfg
         q8+XZXW1B+JSuEp9LeaHjinIQ+eth0iXkAqONLvHQ0R6qVaPMiKsstlyq88NMGmmClFg
         nRGoSM5ve3dy1scv6nfGDy4k6gGttQZxjbSe6/FsF6AUjZsoRTecUakyFGoZrbbec2U0
         fm0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d38si17230492edb.50.2019.06.20.04.04.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 04:04:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9F7BFAF92;
	Thu, 20 Jun 2019 11:04:56 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 021901E4241; Thu, 20 Jun 2019 13:04:54 +0200 (CEST)
Date: Thu, 20 Jun 2019 13:04:54 +0200
From: Jan Kara <jack@suse.cz>
To: Ross Zwisler <zwisler@chromium.org>
Cc: linux-kernel@vger.kernel.org, Ross Zwisler <zwisler@google.com>,
	Theodore Ts'o <tytso@mit.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>,
	linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, Fletcher Woodruff <fletcherw@google.com>,
	Justin TerAvest <teravest@google.com>
Subject: Re: [PATCH 2/3] jbd2: introduce jbd2_inode dirty range scoping
Message-ID: <20190620110454.GL13630@quack2.suse.cz>
References: <20190619172156.105508-1-zwisler@google.com>
 <20190619172156.105508-3-zwisler@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190619172156.105508-3-zwisler@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 19-06-19 11:21:55, Ross Zwisler wrote:
> Currently both journal_submit_inode_data_buffers() and
> journal_finish_inode_data_buffers() operate on the entire address space
> of each of the inodes associated with a given journal entry.  The
> consequence of this is that if we have an inode where we are constantly
> appending dirty pages we can end up waiting for an indefinite amount of
> time in journal_finish_inode_data_buffers() while we wait for all the
> pages under writeback to be written out.
> 
> The easiest way to cause this type of workload is do just dd from
> /dev/zero to a file until it fills the entire filesystem.  This can
> cause journal_finish_inode_data_buffers() to wait for the duration of
> the entire dd operation.
> 
> We can improve this situation by scoping each of the inode dirty ranges
> associated with a given transaction.  We do this via the jbd2_inode
> structure so that the scoping is contained within jbd2 and so that it
> follows the lifetime and locking rules for that structure.
> 
> This allows us to limit the writeback & wait in
> journal_submit_inode_data_buffers() and
> journal_finish_inode_data_buffers() respectively to the dirty range for
> a given struct jdb2_inode, keeping us from waiting forever if the inode
> in question is still being appended to.
> 
> Signed-off-by: Ross Zwisler <zwisler@google.com>

The patch looks good to me. I was thinking whether we should not have
separate ranges for current and the next transaction but I guess it is not
worth it at least for now. So just one nit below. With that applied feel free
to add:

Reviewed-by: Jan Kara <jack@suse.cz>

> @@ -257,15 +262,24 @@ static int journal_finish_inode_data_buffers(journal_t *journal,
>  	/* For locking, see the comment in journal_submit_data_buffers() */
>  	spin_lock(&journal->j_list_lock);
>  	list_for_each_entry(jinode, &commit_transaction->t_inode_list, i_list) {
> +		loff_t dirty_start = jinode->i_dirty_start;
> +		loff_t dirty_end = jinode->i_dirty_end;
> +
>  		if (!(jinode->i_flags & JI_WAIT_DATA))
>  			continue;
>  		jinode->i_flags |= JI_COMMIT_RUNNING;
>  		spin_unlock(&journal->j_list_lock);
> -		err = filemap_fdatawait_keep_errors(
> -				jinode->i_vfs_inode->i_mapping);
> +		err = filemap_fdatawait_range_keep_errors(
> +				jinode->i_vfs_inode->i_mapping, dirty_start,
> +				dirty_end);
>  		if (!ret)
>  			ret = err;
>  		spin_lock(&journal->j_list_lock);
> +
> +		if (!jinode->i_next_transaction) {
> +			jinode->i_dirty_start = 0;
> +			jinode->i_dirty_end = 0;
> +		}

This would be more logical in the next loop that moves jinode into the next
transaction.

>  		jinode->i_flags &= ~JI_COMMIT_RUNNING;
>  		smp_mb();
>  		wake_up_bit(&jinode->i_flags, __JI_COMMIT_RUNNING);

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

