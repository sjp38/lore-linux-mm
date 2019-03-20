Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48C23C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 01:01:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D69FB2175B
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 01:01:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="YjBUampI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D69FB2175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FE156B0003; Tue, 19 Mar 2019 21:01:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 584356B0006; Tue, 19 Mar 2019 21:01:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 425846B0007; Tue, 19 Mar 2019 21:01:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 172066B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 21:01:08 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id n64so19512821qkb.0
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 18:01:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=Qm0r/S4Ne4XTZAHDLismxE9m3x/wdarSZ1AUHvBMnnQ=;
        b=tJAbf4/dkPoedOrH/lCMyqDsbzNRCcKaLTckO77giS4eiYsJLWrBl1JtUMPQVbgCX5
         km9cwi4PrR4Vhestjh5Xs+smaFR6yaV7PGvg/zIgghthtk4iTiVbD3TQr+Vt37fS+2L4
         ZEbHWQq5wXiriqVBfDMO0WEwtz1otfsYi0nzq3Dfviw1Shy/iFrFx+bhk5xeGtddwBbW
         9xglYUSoQT7NtdQdwMXJ1EGH1dgXXUneMoaVLArf/OZULmbwuuDvWV1mV2JzBntdBwa0
         sG/iRGizq717um1QuWxHXDZU+vFCaGG4Qi2IO08mhjMAqdTk6uA6BJsDVF3Vb9cqgsb9
         i5mQ==
X-Gm-Message-State: APjAAAULNDTI00574yyiMEEz3buc8+gl4BsOJlEmLiU/gChIZh3VISor
	ghd5j53kLD/esCtzO4i0xk5smE4dn39XHAiNFR76otYjjGVD7gZpNhU4PgtfRNAZpxvu8SfWbVY
	sV7tFdRBgQRnpvLDXw13Vx5uzDdYrAw5FlE+E5AMpJA5e5WQyiOI+ZIrNozzgHYk=
X-Received: by 2002:aed:23b4:: with SMTP id j49mr4721247qtc.175.1553043667807;
        Tue, 19 Mar 2019 18:01:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgHtGGvyid1LOFtgTkp6nKKhQ7nnFDCgvtMTKk5nQqDwQux87BeVSMNI6SQJF2+4Ja8U/N
X-Received: by 2002:aed:23b4:: with SMTP id j49mr4721189qtc.175.1553043667057;
        Tue, 19 Mar 2019 18:01:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553043667; cv=none;
        d=google.com; s=arc-20160816;
        b=w4bG4tuBPzHJWr7/wytamF6O86MNtDi6/OsZf2ODRsXx99SnUkSBNk5lCu5GcU+Ogw
         XQ7aZhnTAvSCqzx63q57cBffmSwNJoeyuRMtiTvwM5Fk3s0tmKm9ISj0kZXSgwp/birv
         +bdgSSTlAKW8hUOG19Yxk8f0DuYEr0wwBBZBqRtb8unaqxmvVequZwkdWbTi2nnpImtf
         55vLUsmnxs8fr/FLFFdaXgp3J112GkFUnH6paEah4ZmZYqYPLSAklfV7KeISLLAdaXUK
         /papMPMUsf65QPKcdr7OU0bDCYJIpCNVWoJYQKCh0sj1QAvlTHqZTmBgT1f+Q1RJDuzX
         LKNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=Qm0r/S4Ne4XTZAHDLismxE9m3x/wdarSZ1AUHvBMnnQ=;
        b=Kf3JratzLa6SO4zM5iqARa2DFg3hq9aRekUxP2wUG0ew/LE0Rxczr5RSvGRzMeLaVb
         JYLWWK8hllNsu1zc96o9w0IkFQiedHSGF4BwX0Ksi3GwoEMb3uf+WCdi7psp67EgvDF7
         EyauMgsR2d7F7LxRbzy37pmUDe4C/SRwFQXHvnMnjkAOtV+l2enj/kIepkPKrZI8krB2
         STSwQ8hBAA5TaccR09gHUvddf2b4laYN6P9JX6fs3I7SU6OxnlGAIAQTJXA74vfHKj2V
         5+Az0L58SbEeb0HRtRDAUULnfiv/iJ3EQMGSi5Jmj25EqYcsjhDwXghQtYQ1FJF+C0IJ
         Aaug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=YjBUampI;
       spf=pass (google.com: domain of 01000169989db656-8868a4b2-a8eb-4666-872f-2ed9885c99e6-000000@amazonses.com designates 54.240.9.92 as permitted sender) smtp.mailfrom=01000169989db656-8868a4b2-a8eb-4666-872f-2ed9885c99e6-000000@amazonses.com
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id t25si332290qtb.354.2019.03.19.18.01.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 19 Mar 2019 18:01:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of 01000169989db656-8868a4b2-a8eb-4666-872f-2ed9885c99e6-000000@amazonses.com designates 54.240.9.92 as permitted sender) client-ip=54.240.9.92;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=YjBUampI;
       spf=pass (google.com: domain of 01000169989db656-8868a4b2-a8eb-4666-872f-2ed9885c99e6-000000@amazonses.com designates 54.240.9.92 as permitted sender) smtp.mailfrom=01000169989db656-8868a4b2-a8eb-4666-872f-2ed9885c99e6-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1553043666;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=Qm0r/S4Ne4XTZAHDLismxE9m3x/wdarSZ1AUHvBMnnQ=;
	b=YjBUampIgq93H7NdpjoHwlbka+MNSa7HfbivjdfJz2BjHertUJNb19GG8bNMjG+N
	iF35ywDLZrnkqgecUxB12DQFn/81gops112YhDaaLzDBYIwTlS8+I+gs1fhkLMhugh0
	f8t9ZHIseriw4WNyToiVQfCpkHirywg0aSE2ezwA=
Date: Wed, 20 Mar 2019 01:01:06 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Dave Chinner <david@fromorbit.com>
cc: Jerome Glisse <jglisse@redhat.com>, 
    "Kirill A. Shutemov" <kirill@shutemov.name>, john.hubbard@gmail.com, 
    Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
    Al Viro <viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, 
    Christoph Hellwig <hch@infradead.org>, 
    Dan Williams <dan.j.williams@intel.com>, 
    Dennis Dalessandro <dennis.dalessandro@intel.com>, 
    Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>, 
    Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, 
    Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, 
    Mike Rapoport <rppt@linux.ibm.com>, 
    Mike Marciniszyn <mike.marciniszyn@intel.com>, 
    Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, 
    LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, 
    John Hubbard <jhubbard@nvidia.com>, Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v4 1/1] mm: introduce put_user_page*(), placeholder
 versions
In-Reply-To: <20190319235752.GB26298@dastard>
Message-ID: <01000169989db656-8868a4b2-a8eb-4666-872f-2ed9885c99e6-000000@email.amazonses.com>
References: <20190308213633.28978-1-jhubbard@nvidia.com> <20190308213633.28978-2-jhubbard@nvidia.com> <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1> <20190319134724.GB3437@redhat.com> <20190319141416.GA3879@redhat.com> <20190319212346.GA26298@dastard>
 <20190319220654.GC3096@redhat.com> <20190319235752.GB26298@dastard>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.20-54.240.9.92
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Mar 2019, Dave Chinner wrote:

> So the plan for GUP vs writeback so far is "break fsync()"? :)

Well if its an anonymous page and not a file backed page then the
semantics are preserved. Disallow GUP long term pinning (marking stuff like in this
patchset may make that possible) and its clean.

