Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C866FC10F0B
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:59:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58A372075C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:59:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="SBr3m5X/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58A372075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B89408E001E; Wed, 13 Mar 2019 15:59:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B394E8E0001; Wed, 13 Mar 2019 15:59:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A27098E001E; Wed, 13 Mar 2019 15:59:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5C5DC8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:59:01 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e5so3396184pgc.16
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:59:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=SajRrUaUGaud6Nn4Qj6K9i18P4JO+MNtdJ37Bn8y7bQ=;
        b=eC/cjXPMG1cIxziDsOTh938qs9TTiALorufwRNFNgj09dM5I+xDbHIuIuwPOxug+UI
         37scoHwZe61A9Q1NiwBjFtJOBsTmjsWhDJ2c+aJPowCJgCDsRPKqgcoweRmfMKLsh5Xt
         z/4PLddD1CmjoHwlEKsURYlc5ydOfDiT1OrtRVoj76oa297IX8quXL+xj8bGiJ1jVT8B
         gB8Mtyh2Md46xjfOoQxKU8SyTewPNGPymeG2bcJUIu3T+wI7RkxJoTdNb3aGh4Jc1TMd
         kre809+XWV+Bi+4nm03IbMb9nUyB78uE1E9wCjqfxneg+I428/MKTQxJZNMwz4AIw/E6
         l5HA==
X-Gm-Message-State: APjAAAXCUAYUTXwnJujFX/r0Nt1HRuGiPafLXGcRxCJ5nfnr9bzj7/0Z
	mfHJCmKfxe7VAKSHQQQ2ErVSY9lojgsKmOrQV7r+4NVkbg9VziGyeFfC6Nbggqi1u8lpze6fCjt
	BlMYFUJeAc6oFZ6AIUqvbk/3yBJDXoCLCr0xHXSa3IhELX0G3Kerb4bdwgOHhvSvk9AcXkG5GtW
	/ot+ebmeo/z6+hawHIamMyiK63BP3i5xQyXaD8M6jLYwJobR+k0ufA3J7se/zrVwMJuMBsIjIVM
	5Wsd9+Qe3LHQ2Su4lvk+xiTx7ni9hkw4/CdDTGEibep5t4k9v3H0+QEfyQLSDy0PjqCfliMCUCD
	RPL5OeXTDL7cxFjuAADVktokbOEsawRHgyQog2aW49K1WmmMqGzWDi4G6dsGCefLVreajcXHpEq
	V
X-Received: by 2002:a17:902:b217:: with SMTP id t23mr17977890plr.184.1552507140957;
        Wed, 13 Mar 2019 12:59:00 -0700 (PDT)
X-Received: by 2002:a17:902:b217:: with SMTP id t23mr17977825plr.184.1552507140022;
        Wed, 13 Mar 2019 12:59:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552507140; cv=none;
        d=google.com; s=arc-20160816;
        b=SU8gefBeE6pjEaGH8wE0mtuhbluv9XeZQWhIGMNdzb3s8RXHWDUv3eJhizvlbITem5
         EZm4RrGmPfZbc4s4rff8+tS4Cph/ioXUDbkMiJAymYVyfWHzgAYlFF3htOdSVlTShxDR
         wwnciSc3lEtk8oSKYWfK3MCqCsI09UR0PW2l7P48kmwQX/8PXilge+oNJ4eopfIZiyq2
         PDWagtSJ7oAgeYVL1Abz4mkveAP01jBTIeR4j6NewkHpFZ96rNfb5eKIwv19p9t3mjIo
         jttyvTRFiDiKysLArOdCcd3CQsKh3oDHfwCfVKOHJB25SLvxAkrwKqAcp99XP0eSi5FR
         ewvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=SajRrUaUGaud6Nn4Qj6K9i18P4JO+MNtdJ37Bn8y7bQ=;
        b=O/72Zsd27EFJJw2MargVxcJ4lHf3CxWBTtHgzemDQGWInByhF5XCtnMNtpLKLnbdEY
         lJFPU4M47xy8TxphbzdEFj3ip96l28BTY4wOWD77uXySdnzw6Qp4un5EQDtQ+oHvIcBJ
         ORFJy/IbfjJEzJ/BMZkV7cFrJDaByLRpBJr3NkspnHVQoD103k3rC8hXB3rE8A26ZUqd
         +3OQ8DtYqlcdsVjr1vqGberfZHcreS5OihBBYhKDsbwmehLnF30id4A3Of2zzjSERUyt
         LUw3n6DMNuMR6So39w9xj19FAodbqz3hPzm5W7QQZoRFc8uLvqSvVq7xmMwdCoi4LABN
         HWGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="SBr3m5X/";
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b13sor3838896pfi.19.2019.03.13.12.58.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 12:59:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="SBr3m5X/";
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=SajRrUaUGaud6Nn4Qj6K9i18P4JO+MNtdJ37Bn8y7bQ=;
        b=SBr3m5X/eJzdT+sEonH+SmkvXYruM+CrkEu9nppT3EY0319WJl+seG3l5xz3A4DZYE
         A+oRZ9HXJeu60cYin5WicOu2UtNbEI4SBvN25Tni1LO2EXl+FCnyKxPkxb7K6d9IRthM
         6sVG/zHpR+leoapOgFGFCQayKJJr81IyKkQ3KgWD9FHZEi+H7GyYf9aGJILNWm3j5MJv
         7X8Ap3skyXpWAGZJbnrxBuZltTxhekSKYPjUddN1oy4zJFFHkKnvFlvpnuorr/qczwVy
         su7wZJV7u72Q1W1t881hlTX/VvhqJdGEGK+UJpXt/fG3xqpYm9CN7TbG1JfQPB8qIvCu
         Uy9A==
X-Google-Smtp-Source: APXvYqxtqw/l3jAmyf1Nv+r2FH56v+9+XlPl1VhkWGkRCkFf6Jsi+2m51OrFhzBX29knybK33dc4mA==
X-Received: by 2002:a63:2bcd:: with SMTP id r196mr40920203pgr.355.1552507138925;
        Wed, 13 Mar 2019 12:58:58 -0700 (PDT)
Received: from [100.112.89.103] ([104.133.8.103])
        by smtp.gmail.com with ESMTPSA id e63sm17933208pfa.116.2019.03.13.12.58.57
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Mar 2019 12:58:58 -0700 (PDT)
Date: Wed, 13 Mar 2019 12:58:26 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Sasha Levin <sashal@kernel.org>
cc: linux-kernel@vger.kernel.org, stable@vger.kernel.org, 
    "Darrick J. Wong" <darrick.wong@oracle.com>, 
    Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
    Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org
Subject: Re: [PATCH AUTOSEL 4.20 37/60] tmpfs: fix link accounting when a
 tmpfile is linked in
In-Reply-To: <20190313191021.158171-37-sashal@kernel.org>
Message-ID: <alpine.LSU.2.11.1903131248210.1629@eggly.anvils>
References: <20190313191021.158171-1-sashal@kernel.org> <20190313191021.158171-37-sashal@kernel.org>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

AUTOSEL is wrong to select this commit without also selecting
29b00e609960 ("tmpfs: fix uninitialized return value in shmem_link")
which contains the tag
Fixes: 1062af920c07 ("tmpfs: fix link accounting when a tmpfile is linked in")
Please add 29b00e609960 for those 6 trees, or else omit 1062af920c07 for now.

Thanks,
Hugh

On Wed, 13 Mar 2019, Sasha Levin wrote:

> From: "Darrick J. Wong" <darrick.wong@oracle.com>
> 
> [ Upstream commit 1062af920c07f5b54cf5060fde3339da6df0cf6b ]
> 
> tmpfs has a peculiarity of accounting hard links as if they were
> separate inodes: so that when the number of inodes is limited, as it is
> by default, a user cannot soak up an unlimited amount of unreclaimable
> dcache memory just by repeatedly linking a file.
> 
> But when v3.11 added O_TMPFILE, and the ability to use linkat() on the
> fd, we missed accommodating this new case in tmpfs: "df -i" shows that
> an extra "inode" remains accounted after the file is unlinked and the fd
> closed and the actual inode evicted.  If a user repeatedly links
> tmpfiles into a tmpfs, the limit will be hit (ENOSPC) even after they
> are deleted.
> 
> Just skip the extra reservation from shmem_link() in this case: there's
> a sense in which this first link of a tmpfile is then cheaper than a
> hard link of another file, but the accounting works out, and there's
> still good limiting, so no need to do anything more complicated.
> 
> Link: http://lkml.kernel.org/r/alpine.LSU.2.11.1902182134370.7035@eggly.anvils
> Fixes: f4e0c30c191 ("allow the temp files created by open() to be linked to")
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Reported-by: Matej Kupljen <matej.kupljen@gmail.com>
> Acked-by: Al Viro <viro@zeniv.linux.org.uk>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Sasha Levin <sashal@kernel.org>
> ---
>  mm/shmem.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 5d07e0b1352f..7872e3b75e57 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -2852,10 +2852,14 @@ static int shmem_link(struct dentry *old_dentry, struct inode *dir, struct dentr
>  	 * No ordinary (disk based) filesystem counts links as inodes;
>  	 * but each new link needs a new dentry, pinning lowmem, and
>  	 * tmpfs dentries cannot be pruned until they are unlinked.
> +	 * But if an O_TMPFILE file is linked into the tmpfs, the
> +	 * first link must skip that, to get the accounting right.
>  	 */
> -	ret = shmem_reserve_inode(inode->i_sb);
> -	if (ret)
> -		goto out;
> +	if (inode->i_nlink) {
> +		ret = shmem_reserve_inode(inode->i_sb);
> +		if (ret)
> +			goto out;
> +	}
>  
>  	dir->i_size += BOGO_DIRENT_SIZE;
>  	inode->i_ctime = dir->i_ctime = dir->i_mtime = current_time(inode);
> -- 
> 2.19.1

