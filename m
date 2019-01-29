Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98BBCC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 22:56:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CD1220882
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 22:56:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CD1220882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 032D08E0004; Tue, 29 Jan 2019 17:56:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F245A8E0001; Tue, 29 Jan 2019 17:56:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E13538E0004; Tue, 29 Jan 2019 17:56:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id B36B48E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 17:56:55 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id p3so15352553plk.9
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:56:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KYKjTDYUL48et6LEE0rj/lM2WPEO20nj1oj552IIoVI=;
        b=ZUWuYLt5O3Z9dknL/RT6pKSWeA74OC0OZCeQLqJ22AhiX2huST6GVJmOXFVgbzFJQq
         HUIp6NxVqfldmBmuE/oBnEkFIjbC4uZ0vPsy50ZrX2p8R6hDIIdRx9jVQBWgBDiOyptn
         1g9PkZE+zcA5UXCwK05kjvGLLYL0rX2nnjaa/gRO4Adgg3tphs2/Kd3sdOFNE51ICpDE
         CIyY3ORIjtOtPN32hybpErcMJQBXjGWhbr9wIISWN3jQqCfnQWSCwrfBt6Sjc6y+0VYS
         YrfB5K8I7pvWAXamtu1s6sSPSyRbAnsHtuV/C4Vg/1Rri75fAvt721IRwzaQyrq2pP9n
         5CKg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUuke3LJnWYXz7ieFVBag8XHLNxBhTX/nB4gWrf56dQjdF3qHp99jZ
	lv/1fRkpZkVM37mzOtnQ+950BgR2fD6sCEGIt+l5qKLvrjtDyELlGZDK2s1qu08/QOoJr2ud31a
	BY9MVOMOpKwVx26foc9YozvISsNmUJoVhJIKlpQLYTot94PJvXecuSshTaRY9B/h3vg==
X-Received: by 2002:a62:3c1:: with SMTP id 184mr28319093pfd.56.1548802615415;
        Tue, 29 Jan 2019 14:56:55 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5wlsekjxfxIOYAsk15YpXWyCD2fLrKIRx5A2qKAeE/oWQS26iJ1VtRUDCJcWjd7yHlSeIY
X-Received: by 2002:a62:3c1:: with SMTP id 184mr28319066pfd.56.1548802614783;
        Tue, 29 Jan 2019 14:56:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548802614; cv=none;
        d=google.com; s=arc-20160816;
        b=jvK+p5GKDXAcnGG9k9MQW1hskX6yIShL6eW0kQNfNnBstUJcyFfxiPw6R5WJ5oFvI0
         QLim0XKJDFaSm3cFzamWpz7BYAi+7neygD91P0pl7uKfTBCuk3bIDFVptVZhv4nW0klF
         V+wP1avwzAA0aHgez6D85ONfSK70Xd5CdGFiti16pIJnfYz418oNFTljkYhxVayGJMqQ
         V9zGyJG9BiEQY6svwJ2b3jYrM/dTVo993RH1/za8MFBzWqmV4uF1NbmLy0jRZqjxwfAd
         l4xDNErgEx/LIZBYDJwqp2A2jJyj4xX5vxB7qzAFyGQnNTiU0cJnu18NZKSYasTQpOZn
         ecew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=KYKjTDYUL48et6LEE0rj/lM2WPEO20nj1oj552IIoVI=;
        b=ZZNTX3fk4iqUFmNKZ1w0Ekfm19316zrbwUGdlL/jihoKEm3KeVR2HRWkuRqmcOLwav
         V3RRQspkYlPxx4BldRrt2AdohanDOLmZpz22dpBZREiUg7exo6IhhWCgresSt+21q6pz
         7MvmY+QN7FArflDC7yLxOx/QMEmMs60GMWMgb9mAPUT+DiwdeJB8EnXJnjxhgP0Wa56u
         kmTP+0iyxEPMxkvCloReYDjqnT8msF4l3YHwgCXeczXyHVfJEElNpf4XgsI9/CJm/tRD
         YV0/Jb2lLmYYmMF9XzWte+h8sZBePrJYTWLqsnr/LJQ9r4SItSyipz59+W71CgKKIQSW
         pxYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l66si37721075pfl.258.2019.01.29.14.56.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 14:56:54 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 35E213470;
	Tue, 29 Jan 2019 22:56:54 +0000 (UTC)
Date: Tue, 29 Jan 2019 14:56:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>,
 David Gibson <david@gibson.dropbear.id.au>, Andrea Arcangeli
 <aarcange@redhat.com>, mpe@ellerman.id.au, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH V7 0/4] mm/kvm/vfio/ppc64: Migrate compound pages out of
 CMA region
Message-Id: <20190129145652.c4021a4adf8416618211c38d@linux-foundation.org>
In-Reply-To: <20190114095438.32470-1-aneesh.kumar@linux.ibm.com>
References: <20190114095438.32470-1-aneesh.kumar@linux.ibm.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 14 Jan 2019 15:24:32 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:

> ppc64 use CMA area for the allocation of guest page table (hash page table). We won't
> be able to start guest if we fail to allocate hash page table. We have observed
> hash table allocation failure because we failed to migrate pages out of CMA region
> because they were pinned. This happen when we are using VFIO. VFIO on ppc64 pins
> the entire guest RAM. If the guest RAM pages get allocated out of CMA region, we
> won't be able to migrate those pages. The pages are also pinned for the lifetime of the
> guest.
> 
> Currently we support migration of non-compound pages. With THP and with the addition of
>  hugetlb migration we can end up allocating compound pages from CMA region. This
> patch series add support for migrating compound pages. 

Very little review activity is in evidence.  Please identify some
appropriate reviewers and ask them to take a look?

