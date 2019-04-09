Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 375ADC10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 16:01:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D879C2084C
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 16:01:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="QEWNNzv2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D879C2084C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74C376B026A; Tue,  9 Apr 2019 12:01:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FB096B026B; Tue,  9 Apr 2019 12:01:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EB3B6B026C; Tue,  9 Apr 2019 12:01:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1966B026A
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 12:01:18 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id 75so14957628qki.13
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 09:01:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=ukIp5K6XgUw8eCYSQP4WBy1wOYWCCxL8MZRY+ss74fk=;
        b=BdF0IUmckRLM+cFx3vbC5uYYTgUP/mAqkJYbAAvuHTJ2pQzfTlP7TAAas9HfgRj5Lp
         ACLk889qZcqCvzGQA2XRFtwa1XMq+CCfFJu31qIqjhmeo/qyHYeTL8gK4XXHGd3NdPd9
         QVzoY0VuT19TwL76x0hOH3+o02bs5fx6S679Bh5DU3ISaZ7e9NSuGLezUQZzafwctGcZ
         XCLbH1KNRbtWmO/6wKwrITm8lirdDJ5N7PwonGuCgykCzUg6Xco24QHIR44232AKlTps
         0piTRRxk9lqJI+tNGkWPlZpPnJxLGhv4/Rs4JVsTGhE8meqdDx6SXmRSewGpW1qdmI7U
         o4xA==
X-Gm-Message-State: APjAAAVz2n8OskGYjUfWa4aNUYUfgRCX4JQz6/gFQud5e4Crj9cEQ1ud
	erpzHt7N8iPXqbQ+wThhN30EIUpC1Hy2jhN8jHCTgcw7QMwT3t1qDEgzCi9VRhp+2vvfWRXlolr
	kw5k/QzWSg2+sXRsez2fBFf1gzhMk2S83xFUZRHte3BzqGQjrbtkXCbkxx8ZdUJw=
X-Received: by 2002:ac8:2285:: with SMTP id f5mr29740810qta.241.1554825677502;
        Tue, 09 Apr 2019 09:01:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyh1TbEV1aRfYmQw8BvuKgBdGERiktedlXgLY3ynERwWK9hRErO66HVWUQjYre9CKVmXjCe
X-Received: by 2002:ac8:2285:: with SMTP id f5mr29740661qta.241.1554825676228;
        Tue, 09 Apr 2019 09:01:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554825676; cv=none;
        d=google.com; s=arc-20160816;
        b=oJ/Qh7CN1ztjy4JbmOqz6ysZ6NTNHtkxWzH8Bu3jVLVoYfjSdw+e1lhP1wFXQYSkVk
         0GOzIpw2spjafZ7zeX+qzYU76xiCNUA91WklAEPD4rvPphZyxSr6PnytR1WqRgn/9n7e
         l996LU9mhzWolNdEQXiWH0onhduToLFIikVZPfEQ5LaGJL34n02JtN7rpr3TP7meB0nd
         UplCenCNZQoVvlRBwoBID6kw+DJjOSLpSN4hVQ1VB5kLQj1Dg5lHZD3PsdXjyqO2RN3J
         iD3L+ZqS8JBwcEOvkP/MZJLRDnXu1yF3oHuo0y/SwZrjfTv4b7QPMwbJdPNcdzAOFRU9
         7j4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=ukIp5K6XgUw8eCYSQP4WBy1wOYWCCxL8MZRY+ss74fk=;
        b=CS9yHP428bFy/OXp+habZB6P7aWfxq9QDfvt2ZpFRydnQgzPUvX4mqaKAZfsqCCOAh
         jKg2r28cpkhZnnmOkVJaU41bhRpnb6u8/tdNFxyrED/OIXpY+kAusHb/wOcVds18dtaf
         dQg8w6i8oeB3NHQcZKkqEybrfDNBmhBBruzfezRGeX9PbYtAJ/OGvS/ydrd3eru2Ew8o
         4SUP2ta6KV0wObpvPEcF9d+XyfDZD1QrUzSDfYXqmalJTPSgtAacOR1KsYRq2+Rzq3vV
         WbzU8K9JFwDmAxI/q0iMBaoHdpvFzjEZfAaADxj74h7A6Jf8odIAeLd6x6X03FY3NMKO
         sFHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=QEWNNzv2;
       spf=pass (google.com: domain of 0100016a02d5038e-2e436033-7726-4d2a-b29d-d3dbc4c66637-000000@amazonses.com designates 54.240.9.33 as permitted sender) smtp.mailfrom=0100016a02d5038e-2e436033-7726-4d2a-b29d-d3dbc4c66637-000000@amazonses.com
Received: from a9-33.smtp-out.amazonses.com (a9-33.smtp-out.amazonses.com. [54.240.9.33])
        by mx.google.com with ESMTPS id l15si7792578qvo.18.2019.04.09.09.01.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 09 Apr 2019 09:01:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016a02d5038e-2e436033-7726-4d2a-b29d-d3dbc4c66637-000000@amazonses.com designates 54.240.9.33 as permitted sender) client-ip=54.240.9.33;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=QEWNNzv2;
       spf=pass (google.com: domain of 0100016a02d5038e-2e436033-7726-4d2a-b29d-d3dbc4c66637-000000@amazonses.com designates 54.240.9.33 as permitted sender) smtp.mailfrom=0100016a02d5038e-2e436033-7726-4d2a-b29d-d3dbc4c66637-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1554825675;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=50hYcoxn2BeHRqUR1dpDDp6CiUZIJ7B2QB39HCVWIo4=;
	b=QEWNNzv2USVY0eK4qZBeLwqUhjEJKQaLcv2Sjoj0ui7jHwhE5VYqbs+gguUqGV/Y
	8jePuQR1l7hK5LYSixUqXo6iIejvUJ8sb0KgVNwUC3sZX6/LBq8ked3lgviThFihuJO
	R9zkPKuicFLqOtOOWM81WYtIAFsm6miHL94a1KDw=
Date: Tue, 9 Apr 2019 16:01:15 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
    "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: Basics : Memory Configuration
In-Reply-To: <SG2PR02MB3098925678D8D40B683E10E2E82D0@SG2PR02MB3098.apcprd02.prod.outlook.com>
Message-ID: <0100016a02d5038e-2e436033-7726-4d2a-b29d-d3dbc4c66637-000000@email.amazonses.com>
References: <SG2PR02MB3098925678D8D40B683E10E2E82D0@SG2PR02MB3098.apcprd02.prod.outlook.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.04.09-54.240.9.33
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Apr 2019, Pankaj Suryawanshi wrote:


> I am confuse about memory configuration and I have below questions

Hmmm... Yes some of the terminology that you use is a bit confusing.

> 1. if 32-bit os maximum virtual address is 4GB, When i have 4 gb of ram
> for 32-bit os, What about the virtual memory size ? is it required
> virtual memory(disk space) or we can directly use physical memory ?

The virtual memory size is the maximum virtual size of a single process.
Multiple processes can run and each can use different amounts of physical
memory. So both are actually independent.

The size of the virtual memory space per process is configurable on x86 32
bit (2G, 3G, 4G). Thus the possible virtual process size may vary
depending on the hardware architecture and the configuration of the
kernel.

> 2. In 32-bit os 12 bits are offset because page size=4k i.e 2^12 and
> 2^20 for page addresses
>    What about 64-bit os, What is offset size ? What is page size ? How it calculated.

12 bits are passed through? Thats what you mean?

The remainder of the bits  are used to lookup the physical frame
number(PFN) in the page tables.

64 bit is the same. However, the number of bits used for lookups in the
page tables are much higher.


> 3. What is PAE? If enabled how to decide size of PAE, what is maximum
> and minimum size of extended memory.

PAE increases the physical memory size that can be addressed through a
page table lookup. The number of bits that can be specified in the PFN is
increased and thus more than 4GB of physical memory can be used by the
operating system. However, the virtual memory size stays the same and an
individual process still cannot use more memory.

