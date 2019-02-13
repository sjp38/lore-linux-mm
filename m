Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88DFBC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:12:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50B132070B
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 17:12:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50B132070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E139F8E0002; Wed, 13 Feb 2019 12:12:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC1C68E0001; Wed, 13 Feb 2019 12:12:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD7D58E0002; Wed, 13 Feb 2019 12:12:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 78C8F8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 12:12:39 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id x15so1306409edd.2
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 09:12:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=17e0/q4PYsBFQAvs4qmYyeLRljKF4qPlKW7i8nZTDY8=;
        b=QalUe5u9aTRQ8jL0oKGlZ6q9SBasJcWbkF56I9TrVMUuv/XU5BEUfxpd7EcUCp8FfG
         xmSo7ohZWuUDWX6tWfqPBxXv+PE1KvJVKfHb20+7QB8ruy+3yPP1fr+p4ypHHouSS90+
         yzLtbju4S0D4PaMLysXOitIPNFf+WRq2QI8hkqhzJqrDZVJxBP5ogrj2gI/mTbwGZyHc
         xN3v1DTIvFwYuA2BmkCGIj3D7ledwppXuMaUfqYVboJguVkhUmXAn9tO+fPKSx8mz2AH
         PurA4KMUSoNm/2m05GsrjQqWcgogSUvAppQDKFfw57gtPA+fRpCHYBdemC1v+P6YaAdC
         kz+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AHQUAuYNgI7hf3dK8q53K/Nh/M4MguVj4zv+xZ8U0Rc6NicAhgr1bt/1
	t6abMsZcbj/yhYRu/vDHqoSQnSsXpwjPVq2nQCNf3A0TsfylpYHdI2WpHFF/C2HK1MKsZqm20Q5
	VywcZ2EjijTjX08IgEJQmRhJJ6AF5/N2+DW1SSLCHxlUW0tvIsi3ZPQRD3fzz4KDnrA==
X-Received: by 2002:a50:8b26:: with SMTP id l35mr1194212edl.146.1550077958970;
        Wed, 13 Feb 2019 09:12:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZbwskdmTWeXwVhaZFo7eVQjYZQ1IgGIh+iOsGhLO5ymolkLYfeoByoObj6Bz/YvSttMoMh
X-Received: by 2002:a50:8b26:: with SMTP id l35mr1194155edl.146.1550077958181;
        Wed, 13 Feb 2019 09:12:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550077958; cv=none;
        d=google.com; s=arc-20160816;
        b=XkSqNk+5nyZ2IsoJfplDu0R5Lf9XpvhSUjKg10Mlavs4uuiU2Fc+eNKLKO4IzFW3D0
         PcpJZs0bTfN07epmxipSVllyo3pWM1Qqbi/EzIk39aBYoOLQHesPW0uYRJD7OZmhQq0Z
         JM2TJK4T5mfYBXbqig7E6OtgwLpb3OJpYJp3a5M/sdZ/kkI4of3J4Ct5aopcU2o1xOHr
         NBzAvfcd4W1vjxdfgWjzLcttByJpa4P5kaJ3gmyw58idGOSklUowHVd/Q6xx9+PnVOS2
         JsURHKha9RH+NfKZBF+p+9Y7zxVeJFo0+2cXwgU0OsGig2XSm3VYhQ7fHGo0GCkESI13
         ahcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=17e0/q4PYsBFQAvs4qmYyeLRljKF4qPlKW7i8nZTDY8=;
        b=EZH+3zy+fwFN52QuRFLXPRRjoYPZvoYqvtaLwt/+pr7/xqizVmZVXygemfQiy/sNO+
         GmfPYs8eaB3haoE/6zO9es4NmEDy3a7Isr+iQ5WkGOgmTEg2A/AhiBxzeEB9sYSG1Bzk
         GCSCDvdmzuybJFBWVYKABiCIaNzB701qkpu/u4qx4jDvnbowiuG5+Y8qvGC0GAwm4Jhm
         BAnnR0QrnWgV0mdDdZR1Jw87d3AY8Sjn9K2aS2XUfL/FczUGpClFOdAvgbhrFt53FdGE
         JviZSNCo8cz7aKpVqzw0eUNJFHVKt1tIuT0tYti1UH8iE2Wq8GKagKG3n4lPSQdNoRMg
         6+Xw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f4si1519500ejb.76.2019.02.13.09.12.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 09:12:38 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F0599B157;
	Wed, 13 Feb 2019 17:12:36 +0000 (UTC)
Subject: Re: [PATCH v6 0/3] iommu/io-pgtable-arm-v7s: Use DMA32 zone for page
 tables
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicolas Boichat <drinkcat@chromium.org>, Will Deacon
 <will.deacon@arm.com>, Robin Murphy <robin.murphy@arm.com>,
 Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>,
 Levin Alexander <Alexander.Levin@microsoft.com>,
 Huaisheng Ye <yehs1@lenovo.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>,
 linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>,
 iommu@lists.linux-foundation.org, lkml <linux-kernel@vger.kernel.org>,
 linux-mm@kvack.org, Yong Wu <yong.wu@mediatek.com>,
 Matthias Brugger <matthias.bgg@gmail.com>, Tomasz Figa <tfiga@google.com>,
 Yingjoe Chen <yingjoe.chen@mediatek.com>, hch@infradead.org,
 Matthew Wilcox <willy@infradead.org>, Hsin-Yi Wang <hsinyi@chromium.org>,
 stable@vger.kernel.org, Joerg Roedel <joro@8bytes.org>
References: <20181210011504.122604-1-drinkcat@chromium.org>
 <CANMq1KAmFKpcxi49wJyfP4N01A80B2d-2RGY2Wrwg0BvaFxAxg@mail.gmail.com>
 <20190111102155.in5rctq5krs4ewfi@8bytes.org>
 <CANMq1KCq7wEYXKLZGCZczZ_yQrmK=MkHbUXESKhHnx5G_CMNVg@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <789fb2e6-0d80-b6de-adf3-57180a50ec3e@suse.cz>
Date: Wed, 13 Feb 2019 18:12:34 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CANMq1KCq7wEYXKLZGCZczZ_yQrmK=MkHbUXESKhHnx5G_CMNVg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/22/19 11:51 PM, Nicolas Boichat wrote:
> Hi Andrew,
> 
> On Fri, Jan 11, 2019 at 6:21 PM Joerg Roedel <joro@8bytes.org> wrote:
>>
>> On Wed, Jan 02, 2019 at 01:51:45PM +0800, Nicolas Boichat wrote:
>> > Does anyone have any further comment on this series? If not, which
>> > maintainer is going to pick this up? I assume Andrew Morton?
>>
>> Probably, yes. I don't like to carry the mm-changes in iommu-tree, so
>> this should go through mm.
> 
> Gentle ping on this series, it seems like it's better if it goes
> through your tree.
> 
> Series still applies cleanly on linux-next, but I'm happy to resend if
> that helps.

Ping, Andrew?

> Thanks!
> 
>> Regards,
>>
>>         Joerg
> 

