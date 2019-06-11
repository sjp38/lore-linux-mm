Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AC0BC4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 19:49:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3927521734
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 19:49:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="rK0o3lbW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3927521734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD09A6B0008; Tue, 11 Jun 2019 15:49:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D816E6B000A; Tue, 11 Jun 2019 15:49:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C234D6B000C; Tue, 11 Jun 2019 15:49:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id A14BB6B0008
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 15:49:46 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id k10so14866310ywb.18
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 12:49:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=9AmA5DfbQrhm6Jd6LENDMh9Jm9BdVFb9bY0Ese/IZfk=;
        b=V3Soyo8umnQtkXZe0GguvH5SHr5JAxSFowDILq1DB/zgEHiaRuumly3HWaj8g8zOjf
         ARxqb5luDUx3BqGFqBzjgeZowD/O31SBPdHV49aWlxJEL2s1f1JoKE+OrtY+mf+Hcm4v
         oVLBX9ziTV5oosMLywOqclWcSmZFFont1fBjKp9hEgwoABZUti5ln9cnEKWtEFidfEmE
         l9W32JpIal+2J8+77QDcmet+/Brbtw2vBuKs+hOs3grJ59bDy5Iz3eNzEwrnBmXsUv/G
         EMY5Gdgu4CSFTyjXWSgMY1rVY5alH5592c/nSPzmtvMxy626o7FkTwOVlG1ZRp5/i62r
         X7tA==
X-Gm-Message-State: APjAAAV9hJe9nyEJP0sESwNEBUmmGW5t0xrrz/e97ftoDcRmCkV+FPv9
	Q1C9D8nNAhI/lBIf620UfkGsrTh4nw0XBcfdLqzLJSsQMNHYO7dSZvvKax2xA2hw3/DP0y5jTht
	LZwBoWlIvfyCDkyxbaYjXBCJZfgqoGQu4ULjCwS4pb7C3o5KZD/JW3oIGYHg/dvB59g==
X-Received: by 2002:a81:4709:: with SMTP id u9mr38571307ywa.39.1560282586377;
        Tue, 11 Jun 2019 12:49:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/7jXmjQ/1mNf60KbQZRWYIjiiI883usyIBHl3yDEK0Kwziz/gLcpGfgdHHIuR9v0VjfsR
X-Received: by 2002:a81:4709:: with SMTP id u9mr38571276ywa.39.1560282585703;
        Tue, 11 Jun 2019 12:49:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560282585; cv=none;
        d=google.com; s=arc-20160816;
        b=a8S4yQRq1vUSayLCG3KVQsu3SuiXbiEe4GggeASrrHGa1w9tihMwuJUbuy4fBulx+2
         VBYSQUajLqoz89NKzmruCVo/flukkucicK0y+TqMJudWbMmbKo4tZk1ZISFkiQx39+L0
         9k6hbXBhXt2hR1iiHBvXBDzga/5est8jxAKNURwkuhU37wTVX1VGL9bdy8RvAlVQhg8N
         Ts580S9KFjDw7eXZV5kwQjR0gmzpyUXg9BWLl03vzwhXH51AvYHmv0qjRqOdj9RK2+WL
         yPNkEa/Qp1EcpWcx326WXyJPb22L02xLpAWkeO/RUigE6v46Slc+lKLP2m13azioCBvt
         MZow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=9AmA5DfbQrhm6Jd6LENDMh9Jm9BdVFb9bY0Ese/IZfk=;
        b=IBaTiVDhjPIY3Vy5+Ipkvcnoj7u3SNcvpQa9E7lH2PQCZ9qIDboo4G7694OxMjilPP
         LrvHzvasOJY/lIHbO+rc2q3FB4GF6Gb5XievdYGyutbQKIbKje52c60ummD099W/LIVS
         2VLceY2q/qhVUlRWxiOmxCYyM81QurEvMdiVRgBUonRL+sLkBULOUSAJdNyVc082i5Ag
         ZGl/sGbbqE5qfJZfpmRp0FS9r4IgJUjdL0rRPvNwJ9univlAMqKhJy97P5/8/bGzglc8
         t5SfPmh8CuZ3jX6xce5gjE5CEwfSjhOhiOvHDuVo2Xu+w28BVycnru8SudfSyNn8WoeJ
         R/jg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=rK0o3lbW;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id x65si4720894ywf.419.2019.06.11.12.49.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 12:49:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=rK0o3lbW;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d0005d60000>; Tue, 11 Jun 2019 12:49:42 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 11 Jun 2019 12:49:44 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 11 Jun 2019 12:49:44 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 11 Jun
 2019 19:49:44 +0000
Subject: Re: [PATCHv3 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in
 get_user_pages_fast()
To: Christoph Hellwig <hch@infradead.org>, Pingfan Liu <kernelfans@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>, Ira Weiny
	<ira.weiny@intel.com>, Mike Rapoport <rppt@linux.ibm.com>, Dan Williams
	<dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Aneesh
 Kumar K.V <aneesh.kumar@linux.ibm.com>, Keith Busch <keith.busch@intel.com>,
	LKML <linux-kernel@vger.kernel.org>
References: <1559725820-26138-1-git-send-email-kernelfans@gmail.com>
 <20190605144912.f0059d4bd13c563ddb37877e@linux-foundation.org>
 <CAFgQCTur5ReVHm6NHdbD3wWM5WOiAzhfEXdLnBGRdZtf7q1HFw@mail.gmail.com>
 <2b0a65ec-4fb0-430e-3e6a-b713fb5bb28f@nvidia.com>
 <CAFgQCTtS7qOByXBnGzCW-Rm9fiNsVmhQTgqmNU920m77XyAwZQ@mail.gmail.com>
 <20190611122935.GA9919@dhcp-128-55.nay.redhat.com>
 <20190611135212.GA4591@infradead.org>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <0a05a49f-ac93-1d07-d222-0ec928e61568@nvidia.com>
Date: Tue, 11 Jun 2019 12:49:44 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190611135212.GA4591@infradead.org>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1560282582; bh=9AmA5DfbQrhm6Jd6LENDMh9Jm9BdVFb9bY0Ese/IZfk=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=rK0o3lbWourRcCz6mKsDXKAsjWmJ/LAIe0BeXKud/M/0EDVKbA5ztauiV3dvS5e8E
	 D7nGQhx3rwfxXhwyYsB2sRUjmEjurJhyK0Oc0WLrNlX6TzmTco9YWeS5fmwnml7fKf
	 tlTR7NCR3HKwvOsFgYcLWt9syBcSo1LHM0yVUzOWIuGHAomET5MNtcmJCRliAdmrHh
	 h63WHG8rX4vDMac19zxJQQgwum1Ko7jB19id+H7xZ98ac4biAz/DPnqA0WZQR0JUwJ
	 ojMkmWSEYeUjv3e21lAfka8L7vPgIY0sJ6fR3PYNKqCQwsMa0LXdEn/mKZ7925IqHb
	 GEl0wIQTeeuSA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/11/19 6:52 AM, Christoph Hellwig wrote:
> On Tue, Jun 11, 2019 at 08:29:35PM +0800, Pingfan Liu wrote:
>> Unable to get a NVME device to have a test. And when testing fio on the
> 
> How would a nvme test help?  FOLL_LONGTERM isn't used by any performance
> critical path to start with, so I don't see how this patch could be
> a problem.
> 

yes, you're right of course. We skip the loop entirely for FOLL_LONGTERM,
and I forgot for the moment that the direct IO paths are never going to
set that flag. :)

thanks,
-- 
John Hubbard
NVIDIA

