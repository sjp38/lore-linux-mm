Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEEDEC169C4
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 15:33:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 782462080F
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 15:33:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="DcdwDK8G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 782462080F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D0B58E0090; Fri,  8 Feb 2019 10:33:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07F238E0002; Fri,  8 Feb 2019 10:33:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED7178E0090; Fri,  8 Feb 2019 10:33:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id C152E8E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 10:33:51 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id d13so3890212qth.6
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 07:33:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=dudYlflGa1PTisipnwJdjwuKifAFehwnAnNXxUD3VNA=;
        b=lF2K/HBYjW8egnZ66tro+UxYKf6gfmAYkOxEq49WnLqbRvTIOnWwZMg+UkDn7NugYE
         wvIa2vRN+1+jHhdTioXoIY6sGnEvbtJosqh9oVxZk5qMcWiJnMpXAkxYffv5Te5txoX+
         QEzH1Fq5eJsGybbZCEA4WazxVtesPKH9bG4q8n2GYRngqw8iE2W/+eNCwnKJ8n0z+kyh
         itZAr7HUzd1QMxx9aOaxByvjD1H4TKHI6Jtmb3lgRVw+B8nw7/0xL4pIgSZdB9KOCrJQ
         9U4tu0A9yJYP77wh/auDrVf938UaXmQcksl7VvYP+GCw7n/IrKJsDPQjeycXT7S+Bpf/
         TFBw==
X-Gm-Message-State: AHQUAuZTlv7VpgQAJmS4SqXa6ZDfQBrcj4hKQg5ORD1SeX/LtTIeMjQC
	VEzFBNlR+k6BHFkl0HOVWUNUVDOdyvsvtwDbj4pFy8f00tEpUmH0GvgUMCFSC0Ag3dOhMZjMVTC
	ojdEue7TftujTOoeOwc5JyCZhW0VC2FjG66DMBA43rt+9N3mnzI46nM3NpGxLOjY=
X-Received: by 2002:a0c:9873:: with SMTP id e48mr12211542qvd.42.1549640030398;
        Fri, 08 Feb 2019 07:33:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ3nNjuss1dXiu0olgh6L/M5Q1DDEmAql0//RiFb7wKJ6txirEOH7lI1l9mp1C5aQ9w/v4b
X-Received: by 2002:a0c:9873:: with SMTP id e48mr12211492qvd.42.1549640029555;
        Fri, 08 Feb 2019 07:33:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549640029; cv=none;
        d=google.com; s=arc-20160816;
        b=mcJz24L85GkutiyKekguFl4v7L1pBcpSmJohSZwhinfXhYKzIfpU2uA7aoA6USX4bR
         ++vZOeURGfNUjrTivLoWiF9OO/J7GYvBl6MnkjEzxU1Vu3RAkexndRBb8kpiQv1ZIftq
         Mwp1UdTi4FWQFqUyjr/b420ka6qyMtLMmnyjkordK1TAhV4CbkIFVHKwVHdeI39fNQ1x
         6mX4XpxN9ajQPG3trNmbmvXJVrxQm9HACOuhzbevGyB7Ha0r7kAnBBKtlAPu3Avo5cSw
         ak7/ikJZPdXvjFl+DaZltYr8eM4eKlnBggEyGSxoH/yw0SdFaVSWJg3n2e48GsdjgzLN
         vrRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=dudYlflGa1PTisipnwJdjwuKifAFehwnAnNXxUD3VNA=;
        b=m+mjdou8O9oPOJvYNTOGs+LBCsLPdJGChe5CxhjWrRCcaQzIqz0ij40u7GSgSiyZHY
         8wArkBRmPhp1LwLUwh0FRAtKHH9mUhUdIGDZSC5hC+6Np8X5BKzDhcjv0QhL8tD5xZJS
         IXJL3m0Me/fS6M2q5DIYOXkkhVNVV81Hls12ddu/GEKlgeHK/xrRGnBE3GBaWD8NiRII
         Vp4GNi3eM+7BwZp9XV5tzvjuj56rwJvj1yDyyIbC5LytizbaSur0J/bAkRrUsO5F4Udh
         wPhOZi67vEvTyWcbud5vJP1dYAi/W8qCy2orLi8Ijzxgh1lwJe2qeEyM8Ipwlt1FYIbK
         Zr9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=DcdwDK8G;
       spf=pass (google.com: domain of 01000168cdbe520b-2b2be741-8ceb-4a5d-92f2-9f68795d7db3-000000@amazonses.com designates 54.240.9.35 as permitted sender) smtp.mailfrom=01000168cdbe520b-2b2be741-8ceb-4a5d-92f2-9f68795d7db3-000000@amazonses.com
Received: from a9-35.smtp-out.amazonses.com (a9-35.smtp-out.amazonses.com. [54.240.9.35])
        by mx.google.com with ESMTPS id y20si1682765qvc.145.2019.02.08.07.33.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 08 Feb 2019 07:33:49 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168cdbe520b-2b2be741-8ceb-4a5d-92f2-9f68795d7db3-000000@amazonses.com designates 54.240.9.35 as permitted sender) client-ip=54.240.9.35;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=DcdwDK8G;
       spf=pass (google.com: domain of 01000168cdbe520b-2b2be741-8ceb-4a5d-92f2-9f68795d7db3-000000@amazonses.com designates 54.240.9.35 as permitted sender) smtp.mailfrom=01000168cdbe520b-2b2be741-8ceb-4a5d-92f2-9f68795d7db3-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1549640028;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=YzFUGu859kPEo2hZyafj6+czbU6iIrLvVd2hSFt0EA0=;
	b=DcdwDK8GKlrlp+j/BPj49Ohwy5qY4VbMcl1vFGR69Au2TBSk47MucreBAWCc/qIM
	oKa96zjU9ZDlHhlf3j+o6aYmPUWAjAuZnFWwo6Ln1lLfSreZPnALHsN9wQvK0WYnnUV
	eEb2bAdYLQaF0V1pEq/QP6B5FwSq0xolmm5GhEI4=
Date: Fri, 8 Feb 2019 15:33:48 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Dave Chinner <david@fromorbit.com>
cc: Doug Ledford <dledford@redhat.com>, 
    Dan Williams <dan.j.williams@intel.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
    Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, 
    Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org, 
    linux-rdma <linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
    Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
    John Hubbard <jhubbard@nvidia.com>, Jerome Glisse <jglisse@redhat.com>, 
    Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving longterm-GUP
 usage by RDMA
In-Reply-To: <20190208044302.GA20493@dastard>
Message-ID: <01000168cdbe520b-2b2be741-8ceb-4a5d-92f2-9f68795d7db3-000000@email.amazonses.com>
References: <20190206173114.GB12227@ziepe.ca> <20190206175233.GN21860@bombadil.infradead.org> <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com> <01000168c43d594c-7979fcf8-b9c1-4bda-b29a-500efe001d66-000000@email.amazonses.com> <20190206210356.GZ6173@dastard>
 <20190206220828.GJ12227@ziepe.ca> <0c868bc615a60c44d618fb0183fcbe0c418c7c83.camel@redhat.com> <CAPcyv4hqya1iKCfHJRXQJRD4qXZa3VjkoKGw6tEvtWNkKVbP+A@mail.gmail.com> <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com> <20190208044302.GA20493@dastard>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.08-54.240.9.35
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 8 Feb 2019, Dave Chinner wrote:

> On Thu, Feb 07, 2019 at 04:55:37PM +0000, Christopher Lameter wrote:
> > One approach that may be a clean way to solve this:
> > 3. Filesystems that allow bypass of the page cache (like XFS / DAX) will
> >    provide the virtual mapping when the PIN is done and DO NO OPERATIONS
> >    on the longterm pinned range until the long term pin is removed.
>
> So, ummm, how do we do block allocation then, which is done on
> demand during writes?

If a memory region is mapped by RDMA then this is essentially a long
write. The allocation needs to happen then.

> IOWs, this requires the application to set up the file in the
> correct state for the filesystem to lock it down so somebody else
> can write to it.  That means the file can't be sparse, it can't be
> preallocated (i.e. can't contain unwritten extents), it must have zeroes
> written to it's full size before being shared because otherwise it
> exposes stale data to the remote client (secure sites are going to
> love that!), they can't be extended, etc.

Yes. That is required.

> IOWs, once the file is prepped and leased out for RDMA, it becomes
> an immutable for the purposes of local access.

The contents are mutable but the mapping to the physical medium is
immutable.


> Which, essentially we can already do. Prep the file, map it
> read/write, mark it immutable, then pin it via the longterm gup
> interface which can do the necessary checks.
>
> Simple to implement, the reasons for errors trying to modify the
> file are already documented and queriable, and it's hard for
> applications to get wrong.

Yup. Why not do it this way? Just make the sections actually long term GUP
mapped inmutable and not subject to the other page cache things.

This is basically a straight through bypass of the page cache for a file.

HEY! It may be used to map huge pages in the future too!!

