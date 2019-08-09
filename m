Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48ACFC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 23:31:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 072F12086A
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 23:31:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 072F12086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 901C46B0005; Fri,  9 Aug 2019 19:31:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 88BC26B0006; Fri,  9 Aug 2019 19:31:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 779966B0007; Fri,  9 Aug 2019 19:31:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3BF456B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 19:31:49 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g18so58302448plj.19
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 16:31:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VZqSj6TN0PrnZvnLK23CMSZjNWa6hNovkYWw1h0gFbk=;
        b=UL6EPqg8GBRBDEmxaHPi+3Lj8xPpmUeWUhB3de0UrND9pLUYAmkaMUAuntKnKarlmM
         ehSvKWt1hkwcZOUdY71uZiBHQHvwVCOY7dOd0wmPVZftWt40vpUuFWbU50ODG+udE8Ro
         j+FIeQRT51l+5sIpIRkK/QTCFUWTB6hHbVgF8WDwc3yqDRQwuTaphX/JRlkBKnl7CWc/
         v+LAOZ6HcOsfvTMQw3E4SNBjLfE+zgP3y/4RpRTl00ouu4lZb2h93RtL1dhWeuacDuZn
         yn0uS6RYyvjC6dNoMfbzntGADZ+FUz1OQ1O6If6urUlDOohBK38+CusAmj3OXYfKIRmC
         s/ZA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAWY2cLLKd1uTM5e2bDDBNdtw7Yfv55BrcHwDG9ahkMC10AGRPdN
	K1Zu71lCCabVGANAfsiGKbB+UVd0pio0q1ah4GdxU1OOK7WZshyfKZ3NiJzbfbOkZLY6vn6WEgA
	d9WfMhKwB78ESomV3xd/N3euN8MeRaKSbQvYTE+X4z/Ko7LcP86iR8AiepsSCQhs=
X-Received: by 2002:a63:5162:: with SMTP id r34mr19050277pgl.229.1565393508835;
        Fri, 09 Aug 2019 16:31:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz/61CUK/WSKt22aOkmyD4nXIcA93j0l2I95NhFtgBgaUgMXhU0Qxf3LxluNPfl3L5JqT0t
X-Received: by 2002:a63:5162:: with SMTP id r34mr19050174pgl.229.1565393507072;
        Fri, 09 Aug 2019 16:31:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565393507; cv=none;
        d=google.com; s=arc-20160816;
        b=jjB0YZXNkTx8EXq5jG/CGs6YdOhcROGL6Y98frFeo/V8XeQJx8lGSlcyaEeSoMPRal
         356zDkf4A1FGni2dTxCyjjBKnXVrNepsSb4uLzakBAXP831lpJMnMfPSWoKfx2EEucaf
         or4Pdaa9LSw5RUcwMRiYJsqRJ6rEiCAx+3UDFfs3g5NZTLXveg4Xfw2LwzZiOrkOMWkE
         jSaKRY8W76rEVXv+fDnhQI03abX4h2hoAykgfAIH/XncvolWb7GJeu8lmV8bdhfhIMcp
         j0Y/lFJFI8RdQP81oVf5RrWvSZAt6MfUC2IUE0hTZDQY0g0nXuG9D/GIdr9fxGrdk/pQ
         BAeg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VZqSj6TN0PrnZvnLK23CMSZjNWa6hNovkYWw1h0gFbk=;
        b=w6HMbjL9QO/rrYDOoDs59ohcnrbN+c3I/4r7tG6UYUYF39E+xfJg53p4jig0Q6YM3c
         ocVQzS4PajNn5Qr9+iiOO/0SNnRK1gUOTJsWYYiKwekcbULZ70TOX3UkH3uRhXYbkTUi
         ZAdUQWgAa5zR/JfdT6j6GRfNlpeaCowaFZT1idqhlmJEfD+sCM4qfWGX2e6w0nXon2kg
         IBjyRvuAcbm/3XaBchvqCksADuZuSlPy2DuWzW+ZTc8TyZ2Ksm1aCNwLRiP/9g0P0tAn
         ja2Zb3dY6iD+qJVk2+KVSzOsra+GzavNZiD1gnxiaK0FgxvDQDDPfWU9EoXZdg+J0Tbg
         5Prg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id m32si52835685pld.236.2019.08.09.16.31.46
        for <linux-mm@kvack.org>;
        Fri, 09 Aug 2019 16:31:47 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id CE576364A0D;
	Sat, 10 Aug 2019 09:31:44 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hwELF-0001Z4-7E; Sat, 10 Aug 2019 09:30:37 +1000
Date: Sat, 10 Aug 2019 09:30:37 +1000
From: Dave Chinner <david@fromorbit.com>
To: ira.weiny@intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>, linux-xfs@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org,
	linux-ext4@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [RFC PATCH v2 07/19] fs/xfs: Teach xfs to use new
 dax_layout_busy_page()
Message-ID: <20190809233037.GB7777@dread.disaster.area>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190809225833.6657-8-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190809225833.6657-8-ira.weiny@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=QyXUC8HyAAAA:8 a=7-415B0cAAAA:8 a=Goxn531fkllQGndbsM8A:9
	a=CjuIK1q_8ugA:10 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 03:58:21PM -0700, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> dax_layout_busy_page() can now operate on a sub-range of the
> address_space provided.
> 
> Have xfs specify the sub range to dax_layout_busy_page()

Hmmm. I've got patches that change all these XFS interfaces to
support range locks. I'm not sure the way the ranges are passed here
is the best way to do it, and I suspect they aren't correct in some
cases, either....

> diff --git a/fs/xfs/xfs_iops.c b/fs/xfs/xfs_iops.c
> index ff3c1fae5357..f0de5486f6c1 100644
> --- a/fs/xfs/xfs_iops.c
> +++ b/fs/xfs/xfs_iops.c
> @@ -1042,10 +1042,16 @@ xfs_vn_setattr(
>  		xfs_ilock(ip, XFS_MMAPLOCK_EXCL);
>  		iolock = XFS_IOLOCK_EXCL | XFS_MMAPLOCK_EXCL;
>  
> -		error = xfs_break_layouts(inode, &iolock, BREAK_UNMAP);
> -		if (error) {
> -			xfs_iunlock(ip, XFS_MMAPLOCK_EXCL);
> -			return error;
> +		if (iattr->ia_size < inode->i_size) {
> +			loff_t                  off = iattr->ia_size;
> +			loff_t                  len = inode->i_size - iattr->ia_size;
> +
> +			error = xfs_break_layouts(inode, &iolock, off, len,
> +						  BREAK_UNMAP);
> +			if (error) {
> +				xfs_iunlock(ip, XFS_MMAPLOCK_EXCL);
> +				return error;
> +			}

This isn't right - truncate up still needs to break the layout on
the last filesystem block of the file, and truncate down needs to
extend to "maximum file offset" because we remove all extents beyond
EOF on a truncate down.

i.e. when we use preallocation, the extent map extends beyond EOF,
and layout leases need to be able to extend beyond the current EOF
to allow the lease owner to do extending writes, extending truncate,
preallocation beyond EOF, etc safely without having to get a new
lease to cover the new region in the extended file...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

