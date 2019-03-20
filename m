Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90166C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 22:12:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 529E12175B
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 22:12:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 529E12175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDABD6B0006; Wed, 20 Mar 2019 18:12:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D89FC6B0007; Wed, 20 Mar 2019 18:12:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA2B16B0008; Wed, 20 Mar 2019 18:12:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A4B506B0006
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 18:12:48 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id g83so3872071pfd.3
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 15:12:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=f46XFi7xs49aQqICCPU9wzgQzl0nDcTH6oCrjaZ7PrE=;
        b=KP31InNkcnfBufudg5WvKmp/pGvCKtkKIer7zpeenw8ZLxgnyE875uzouAIA0K0sTT
         oIHPn6E/jtlq1CWjXuFywcfy0EwEaQK912gotrhb/PqEh5uh8Ljac9ldz6clGGT9tVID
         /xEH17KM2/b4/Hjvs3ejUkiGGmGPcEOAca8X6VyADpfe/6Sww4nGY6QnhrMVGDtgSBhy
         FtMi3XzVjfCOxKXd0jCq1QNsIwRqA+9Xfrault9a53oFkCl4xlqUZvMMl8mdV+jJisfc
         D5SaTQSNWLKIuZpEEumVOCdxUdpwo47AE8IFuhl+7XyPbvo6dtsrS45F/4DOMQqdPI7a
         05KQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAUhsseVFD4RCmNgexDLxZml6XGkVfo75fb4okDtHb5AS+lNU8l0
	5SDiABeWcKK1phvW87CFexap2njhkR5WTFiMrzkZ1oVDbQAwSSGkHyPgrvdK2BEiXe0YCk+opMd
	W4Birx+KhPeEjsR+uLWcr6q+sM9s2NQ2zAQvws+nxWzzcdtXGykk7G9j+2rtSpKnwMg==
X-Received: by 2002:a62:41cc:: with SMTP id g73mr85073pfd.145.1553119968354;
        Wed, 20 Mar 2019 15:12:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaRG+XRsXWQEN5PLhJPlJsyBuSxOyhhfW3yOoclaaBtdi1xuPogczEc2s/Ljva2XgC8E/Z
X-Received: by 2002:a62:41cc:: with SMTP id g73mr85026pfd.145.1553119967678;
        Wed, 20 Mar 2019 15:12:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553119967; cv=none;
        d=google.com; s=arc-20160816;
        b=Kd4354CDbiN+yVO0CZ5YwhWXG+NdeTDfa701PZE9oxTTugi9vQ5DV/uxBCOn03HJ5K
         iQhMPnAx9ZIuk6gyVuL6CpqxlIKnorQmE1tdRfEc/SWUpfJhH+Gi8td8cl7pVIBBvhis
         2gXOe6B/1Qo2u97xrjb+9nxBnd+Lvu+dNGv7q3XjxieWvvHSxGyWWVx03v3ThFaCqYST
         oRD//WQj59HXsFKSTbDfyvdJQ0gtXELLXVUItqPe3ZmzQSxv8ZBt9g+gEPReXZUB/zpk
         zab8KOH5oyFhh89AqPRZa8gXdgzT5Kqko4P+23P3Rnvzu0MAI144chMFSQLDvY/xFcSv
         ZevA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=f46XFi7xs49aQqICCPU9wzgQzl0nDcTH6oCrjaZ7PrE=;
        b=Nq2mrN9VwMMGoZ2IbtgK2YqoR9Q91XBymeG0lPFaWI4MbWx0UjwyYsKZ0ye7Cpt3us
         dza62dSvR+DcPvhw3tBZCyyyigj7iCsvh2XQ11Z6zyqO9RFsx3GJL3S7w/4ZJFWyHEb0
         SB+V5wfqLmDnmWWhz3E+pD5MjfZR3LDdmvAMS2up7W6JNi3L08D5XVs6LvWO76i8ZnjO
         +V/FACCP+YGdQKN5VjJUdUPkvWuT/sRbY/tYlZ2d1t3mV57sCuN6NvPnQ/Q+ROCE6H1h
         1l5VaUs7KXRytPYOB7cjNVnXuZuGSkgqADBF0DL3vALk4dudknY7slaK5SRjWEI4Q7l1
         f7Zg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x24si2635810pga.46.2019.03.20.15.12.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 15:12:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id EF146EA2;
	Wed, 20 Mar 2019 22:12:46 +0000 (UTC)
Date: Wed, 20 Mar 2019 15:12:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Yue Hu <zbestahu@gmail.com>
Cc: iamjoonsoo.kim@lge.com, mingo@kernel.org, vbabka@suse.cz,
 rppt@linux.vnet.ibm.com, rdunlap@infradead.org, linux-mm@kvack.org,
 huyue2@yulong.com
Subject: Re: [PATCH] mm/cma: fix the bitmap status to show failed allocation
 reason
Message-Id: <20190320151245.ff79af49fe364ac01d4edb14@linux-foundation.org>
In-Reply-To: <20190320060829.9144-1-zbestahu@gmail.com>
References: <20190320060829.9144-1-zbestahu@gmail.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Mar 2019 14:08:29 +0800 Yue Hu <zbestahu@gmail.com> wrote:

> Currently one bit in cma bitmap represents number of pages rather than
> one page, cma->count means cma size in pages. So to find available pages
> via find_next_zero_bit()/find_next_bit() we should use cma size not in
> pages but in bits although current free pages number is correct due to
> zero value of order_per_bit. Once order_per_bit is changed the bitmap
> status will be incorrect.

When fixing a bug, please always describe the end-user visible runtime
effects of that bug?

