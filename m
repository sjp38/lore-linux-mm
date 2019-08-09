Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB8A2C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 23:53:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7BAC720859
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 23:53:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BAC720859
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 102006B0007; Fri,  9 Aug 2019 19:53:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B4476B0008; Fri,  9 Aug 2019 19:53:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0B4D6B000A; Fri,  9 Aug 2019 19:53:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB9E36B0007
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 19:53:43 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id i134so23393881pgd.11
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 16:53:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=iy3ApUbSFsVUu+rDY7e8675Jr6KP4QqsvffyBDnIWRs=;
        b=Bdp+9e0ARiXlHmp+aS6EDxRGHODeFb7Fnxbte6ak660+WBP8dAXpw0sxCXhzlx6epk
         6APZ/JWMJeOZVu0f3acAoLTVhSSOoiJ05JTf4FlR5HAh5KXlWmYD/piUBbjkueFdr3J1
         3fHksPT+WoPmoCT76/NA4Xstuu4MLEydFshX72X63UdBKNU5QIKF252tcBYVcxOuCwz/
         MmKSVpijg4mzJASjRgCqfdIacgxqUdLKxGBykgrundAtMo9tSL0iOvX0sP3i+K5Owq/e
         l/NJbK2okXhTaEvQYi7xUIneCSNr+cOb78s5DCbtBDZWaosS90p224OmwJYk+MHL75RE
         OZiA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAWJUyDnwtDo3or2bU74MRGA3sTvq5UIEaV7t0NHwsKtkTeBVvBb
	rfwXok46irv9As0O+11xXuvQfT7uiScrX4lE6nN8yli0s5yD9BBhMSfmfIXGFMZNL+mXnjrDIIA
	NBRUKH9j5Y72o4IUYjcsCgZJQO1eS8+rSBcQajsv7gWJm7M7XiVWL59DPNrQg4D0=
X-Received: by 2002:aa7:91d3:: with SMTP id z19mr7913406pfa.135.1565394823294;
        Fri, 09 Aug 2019 16:53:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFJfTNWBcpDhLdvfsBhnWe9TM4vDj/wlBpBjyHQCCNyG/Jm8Pzkybuxh/fa15GEwC0A9fs
X-Received: by 2002:aa7:91d3:: with SMTP id z19mr7913357pfa.135.1565394822420;
        Fri, 09 Aug 2019 16:53:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565394822; cv=none;
        d=google.com; s=arc-20160816;
        b=E7bwnKB4pL1W9fEN1GP4bP9mM2htqf0P+/MaOYuID2TfNx4IQi7J5fie1sVfol+lrE
         RGlYxpRnqbbB4fyXALngEvaW8VZJXmj6+7cT+i8bmS51gtVL8If9W1H0w93wCW71Ahln
         OXn3CIZEN6aBO/TSC1NN35hRiPKIV/I+Sqmq6Y1ZJ9qoMJrDM0fT5+zmFfsudp6yDuRA
         Q7sNosu88WBWdQXUKA+OiF+OtboZFrlciSXHu4OrjFq3CCK14zTIjFMe+C1TF962I/4g
         1kpolXQ1Mk8OgqmLU2jlhjpAKfay6APN93p3F2nFMm68qFLrItQlLyPI8SuzUaaS29lf
         v8Fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=iy3ApUbSFsVUu+rDY7e8675Jr6KP4QqsvffyBDnIWRs=;
        b=tC+sQb1x6eaQr7eP5eAov484tzlQJYbFztAUah8g31plEPmY0sqICkzfl8sOhyUeho
         6r+UispzHy5tUVyLrcD78xRDuUsWoXzyZsnWPI4KdIT4/5rVrQL5p/frhBX5ZH7aUFgi
         +4FgHR0zrGsr240zMc1MxheN4PPMlx9uiqPQet8EDakWjIsezQrHbH1gDzTLQkPg6V5w
         d5EwCSU/O1gnZAE33ZaYPUhizKSmEmwy3vtGWOOCauX2wEemO5p4+edclNJjVbwgJ6jl
         vTMfjFPZwQncCEluRD0fftTypGZzG+PKrhBhs1Xc8rP8ilrHhk0iXyA8l4yq4U2t4zeV
         GjFw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id g9si51445116plm.207.2019.08.09.16.53.41
        for <linux-mm@kvack.org>;
        Fri, 09 Aug 2019 16:53:42 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id DAF307E93B3;
	Sat, 10 Aug 2019 09:53:39 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hwEgR-0001ae-PY; Sat, 10 Aug 2019 09:52:31 +1000
Date: Sat, 10 Aug 2019 09:52:31 +1000
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
Subject: Re: [RFC PATCH v2 01/19] fs/locks: Export F_LAYOUT lease to user
 space
Message-ID: <20190809235231.GC7777@dread.disaster.area>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190809225833.6657-2-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190809225833.6657-2-ira.weiny@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=QyXUC8HyAAAA:8 a=7-415B0cAAAA:8 a=U9j2fOsc8QPwp6X3jq8A:9
	a=CjuIK1q_8ugA:10 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 03:58:15PM -0700, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> In order to support an opt-in policy for users to allow long term pins
> of FS DAX pages we need to export the LAYOUT lease to user space.
> 
> This is the first of 2 new lease flags which must be used to allow a
> long term pin to be made on a file.
> 
> After the complete series:
> 
> 0) Registrations to Device DAX char devs are not affected
> 
> 1) The user has to opt in to allowing page pins on a file with an exclusive
>    layout lease.  Both exclusive and layout lease flags are user visible now.
> 
> 2) page pins will fail if the lease is not active when the file back page is
>    encountered.
> 
> 3) Any truncate or hole punch operation on a pinned DAX page will fail.
> 
> 4) The user has the option of holding the lease or releasing it.  If they
>    release it no other pin calls will work on the file.
> 
> 5) Closing the file is ok.
> 
> 6) Unmapping the file is ok
> 
> 7) Pins against the files are tracked back to an owning file or an owning mm
>    depending on the internal subsystem needs.  With RDMA there is an owning
>    file which is related to the pined file.
> 
> 8) Only RDMA is currently supported
> 
> 9) Truncation of pages which are not actively pinned nor covered by a lease
>    will succeed.

This has nothing to do with layout leases or what they provide
access arbitration over. Layout leases have _nothing_ to do with
page pinning or RDMA - they arbitrate behaviour the file offset ->
physical block device mapping within the filesystem and the
behaviour that will occur when a specific lease is held.

The commit descripting needs to describe what F_LAYOUT actually
protects, when they'll get broken, etc, not how RDMA is going to use
it.

> @@ -2022,8 +2030,26 @@ static int do_fcntl_add_lease(unsigned int fd, struct file *filp, long arg)
>  	struct file_lock *fl;
>  	struct fasync_struct *new;
>  	int error;
> +	unsigned int flags = 0;
> +
> +	/*
> +	 * NOTE on F_LAYOUT lease
> +	 *
> +	 * LAYOUT lease types are taken on files which the user knows that
> +	 * they will be pinning in memory for some indeterminate amount of
> +	 * time.

Indeed, layout leases have nothing to do with pinning of memory.
That's something an application taht uses layout leases might do,
but it largely irrelevant to the functionality layout leases
provide. What needs to be done here is explain what the layout lease
API actually guarantees w.r.t. the physical file layout, not what
some application is going to do with a lease. e.g.

	The layout lease F_RDLCK guarantees that the holder will be
	notified that the physical file layout is about to be
	changed, and that it needs to release any resources it has
	over the range of this lease, drop the lease and then
	request it again to wait for the kernel to finish whatever
	it is doing on that range.

	The layout lease F_RDLCK also allows the holder to modify
	the physical layout of the file. If an operation from the
	lease holder occurs that would modify the layout, that lease
	holder does not get notification that a change will occur,
	but it will block until all other F_RDLCK leases have been
	released by their holders before going ahead.

	If there is a F_WRLCK lease held on the file, then a F_RDLCK
	holder will fail any operation that may modify the physical
	layout of the file. F_WRLCK provides exclusive physical
	modification access to the holder, guaranteeing nothing else
	will change the layout of the file while it holds the lease.

	The F_WRLCK holder can change the physical layout of the
	file if it so desires, this will block while F_RDLCK holders
	are notified and release their leases before the
	modification will take place.

We need to define the semantics we expose to userspace first.....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

