Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A173C73C63
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 00:28:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C12A20693
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 00:28:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="bcORr81N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C12A20693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 691328E005E; Tue,  9 Jul 2019 20:28:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 640198E0032; Tue,  9 Jul 2019 20:28:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 556F08E005E; Tue,  9 Jul 2019 20:28:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2DDCC8E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 20:28:26 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i2so264005pfe.1
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 17:28:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=F1YEfnrX5gkf5eSCFBBgYDnY9VrRZyGi7EMYFBwhLqA=;
        b=b3Jd+JCvueUxIvb0Zreef5qjTzdKf+eOleAF7zWZfhZZ7oIk9yBbIzVica9xkTlKla
         JA011irhUgQ+z8BIArHwTSLpbQY+m1lY0Ue+BTzF833rxTvkuVKnl7HP13dN4G0SsV+y
         BOSW2mFpTQDWjuo8nfqBf0L6L42mrP61HykLUrRTQzhGSZcByPY9SpEjbwhQMfhLFbkt
         J/+FbyUI65B5we2rAIHc5j5++Tfk301puga8APJUUEtIb0cGSogc6ONRZTEc3YfBekt1
         i/kLJxnhaEfeNoWjFK+pN8tx6SR7Yw2lxq1NeoL/+w9UQktBFGc2aopwzIJu92b4wdGY
         yerQ==
X-Gm-Message-State: APjAAAU8CvKJFalImqeISvneKn/tVxxUtUUJ+9Wvg5w5WIKAwTK4OSQt
	PkyNaRdl0pHmIAj8pP0siLzfsHMj2a9FLkpCdL0m/JbPES9bnjn4uLfivQSdxafSZum9X8fFCR8
	EXnWej1HP8YuU5Tcv9qaGGonJkP9bTgWZg2NScXZ5cAhOQByNCbb+WDyUEZ0qTGL9tA==
X-Received: by 2002:a17:902:324:: with SMTP id 33mr34559467pld.340.1562718505658;
        Tue, 09 Jul 2019 17:28:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9N8KfTUDgfUpyANog4xLAD2Mi7ZlRqrnEQc8oYkm4OJIoTIRUfBWlxaZeHeOcWwDeNRt3
X-Received: by 2002:a17:902:324:: with SMTP id 33mr34559417pld.340.1562718504854;
        Tue, 09 Jul 2019 17:28:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562718504; cv=none;
        d=google.com; s=arc-20160816;
        b=nfYyhJIVY0udt2TZXbZd+M8QWqrZhjzmOABCDprI3y5sX8j0jhZfSVkpsYB1stz5A4
         r8WDc0n9KQDvsV1xp8mMd0TRsdCz9Zpbokn5JTs4DNxMTeRDrOrTrLYjrOJB6rxV3FMD
         y3h/ESB0Mxkvk93ofdFgdsvX1lR27cKEuVBkNTGJvJUli4sZP0adi9vPWWS26cht9E0K
         7ldUt15jkceF9czNS+YcgKqhvW/oP3NelpacaYV+nL6tLi0UyYME4dzadz0bQyHVrhcn
         CWp4yjM0wwso5ABGP1bKHNr41Xf2r74w+mN4gLGV6Gr8S1s326SNtQ+b42vn7DuBNmzA
         FalQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=F1YEfnrX5gkf5eSCFBBgYDnY9VrRZyGi7EMYFBwhLqA=;
        b=i0HSXyUeiN4tQDL3osbbfIKGKRsja7/ZK/uX2zv4AdvzyFf11TpPzxrGHdXHt2d6MZ
         MRqQxbuUwfaEF+ssWyvaZ9fqtf5XULJ2KK5UkQoh7pjUNq/SoT48dZTVX3bAO1lr79d1
         SkP3zvWdHHW5Mg1Q/CYqEp+ASsCWwNO3a3ZNXoGnPHZhXIL09E5pmppNVSIo1DUgRv0c
         MUch1LWYF+Us6DlSdJ1SuDLaMITbyeJqkhdVExyqOCaeiTXJmeHRNkciTrcD/6QJt1oc
         Yhx1LA54NfdrXQWKYGkSg1+2GSEVDIAmocW/MOCwZ8Wcqa67v+N9kc3B1vd1H/PO+Y9u
         aVMw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bcORr81N;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f26si485875pga.117.2019.07.09.17.28.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 17:28:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bcORr81N;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0E7DC20645;
	Wed, 10 Jul 2019 00:28:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562718504;
	bh=pgC6c3DPV5AItfmGQQFtB/x1Xt0vg1j5Q5WBogBNnOY=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=bcORr81NEQsz5D+zOUG6k8DlarV4FeSW19kgXYYSMd9qxtzYAp2QLxXViDAJRru6M
	 dtwMY3UTEic/u5ydDJe4uucQjbfejE/8h+7uvSrHfdzgxUJFHps8dEZGqI+bVmC1qW
	 p6MjkxHTx75iefkEq1M0pWmNUiKj0HVfWBXbH/Ys=
Date: Tue, 9 Jul 2019 17:28:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, =?ISO-8859-1?Q?J?=
 =?ISO-8859-1?Q?=E9r=F4me?= Glisse <jglisse@redhat.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mike Kravetz
 <mike.kravetz@oracle.com>
Subject: Re: [PATCH] mm/hmm: Fix bad subpage pointer in try_to_unmap_one
Message-Id: <20190709172823.9413bb2333363f7e33a471a0@linux-foundation.org>
In-Reply-To: <20190709223556.28908-1-rcampbell@nvidia.com>
References: <20190709223556.28908-1-rcampbell@nvidia.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Jul 2019 15:35:56 -0700 Ralph Campbell <rcampbell@nvidia.com> wrote:

> When migrating a ZONE device private page from device memory to system
> memory, the subpage pointer is initialized from a swap pte which computes
> an invalid page pointer. A kernel panic results such as:
> 
> BUG: unable to handle page fault for address: ffffea1fffffffc8
> 
> Initialize subpage correctly before calling page_remove_rmap().

I think this is

Fixes:  a5430dda8a3a1c ("mm/migrate: support un-addressable ZONE_DEVICE page in migration")
Cc: stable

yes?

