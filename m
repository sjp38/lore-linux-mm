Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEF9CC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 09:23:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B54C72173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 09:23:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B54C72173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 418F68E0003; Tue, 26 Feb 2019 04:23:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C78F8E0001; Tue, 26 Feb 2019 04:23:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DF668E0003; Tue, 26 Feb 2019 04:23:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C66878E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 04:23:31 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id m25so1312171edd.6
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 01:23:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=JhebPdqQR1aCPOBdDYkPcx03ShVXWDP/+qvOfy/bcFM=;
        b=BeHNZPYcY2EAQ48xVJzseLYN1MNmx+Vlpn0U3fR+EJXwMnaa38hZ2q+nelo+9JpSrt
         tK56SwbRjxY+YY6rGidv7H9GGLWTj18dZ9NaVNUuQFcerD4drVuVKo0FlftYsf793zkk
         IzWcUm6iT3gbHfvq2beCfivPbfwfGNdXIFZ/4N+GWQIihxOEZLXooJdv6l4MJMGBME3q
         39L2/jx7E4KgafTFFUmOmgiK9vkSZcvpWq7Q39vSUWHD4Ib+Ru0sOrjQZVYFe1r+WcHY
         vQWyPb0SRPKaXeIv3ncyq9UXELy0ZReDieWGRAHVca4MsV1mvqAkLcOR7DIUKD5et1CE
         y7qw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAuZliw2w5ygGkq5Dklp0h2+T0Q2xTMqR4BOxH9ZYYtMPJxfmhcrC
	qvnhUWIQ3hv1WS9X/rJWDIgxSoGkto44ViXSKJfcf/m+SpfcEqDqMLH9RbSicXsL7l8ZdhacYuc
	k0MKe+tvknLbbXdQM26SgkrAeoFumHZENFd2JW+6I1Nf425XJudfqmY+0EZihSyyeig==
X-Received: by 2002:a17:906:5784:: with SMTP id k4mr15999927ejq.107.1551173011356;
        Tue, 26 Feb 2019 01:23:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYXW4chBpjCd6mSmAEwSusWcfwsH2a2cdDWTSlBZMvis5fCDvavLJgYBJbUGYe4Hyu71rRK
X-Received: by 2002:a17:906:5784:: with SMTP id k4mr15999871ejq.107.1551173010295;
        Tue, 26 Feb 2019 01:23:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551173010; cv=none;
        d=google.com; s=arc-20160816;
        b=huUdyt/4J7qgIIRNaYLtjaUr+0pJP65MgOWOE/p4IpSF+tWyOZCMsLOcd4N3K5JnWV
         prXhSiiCe5IKRU6u1nMOxQt6vn+YIzAuaT2/DEQf6/9XpNnF743A4Odt2wVDRzSVur69
         MJlwKVbj9s/DwCQdqo8UNFLUjFe4sC21dEXA9Ily13PMQETGpeYN3N4jLtLTKIYUsoiH
         dpFTW9L1mP9jmAywOcfZuLQcL5sRyZ54X/JVMOXqbBTjl94LY/APTW51D2ZzYDPwaB2i
         aV5k0aWofSbIU78xwQtMe5R+NUzZL1QkCmpvKrAvjqe4i9Dsij56bVyMAbHf095U79Td
         iEZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=JhebPdqQR1aCPOBdDYkPcx03ShVXWDP/+qvOfy/bcFM=;
        b=sayLrMLhMJYXQ4K3XAdL5vD7LDuowq5HO6jD5evaSNkPldCZXBAcdyTsVHvqe9rNZm
         r1jUrsB15csh70pyxCaJBQaQDOsl4J2FCXGq25YwHT03QOKIcQnNHzjCQSd4ympLgHwh
         VOpkR7aQy6dzRQ4JO33ib1KQ3PbcYFKRpTmwqjvj4r65VpVoNN5iqBbqRNlCwB2irFOa
         MtTMuR+V/RoXnAQEpkdvFbAAkjbcit6KKtOEU5Blf5TTQJfg3vqDh0R2osj9IjRnD/IH
         nEWVIHsIKMQh6b186uEwOPZYl+i44Tjt5vCelZDA6Aac4VpF2x2Woi24cVA07pgWhrkk
         +hMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g10si2145866eda.254.2019.02.26.01.23.30
        for <linux-mm@kvack.org>;
        Tue, 26 Feb 2019 01:23:30 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3B0BF80D;
	Tue, 26 Feb 2019 01:23:29 -0800 (PST)
Received: from [10.162.40.137] (p8cg001049571a15.blr.arm.com [10.162.40.137])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A96A13F71D;
	Tue, 26 Feb 2019 01:23:27 -0800 (PST)
Subject: Re: [PATCH] mm: migrate: add missing flush_dcache_page for non-mapped
 page migrate
To: Lars Persson <lars.persson@axis.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Cc: linux-mips@vger.kernel.org, Lars Persson <larper@axis.com>
References: <20190219123212.29838-1-larper@axis.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <6d12d244-85be-52c4-c3bc-75d077a9c0ee@arm.com>
Date: Tue, 26 Feb 2019 14:53:34 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190219123212.29838-1-larper@axis.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 02/19/2019 06:02 PM, Lars Persson wrote:
> Our MIPS 1004Kc SoCs were seeing random userspace crashes with SIGILL
> and SIGSEGV that could not be traced back to a userspace code
> bug. They had all the magic signs of an I/D cache coherency issue.
> 
> Now recently we noticed that the /proc/sys/vm/compact_memory interface
> was quite efficient at provoking this class of userspace crashes.
> 
> Studying the code in mm/migrate.c there is a distinction made between
> migrating a page that is mapped at the instant of migration and one
> that is not mapped. Our problem turned out to be the non-mapped pages.
> 
> For the non-mapped page the code performs a copy of the page content
> and all relevant meta-data of the page without doing the required
> D-cache maintenance. This leaves dirty data in the D-cache of the CPU
> and on the 1004K cores this data is not visible to the I-cache. A
> subsequent page-fault that triggers a mapping of the page will happily
> serve the process with potentially stale code.

Just curious. Is not the code path which tries to map this page should
do the invalidation just before setting it up in the page table via
set_pte_at() or other similar variants ? How it maps without doing the
necessary flush.

