Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02461C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 07:03:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B6F5206DF
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 07:03:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B6F5206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.ee
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39F1B6B000A; Wed, 27 Mar 2019 03:03:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34FF66B000C; Wed, 27 Mar 2019 03:03:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2664C6B000D; Wed, 27 Mar 2019 03:03:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id D3E6D6B000A
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 03:03:42 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id c21so4528697lji.18
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 00:03:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=0UU8i5p2Jl2g6+/8ctZNo2+VkEfBip0TJ4+lGmWby9U=;
        b=gzrIILd/Q9k+CfniYrlZ+BIma0dI8o9r6ck97Hg5FHpArBMzo7+9ClvrO9mbV/M+I7
         uRA7oZvkEkHMao40Dt6uwMYVws8EGEh/nQUY6yAhIZybiLr5wOSdudT6akN5cFaM3mb0
         xnlfvNjw0k2hW/wFRhY/N+dJsMNCUzuWCaY80Af+OTQn/XJcYvF7wLsBfYxg9zAon2Vm
         o56djasY9yTmZ3OZVdiyENvJUhyHJ0GLA3+SIxnJhkGm+hBxnBUcNxjgFAtjV+5GPNmC
         hJYWlheUPbhQS2mwnixTgjrkdkMzSyvvsHmBXPryui4CnG/cG1vpD1R5emni8sUzDxgh
         KH/A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
X-Gm-Message-State: APjAAAVwJZ0eK9CRuerNZ6mkGTwpeFiGt8F8Kr0yB3iGsBWhKMcui0ij
	FH9ixIAmBflz+b3cft4Bc8OT6GKjD24NorX/MdVxyceLxJ3KPUEWvpP3pWfv1DgfnhukviaUUIW
	eLdn0zFL4FYCUMdqNHqSuzSibz5/zXuNVyxOsiFBqGVo/CM8uINSbDRsdFP/eRZ0=
X-Received: by 2002:ac2:5961:: with SMTP id h1mr13051779lfp.167.1553670222200;
        Wed, 27 Mar 2019 00:03:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzs7TyCpCAAGyKbqBfhjdFnsmNMF/mT3Jsu4zDMGMt8lB/mlP1bP8sETuhbLRY/J2XlWKKE
X-Received: by 2002:ac2:5961:: with SMTP id h1mr13051679lfp.167.1553670219724;
        Wed, 27 Mar 2019 00:03:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553670219; cv=none;
        d=google.com; s=arc-20160816;
        b=pcK1dBQPDznfb3auLwETnPSDnOb4wX7flJCEFVvpNWz2aeXDvSeXWt2WVbXJKi5im8
         iv83olLQlSSNJRY3nwoLy3goEm+YYsV6MiXO/ILc64bYuvZuQyGvo6F3QA8mQ3hEakZE
         fZPFcbMXkp8w3VZjBJyV9vAdP8XBtUNRpsQJmr8q8p5+gbQ8g+oSr5Lvfq7q6sf2TSwT
         6WCbfHWzTlnqrA/VpwHrCanJONdSlYj0/yj31BjvpTksFcspYWHCcJ2bbbEccV6rvZF4
         vPyjFX/V7G+/prMPXgQX0Z+lg5KVI1BUgFZcqTIzMYxwwyCqePGbGJFffPD8oR0+Rxvf
         T+2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=0UU8i5p2Jl2g6+/8ctZNo2+VkEfBip0TJ4+lGmWby9U=;
        b=S21eFwfvt+liVBbDkpU12D+9HgV1b9lYSWy390BTq6WWB+CCGTm+Si+Z32L1UHaqH4
         fog2iT/lhXC/yu4Uu0SG2dzMrwNnex5s60S/1eAN24usfd6VY/+Q/dH5OWFHs52+BwkS
         Tf9yVK8DadtnYnK+dIfkzEFlqW4UrKb+cRvwCUi7f1CAKFG+UjVm95ayJUl2pXUd+kM+
         sHqbTqmHKbNJWu4A895lixspi12mdDmB9WlFDsVbCdV445P/pTQ5GrpuO1XDP3w8wMKd
         kcTOUyNuW71G6fqGZtB+cKFFuG43Dp0QrceU4B/lIXqBcdcpHkLCmVi23yddVO7CHjns
         Gxug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
Received: from mx2.cyber.ee (mx2.cyber.ee. [193.40.6.72])
        by mx.google.com with ESMTPS id p8si15754450ljb.157.2019.03.27.00.03.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 00:03:39 -0700 (PDT)
Received-SPF: neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) client-ip=193.40.6.72;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 193.40.6.72 is neither permitted nor denied by best guess record for domain of mroos@linux.ee) smtp.mailfrom=mroos@linux.ee
Subject: Re: CONFIG_DEBUG_VIRTUAL breaks boot on x86-32
To: Ralph Campbell <rcampbell@nvidia.com>,
 William Kucharski <william.kucharski@oracle.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
References: <4d5ee3b0-6d47-a8df-a6b3-54b0fba66ed7@linux.ee>
 <A1B7F481-4BF6-4441-8019-AE088F8A8939@oracle.com>
 <f39477da-a1ef-e31e-a72d-8ea1d5755234@nvidia.com>
From: Meelis Roos <mroos@linux.ee>
Message-ID: <dca61136-db66-a89e-e79d-679ee2281d8d@linux.ee>
Date: Wed, 27 Mar 2019 09:03:37 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <f39477da-a1ef-e31e-a72d-8ea1d5755234@nvidia.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: et-EE
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> You might be hitting a bug I found.
> Try applying this patch:
> https://marc.info/?l=linux-kernel&m=155355953012985&w=2

Unfortunately it did not change anything.

-- 
Meelis Roos <mroos@linux.ee>

