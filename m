Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DA1BC606B0
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 01:53:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBD17216C4
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 01:53:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBD17216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 692128E003A; Mon,  8 Jul 2019 21:53:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 643E58E0032; Mon,  8 Jul 2019 21:53:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 558DF8E003A; Mon,  8 Jul 2019 21:53:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3558D8E0032
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 21:53:32 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id n19so10094226ota.14
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 18:53:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=doFEHHtUNrp9yhDAK7Wgc+p+MPUgottJC0hRAzgyrWc=;
        b=AKHxIq5e6r/hNL64KOywo5z08NkUx91HSDQs0i4r9cqYXnvf+MVlulEKatqLn31PWs
         F52+Z6tEfHTtFntYwklzWjyX7ZUG1vL3mtQaYfOh+7/kZMouqAPnOUd4uX30WfEK5Ins
         jjUVTuq5hNZBn/Et+DrUwjrx2dt6cBnkyomRSHFgLj8N/i46VXq5ATHAEHocbDrTPr3y
         4YkbO3tnVS4BJYYHli3LVFT0Bc8euGo2pB00m6QuNMlIUsR9LsGgzyjHkG0ej/2ynePd
         yUkGLzJ3aRZk7PZUZcIYZaZcKGv4mPl8kPAETio14dfMcfdqcRXZLqz/mY1eEEF1qZLZ
         Y4Tg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAVZS5H4vvSvg+5Ha7WQppFOZAEOBS1XG4PU/eLDMMbx6OT0iY3q
	F3MGEK5abC0b1EpGlS7zyhaHAaQoT3UVJ31s7IvMCWbt/wH27J7w0aheGehd9IIWilJHhAdjHFq
	Q9Bnc7iX5rfwk0Sv2uUqXk3EHWnk5GhB/q24GANcJHtcgseMlsWUz1LmLHBNxJojh6w==
X-Received: by 2002:a9d:6c4a:: with SMTP id g10mr15844114otq.31.1562637211924;
        Mon, 08 Jul 2019 18:53:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwyS7eIGV9EwWUkNQ/0T+/B5p1SmVCfvl/gMyFyhpteAq95bk9F3Yc9BiystNBCC8ph3wt7
X-Received: by 2002:a9d:6c4a:: with SMTP id g10mr15844084otq.31.1562637211385;
        Mon, 08 Jul 2019 18:53:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562637211; cv=none;
        d=google.com; s=arc-20160816;
        b=zrRkCz6WLterOGEjjOVAddAEEVlK7aQII4+Jnm4IeG9zVV+G51Lq3nILflffzFkc80
         Cq0lz6d/ykBHHMi3bPX/fKbhPPRsyvJS3cgnucaa2TmpupQ823N8Teif1LXYNyO1GZjV
         WaZ5osESlry/zAO/R4EhYeCV0fjL9PAYTi/OL0wG+hMwmqJIqkvMBISi6Hl6DZcCRjVj
         l3HaHYMW2SjoZ6QQyrgpcW0IxeknjdxfbivpIVt1dFI91E9g7Pu9YuaeQRQhJbCXbP0n
         dC0Ww45MzT0YBCcQBAiIb+Xs6P7JORMY3CCV+chO5yJHov93RDNZxZNhTx95VGRaW6Yi
         MJEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=doFEHHtUNrp9yhDAK7Wgc+p+MPUgottJC0hRAzgyrWc=;
        b=LJ4B5buFOB9Knt39yEL4fHRk53upi0bN1qKNwlf2q8lZepQJKDfQHfCc9G5NrcE5L4
         OebrsUrU2PI/hA1KpO6SKC4DRU4C0gwCDncY8DBCXbMuqKmGnQqjtELKQyHb3Cf8zSpk
         JX+yr+QthQ/LB9Xighis6EcIknEOaEsaD5ymx+5R9MieK2kyCO+rgMso+nxahAhsBrhs
         nQ+HDgfVc0558z0H5BIALqaKVIawjiDXipvItn/rl06i2qIWrkJ6y1eMlHr8FMMj+MXX
         LGr8KUOCMN082WVWdYnbzKGe/elm1Ek9d/OHWI4KSikpiITiaXFlLrZZFtLG+mn5Jt9E
         2xAA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id 59si10789138ota.198.2019.07.08.18.53.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 18:53:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS406-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id E197C582CD666893E410;
	Tue,  9 Jul 2019 09:53:25 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS406-HUB.china.huawei.com
 (10.3.19.206) with Microsoft SMTP Server id 14.3.439.0; Tue, 9 Jul 2019
 09:53:20 +0800
Message-ID: <5D23F38F.5060008@huawei.com>
Date: Tue, 9 Jul 2019 09:53:19 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Matthew Wilcox <willy@infradead.org>
CC: <akpm@linux-foundation.org>, <anshuman.khandual@arm.com>,
	<mhocko@suse.com>, <mst@redhat.com>, <linux-mm@kvack.org>
Subject: Re: [PATCH] mm: redefine the MAP_SHARED_VALIDATE to other value
References: <1562573141-11258-1-git-send-email-zhongjiang@huawei.com> <20190708144319.GE32320@bombadil.infradead.org>
In-Reply-To: <20190708144319.GE32320@bombadil.infradead.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/7/8 22:43, Matthew Wilcox wrote:
> On Mon, Jul 08, 2019 at 04:05:41PM +0800, zhong jiang wrote:
>> As the mman manual says, mmap should return fails when we assign
>> the flags to MAP_SHARED | MAP_PRIVATE.
>>
>> But In fact, We run the code successfully and unexpected.
>> It is because MAP_SHARED_VALIDATE is introduced and equal to
>> MAP_SHARED | MAP_PRIVATE.
> No, you don't understand.  Look back at the introduction of
> MAP_SHARED_VALIDATE.
>
> .
>
Thanks,  I will look at the patch deeply.

Sincerely,
zhong jiang

