Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06D60C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:14:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA0A72084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:14:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="U4RFCPQW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA0A72084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5043D6B0003; Fri, 26 Apr 2019 10:14:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4629A6B0005; Fri, 26 Apr 2019 10:14:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32D3D6B0006; Fri, 26 Apr 2019 10:14:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 10A4E6B0003
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 10:14:49 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id k7so2548057qtg.8
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 07:14:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=w9slGZvLHxuV7S3a5IfAzVKNyURT39PnsyVIpnGpH9A=;
        b=WJy2MGvZ3w/W2+LPwg1XBuASLvERjQyTGE5GZAUZkO0F0CZAaeSb8fNZZMeLBDBhd+
         7+UM9Sx2A/A2DXtm1rYQP8Jqc7ma5vPB6M0aJVe1zpq7qG6jeGqlfZpV07E2uDQvbX/L
         CzjrsedUnRdTYO/BWwS4V4kwjfH7JqfPiHGR4QT1m4yQO8N/iTDbumh5wFXtYT2a+N/8
         eFzoTZFOiQsJddo7CSyiYZhlHJTf40lKRWyniXn29/kDkHr0WuSe/aRRNkOEjuBwCX5j
         mit0KkTOutaiRkILf5t5AxJVRG0vRNhAKEUpZuowohNXMKqSgKsBvtM9iTIDe62dYgfS
         csyw==
X-Gm-Message-State: APjAAAUW1bRjmcuNKGdx4J8QiJjqiPBEfY9gph6BOCGxY48Bw2XsxAdU
	4LnqBAv4CHKDSUqWyS1laFfNCqZgfikXu8+6q74IDd72vM0MoNPwpDLGCYWyL9968tnKw41gdpp
	tnpXSotJUp4DRYJyJbABA5eRurg0AOUuLWfUSXgP73T/Y+NaGsX9LxZkuhVod7fo=
X-Received: by 2002:ac8:3f38:: with SMTP id c53mr25912979qtk.152.1556288088799;
        Fri, 26 Apr 2019 07:14:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrFyJCxBXo5P4/zwx4jmvRWmnNV69fza5Ehr2u4nj2YcyrquPwLp+mXarWnmUs/+XHwEXC
X-Received: by 2002:ac8:3f38:: with SMTP id c53mr25912932qtk.152.1556288088179;
        Fri, 26 Apr 2019 07:14:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556288088; cv=none;
        d=google.com; s=arc-20160816;
        b=ANsOKKejXfKFsZ0zTr5ZOuQ0pUYMubJxTekGBPcZ7KKsHoUANfKRE1+la7tTGDP4s9
         77SPMDi0R+NTB01dkHBHZWuJT0KbzHIHvuA6QUESNOgSv9Z4tSIOESGBjwXcG0n5n9KM
         VHPjHhoSXOu0QTMXPoLd3Dhg+EOloLMzkhazzKNd2lWkCBer00fhyarlRw/Vg/Hu6F21
         kr0VTBl/ujR/RLkd/kn4pK/h/vACxkNkBLEfH5huRmgqewj4AzOKSTwBIRAjysXxDxtm
         +/xCVK+0MhpwY/pOgRPalGxV8yFwk9HbrrpCgZ0fTLn2VGEoyLORcH6wuTBqOVGxVwLH
         qv9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=w9slGZvLHxuV7S3a5IfAzVKNyURT39PnsyVIpnGpH9A=;
        b=PRzVClZVRLHzRw5XhPIMwOjInxg0hW6WSLXJQz9CucUuOQL06MDdIs/uUCOsSd4rvH
         JdM/TeZmtnwDaG7AOeR0hFA3lapZ0hFMXz8NZmDSSQhGL7PuaA3sZwmFaeO9ohslj4gf
         nlZKJptRpujBdBdWGuLBzmcy8/pSZWxReCKPy6FipVHTl/8p4W1+HDDvX3MWF69tC9aT
         pnHCFSJdDG7SBn1kicAtviqA3ozlJdyd0ahrZGanXI7ebuqWbrAohTQABWI5W6vhLgDS
         zhZG9jmaRNLQjRzizwJqmul0TD5lSWde7VGofNjYErJK8fIgm0FeRAUhi469bSBXDpM+
         O6GQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=U4RFCPQW;
       spf=pass (google.com: domain of 0100016a59ffa618-56d49996-ecb0-481c-88c3-380495651623-000000@amazonses.com designates 54.240.9.30 as permitted sender) smtp.mailfrom=0100016a59ffa618-56d49996-ecb0-481c-88c3-380495651623-000000@amazonses.com
Received: from a9-30.smtp-out.amazonses.com (a9-30.smtp-out.amazonses.com. [54.240.9.30])
        by mx.google.com with ESMTPS id b124si2648903qkd.1.2019.04.26.07.14.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Apr 2019 07:14:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016a59ffa618-56d49996-ecb0-481c-88c3-380495651623-000000@amazonses.com designates 54.240.9.30 as permitted sender) client-ip=54.240.9.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=U4RFCPQW;
       spf=pass (google.com: domain of 0100016a59ffa618-56d49996-ecb0-481c-88c3-380495651623-000000@amazonses.com designates 54.240.9.30 as permitted sender) smtp.mailfrom=0100016a59ffa618-56d49996-ecb0-481c-88c3-380495651623-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1556288087;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=w9slGZvLHxuV7S3a5IfAzVKNyURT39PnsyVIpnGpH9A=;
	b=U4RFCPQWz4jXUFfMGOHX4HlHYj86E0xiwRKBsja0h5KkUEcbg030FIk1xEfdMOP+
	6NtV8IjdnxUm+2JCNqWPJri0AwN8QzdR6rnn1ulMRWuJXoueQ1audlHWTtKSRf4JvwI
	5yQTY0JYLP6FLFj/XbeqnIrsWlc9S/CnWTLeXbVs=
Date: Fri, 26 Apr 2019 14:14:47 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Alexander Potapenko <glider@google.com>
cc: akpm@linux-foundation.org, dvyukov@google.com, keescook@chromium.org, 
    labbott@redhat.com, linux-mm@kvack.org, 
    linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com
Subject: Re: [PATCH 1/3] mm: security: introduce the init_allocations=1 boot
 option
In-Reply-To: <20190418154208.131118-2-glider@google.com>
Message-ID: <0100016a59ffa618-56d49996-ecb0-481c-88c3-380495651623-000000@email.amazonses.com>
References: <20190418154208.131118-1-glider@google.com> <20190418154208.131118-2-glider@google.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.04.26-54.240.9.30
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Apr 2019, Alexander Potapenko wrote:

> This option adds the possibility to initialize newly allocated pages and
> heap objects with zeroes. This is needed to prevent possible information
> leaks and make the control-flow bugs that depend on uninitialized values
> more deterministic.
>
> Initialization is done at allocation time at the places where checks for
> __GFP_ZERO are performed. We don't initialize slab caches with
> constructors to preserve their semantics. To reduce runtime costs of
> checking cachep->ctor we replace a call to memset with a call to
> cachep->poison_fn, which is only executed if the memory block needs to
> be initialized.

Just check for a ctor and then zero or use whatever pattern ? Why add a
new function?

