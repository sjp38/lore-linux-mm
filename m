Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3462DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:36:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E49322229F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:36:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E49322229F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BA308E0007; Thu, 14 Feb 2019 05:36:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8693C8E0001; Thu, 14 Feb 2019 05:36:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7593D8E0007; Thu, 14 Feb 2019 05:36:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 21A1F8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 05:36:13 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id u13so398133ljj.13
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 02:36:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=XzpuCJyHp+Q6O5jGlAKbYYy0q1phyLeTXuESwOO0+Oc=;
        b=SDbjOY+QFpPyquB50GwCmOaQ9wDLfwc/rEUhXm+ltpGN5MhELVXBgyE6QZQPg+1RRa
         CyTUVeDnxC7Ap1b6y7I1/e6Zw40hNFqPg9/ljLBVbjV5ZkNYuWSJDmlODm3Og28Y8r4F
         yqgTeohn5VWE9RAPy6ckozB/Z47Lx08ujMEqf7skkewBxme5h6vfzE6GxtsgA4CjsmUH
         58HZ5nXp4m1koU8qjT2bSJbhWg1ooJINqYwvhQdFOiGujNd5GVpFzrYs6ESGNf0JxmH/
         QiqtUSrN5SkU1q62eMUnUBkE/b2PmzsxfVOUFkDWAHXZHRKL0SyoFxqM2IGwEgUn02EZ
         Or2Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuaLeASaWBzQcSSnbZdXzg5XcW4zu1Ax+APtR6U2bw7BLdHQmLzR
	D9f8JhP5kW3mRBYjkZ7ganmMME96GF2tYWSw4wbUdwrmxCIiPbpCtG4/69kpux8co6gdbYPiOkc
	FySZDbwUamEXmMJ/yvwZ7rKXlyl1R7jaCh4ag+JMQcsecFozaTjO+cYGjCZ0DxNVtDA==
X-Received: by 2002:a2e:7316:: with SMTP id o22-v6mr1926834ljc.82.1550140572494;
        Thu, 14 Feb 2019 02:36:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZP7pFGcluQIKT+Crm9wS7ek++lL930+5m52q49QqGtJBUPHs81Vj3KEsOw3wcqRWM/uZRF
X-Received: by 2002:a2e:7316:: with SMTP id o22-v6mr1926789ljc.82.1550140571674;
        Thu, 14 Feb 2019 02:36:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550140571; cv=none;
        d=google.com; s=arc-20160816;
        b=EAwlN7x0dIsifDSFA22Z5z9ETTrAFhg+2pHdlJbEvdVQfJZkUCrmDsr04FSg94SA9O
         2Ddd/XOlR6nEEq0dzZR5PrPtUa7qeY87/h79v/EOreKyvPpygUlD+mqTzbbARfd/iJB2
         xi/lLLmcTxyeHXAGJV6oyHW+dRE6dU67rq+LESpfYTSJYsO11zZIFsPKvoC1wxePgbEv
         p4taRw5cZ+hQyi59OBL/k3ushM+AS/PrPC2YUHP40m3am4l1V+8jU3FXvEIrrBglgb2I
         Dq0YpwSnFWJnCYbe+P40E8r3mR8E3obDIbkUNInpVXDFmkiUR8IieOqlV1sr/ZFx5nxo
         AXSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=XzpuCJyHp+Q6O5jGlAKbYYy0q1phyLeTXuESwOO0+Oc=;
        b=nSs4rJzKx4PekTx6Ymf0gsIGgZELGAECtH3dQdLCtA4yvK1tewLlrqX5I5M5K1gMSw
         x0hqBjHRLrIGRn3060JFtTAnQBGs8FoPtu/SVTGSS+xLx7hCI5jr0hH2BmvP/tavDYvK
         9JqoEjx6zVKwnO6CIbrIbDDaq5Fb5kyUiZkKgk21pGqwH6wJQ9LBMS5GDPUSQpX0JLHQ
         2oRapZ2XOFSGljkGcPPvQRbnzN9G/pem3iGJff8GRUzSi65TfvKdavHQh/ALlX68CaEr
         9VLytkdpxeYMnX6SFBIDw0zsEMtOJ0l3SCnTGgc2ZiSzU3kb8L9FZi9e2heWfvNoQRQO
         LYuw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id e10-v6si1545446ljj.193.2019.02.14.02.36.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 02:36:11 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1guENH-00054N-32; Thu, 14 Feb 2019 13:36:11 +0300
Subject: Re: [PATCH 3/4] mm: Remove pages_to_free argument of
 move_active_pages_to_lru()
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <154998432043.18704.10326447825287153712.stgit@localhost.localdomain>
 <154998445148.18704.11244772245027520877.stgit@localhost.localdomain>
 <20190213191446.r3pop7kv6kp6b2qv@ca-dmjordan1.us.oracle.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <14693e22-ebe6-56cd-928b-4d68f6f52909@virtuozzo.com>
Date: Thu, 14 Feb 2019 13:36:10 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190213191446.r3pop7kv6kp6b2qv@ca-dmjordan1.us.oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 13.02.2019 22:14, Daniel Jordan wrote:
> On Tue, Feb 12, 2019 at 06:14:11PM +0300, Kirill Tkhai wrote:
>> +	/* Keep all free pages are in l_active list */
> 
> s/are//

Yeah, thanks.

