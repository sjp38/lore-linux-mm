Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5B85C282DA
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 19:16:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80EAE218B0
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 19:16:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="VJLzZzDJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80EAE218B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BDCF8E00EF; Wed,  6 Feb 2019 14:16:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16CFF8E00EE; Wed,  6 Feb 2019 14:16:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05C5F8E00EF; Wed,  6 Feb 2019 14:16:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id D37528E00EE
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 14:16:22 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id x125so7223504qka.17
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 11:16:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=9isjYD3tDqSs6ntkDZQPz51nVFSZOituqfkcmLlMU/s=;
        b=awE3ph9Bis0XH5UCV++rIaQz468xdvNptKQKU0qYNPrfIFnEWmDGJNurVM0eo8cixl
         pWsrIvuenyMluQaG5hbSqc2fPpKgY6BZ4WOTLJSTS9x8A9wAUSLwbVWBlIk47sRYK8bj
         AlHCOWKYkCmz9kClXUTdoVgt/CvRbKmWiKRfakWI8MEl67Wei20U/ZAfDWNDI5jIOFO0
         c9B/S1eRzER1xLDgssexCKGQMww5zbw79utwTLh4sIF1wIVuVr71x43qswRLS0u/xK1V
         SdKZWpG0+MxTNRPx0sIIcdtxc4rsPYgyRlZ38rBI/1Gw/KfL8EYzDNPMTaadIrDmF+2Q
         1iJw==
X-Gm-Message-State: AHQUAubPwpVRtmiNUJcH3bo03UZ3MJxt29slXB7hGzk46SkG2TrSxsh8
	VlDk74jLm88sJjzwN6csmxdhbdijQNnk5fQvtDTy5b1crUyOZ4XSeHv+ll1qXTC/2hqw3gRUCBD
	c1KRKAEY4EN9UD2aNSoPIBgWxJ8SrQJm09y4n2/VGpjlnNgxrvJVPUTYuU8sQLVk=
X-Received: by 2002:a37:a147:: with SMTP id k68mr8710834qke.190.1549480582583;
        Wed, 06 Feb 2019 11:16:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaUyh5uuF8kEIoO5BJtm1MDlEJhRyobtIRoOgHoIsbouEtK73Dw7bFJ4JIZqv9rLWjWBAT3
X-Received: by 2002:a37:a147:: with SMTP id k68mr8710805qke.190.1549480582103;
        Wed, 06 Feb 2019 11:16:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549480582; cv=none;
        d=google.com; s=arc-20160816;
        b=sNgZeqPinI1cP9zEzX96eIuR9EEleSx9iVEMF1OXX/6VckInHfrXl4GEcaqsmW8RsQ
         AoP5Kp/C/XkQINlLy2GspKE3jonD68JrrzZqQDzbUiXKOLMBR6ZPWnRfL8cayFWfZVkv
         /ujqOebr2ir6aGI8SLfpVLdfkR0wCtpK6tg9mSle5QVVhr5TaKP9B8qpEu6NZ+FRACp4
         olLxKLJdfRW+Hd690M6bYDMR3jBURv5MvATEmhf1peEd7t0IGHQ2jL9wNwXCkvX8eIEZ
         MF+/9HM2fs/wWxTO6rw4Sg1PuxstUqrIUrvHGcTMvi39Q9MSeOlmxOxcbWIVWZtJwX6U
         XK8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=9isjYD3tDqSs6ntkDZQPz51nVFSZOituqfkcmLlMU/s=;
        b=CzyCcaHFo5g3mE4IlEqHExTk2t/OFd90tUPId2lYVaAAWRsWBnNMgj/ZLaTjTKo2E4
         SaYXcRtz6Xhtzajz+m74qnWp/O98l+PjwGAEg8pWDrAxVPpxUEsyKpDmgKD+ZnXIwYl2
         t7/igszTG89P9CD+ctYHsaGe4M/OtOOlEroN19Bwq+bJVJFkeI063Mmxymhwx/WaistC
         6CZTzIDg8cJHUjlWGEyk/uNAubUTByyLBfrYtvCNNOXy5sKTNnvXmWIrI/mTfjN9fMJh
         2ueCLfJku5oNXi0X5KsASw6tjjKP+EQJHx2KNY+kG9v2+taU6vO8rvzxuiWo2pGJC8Dy
         u61g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=VJLzZzDJ;
       spf=pass (google.com: domain of 01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@amazonses.com designates 54.240.9.33 as permitted sender) smtp.mailfrom=01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@amazonses.com
Received: from a9-33.smtp-out.amazonses.com (a9-33.smtp-out.amazonses.com. [54.240.9.33])
        by mx.google.com with ESMTPS id y25si4616426qvc.14.2019.02.06.11.16.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 06 Feb 2019 11:16:22 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@amazonses.com designates 54.240.9.33 as permitted sender) client-ip=54.240.9.33;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=VJLzZzDJ;
       spf=pass (google.com: domain of 01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@amazonses.com designates 54.240.9.33 as permitted sender) smtp.mailfrom=01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1549480581;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=znIZuWNF4X3qMOcXoMBkQ62oatbaP8owCgJHWHXID7U=;
	b=VJLzZzDJARHqbWqB+oPbQUvfBw3ad4uMs5V9EZ6Sxrql4TaUUv54mEAg6vkqb2wp
	hJ+8gmBbIEEET+f2gIwCeApJpoU8ID418zMmx4PlsqnaxKp/hhvS5vfXcdC5L/9tWVT
	lH1yxIoaaol35eryN2nGrJnPhI272qHM6o7zat1A=
Date: Wed, 6 Feb 2019 19:16:21 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Doug Ledford <dledford@redhat.com>
cc: Matthew Wilcox <willy@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>, 
    Jan Kara <jack@suse.cz>, Ira Weiny <ira.weiny@intel.com>, 
    lsf-pc@lists.linux-foundation.org, linux-rdma@vger.kernel.org, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
    John Hubbard <jhubbard@nvidia.com>, Jerome Glisse <jglisse@redhat.com>, 
    Dan Williams <dan.j.williams@intel.com>, 
    Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving longterm-GUP
 usage by RDMA
In-Reply-To: <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
Message-ID: <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com> <20190206095000.GA12006@quack2.suse.cz> <20190206173114.GB12227@ziepe.ca> <20190206175233.GN21860@bombadil.infradead.org> <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.06-54.240.9.33
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Feb 2019, Doug Ledford wrote:

> > Most of the cases we want revoke for are things like truncate().
> > Shouldn't happen with a sane system, but we're trying to avoid users
> > doing awful things like being able to DMA to pages that are now part of
> > a different file.
>
> Why is the solution revoke then?  Is there something besides truncate
> that we have to worry about?  I ask because EBUSY is not currently
> listed as a return value of truncate, so extending the API to include
> EBUSY to mean "this file has pinned pages that can not be freed" is not
> (or should not be) totally out of the question.
>
> Admittedly, I'm coming in late to this conversation, but did I miss the
> portion where that alternative was ruled out?

Coming in late here too but isnt the only DAX case that we are concerned
about where there was an mmap with the O_DAX option to do direct write
though? If we only allow this use case then we may not have to worry about
long term GUP because DAX mapped files will stay in the physical location
regardless.

Maybe we can solve the long term GUP problem through the requirement that
user space acquires some sort of means to pin the pages? In the DAX case
this is given by the filesystem and the hardware will basically take care
of writeback.

In case of anonymous memory this can be guaranteed otherwise and is less
critical since these pages are not part of the pagecache and are not
subject to writeback.


