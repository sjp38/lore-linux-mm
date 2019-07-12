Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EE11C742A5
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 01:20:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5737021530
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 01:20:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="R4h7JwRV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5737021530
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E4FEC8E010D; Thu, 11 Jul 2019 21:20:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DFF348E00DB; Thu, 11 Jul 2019 21:20:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEDD08E010D; Thu, 11 Jul 2019 21:20:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 982D68E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 21:20:16 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id h5so4677419pgq.23
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 18:20:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=9g6/fZlIh31dr01ionxF1b9bzXuts5lLepUnNLpOcqE=;
        b=clSKLwmO/auipEfAcUnuQmYcpWSxwUrdyh9AG1yAFvRH2IA5Bc8cTZEVgtgQmziZOK
         +kc2HKWBxkZwJ0kxFL3LebIh+jf90mo3tVgy/Iu7OXk9htogj6O4BytPMMEdgGQoBIdk
         j1ka41P3UE5DMu7mwVCxXivk1zyzOJYbKXzSQBUypiAR8xtAw1VLFlAZUD3Ry+kqcfJU
         fxBLsB89UIiJU8sB9N0sxvlVMNdGN55d27I3PnDwqpAECUTmtvIzy+O4eZtG1nLzO77W
         MNffao0VpsXJUbRLGqF12KDsLPHtriXbHP/jSiK8EJh1efI+XKPcyVpPi1x8x5RBqCXV
         I0zg==
X-Gm-Message-State: APjAAAWWUTPCtUyME/VU6g0/EwoGCQXcbgKgeknfI/UomGe50edB64Zy
	hypx6B098acC4HNJgeZtCXaNjVxTuFqTcjdq8cmRFkQh7EMHUBbaQPANejUqrDVAQZeKlpTZdmS
	xaRnuDTmG49dlQl0VXswtYdlRvMQj3hV12eBf9JXea7z49pVRJ0SqmfH1p1WPTSVqIQ==
X-Received: by 2002:a17:90b:f0e:: with SMTP id br14mr8188471pjb.117.1562894416296;
        Thu, 11 Jul 2019 18:20:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaDzJYyihy0vZ8Wp4H9BtiEiQEhcdLxuCDMVwE0GKPcLmH/VkQlbXAEJUjwJukqkWtnIoE
X-Received: by 2002:a17:90b:f0e:: with SMTP id br14mr8188411pjb.117.1562894415583;
        Thu, 11 Jul 2019 18:20:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562894415; cv=none;
        d=google.com; s=arc-20160816;
        b=qpUsSjJo+o/hbXsDO2uSqhJC5CPpCnvl3G/0wiu9j/YqtSt+661/M9XWCUunZTQylF
         Ro8fPJGFFuZRy6+dGTx7Qjx4O8X9AQzyce97JRoS5Q4DlEUKmdUlLo2eCKQ2nUTvGrYO
         t2ond/oRGmORSer/ZIDqDaMnP+zxn7pmkk3vOIxH92d5w1aDV8K2qlJCEykkstGVEvze
         x1cUPoWWHCmzGjQe8nozyBlXmOjYPmN4ivAadrW6UeIrDiz1nQVvkPiDMgl/zIIXzReY
         W4QzmVZoYPzBrfP82wHO5mza6EruD9lByWYOVyhcX6mZWPETOZRgVkriruu8EiAImTig
         w23w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=9g6/fZlIh31dr01ionxF1b9bzXuts5lLepUnNLpOcqE=;
        b=t0fjZ3wJGi/1xLwuH7JWNIxsUgGGwIXY3p8Z3RwoLhKNrrTFfSPJrA8Us2a61jSill
         f9HkGXtLdk1I/M3MjK2Wf2ATyebj656dRjPNhn3qTnn4DMAsNwya9qE12ZB0/kzEqSTU
         pySk40qZrw0QX9WnQn6nzqYqvHV4t1Ya/RFBL/gIL0Xx4RCbMdFnx4m+FuNRg1beVsEB
         WbWn7N5yq/UCQEso8rdlzFO7/ksqgnNZrU4got7vNfV6F+C3olTb1M+pXZLbk6eZo2Dc
         p12a+DUo80MnTDoZ8DFSyZpp04dFYd9j224cuZL+v8QXfc1PGUfsOEAF163QzWnCvily
         sSbg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=R4h7JwRV;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m68si6786842pfb.75.2019.07.11.18.20.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 18:20:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=R4h7JwRV;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9C84F21019;
	Fri, 12 Jul 2019 01:20:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562894403;
	bh=+sq2cZXnBxcRqUWRVVIP9zpWg9uQ8vXX5lA2Ew1UBSs=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=R4h7JwRVFMQ3Yv1uTjLPBWes1X2fsmN8WCOke8y+u57VyP4kCE/HgaVIv8HyASiyC
	 NEm8IhZwTbYwcfKq8NBs6uOyhPBQN+vGW+xi3G3IwAr+qEsU5oQq2Yp63+7Eh6L3+O
	 x4z1p7S+jBwRLuLyE7TMbYjf2HEZ7NkbtkJMY/UU=
Date: Thu, 11 Jul 2019 18:20:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: "chenjianhong (A)" <chenjianhong2@huawei.com>
Cc: Michel Lespinasse <walken@google.com>, Greg Kroah-Hartman
 <gregkh@linuxfoundation.org>, "mhocko@suse.com" <mhocko@suse.com>,
 "Vlastimil Babka" <vbabka@suse.cz>, "Kirill A. Shutemov"
 <kirill.shutemov@linux.intel.com>, Yang Shi <yang.shi@linux.alibaba.com>,
 "jannh@google.com" <jannh@google.com>, "steve.capper@arm.com"
 <steve.capper@arm.com>, "tiny.windzz@gmail.com" <tiny.windzz@gmail.com>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 "stable@vger.kernel.org" <stable@vger.kernel.org>, "willy@infradead.org"
 <willy@infradead.org>
Subject: Re: [PATCH] mm/mmap: fix the adjusted length error
Message-Id: <20190711182002.9bb943006da6b61ab66b95fd@linux-foundation.org>
In-Reply-To: <df001b6fbe2a4bdc86999c78933dab7f@huawei.com>
References: <1558073209-79549-1-git-send-email-chenjianhong2@huawei.com>
	<CANN689G6mGLSOkyj31ympGgnqxnJosPVc4EakW5gYGtA_45L7g@mail.gmail.com>
	<df001b6fbe2a4bdc86999c78933dab7f@huawei.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 18 May 2019 07:05:07 +0000 "chenjianhong (A)" <chenjianhong2@huawei.com> wrote:

> I explain my test code and the problem in detail. This problem is found in 
> 32-bit user process, because its virtual is limited, 3G or 4G. 
> 
> First, I explain the bug I found. Function unmapped_area and 
> unmapped_area_topdowns adjust search length to account for worst 
> case alignment overhead, the code is ' length = info->length + info->align_mask; '.
> The variable info->length is the length we allocate and the variable 
> info->align_mask accounts for the alignment, because the gap_start  or gap_end 
> value also should be an alignment address, but we can't know the alignment offset.
> So in the current algorithm, it uses the max alignment offset, this value maybe zero
> or other(0x1ff000 for shmat function). 
> Is it reasonable way? The required value is longer than what I allocate.
> What's more,  why for the first time I can allocate the memory successfully
> Via shmat, but after releasing the memory via shmdt and I want to attach
> again, it fails. This is not acceptable for many people.
> 
> Second, I explain my test code. The code I have sent an email. The following is
> the step. I don't think it's something unusual or unreasonable, because the virtual
> memory space is enough, but the process can allocate from it. And we can't pass
> explicit addresses to function mmap or shmat, the address is getting from the left
> vma gap.
>  1, we allocat large virtual memory;
>  2, we allocate hugepage memory via shmat, and release one
>  of the hugepage memory block;
>  3, we allocate hugepage memory by shmat again, this will fail.

How significant is this problem in real-world use cases?  How much
trouble is it causing?

> Third, I want to introduce my change in the current algorithm. I don't change the
> current algorithm. Also, I think there maybe a better way to fix this error. Nowadays,
> I can just adjust the gap_start value.

Have you looked further into this?  Michel is concerned about the
performance cost of the current solution.

