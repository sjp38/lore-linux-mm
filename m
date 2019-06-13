Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C8A8C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 11:28:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0BB96208CA
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 11:28:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BB96208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E79A6B0271; Thu, 13 Jun 2019 07:28:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 998126B0272; Thu, 13 Jun 2019 07:28:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AE796B0273; Thu, 13 Jun 2019 07:28:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6CB446B0271
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 07:28:08 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id j22so4982944oib.7
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 04:28:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=UbxihoWZ3mXaFgGzQ0L2D9nfKgmrQFc66XZo2cq89EI=;
        b=oQk2SAUjCi8MB6EOAex/k5KyG6vAjpM5OAgRqNHfVnUQGPdJsvksxmc9w1OtJvZj67
         cF1JLFRJxfqVpnWwrpn7498hR+fIeOqJmPnlo0EikCIpNBRVhr7ciedVv10ZZ+K+sWpb
         P2Ks1G0hrdHeeOf9bTpifKWhivVagAewqeMxUlbtZ6U9f5nriABfhc0+OVUmW7KkrtfI
         wn3ql7Z/1Od8lYrUOBRBT/6Mf2y4du1TSIVSwLupUZutNXDL/RW3PlwXvqic/8Mbz5cx
         VpKcOLMLsWo67ZtmwiNm7Z3vEzi9Q26m7+diKKGiUkCp+SXDYPDS3gesZh+25iyi5JFZ
         ML6A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
X-Gm-Message-State: APjAAAUKE3XCu9aK1y/WkzapcuntvR+R9qKbMg0Bmp85ZQVc8C4KtGLF
	gtitHtJ2nyJQyVA3oppbOb4Z/Y5x/tB8edqBoClkbcuAGrsqeOaXtf3L+JcKDEyamlAlcHAIB+O
	YffKfLGepoGu3dkzs8ady0Y+GfmvPhA/rWGgj2LdwqIjrkA40yirj554o/my6nhx1sA==
X-Received: by 2002:a9d:5512:: with SMTP id l18mr8426758oth.260.1560425288213;
        Thu, 13 Jun 2019 04:28:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzcExLWoFeld1TWr8bagMH8/6dyAK1AiMtRO9is07VEL3QgTqkdl3C8QV4OOdXR1T117AK
X-Received: by 2002:a9d:5512:: with SMTP id l18mr8426727oth.260.1560425287670;
        Thu, 13 Jun 2019 04:28:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560425287; cv=none;
        d=google.com; s=arc-20160816;
        b=vCp9UIYbNE+kis+allMyJgUzVOevAhq1Qm69rYVh9CJ/FqslZ0/PquUKX5VtAuSpRb
         +caysRas3Ul7wLcLTLoh3aqyCrzaKLDxkKudBb5MhQaKJuyXg7c5lbid0J7+970aFuua
         +i0wxKFO4jjqj8nokAD7Jh1lOzunp1JiYtfcgDK3yx8bf2gu2pG/15MN44X7GeLmI8WH
         LqiCbUBeiEM9iQPICoTbnQ75c0zMV+Pnv2pDNimeCPGuHVRg+HSJa52CgnG6ZGzWBtAu
         9dosYprma/tC9R2ikrfdVnBP6BroiiRHHjwtg1PgZdJ48roXnX2hDYJngW8YvEzGTREE
         1QTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject;
        bh=UbxihoWZ3mXaFgGzQ0L2D9nfKgmrQFc66XZo2cq89EI=;
        b=O3ZHSXendeJRjUN/RQEGBg1RsdFzzC/nGK/3lrk8wQvtiJpJX2cVOHk+WgIRyNY/KE
         3XnAyC3+4NGos24wD7cmCaQP29DK4uIjKDvaxWofOpH18rYZdVHsKMgrvvqlc+smQJqt
         mwwQFsjhZsLQXpqtKg0RXs7UXYQDBwhOb1EvX07fpLRdgHp6hQFYLrLmGcjkLzz7Wll/
         +XNE5kGemE3bx/7+6FwMxf5K4eW35SV/2ZVA7PenuxXTsSOg8cL+yQRvULVa87F0Yh91
         xf9PXSdxDMQzcRwiKkJPJBwJOSHZc0M2W0peXF3jup6rX+Gcv0ApxO1Jva/MNlPmeayk
         Vegw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id z10si1602409otj.2.2019.06.13.04.28.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 04:28:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of chenzhou10@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=chenzhou10@huawei.com
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id AB2461C04B2F61064578;
	Thu, 13 Jun 2019 19:28:03 +0800 (CST)
Received: from [127.0.0.1] (10.177.131.64) by DGGEMS414-HUB.china.huawei.com
 (10.3.19.214) with Microsoft SMTP Server id 14.3.439.0; Thu, 13 Jun 2019
 19:27:54 +0800
Subject: Re: [PATCH 1/4] x86: kdump: move reserve_crashkernel_low() into
 kexec_core.c
To: Dave Young <dyoung@redhat.com>
References: <20190507035058.63992-1-chenzhou10@huawei.com>
 <20190507035058.63992-2-chenzhou10@huawei.com>
 <20190612084551.GA24575@dhcp-128-65.nay.redhat.com>
CC: <catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<akpm@linux-foundation.org>, <ard.biesheuvel@linaro.org>,
	<rppt@linux.ibm.com>, <tglx@linutronix.de>, <mingo@redhat.com>,
	<bp@alien8.de>, <ebiederm@xmission.com>, <wangkefeng.wang@huawei.com>,
	<linux-mm@kvack.org>, <kexec@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <takahiro.akashi@linaro.org>,
	<horms@verge.net.au>, <linux-arm-kernel@lists.infradead.org>
From: Chen Zhou <chenzhou10@huawei.com>
Message-ID: <681c9884-4b8b-be87-2d78-d5f53ab23f34@huawei.com>
Date: Thu, 13 Jun 2019 19:27:51 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:45.0) Gecko/20100101
 Thunderbird/45.7.1
MIME-Version: 1.0
In-Reply-To: <20190612084551.GA24575@dhcp-128-65.nay.redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.131.64]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Dave,

On 2019/6/12 16:45, Dave Young wrote:
> Other than the comments from James, can you move the function into
> kernel/crash_core.c, we already have some functions moved there for
> sharing.

Sure.

Thanks,
Chen Zhou

