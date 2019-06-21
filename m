Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4AECC48BE0
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:39:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61C72208C3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:39:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="MMv0Ydn9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61C72208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A3396B0007; Fri, 21 Jun 2019 09:39:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 02E1A8E0003; Fri, 21 Jun 2019 09:39:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E10888E0001; Fri, 21 Jun 2019 09:39:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 92CEB6B0007
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 09:39:48 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b21so9209090edt.18
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 06:39:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=AdpAsciClW5VStBwxplQLFyT5xLaWG5vW4nBjzS9ue8=;
        b=UZL4duuAHckI5Z5YDvtA27cKS47wuAvckszJXI6Zopb+6LPzdkuXQC3o5rWfv07yKu
         mm1BOJ9OIm/m94YPoYIiUFjkcYQKffnaw/CRNpS/MjiaQ5LqGb1t5oLlTo6jesqyY5mn
         2/YPLNot2zqECP7Rrbv9yrii4Q04iQw9fD+E8zAWN/DWugwSbEbc1xh1YIn1bgPfpJuY
         BsXGjt07uWsMn8qatkCN4jUT2l9YHFfbNpZ33om13Njx41g90Zv+3wvVy91FG4NePUAt
         e/RUN2Il/JR2QX8CmP/fhIXXywDoPCQyPGOUNY4ZVi/lN5dxLtoOCdf7zb/wQu6nCoA3
         yhhg==
X-Gm-Message-State: APjAAAWhGqp2elDt9dBoaiUWY1esSCcCfWj2YJfP1jsDh09u/szRhXT3
	hX9YV+oznSvEa8c1OqKsT5cudXMi+Wp7T3VTyZhQiArWCFVNu/N0U2Z3DzdeQGCXHw9YcvL5Vhj
	Ychv7kkb6Wn1kMN8/iDtgWI0fLCTr7/8Ku0/GCIm4qf4t2zUQFQpoe5As5k4sWZ2CXA==
X-Received: by 2002:a50:8a85:: with SMTP id j5mr97401789edj.304.1561124388179;
        Fri, 21 Jun 2019 06:39:48 -0700 (PDT)
X-Received: by 2002:a50:8a85:: with SMTP id j5mr97401698edj.304.1561124387379;
        Fri, 21 Jun 2019 06:39:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561124387; cv=none;
        d=google.com; s=arc-20160816;
        b=JcHdNiWU+ElhrkS4nFvmwtKkipK5zq41ql1GyoI6eHn8W17UCRHP8kb+j6C8CuXjIJ
         Tptc2B9WDlMniGF7+BWjKq/n6inYr4su4KU5TseUa6tAR8FFWcY0WI1wusWrtp67xKzq
         HmJHHAa6Ebx8asLglrGXRElAmbLhk7gvi6TnBDi84VPuf81Ozj3L61JaeVQbNqlM6yTL
         4kpA8Vv9AaGSJedx9KqWC79SQGA2H1kbyONI9BCYAFPAGa6F18HVEptd1utGE4iDkZ9c
         ytgQENVx65+oTEISVAxt00ojejaDvawAdFe7jYEa+EyRXB1Zhog4zM9QBtpNeLhq3pyY
         ogug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=AdpAsciClW5VStBwxplQLFyT5xLaWG5vW4nBjzS9ue8=;
        b=C9OkPvsBqoghjk2PgwZE/DuljMt9ybLysMt5MstOibP/ahw+z04+6mRC3LR9TNvK7I
         T3X+1H6vzAph5FoDrhbLzhgV6s13UcVbmVwC1NXCHsU3iPv+nryqdmCP5ple/DOGLniB
         2Ad3NSU8DN0RooZuM7jhCstDeot7CQa2ZSRXZjZmjpVZSf8taJWGxk6ByupjrxVabWa1
         Hh9lN+EmQD/YeA9yyf7Qq/vMGHLcwGMdn+iMGPfykuf5+Tv1Guk+b4reecazX+t4adFT
         t5w0KAaYWmr+o15vFN9JG1V+9Hs7uDJ9NBtJvdxsaLaCUd6UJJUBqBjOETOUhS1XVson
         2r4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=MMv0Ydn9;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b21sor2937011edc.13.2019.06.21.06.39.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 06:39:47 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=MMv0Ydn9;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=AdpAsciClW5VStBwxplQLFyT5xLaWG5vW4nBjzS9ue8=;
        b=MMv0Ydn948bMlAsUr3EOQTiiiIsndLshwaLg99cYJeSWvgk03QQ2LSLT1DwHnI+ttt
         fYLpn0rHMLs5dRVqs577Vdjp9fQVNg1AI7YMotlVBRgN2G+jxYa30fNPDT4cxuIBbnbv
         dvkhiikckPj8I9WO4qszbrxQqjT4JDmftO4ZkqoU6ylL3W02f46VZgCH18TT1nSpqoIR
         iYL16BfVrpSfbVFU4fdiZv/1CJyG5zDKZV62sGCL+E2XVUEGFbl4jyZB5dUrvDb+Wm2X
         ESnK59f5G2A768/OcKoYqJIV3GVjhBwChxmegwrnBe1M3OaBl4qF1jOpFlqBJ6y5eTG+
         g4KQ==
X-Google-Smtp-Source: APXvYqyfo29+EXbgAlEhNY5mM3p5DZaIm16f0XKm7106HMmSS3lHu91bLkjtSP71e9ueQByDkzUQEg==
X-Received: by 2002:a50:974b:: with SMTP id d11mr110357427edb.24.1561124387072;
        Fri, 21 Jun 2019 06:39:47 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id c49sm856113eda.74.2019.06.21.06.39.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 06:39:46 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 779E810289C; Fri, 21 Jun 2019 16:39:48 +0300 (+03)
Date: Fri, 21 Jun 2019 16:39:48 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: Linux-MM <linux-mm@kvack.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
	"kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
	Kernel Team <Kernel-team@fb.com>,
	"william.kucharski@oracle.com" <william.kucharski@oracle.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 6/6] mm,thp: avoid writes to file with THP in pagecache
Message-ID: <20190621133948.2pvagzfwpwwk6rho@box>
References: <20190620205348.3980213-1-songliubraving@fb.com>
 <20190620205348.3980213-7-songliubraving@fb.com>
 <20190621130740.ehobvjjj7gjiazjw@box>
 <ABE906A7-719A-4AFF-8683-B413397C9865@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ABE906A7-719A-4AFF-8683-B413397C9865@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 21, 2019 at 01:10:54PM +0000, Song Liu wrote:
> 
> 
> > On Jun 21, 2019, at 6:07 AM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > 
> > On Thu, Jun 20, 2019 at 01:53:48PM -0700, Song Liu wrote:
> >> In previous patch, an application could put part of its text section in
> >> THP via madvise(). These THPs will be protected from writes when the
> >> application is still running (TXTBSY). However, after the application
> >> exits, the file is available for writes.
> >> 
> >> This patch avoids writes to file THP by dropping page cache for the file
> >> when the file is open for write. A new counter nr_thps is added to struct
> >> address_space. In do_last(), if the file is open for write and nr_thps
> >> is non-zero, we drop page cache for the whole file.
> >> 
> >> Signed-off-by: Song Liu <songliubraving@fb.com>
> >> ---
> >> fs/inode.c         |  3 +++
> >> fs/namei.c         | 22 +++++++++++++++++++++-
> >> include/linux/fs.h | 31 +++++++++++++++++++++++++++++++
> >> mm/filemap.c       |  1 +
> >> mm/khugepaged.c    |  4 +++-
> >> 5 files changed, 59 insertions(+), 2 deletions(-)
> >> 
> >> diff --git a/fs/inode.c b/fs/inode.c
> >> index df6542ec3b88..518113a4e219 100644
> >> --- a/fs/inode.c
> >> +++ b/fs/inode.c
> >> @@ -181,6 +181,9 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
> >> 	mapping->flags = 0;
> >> 	mapping->wb_err = 0;
> >> 	atomic_set(&mapping->i_mmap_writable, 0);
> >> +#ifdef CONFIG_READ_ONLY_THP_FOR_FS
> >> +	atomic_set(&mapping->nr_thps, 0);
> >> +#endif
> >> 	mapping_set_gfp_mask(mapping, GFP_HIGHUSER_MOVABLE);
> >> 	mapping->private_data = NULL;
> >> 	mapping->writeback_index = 0;
> >> diff --git a/fs/namei.c b/fs/namei.c
> >> index 20831c2fbb34..de64f24b58e9 100644
> >> --- a/fs/namei.c
> >> +++ b/fs/namei.c
> >> @@ -3249,6 +3249,22 @@ static int lookup_open(struct nameidata *nd, struct path *path,
> >> 	return error;
> >> }
> >> 
> >> +/*
> >> + * The file is open for write, so it is not mmapped with VM_DENYWRITE. If
> >> + * it still has THP in page cache, drop the whole file from pagecache
> >> + * before processing writes. This helps us avoid handling write back of
> >> + * THP for now.
> >> + */
> >> +static inline void release_file_thp(struct file *file)
> >> +{
> >> +#ifdef CONFIG_READ_ONLY_THP_FOR_FS
> >> +	struct inode *inode = file_inode(file);
> >> +
> >> +	if (inode_is_open_for_write(inode) && filemap_nr_thps(inode->i_mapping))
> >> +		truncate_pagecache(inode, 0);
> >> +#endif
> >> +}
> >> +
> >> /*
> >>  * Handle the last step of open()
> >>  */
> >> @@ -3418,7 +3434,11 @@ static int do_last(struct nameidata *nd,
> >> 		goto out;
> >> opened:
> >> 	error = ima_file_check(file, op->acc_mode);
> >> -	if (!error && will_truncate)
> >> +	if (error)
> >> +		goto out;
> >> +
> >> +	release_file_thp(file);
> > 
> > What protects against re-fill the file with THP in parallel?
> 
> khugepaged would only process vma with VM_DENYWRITE. So once the
> file is open for write (i_write_count > 0), khugepage will not 
> collapse the pages. 

I have not look at the patch very closely. Do you only create THP by
khugepaged? Not in fault path?

-- 
 Kirill A. Shutemov

