Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D7FAC282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:56:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F253218D3
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 16:56:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F253218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D30748E004D; Thu,  7 Feb 2019 11:56:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDE328E0002; Thu,  7 Feb 2019 11:56:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF4588E004D; Thu,  7 Feb 2019 11:56:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 80AA58E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 11:56:02 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id g188so268786pgc.22
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 08:56:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=afgelWKDK/Y3MYKADfO1KqpKnCn2JdCVpNj6jq8rS0I=;
        b=d/WE0Z9OH55EwGO6FCNSWdpugqYp7iIn8Ki1W0j8pCRUu97wv+smK5Y0EZqxJ57QR+
         OsxtjAqmy/41pUzxerU8+YUbwYNdNqmvkvNAsV0/V6ZpzLm1UMMmrnCfRUPqTOWNiMsJ
         8dLoccphwnpVUl2WP6TWM39K19aNjySZbJf0DGWYWp27WA+3qW1yhJ6eD/4yin+/PePu
         nK8LM+oZwDkFR5NztKtEo4t8OePQIxAwgwLKcBTsmBF0VS6muabA1nyunUvRIZJ8jGrO
         LD/9/lxanCF/ZwI2cDOmbHNvnGOPa03mjPwEv2Rrd0+tnciALNuy9e7c653Rx7cpi/fy
         YznA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZxQRAQs9vp6Xyfe8ALbnZR1tDbdmZU96YGmNluSrKA8vT7dJ6F
	AN00qQIpvREPTfsVVg2Cy8MNzjAqETUNQOD+rokWtZ5hJq5+PKmf62b4EiBi6n8dtM/d2+4SHHR
	rrqGDNEmfKT2/Vo1FrM/ixC65iYJZlZJzufJ8j+nTYt56NMWGM0yekQXwSt4Fd23dMQ==
X-Received: by 2002:a63:484c:: with SMTP id x12mr15604976pgk.375.1549558562189;
        Thu, 07 Feb 2019 08:56:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaRT1NTq621DiBOMrPYqhmsNhlhKBpyi+OzMqBP3uhsLvnqdSn4cA58TeMwaVYerwyCbG70
X-Received: by 2002:a63:484c:: with SMTP id x12mr15604916pgk.375.1549558561357;
        Thu, 07 Feb 2019 08:56:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549558561; cv=none;
        d=google.com; s=arc-20160816;
        b=y9ca31PYqJVkV0M4yeqZ4zjSpgPqVAG6Uq64CUpRm9RVCYbCBCawxqg851xf0XvKeg
         pWAbQOobEDcrKbyFm/n5E1OZc8423k0FrqGhDpf7OvXyuCLip5OhmtGgFheKXQsyx/7D
         dBVhsJ88zWXV1wZHA3lbIB+SYaWxKDtUC/5lulT7N0CJkjuPqMMflwLQ1D3rjzKfRvhR
         S14LstF2VewChs7TiBTerTC8tVvXnmdbdgyRkwGfCaP3BFj5dB5riE9o5ROS20O8DwzZ
         V6HMPldnyD1DtlIhiGtIMde3TANhEjnAzFlvGvV/ePqcbZtw0+zgUzsdhSgOlj7NYp4l
         Fhzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=afgelWKDK/Y3MYKADfO1KqpKnCn2JdCVpNj6jq8rS0I=;
        b=LAQhfVUAlGABjXXTji4ImIFVtQkdjrwtGllVXayejLCeXKT/2BrA73Xtrn8BmSeIgs
         hBUW2KpoQZ1ecL7tRb+niN8o5wTk7UhPSZ0Vn2VMp/eou9QzpBQFfbEJisrb526a/USy
         631R7Q1p2lW4u8x8socxPmmQ19T6IrGjNNYeznx51s2VV+EQ/vwJ2B90+Gar67VrX9S3
         88BPoX7VwBKTMbVYdKkNySvqtO7WuKmkLJbF9E+/IvCZPFJxrooeruuh1AtymXAdfNKk
         ZurMnG5hujQMaGpezJy2AEMom65WNRRBqrkRlFiRYSrHwaVSznLwOi8vRJRprnjXNJj4
         N9bw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id o9si9593638pfe.63.2019.02.07.08.56.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 08:56:01 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Feb 2019 08:56:00 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,344,1544515200"; 
   d="scan'208";a="113169778"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga007.jf.intel.com with ESMTP; 07 Feb 2019 08:56:00 -0800
Message-ID: <d28e5bc95cfc18ca8c97e28459692fdd967d52d3.camel@linux.intel.com>
Subject: Re: [RFC PATCH 0/4] kvm: Report unused guest pages to host
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Nitesh Narayan Lal <nitesh@redhat.com>, Alexander Duyck
 <alexander.duyck@gmail.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,  kvm@vger.kernel.org
Cc: rkrcmar@redhat.com, x86@kernel.org, mingo@redhat.com, bp@alien8.de, 
 hpa@zytor.com, pbonzini@redhat.com, tglx@linutronix.de,
 akpm@linux-foundation.org,  Luiz Capitulino <lcapitulino@redhat.com>, David
 Hildenbrand <david@redhat.com>
Date: Thu, 07 Feb 2019 08:56:00 -0800
In-Reply-To: <e0bf61d2-c315-ae4f-6ddb-93b7882fd13f@redhat.com>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
	 <e0bf61d2-c315-ae4f-6ddb-93b7882fd13f@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-02-07 at 09:48 -0500, Nitesh Narayan Lal wrote:
> On 2/4/19 1:15 PM, Alexander Duyck wrote:
> > This patch set provides a mechanism by which guests can notify the host of
> > pages that are not currently in use. Using this data a KVM host can more
> > easily balance memory workloads between guests and improve overall system
> > performance by avoiding unnecessary writing of unused pages to swap.
> > 
> > In order to support this I have added a new hypercall to provided unused
> > page hints and made use of mechanisms currently used by PowerPC and s390
> > architectures to provide those hints. To reduce the overhead of this call
> > I am only using it per huge page instead of of doing a notification per 4K
> > page. By doing this we can avoid the expense of fragmenting higher order
> > pages, and reduce overall cost for the hypercall as it will only be
> > performed once per huge page.
> > 
> > Because we are limiting this to huge pages it was necessary to add a
> > secondary location where we make the call as the buddy allocator can merge
> > smaller pages into a higher order huge page.
> > 
> > This approach is not usable in all cases. Specifically, when KVM direct
> > device assignment is used, the memory for a guest is permanently assigned
> > to physical pages in order to support DMA from the assigned device. In
> > this case we cannot give the pages back, so the hypercall is disabled by
> > the host.
> > 
> > Another situation that can lead to issues is if the page were accessed
> > immediately after free. For example, if page poisoning is enabled the
> > guest will populate the page *after* freeing it. In this case it does not
> > make sense to provide a hint about the page being freed so we do not
> > perform the hypercalls from the guest if this functionality is enabled.
> 
> Hi Alexander,
> 
> Did you get a chance to look at my v8 posting of Guest Free Page Hinting
> [1]?
> Considering both the solutions are trying to solve the same problem. It
> will be great if we can collaborate and come up with a unified solution.
> 
> [1] https://lkml.org/lkml/2019/2/4/993

I haven't had a chance to review these yet.

I'll try to take a look later today and provide review notes based on
what I find.

Thanks.

- Alex

