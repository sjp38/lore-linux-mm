Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8662AC282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 19:30:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 416FF217D6
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 19:30:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="VVg9xA+D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 416FF217D6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D1A878E009A; Tue,  5 Feb 2019 14:30:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC9288E001C; Tue,  5 Feb 2019 14:30:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB88C8E009A; Tue,  5 Feb 2019 14:30:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8F8458E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 14:30:23 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id k66so4236908qkf.1
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 11:30:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=1g+4fGMKS1keHsjyRZr7fNCTBzxy3TOyG/OyE5vxvSk=;
        b=DQ0DZ2jNXwkWFIl3bxYK9xUC2zqaKky7xA5TYCWnen+dZtGleOtP1+ivh7r911upFR
         01DLo8mjuehelTweWrjaa3b9KIbp6DWMsemd3Z6TN60AfIw+AYsBa/6kKmjHThsvvFok
         MJ6/vJHhL29Y/tIJTVkLMDy4h0G2C9VrLhXo1pTfFMcZ3CMrxQI2S5FuBiJ5o/aOHsfT
         4FvQrOmsHVuvRdyRU6Jp0RC4jcugQR3+RCJfrl6tqeZ+So7f5i+89ff2muHbxMRlftSK
         7XQ1kD8cFTTC2T2szXENwmSjTy9HBkGBJfwHZqENgPbZzFN1A519Onjn+DxSID9r/k/p
         JvJw==
X-Gm-Message-State: AHQUAubK55yZXXem7tvTs5u25u5wQUNh8srjSSdYw21Oyl6r1VfAaIGj
	CvCuR4bJ/Rlt4J8WhnXdb10gC03wSt2rq2LUm1NrY2X6kzkzeyQSwrzgILoJJx/fWUmcG4k3m17
	DED7EXZ8ABlqDlrMh0Ur0a9s0souIYiC/9IaePaTtO/gEF6XJQOn+1U6VhRQO7LY=
X-Received: by 2002:a37:6f85:: with SMTP id k127mr4754024qkc.240.1549395023252;
        Tue, 05 Feb 2019 11:30:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZVeTgWYDaAM0QImjBpzoO6YY3S9RR0LQSUW6hYBVFcPGUBdtyp6XpputY3WYITAyUAfaqM
X-Received: by 2002:a37:6f85:: with SMTP id k127mr4754004qkc.240.1549395022719;
        Tue, 05 Feb 2019 11:30:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549395022; cv=none;
        d=google.com; s=arc-20160816;
        b=RU0mEruqTJTI3rUwwUMYmv58E/LAEmkocGxesVjFBPLeN7JPtcocLh55twnnZdlodE
         MZGKZwy57uQ2cYh/bD8RlO50Zot5b89GeHbysNlZ6r6d5FBqrlmq6P69wNhAf9JfmXrQ
         tIvaTeSD3wqt5/OvjZ2SAEBfPlbrFrB4LkSxHT5gC2LeTDoEHvsSea4rM4SAQdPOETkj
         h0LZT9MkneGefguuuAkZTIaTTMsMGEGPLEvCm9w8gFSkszCCFint4O15HqHBW0T0NBJt
         KE+EJt0UKz7rLOppvQcRJz+YfGDEBXclh/Kzbf8vn2L6kLCvTIKqyKeb787gXKIgxZk0
         uC3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=1g+4fGMKS1keHsjyRZr7fNCTBzxy3TOyG/OyE5vxvSk=;
        b=R73542uA/17PYrvjYpGyi6QCUFiBuWdbVpcvkvrKiYrMM5beVS2n058p2ar4CsCinr
         qExv0yaI/poivmezwdtH6BfKfpRV0SkLg48SG35m6tHm71pMPU+QadG6zLtwPHbuxdIr
         NG5zQhtjV23yln4+3Hwh578OG8HG1eaneVHOr36cfZTE13J8BuMdC1eH2dvN2Lag5YMc
         Mm8lD2Wq/f9l6Ya1TZb5N/trMY5UKSkVgzSfnGk93LabrS6gSyXjbjpbb7bV9JkjZOuG
         aYEAGVvSNrVMppw8i76ip3M99L+FeKxbuYdmsUm+fKHvQPTC8t1gc5o444syHZHzzzON
         91dw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=VVg9xA+D;
       spf=pass (google.com: domain of 01000168bf23d0fa-f96456c7-8569-4542-9926-f91baa3c0f06-000000@amazonses.com designates 54.240.9.112 as permitted sender) smtp.mailfrom=01000168bf23d0fa-f96456c7-8569-4542-9926-f91baa3c0f06-000000@amazonses.com
Received: from a9-112.smtp-out.amazonses.com (a9-112.smtp-out.amazonses.com. [54.240.9.112])
        by mx.google.com with ESMTPS id e24si3414716qtp.141.2019.02.05.11.30.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Feb 2019 11:30:22 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168bf23d0fa-f96456c7-8569-4542-9926-f91baa3c0f06-000000@amazonses.com designates 54.240.9.112 as permitted sender) client-ip=54.240.9.112;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=VVg9xA+D;
       spf=pass (google.com: domain of 01000168bf23d0fa-f96456c7-8569-4542-9926-f91baa3c0f06-000000@amazonses.com designates 54.240.9.112 as permitted sender) smtp.mailfrom=01000168bf23d0fa-f96456c7-8569-4542-9926-f91baa3c0f06-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1549395022;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=YJTd4VU+NL7d41BJd/g/275y6kyES9bTfQmjZG0ZH+I=;
	b=VVg9xA+DkL+JMOKCvFEIsD3XF1phH2CCO/7+guj4mnZ3H1lP6Pn4EiG7M3TNes+Q
	F+/9xWOc2jtDS9z+NpYZrsT3EvFzypd6UNaSuc8OcyeiKqsf8uP8RLqRn+5P+soDC2E
	o4/78BCE2H2py7WW36QP0n1XyVmiXR+H7uHrRwh4=
Date: Tue, 5 Feb 2019 19:30:22 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Ira Weiny <ira.weiny@intel.com>
cc: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>, 
    linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>, 
    Christian Benvenuti <benve@cisco.com>, 
    Christoph Hellwig <hch@infradead.org>, 
    Dan Williams <dan.j.williams@intel.com>, 
    Dave Chinner <david@fromorbit.com>, 
    Dennis Dalessandro <dennis.dalessandro@intel.com>, 
    Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>, 
    Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, 
    Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, 
    Mike Rapoport <rppt@linux.ibm.com>, 
    Mike Marciniszyn <mike.marciniszyn@intel.com>, 
    Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, 
    LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, 
    John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 0/6] RFC v2: mm: gup/dma tracking
In-Reply-To: <20190204233513.GA7917@iweiny-DESK2.sc.intel.com>
Message-ID: <01000168bf23d0fa-f96456c7-8569-4542-9926-f91baa3c0f06-000000@email.amazonses.com>
References: <20190204052135.25784-1-jhubbard@nvidia.com> <01000168b980e880-a7d8e0db-84fb-4398-8269-149c66b701b4-000000@email.amazonses.com> <20190204233513.GA7917@iweiny-DESK2.sc.intel.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.05-54.240.9.112
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 4 Feb 2019, Ira Weiny wrote:

> On Mon, Feb 04, 2019 at 05:14:19PM +0000, Christopher Lameter wrote:
> > Frankly I still think this does not solve anything.
> >
> > Concurrent write access from two sources to a single page is simply wrong.
> > You cannot make this right by allowing long term RDMA pins in a filesystem
> > and thus the filesystem can never update part of its files on disk.
> >
> > Can we just disable RDMA to regular filesystems? Regular filesystems
> > should have full control of the write back and dirty status of their
> > pages.
>
> That may be a solution to the corruption/crashes but it is not a solution which
> users want to see.  RDMA directly to file systems (specifically DAX) is a use
> case we have seen customers ask for.

DAX is a special file system that does not use writeback for the DAX
mappings. Thus it could be an exception. And the pages are already pinned.



