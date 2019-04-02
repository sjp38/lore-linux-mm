Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61F3CC4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 19:49:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09C522075E
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 19:49:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09C522075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A4006B0273; Tue,  2 Apr 2019 15:49:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 553636B0274; Tue,  2 Apr 2019 15:49:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46A916B0275; Tue,  2 Apr 2019 15:49:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2580D6B0273
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 15:49:06 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id l26so14371640qtk.18
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 12:49:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=Hj5v9f5m4XcpUD3AHCmGwsgzwcyKpLxNeHtv55UKsvQ=;
        b=czsaf3UGeWRcYlQkQaJsux8xqUiCNyhOw6A6wnayAM3qkTMv/FZVZzAckQ8GJvw0Y1
         mr5yzi4fYrr38abu/kqAir8c+EpuJnhmhbHUCsdcOJTsvpyYdOJ6VMrNGXl6q+84J2zY
         CxdmtDCymT0xmxeDkBkECMF4hyj6Qu6WoKAzQBxePbs9eAvfnnYOS0onKtkl3v6d8gMk
         5eRfeTBZTsad/FYJrOIGKJD7ewGA71jMf7lmMMnc3DYn7n1l/V1uwsY7sreyiguiEXMz
         8i9xfN7dVGZ9Hi+qd5g22ZVR4R7If5fOJjjMiiiPgfU1p82jKGE7olX3voDc2YAAHFrc
         Inqg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXr55Z2WJryD5N3o3tdqW8GNn20W5RVmLmFg7oTxh7YlS1uHpGV
	MpvFNfFdw0GWjVzzTBp3PC/XHju81gSWNMlOaWf243Gxq275BXoNKBm4LN3emUSaIh0gfsmygIR
	t6n8D+pIAQFyGkLDvJYIZtYKNbmKq9q+fEuy/ATAyRAU+sB1K9BzEdX1cFKhisOLc5w==
X-Received: by 2002:ac8:65ce:: with SMTP id t14mr58400888qto.255.1554234545893;
        Tue, 02 Apr 2019 12:49:05 -0700 (PDT)
X-Received: by 2002:ac8:65ce:: with SMTP id t14mr58400846qto.255.1554234545227;
        Tue, 02 Apr 2019 12:49:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554234545; cv=none;
        d=google.com; s=arc-20160816;
        b=QpmU8fz/5mTFCsDVRS91mj98XZoja3QfdiW7dvQilDTMGc01PkucMCv2HnQQOw9Eca
         WrzIuANgqfuysd001ZALUpRUyJraJB5PZLJg/vglSaLhUJE3OuYLM8seGZcNVIhkti3H
         MsPH4mItvYE1oEJUilw8xBMmmDCPj6quzq4ROSWLaRcJpZ//36hHA5YAmfxkZ6a9EU4u
         yqrt/RnB6KsKZmiPgi3k6PT37PbvQJN5JzrSZ71PBV+d4U/5pehKO2ueZaDMqYomFGy4
         TqPNR9M8WHSnpP8AJu4q+uyzf48r9Iw5GQgjOl5Z9IXTti/Sorcf6ZZvVb1cYMQb3Efd
         SKLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=Hj5v9f5m4XcpUD3AHCmGwsgzwcyKpLxNeHtv55UKsvQ=;
        b=vVPdooFivmHoBJn4KmpK9TbTpUT4k1NzajAq/79kJbOFmezw8/aZcoihkIcAVQ9BAd
         WJuKDNlc+3srkS9dCz8Ffmg9aSXHMRpi3urzVXf4lzcc1xX9mgrLuq6cpZIoeKLJc3d6
         Oluo51vCWdVpaig4BbxlOxgv0OhUwSMV7CtmhofFf4Z+2Du6ZH8JtxpD6fKJHsLMI1Sd
         +S0gqRjtf2dYsAC5r5ic4n88RQGs2Yzj/uGN1VNYHkpUHk6LRlFs3pKTd+ONhfRDar7q
         TNjf+ZMnm29SlwVDoBncAeevdybb/Wr4W8FqZM3T796FSOKjrHw3lhV5RMVQcxC9O8uk
         JYWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q11sor19622156qtq.28.2019.04.02.12.49.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 12:49:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqyssdHTS/DKlsZsXRC9d0R0s3gdduOA5QVLCvuRf6QzAqxPUhlhL0TEas0IduN6EdWwMJPg8g==
X-Received: by 2002:ac8:21c7:: with SMTP id 7mr58333120qtz.66.1554234544899;
        Tue, 02 Apr 2019 12:49:04 -0700 (PDT)
Received: from redhat.com ([66.187.232.66])
        by smtp.gmail.com with ESMTPSA id a75sm6940361qkg.84.2019.04.02.12.49.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Apr 2019 12:49:03 -0700 (PDT)
Date: Tue, 2 Apr 2019 15:49:00 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Nitesh Narayan Lal <nitesh@redhat.com>,
	kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
	lcapitulino@redhat.com, pagupta@redhat.com,
	Yang Zhang <yang.zhang.wz@gmail.com>,
	Rik van Riel <riel@surriel.com>, dodgen@google.com,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Dave Hansen <dave.hansen@intel.com>
Subject: Re: On guest free page hinting and OOM
Message-ID: <20190402154732-mutt-send-email-mst@kernel.org>
References: <20190401104608-mutt-send-email-mst@kernel.org>
 <CAKgT0UcJuD-t+MqeS9geiGE1zsUiYUgZzeRrOJOJbOzn2C-KOw@mail.gmail.com>
 <6a612adf-e9c3-6aff-3285-2e2d02c8b80d@redhat.com>
 <CAKgT0Ue_By3Z0=5ZEvscmYAF2P40Bdyo-AXhH8sZv5VxUGGLvA@mail.gmail.com>
 <20190402112115-mutt-send-email-mst@kernel.org>
 <3dd76ce6-c138-b019-3a43-0bb0b793690a@redhat.com>
 <CAKgT0Uc78NYnva4T+G5uas_iSnE_YHGz+S5rkBckCvhNPV96gw@mail.gmail.com>
 <6b0a3610-0e7b-08dc-8b5f-707062f87bea@redhat.com>
 <CAKgT0UdHA66z1j=3H06AfgtiF4ThFdXwQ6i8p1MszdL2bRHeZQ@mail.gmail.com>
 <d105e3c7-52b4-de94-9f61-0aee5442d463@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d105e3c7-52b4-de94-9f61-0aee5442d463@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 02, 2019 at 08:21:30PM +0200, David Hildenbrand wrote:
> The other extreme is a system that barely frees (MAX_ORDER - X) pages,
> however your thread will waste cycles scanning for such.

I don't think we need to scan as such. An arch hook
that queues a job to a wq only when there's work to
do will fix the issue, right?

-- 
MST

