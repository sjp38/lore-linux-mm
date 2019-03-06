Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AE13C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:11:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0787E20657
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:11:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0787E20657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CE5C8E0003; Wed,  6 Mar 2019 14:11:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97E4F8E0002; Wed,  6 Mar 2019 14:11:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86D858E0003; Wed,  6 Mar 2019 14:11:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 322498E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 14:11:05 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id 29so6720536eds.12
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 11:11:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=9sVrivt/oEclglxPpWxhXn4Mr/ZI7Nvd1QtSTCC5hwM=;
        b=XrV5snUKJHGJn8AL9WynRnDZZBdeXRVt+Hk8Kg4bR+AnUpvBHf59B9IxodcapSdr2o
         IWXmFZNUZOa3uHfxx7/XebZkCFz139WpgXuj0DCpByKstIgiJllDdiTo3/gLwWO2Rv3j
         NeRMRs+THtXLfKdkdHIaPidRzmFKXC7/+o+pMECTjIxvHAOjnAZW9dFP12sIzq4WC6dx
         VfI7EUJqu3Bf/pCb7lzMRxe/Jzj3QzpNm7uyXld67hrtrvQDwDINXNV52RYKvirwoyPu
         ygyMTn2L9uln2FGKeWs5sM9NE9vPmtx2UMIaOnkfHEeZCRh6vcDcXKx+I0ZpMp4Glr+C
         G2mA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXSZamIVhKbBptaqjO1t9zx7RCI32psNpb/OTSIC1rrZikcr44a
	1aGc8mZSwKCju1xVnfCmkOM3+KZP1M1IKv8AbprMygm1HX0x2zhwbhvlv2APhf1eiPMfVE4aBaD
	nQFLDIVyzg5StJjTpPHCsCM8zcR8xj8eWx1TOVy3vwdAFEgYXHAGvT+pxA0UOZ5g=
X-Received: by 2002:a50:b7ca:: with SMTP id i10mr24812390ede.37.1551899464788;
        Wed, 06 Mar 2019 11:11:04 -0800 (PST)
X-Google-Smtp-Source: APXvYqxMCe09U0T3Lff35rRsxW40ZmzLEgWkyBQiwEyQc7jRTecyc9TebxMlUdOSkiknEZ8OCX1Q
X-Received: by 2002:a50:b7ca:: with SMTP id i10mr24812361ede.37.1551899464144;
        Wed, 06 Mar 2019 11:11:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551899464; cv=none;
        d=google.com; s=arc-20160816;
        b=aGP2FGm7BVPa/+iB1z5IfJFYlkPBffvbaaQB21nROS2TvgoF0u1IJtlJk92RRMr4M8
         8pshzaxVd6+4/9E5EIntqG7b6G26mHmncDpXG7VAI63nFQU3l50kg/X3u6Ah5Z3sM6Vo
         Bk022HCUoy8q2yRN5NvRSfVHAwGDpgEuC1to8I4liXkVWwQ2kdtgoahxyhPwPqEqeo21
         VCItdR0nN0tLq/99StJfQNX75mny9gpfKI/CfQmoMIYutxA2NCF9lwFaaEv9cTC3LOad
         2OCdGNFAgq03HOHezG+1FeD8zy4RBbYEbO+QWHKCC1buNQ8IpuFcOCYBaHwU/qvrkcIT
         1Apw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:references:subject:cc:to:from;
        bh=9sVrivt/oEclglxPpWxhXn4Mr/ZI7Nvd1QtSTCC5hwM=;
        b=IdJ+WOc0Ve/oRa/R/Fd3pGRFHnjhI/CE3MHIdnw+YuHQ0TUX3gJYUjzdu240TeiaIM
         tWb3J2gNPNifLK/XG7AL7E1UU/WCAxD1nu+wP9RkmdMYkLhWVCKXzJTESgAnlpj8pRx6
         dzKlSm3PO0pb0kDBIahaf4/qHFZyQX4qV8WrasIF/UkuZriMxQjVSDCo+reMEHKv3jmh
         uc046VSR/sSoYH3M6gdy32AD0YnFf+Zf4VzWoPkqmjTJWG5cCJgUeFAXTB07+8FV1EZ2
         cIMRPvEjbjww2o2+/MojsyxNaLOqEGKSnBQJDxUeh+8ZPxgiM1YadM4UO8t8pUw17QUb
         8zVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay11.mail.gandi.net (relay11.mail.gandi.net. [217.70.178.231])
        by mx.google.com with ESMTPS id y15si943528edd.290.2019.03.06.11.11.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Mar 2019 11:11:04 -0800 (PST)
Received-SPF: neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.231;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from [192.168.0.11] (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay11.mail.gandi.net (Postfix) with ESMTPSA id 7693C100006;
	Wed,  6 Mar 2019 19:10:55 +0000 (UTC)
From: Alex Ghiti <alex@ghiti.fr>
To: David Miller <davem@davemloft.net>
Cc: vbabka@suse.cz, catalin.marinas@arm.com, will.deacon@arm.com,
 benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au,
 schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
 ysato@users.sourceforge.jp, dalias@libc.org, tglx@linutronix.de,
 mingo@redhat.com, bp@alien8.de, hpa@zytor.com, x86@kernel.org,
 dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
 mike.kravetz@oracle.com, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 sparclinux@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v5 2/4] sparc: Advertise gigantic page support
References: <20190306190005.7036-1-alex@ghiti.fr>
 <20190306190005.7036-3-alex@ghiti.fr>
 <20190306.110436.1714716608828903522.davem@davemloft.net>
Message-ID: <ac0c5166-f1f6-5339-58e3-a33f085c1220@ghiti.fr>
Date: Wed, 6 Mar 2019 14:10:54 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190306.110436.1714716608828903522.davem@davemloft.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/6/19 2:04 PM, David Miller wrote:
> From: Alexandre Ghiti <alex@ghiti.fr>
> Date: Wed,  6 Mar 2019 14:00:03 -0500
>
>> sparc actually supports gigantic pages and selecting
>> ARCH_HAS_GIGANTIC_PAGE allows it to allocate and free
>> gigantic pages at runtime.
>>
>> sparc allows configuration such as huge pages of 16GB,
>> pages of 8KB and MAX_ORDER = 13 (default):
>> HPAGE_SHIFT (34) - PAGE_SHIFT (13) = 21 >= MAX_ORDER (13)
>>
>> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Much better.
>
> Acked-by: David S. Miller <davem@davemloft.net>
Thanks !

Alex

