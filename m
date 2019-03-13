Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0699C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:16:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53B77217F5
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 19:16:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="mNs0GLwN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53B77217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 085378E0013; Wed, 13 Mar 2019 15:16:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 05CF08E0001; Wed, 13 Mar 2019 15:16:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB4508E0013; Wed, 13 Mar 2019 15:16:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id C26088E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:16:52 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id z123so2504361qka.20
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:16:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=nvIdXTvdBzRmRwQ0Wlhdqbz4+f72Q75prZrvS08u2DU=;
        b=ugpdebv0KgeMU9xJfpoLXCwXNqNokLzwFQWSko13R8K+qbyTsUfDh4E6yJmc3KpC+X
         WVtE9rofXD1uCTUvTYcqHm/qpEIK/7uizZv+MAKpW+/Mcq9Z3xeMO+8mRp04tOto2I2x
         nOplR+VTxwp21BL+165UiS2rbkrVNET3NwwZEgEqRixX8IQOKvOBzWjhYZlzK0LGZDb9
         ppPVhE+z9kgMzLqt2LjrwbhsvmbjCA2m3P9VVp4tN9a7jaUCe+R9Eazb0casI5K44udj
         UoPhI6cJnlsCmT9h1qiPgmuH6iTv6vkFefKRDeOLCQg93HGHhQWOwpaW23yMAT5nMU6D
         233A==
X-Gm-Message-State: APjAAAUTinkvAGqbvy8BALaorfG03foJVGx7PbHDbiiH/2R1CfwrHTqV
	ZLOvT3feRk7dUjUvt8KlsYTavPDbHm5q+kXjPj031Cl+QmcmRX16Qbkd41h538xT/VXVcs9495B
	DYcIGDAUSLbuIC2/aJUU/sjXiMeY+XROb6nnWTGK5r6vM3a5JQ792RzYZP6FAG2s=
X-Received: by 2002:ac8:2286:: with SMTP id f6mr36416890qta.68.1552504612594;
        Wed, 13 Mar 2019 12:16:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVtPYD8NqOq/qLlghttgVOizbhQ2Qfg4OlySYOCxVjIbMDFsI/s2caZec/cHCHAWByW4/K
X-Received: by 2002:ac8:2286:: with SMTP id f6mr36416854qta.68.1552504611885;
        Wed, 13 Mar 2019 12:16:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552504611; cv=none;
        d=google.com; s=arc-20160816;
        b=JYPl+gmhTkft9bTqGNjh+v5R8dW+l6tYh1BxqoNcDxG8PReQkY20Hys3uXnPwrwZUm
         1fI/oeh91QQoImQAdWAPMARBSLgoJVeZdkMMLz3VJ9tJvpQhO/1arV80NA/TvphFka52
         a2bpOKSj5NuF1Ocz6U/UNO2KRRv/gQ9zUAG0wQcDZHFRiwlPqfqjr7Xe2f7sB9hBZxxC
         s7/sWB/XMjaEUPWATLw4jipLdv04gcC+LkI+rPuYMg9BO4VqRoVhJSbpLw3Hw/yp9RRK
         vTrdqYS3urvRKkSBc7AHhpIrK7gfibbGKYtC0yfdO7GQT0U9fgsKaBvBJTlNX9QHoq69
         y/Yw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=nvIdXTvdBzRmRwQ0Wlhdqbz4+f72Q75prZrvS08u2DU=;
        b=sh4wromrLo9PN4wwXN7UBguzzBvMx0WGLE+eQj3f28+H8+hmH/Qt1H2ATApRtMIRPV
         DyFePRpkrGFqZN7WPQW5pOdblUxLNfKYIVip6ub4Lqd4oOXeiyGz8Fjspt6NUylD6Vvm
         Zsfx0HllJfhFMFvj4LItdTUvhaW7LDnSEf/icztiF7CgkjaBOrunIIm9g+ODpTHaJ9c6
         v/iHCvRAx69e7fUr+i8CPr84QDbjIant8K+Hpqfze+8mfW360dLp3UHzRVgYSspRJWlZ
         bREE0lruq23FvkWxjC/EvCkdlozHksdDCmm+mwipEsso6PyQ7rk6zdj7/SPA//3bWNAf
         yAcw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=mNs0GLwN;
       spf=pass (google.com: domain of 01000169787c61d0-cbc5486e-960a-492f-9ac9-9f6a466efeed-000000@amazonses.com designates 54.240.9.33 as permitted sender) smtp.mailfrom=01000169787c61d0-cbc5486e-960a-492f-9ac9-9f6a466efeed-000000@amazonses.com
Received: from a9-33.smtp-out.amazonses.com (a9-33.smtp-out.amazonses.com. [54.240.9.33])
        by mx.google.com with ESMTPS id 21si128081qtz.60.2019.03.13.12.16.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Mar 2019 12:16:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169787c61d0-cbc5486e-960a-492f-9ac9-9f6a466efeed-000000@amazonses.com designates 54.240.9.33 as permitted sender) client-ip=54.240.9.33;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=mNs0GLwN;
       spf=pass (google.com: domain of 01000169787c61d0-cbc5486e-960a-492f-9ac9-9f6a466efeed-000000@amazonses.com designates 54.240.9.33 as permitted sender) smtp.mailfrom=01000169787c61d0-cbc5486e-960a-492f-9ac9-9f6a466efeed-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1552504611;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=nvIdXTvdBzRmRwQ0Wlhdqbz4+f72Q75prZrvS08u2DU=;
	b=mNs0GLwNl9xKR1X8gnj67r8fWgIFpKPvdnFupmcR/v1TqCwF+zAL9fq7tlL4mJj1
	prV0RUzPw/4sHohhMDsy7feO6rSMkyFpihUsF/I+bEn4+zKOiD6lv1BPOwb3WLblNoE
	6eeLXu7iSI62MppM0eQYFX/LSlNl39r960DEmpQU=
Date: Wed, 13 Mar 2019 19:16:51 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Jerome Glisse <jglisse@redhat.com>
cc: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>, 
    linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>, 
    Christian Benvenuti <benve@cisco.com>, 
    Christoph Hellwig <hch@infradead.org>, 
    Dan Williams <dan.j.williams@intel.com>, 
    Dave Chinner <david@fromorbit.com>, 
    Dennis Dalessandro <dennis.dalessandro@intel.com>, 
    Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>, 
    Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, 
    Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, 
    Mike Rapoport <rppt@linux.ibm.com>, 
    Mike Marciniszyn <mike.marciniszyn@intel.com>, 
    Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, 
    LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, 
    John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v3 0/1] mm: introduce put_user_page*(), placeholder
 versions
In-Reply-To: <20190312153528.GB3233@redhat.com>
Message-ID: <01000169787c61d0-cbc5486e-960a-492f-9ac9-9f6a466efeed-000000@email.amazonses.com>
References: <20190306235455.26348-1-jhubbard@nvidia.com> <010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@email.amazonses.com> <20190308190704.GC5618@redhat.com> <01000169703e5495-2815ba73-34e8-45d5-b970-45784f653a34-000000@email.amazonses.com>
 <20190312153528.GB3233@redhat.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.13-54.240.9.33
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Mar 2019, Jerome Glisse wrote:

> > > This has been discuss extensively already. GUP usage is now widespread in
> > > multiple drivers, removing that would regress userspace ie break existing
> > > application. We all know what the rules for that is.

You are still misstating the issue. In RDMA land GUP is widely used for
anonyous memory and memory based filesystems. *Not* for real filesystems.

> > Because someone was able to get away with weird ways of abusing the system
> > it not an argument that we should continue to allow such things. In fact
> > we have repeatedly ensured that the kernel works reliably by improving the
> > kernel so that a proper failure is occurring.
>
> Driver doing GUP on mmap of regular file is something that seems to
> already have widespread user (in the RDMA devices at least). So they
> are active users and they were never told that what they are doing
> was illegal.

Not true. Again please differentiate the use cases between regular
filesystem and anonyous mappings.

> > Well swapout cannot occur if the page is pinned and those pages are also
> > often mlocked.
>
> I would need to check the swapout code but i believe the write to disk
> can happen before the pin checks happens. I believe the event flow is:
> map read only, allocate swap, write to disk, try to free page which
> checks for pin. So that you could write stale data to disk and the GUP
> going away before you perform the pin checks.

Allocate swap is a separate step that associates a swap entry to an
anonymous page.

> They are other thing to take into account and that need proper page
> dirtying, like soft dirtyness for instance.

RDMA mapped pages are all dirty all the time.

> Well RDMA driver maintainer seems to report that this has been a valid
> and working workload for their users.

No they dont.

Could you please get up to date on the discussion before posting?

