Return-Path: <SRS0=ikTF=QP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9963C282CC
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 16:31:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A15172086C
	for <linux-mm@archiver.kernel.org>; Fri,  8 Feb 2019 16:31:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A15172086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 402818E0095; Fri,  8 Feb 2019 11:31:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 389078E0002; Fri,  8 Feb 2019 11:31:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2293C8E0095; Fri,  8 Feb 2019 11:31:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id E5F5F8E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 11:31:44 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id q193so3824267qke.12
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 08:31:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:organization
         :from:in-reply-to:references:to:cc:subject:mime-version:content-id
         :content-transfer-encoding:date:message-id;
        bh=ijc4OkdlwhLQ+vLw/tDEWlSCidAYerorD00INU0H/GA=;
        b=poz6qD3cFzDxmhnesJSey1siG4DfuIjsTTrouCySGYAuFwoJOFpnSqbWg0yDHWS1+T
         hh6cBhtF3yDvRumAEO4nK6ufQU/UPFcUoBIfACBfqEiT9xnk1biYy5pZHmt4bK2oJh/m
         Fdyhw7UE/37ZQ9IGV/jLV8IIk8MGgTXsuHQLkNvdADUNagSAD/dwqHMyC3jAnBmlS6Pt
         fl6iwhyRGvOgs1cGISUFx039YYF45PRLFrBQAIoHGaNvoz2m5TBwX3kGW5pgDCpHEwsS
         mFeAeS1WRBhE2iu6G036rS17aIbfUvKXsytbez2iTpmflcbzYZphU/1Kpt6P+mvbeXIA
         aZMg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaFs34i6NLvDZ82snAflVHy6ckGBCcJZfqHXLd5wAt99cL+O2V2
	C7mhZJcMxUABBHgFItPEzdeWv+96w10hBPuIe82em9LUjKwOnGB3OtK09YGzyfVqjZSjqYcSt0Z
	4DzI6joix/debdjBlmjGrKJEko/dMwOlop5+n9AYov6okEy7YQzXZ2nOJPlKvl7RARA==
X-Received: by 2002:ac8:5411:: with SMTP id b17mr16659999qtq.259.1549643504608;
        Fri, 08 Feb 2019 08:31:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbKFIsiDn0DluOHDbjyGeBxC64Bd+bti40Fo/q8/g1HjVl4WJ/uujPhw1mgDdniYo1cbw4O
X-Received: by 2002:ac8:5411:: with SMTP id b17mr16659961qtq.259.1549643503972;
        Fri, 08 Feb 2019 08:31:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549643503; cv=none;
        d=google.com; s=arc-20160816;
        b=RweOavte1HQ8dAGD1qujPZr1gEC/R5HAvkw3qmvIqsbluD2IhX3/5zTdlm0DeLTKeM
         lmqP571WNJCkh3vsPNuIGx8Ibr4Y0BDqUoO8ff0uzD+g6BzbNehV9CcwCZ+9Y9zsEXFO
         GLqTFvnV5F/cKzgzykiqI0/zkNk1dXAY8O1qP65SJYuX6v3cbbVAAHRcE+p10uq8RfEm
         vwiUMv0IslVZ2z3hwYugRrOnHA8AHK4poI3BVMWkYI2gdFZE0oNLJ/qf/57S8SP5RpPc
         zEv4oGDq8FsCNwbix5oaJHIAQSmZFjDMPNfGzQRBbMgjXI1nGinyUlz9dsEq5fLq3T+3
         4CKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:content-transfer-encoding:content-id:mime-version
         :subject:cc:to:references:in-reply-to:from:organization;
        bh=ijc4OkdlwhLQ+vLw/tDEWlSCidAYerorD00INU0H/GA=;
        b=L1OLB77qL9A/ckFtjwUO63jBETilWEjNsDNVNVGEN9aDAfAi7eqVnbb0PCXI00trwU
         jyPbDdi4OF7zbL0eC7cGvuZx1Mg8Fh28xna/0haXG26OLzo/LGdHrs7lO5oHjq5h/uA6
         h4WQ5CUBlFmRkf0uB2gNYEDMgkgQhbLTROJ0qChBKagWpyHsIfrXp4+fyRtzx2k2DIKy
         fKTIe8HyH3CF7lagScDgEW4tvlcJakwqu6kwu1lAllKKQdhpNYtO0kjeqLbF7W6wvSyi
         aHAMfvZgSI95/Evf14+f/5ipNuceISypGDXNyIfIrwh5c+CI6iXjNnsiL8KnzfWzT0+S
         MHGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i31si1742182qtb.238.2019.02.08.08.31.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 08:31:43 -0800 (PST)
Received-SPF: pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dhowells@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dhowells@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E15E088E52;
	Fri,  8 Feb 2019 16:31:42 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 88AEB10002B9;
	Fri,  8 Feb 2019 16:31:40 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
	Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
	Kingdom.
	Registered in England and Wales under Company Registration No. 3798903
From: David Howells <dhowells@redhat.com>
In-Reply-To: <ce8d60c2-5166-6c40-011f-4dff8dc25ebe@oracle.com>
References: <ce8d60c2-5166-6c40-011f-4dff8dc25ebe@oracle.com> <20190205012224.65672-1-cai@lca.pw>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: dhowells@redhat.com, Qian Cai <cai@lca.pw>, viro@zeniv.linux.org.uk,
    linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -next] hugetlbfs: a terminator for hugetlb_param_specs[]
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <16206.1549643499.1@warthog.procyon.org.uk>
Content-Transfer-Encoding: quoted-printable
Date: Fri, 08 Feb 2019 16:31:39 +0000
Message-ID: <16207.1549643499@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Fri, 08 Feb 2019 16:31:43 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mike Kravetz <mike.kravetz@oracle.com> wrote:

> Thanks for fixing this.  Looks like a simple oversight when 2284cf59cbce
> was added.

I've already pushed a fix for this which Al should have folded in already.

> FYI David, the fs_parameter_spec example in the documentation (mount_api=
.txt)
> is also missing a terminator.

Thanks.

David

