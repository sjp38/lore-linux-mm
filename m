Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC745C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:52:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A78882083D
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:52:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A78882083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4287D8E0006; Mon, 24 Jun 2019 01:52:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D8DE8E0001; Mon, 24 Jun 2019 01:52:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EF448E0006; Mon, 24 Jun 2019 01:52:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id ECBE28E0001
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:52:17 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l14so18766668edw.20
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 22:52:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=WqLOGjyULLoYobsrvrQirJgdfqMbJwT1YPMDuWsxETk=;
        b=fCuMVsvedY7rafSKen46VW5Gwr3zdPVX4J+MqN2GNLgF5Lm9e4ZK/jg1MdEgOeZ1Nv
         n8bQtx/wHglPWkF946EtFNXZXYYl6IpAi2Gg2Df1JoUSqnhpHU/43QmAL1/BLUDHYmmp
         b8fjBakaM4VuShjT3+pT9pjdHGbU6cn4BIXUBRAfXi+GybgR9z1QHoicR6/8m0ziLxp1
         m29jCVKB68nhrzAGAs1dn2Z4hnpBxCkwdVz+OX19WBdI9ZIQRTg1ji35RySmxdb2xtJc
         hWsS9KA3ZpNeRI56GZpul037+SkqY6zu8pKnpBpduNJfmSQMQq9qu2bWrQ+ycZwhDTsX
         TJ8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUFZMn04Y7PxyRcmPib6njvsUncED5T+ujkfg0axkA19/j7Kw5S
	DYA2no3/v4eZ1AdGKeTDUdFWICxMED/gFuH8ReaaAjlVwNx7LEaZp+xKf9QfS7Ksqulr/c8/Rq1
	q2zwo/TlwfNWgDJSCJbMp7E03rc/VRbAPhnG2E/HZHJCYmVpT6aFp11OoD1b+ogZguQ==
X-Received: by 2002:a17:906:a394:: with SMTP id k20mr107053800ejz.46.1561355537526;
        Sun, 23 Jun 2019 22:52:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytrHdoKGw7FEaJ5UFC5G535K/bHho6GIjbOE7DqR5gEXSReT6jDV149bOG3/nuPPPAYLnj
X-Received: by 2002:a17:906:a394:: with SMTP id k20mr107053770ejz.46.1561355536784;
        Sun, 23 Jun 2019 22:52:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561355536; cv=none;
        d=google.com; s=arc-20160816;
        b=OXIZ92iqCPGHNUlokdbl9JHGTD2j6V3bkpH3nOQZfM2+kxeVywDdGq7ntq2iZ8ElUT
         zSzh5U29R2HVpx0k3Omj0PpnwHopT0OIGCDl8JN6tPd78DQYdWz1qSUOW4Y98XluZU7v
         GtkDjl8PJI4hCAIjLfNP+GWDfrjIbuVhkGvaiJBu8xQD7JTXXv4E+IOe+dsA25BAgLcD
         Ci7lkZH0Lf88PSAGLDmVPcE9A4DZg4plZz8wnfS2gOivvIOposVsJSf6yn7aDfTzMPBZ
         UgwOUXBfS9HqqDuIEKEMxXb/zJbykIOLgta+sjplOPUAgXgYj9MObqDQPfrijcVtyVcw
         hqPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=WqLOGjyULLoYobsrvrQirJgdfqMbJwT1YPMDuWsxETk=;
        b=n2+Ga09MUB1HfRCvFtyx9BX/x+/Gy8q7W9LzbUi8oSfJNpMCsJa3hrJk5zxKV1wPqt
         pcXVTWb6nPNqX1FvRHC7NV0yuPfVM55mO3KT5SmjTknxiAMl5tYPHJ0Qprs5M8N6gRaR
         +8WilVK5URcX1Tu45Bd866b8cs759oKLDPP76q8deYNuAIw9NN6ACI4CupIyizA17iDp
         Kjz73+gLvLhWHKtVZVyKAGITCqPjb8pF5VuBwPgR2hfbiIwydLT65jdD2ZV294PVFr3B
         7GNHwSuwlHuwvAHMJcxmiDRdB8GefKa9+D30ETCYjJXTHzwDKkoyT/WKRyFwz7yOOJqe
         p0WQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id b56si8665608edb.202.2019.06.23.22.52.16
        for <linux-mm@kvack.org>;
        Sun, 23 Jun 2019 22:52:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EA957344;
	Sun, 23 Jun 2019 22:52:15 -0700 (PDT)
Received: from [10.162.41.123] (p8cg001049571a15.blr.arm.com [10.162.41.123])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BCCE93F718;
	Sun, 23 Jun 2019 22:54:01 -0700 (PDT)
Subject: Re: [PATCH 0/3] fix vmalloc_to_page for huge vmap mappings
To: Nicholas Piggin <npiggin@gmail.com>, linux-mm@kvack.org
Cc: linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org,
 Andrew Morton <akpm@linux-foundation.org>,
 Christophe Leroy <christophe.leroy@c-s.fr>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Mark Rutland <mark.rutland@arm.com>
References: <20190623094446.28722-1-npiggin@gmail.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <f8139999-1624-617a-b7a5-df2846e6e25b@arm.com>
Date: Mon, 24 Jun 2019 11:22:37 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190623094446.28722-1-npiggin@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Nicholas,

On 06/23/2019 03:14 PM, Nicholas Piggin wrote:
> This is a change broken out from the huge vmap vmalloc series as
> requested. There is a little bit of dependency juggling across

Thanks for splitting up the previous series and sending this one out.


> trees, but patches are pretty trivial. Ideally if Andrew accepts
> this patch and queues it up for next, then the arch patches would
> be merged through those trees then patch 3 gets sent by Andrew.

Fair enough.

> 
> I've tested this with other powerpc and vmalloc patches, with code
> that explicitly tests vmalloc_to_page on vmalloced memory and
> results look fine.

- Anshuman


