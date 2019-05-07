Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7260BC04A6B
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 03:26:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F27020989
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 03:26:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F27020989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CF8E6B0005; Mon,  6 May 2019 23:26:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77E6D6B0006; Mon,  6 May 2019 23:26:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 694B86B0007; Mon,  6 May 2019 23:26:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4F1676B0005
	for <linux-mm@kvack.org>; Mon,  6 May 2019 23:26:14 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id a29so5202613oiy.18
        for <linux-mm@kvack.org>; Mon, 06 May 2019 20:26:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding;
        bh=PZPrutFjQNtD6vRma/+UAW6i4mXt/jPRiSY1dRPJ6C8=;
        b=TLOZ95QTfMIZ6qZ0gIoqCjfMrbLXizdQdFHjIA8bWv/BTdqzDRRYeP0qS8aUtUorBM
         roRZQyczltkA0v5c6U1NEfEtA6Wbstotfdo1BFoLWuLa5BTQu6AQuYnjDBEh3PQJEOrT
         87k/61XDuav2+j9e4kI0yXgVGSorUdz1gvnZK4a0B6Z/EdJI0dd5ZMDFKeoIvGq6blW4
         eEKFwriztXWUtBK1GnX22fLt2j5uFDlZnCKnGRVe9V8sORwtNrQsXB1DN1euNeMgZrco
         3iw9ObzdcajZyg/XnLOFjTNqeJR9TaM3CCNw2te3NYLfx69VaTFfeUCMfkqEjOTtZCZ+
         o7FQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=liuzhiqiang26@huawei.com
X-Gm-Message-State: APjAAAUuvnzaU1kWeSWBZLysB6KNvOrEsfpp1RhC20YcwaIyQLwNbp1f
	WeQ/itXoGhZ9mqQf11khKbZx/aj3ifQ/WUqt0EzP4p50z0Cm7Yq/4QKL7kbbgAjIATWjLZFQ9mX
	IbetNZOT1kZZ9pO9kNmAwyFXdtzyK6A4mR6KWyr7mXE9iTJxNHpQ3qyPL89mVUl60eQ==
X-Received: by 2002:aca:180d:: with SMTP id h13mr965323oih.39.1557199573901;
        Mon, 06 May 2019 20:26:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6NtqJSIbajGc00QGy/OY3HaB+OB3UAy1CoRtGTI4qH6iq0B2keeK1XNQVhH0JFQnJq2kA
X-Received: by 2002:aca:180d:: with SMTP id h13mr965303oih.39.1557199573293;
        Mon, 06 May 2019 20:26:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557199573; cv=none;
        d=google.com; s=arc-20160816;
        b=lzAhW48iJ8zbjpbhYtd5yUbdocncfeNqc5uL2EhsCrjKvsLxFVntGPwDIRCeP2D5ON
         +rk5ucmEE6dd1pxN3IrBY0/rG3T+9riivJt9cLmLhRFCR983FAygz1e+3ZeAlOBrjYuY
         q9/2ZZ9RvA/okPEvpe2eg7b8am+fXSS9L9RJiCjIyrWm/3DSCv3jwxS2mW7UEhU8lkfl
         rzQ4GRrLv4d105z7Qo9aXW2nsI4n1lzs8q6dJ94J+hNZLspxjji6GLliBr0g3FTCgY+9
         qiRwDSKG+Djk5M/KZcC65OkStOAclpzOnSm2xG0Qg4bL9+3DeAvOTv0TrOmE4NZwHhhg
         kR4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:references:cc:to:subject;
        bh=PZPrutFjQNtD6vRma/+UAW6i4mXt/jPRiSY1dRPJ6C8=;
        b=HNco/kg+hnGWXMAWR7JSQopEkygt0LIO7p8+XoLfRGQruz1evNUk6eA8fQbDpwIpw5
         8pwkoHdfeAPwCpOdGmmjlT6Vo2kKoZJ/xGB2j/gKc0iV4sjMMdwPHV6rh4lAAcvFc3dt
         6ETxPb6SsCTn7F/+UOArvwZYE+opMYqP2rlhBiqXMhQzegZHHYa2PcqCOaLVaFNOOddS
         KvnE3ZywrR/AXB0gJgXNY/SlbJf3E1p0wtbFuVmqAarx6C+yO+dWRT5hXnSWOU3H+YPi
         GQvvPzTGAoH9guKcJgYlqyv7wOloxF6XMkiXL/gC8fSOpyFndtjCulO3ICKWgWkuBAV1
         K3Nw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=liuzhiqiang26@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id q19si8058949otn.96.2019.05.06.20.26.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 20:26:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of liuzhiqiang26@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=liuzhiqiang26@huawei.com
Received: from DGGEMS410-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 9B0F33BA8E3B6B52E5A6;
	Tue,  7 May 2019 11:26:07 +0800 (CST)
Received: from [127.0.0.1] (10.184.225.177) by DGGEMS410-HUB.china.huawei.com
 (10.3.19.210) with Microsoft SMTP Server id 14.3.439.0; Tue, 7 May 2019
 11:25:58 +0800
Subject: Re: [PATCH v2] mm/hugetlb: Don't put_page in lock of hugetlb_lock
To: Michal Hocko <mhocko@kernel.org>
CC: <mike.kravetz@oracle.com>, <shenkai8@huawei.com>, <linfeilong@huawei.com>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, <wangwang2@huawei.com>,
	"Zhoukang (A)" <zhoukang7@huawei.com>, Mingfangsen <mingfangsen@huawei.com>,
	<agl@us.ibm.com>, <nacc@us.ibm.com>, Andrew Morton
	<akpm@linux-foundation.org>
References: <12a693da-19c8-dd2c-ea6a-0a5dc9d2db27@huawei.com>
 <b8ade452-2d6b-0372-32c2-703644032b47@huawei.com>
 <20190506142001.GC31017@dhcp22.suse.cz>
 <d11fa51f-e976-ec33-4f5b-3b26ada64306@huawei.com>
 <20190506190731.GE31017@dhcp22.suse.cz>
From: Zhiqiang Liu <liuzhiqiang26@huawei.com>
Message-ID: <32a63fc6-add1-5556-8174-517d41aa8a2a@huawei.com>
Date: Tue, 7 May 2019 11:25:55 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190506190731.GE31017@dhcp22.suse.cz>
Content-Type: text/plain; charset="gbk"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.184.225.177]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Mon 06-05-19 23:22:08, Zhiqiang Liu wrote:
> [...]
>> Does adding Cc: stable mean adding Cc: <stable@vger.kernel.org>
>> tag in the patch or Ccing stable@vger.kernel.org when sending the new mail?
> 
> The former. See Documentation/process/stable-kernel-rules.rst for more.
> 
> Thanks!

Thank you, Oscar Salvador and Mike Kravetz again.
> 

