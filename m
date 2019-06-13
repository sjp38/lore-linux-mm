Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D55AC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:46:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5D142175B
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:46:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5D142175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 746118E0003; Thu, 13 Jun 2019 13:46:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F65F8E0002; Thu, 13 Jun 2019 13:46:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BD868E0003; Thu, 13 Jun 2019 13:46:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 24ADE8E0002
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:46:48 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id x3so730312pgp.8
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:46:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references
         :content-transfer-encoding:mime-version;
        bh=lEzlxuvpSMrNR4n7z6yfIaw8K7RTxUxdTVJa0UdpOPk=;
        b=oFLCaO3NIdaOpfNcRwV40Kyq8dx6RRo+dT/IZIpHN8Eq0vq6q3eqynSZFY5TUAqQC+
         WMOQGOfZCFXhKYWdfQp+mX6WrsERpv/Y6FtOE/gyvWnI1IhvsoSAwEBBQhrx9P08n7Uv
         gvmjSRffmSpDpp4x7+8GC+Q62aliXHwsg3PZzhs1sMxiDW/UuhwkSPMGolh1o7vh2a/x
         kNblyCf9/js3QilI+Abc45rKuqkXuvOaw5RmTjjBy2vy2YNuKdVWJJmUUtXeXgDn441S
         3GI72bfhhwgIiYvOpuRmqlTIKS7hPFZnaTkolbSAWbfq+AoENU0m2uZny6oj9mESPp2/
         SsFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-Gm-Message-State: APjAAAXPvZ5Lhpmp26SwGunooxZG1VnvUxUKsqTATmpQaG49PML53Msl
	AYKhkGNfavcFcdr6/wDjDLwyveCPiLr0nX7IOV6jVeKpgubbNu6BmjsXm570FNyXR3RWEDnzgGJ
	b9d5vPoWq++qBFLjfUNpfe+bGjmf+xOMDRJD41qVtVqpcBD8s0wts88ROmXaue97RAA==
X-Received: by 2002:a17:90a:2343:: with SMTP id f61mr6871162pje.130.1560448007822;
        Thu, 13 Jun 2019 10:46:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqycQGVGgIS5+hHMjT8fio4jIGTuAALwRw4n7MiEAmu4sgOYY0ty+vpQDIAmQRF0XVU7VxLr
X-Received: by 2002:a17:90a:2343:: with SMTP id f61mr6871106pje.130.1560448007110;
        Thu, 13 Jun 2019 10:46:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560448007; cv=none;
        d=google.com; s=arc-20160816;
        b=Ky/0T2jAL/nitzEbt1C5uio3fVnjzfmmFH/MvwIeLx4piwFYihMQ5OSI8egpGrUtYS
         RhJGSUH+9f3KEQTwekz94Me2XO7VH17D/rXhgGBO7x5+PyZDnj9o8UFxE7tHib02KG5l
         hyemeGLjfayAsqQf9lnF48cJdh+nZJzQqzuOkRRtsZ0pORUTK3yuvZv2fpnOvENO+d0b
         XCr0SSXAOJXog8B9bPWPToR3L6DfP680DL+QDGvVKQTRLDuKU0xWf7koXhtFfW0M7Dsa
         DhJsPZU/CZupxsSEsWnVLPO7b9yUsH/BKYQb7c0/lYBx8ueNfwXkfzLL3c10+2GNQGw4
         Vy3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=lEzlxuvpSMrNR4n7z6yfIaw8K7RTxUxdTVJa0UdpOPk=;
        b=E124ydrY12ugZIMP/RW8DLzsSawuZzD3mCqNSB5vRmdHntDmvLBDT27N5yHmD5oFsY
         9uOEnPpIFJAIX9aYoUQEBG3ud2HQw3kKOvw0e+TGMb8rwVWPD5fW3NMlmLRTY3X/nzkC
         M9tp9wxinp+E7XeC+qVX4WkF0mC6Bi3g1OOm//ACFJhVxZsDO8IT2BCTM+DrBPwSN2Lc
         xXrmLICyPLnx/XsA7/BJ8bvD36dpMZsljUsZKFMcFsdT3xMCS4D1FskqB7I0QpvVZgqS
         R4PH4kZKmxFXYhqXilsgsbVTyTZMmCK/seeWx3rdfxdhKvhwyL0ZT2L83hr14n0weFqK
         CAlg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTPS id f32si258754pje.70.2019.06.13.10.46.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 10:46:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) client-ip=210.61.82.183;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-UUID: 1bc9fbe28e904bcf97072f05f18c0602-20190614
X-UUID: 1bc9fbe28e904bcf97072f05f18c0602-20190614
Received: from mtkcas06.mediatek.inc [(172.21.101.30)] by mailgw01.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(mhqrelay.mediatek.com ESMTP with TLS)
	with ESMTP id 795620865; Fri, 14 Jun 2019 01:46:41 +0800
Received: from mtkcas08.mediatek.inc (172.21.101.126) by
 mtkmbs08n2.mediatek.inc (172.21.101.56) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Fri, 14 Jun 2019 01:46:39 +0800
Received: from [172.21.84.99] (172.21.84.99) by mtkcas08.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Fri, 14 Jun 2019 01:46:39 +0800
Message-ID: <1560447999.15814.15.camel@mtksdccf07>
Subject: Re: [PATCH v3] kasan: add memory corruption identification for
 software tag-based mode
From: Walter Wu <walter-zh.wu@mediatek.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
CC: Alexander Potapenko <glider@google.com>, Dmitry Vyukov
	<dvyukov@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg
	<penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim
	<iamjoonsoo.kim@lge.com>, Matthias Brugger <matthias.bgg@gmail.com>, "Martin
 Schwidefsky" <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Vasily
 Gorbik" <gor@linux.ibm.com>, Andrey Konovalov <andreyknvl@google.com>, "Jason
 A . Donenfeld" <Jason@zx2c4.com>, Miles Chen <miles.chen@mediatek.com>,
	<kasan-dev@googlegroups.com>, <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-mediatek@lists.infradead.org>, <wsd_upstream@mediatek.com>
Date: Fri, 14 Jun 2019 01:46:39 +0800
In-Reply-To: <da7591c9-660d-d380-d59e-6d70b39eaa6b@virtuozzo.com>
References: <20190613081357.1360-1-walter-zh.wu@mediatek.com>
	 <da7591c9-660d-d380-d59e-6d70b39eaa6b@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.2.3-0ubuntu6 
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
X-TM-SNTS-SMTP:
	73E573334F60FA682523A92B528AE4E79ADB9EB515874F36690B616CC9E25A672000:8
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-06-13 at 15:27 +0300, Andrey Ryabinin wrote:
> 
> On 6/13/19 11:13 AM, Walter Wu wrote:
> > This patch adds memory corruption identification at bug report for
> > software tag-based mode, the report show whether it is "use-after-free"
> > or "out-of-bound" error instead of "invalid-access" error.This will make
> > it easier for programmers to see the memory corruption problem.
> > 
> > Now we extend the quarantine to support both generic and tag-based kasan.
> > For tag-based kasan, the quarantine stores only freed object information
> > to check if an object is freed recently. When tag-based kasan reports an
> > error, we can check if the tagged addr is in the quarantine and make a
> > good guess if the object is more like "use-after-free" or "out-of-bound".
> > 
> 
> 
> We already have all the information and don't need the quarantine to make such guess.
> Basically if shadow of the first byte of object has the same tag as tag in pointer than it's out-of-bounds,
> otherwise it's use-after-free.
> 
> In pseudo-code it's something like this:
> 
> u8 object_tag = *(u8 *)kasan_mem_to_shadow(nearest_object(cacche, page, access_addr));
> 
> if (access_addr_tag == object_tag && object_tag != KASAN_TAG_INVALID)
> 	// out-of-bounds
> else
> 	// use-after-free

Thanks your explanation.
I see, we can use it to decide corruption type.
But some use-after-free issues, it may not have accurate free-backtrace.
Unfortunately in that situation, free-backtrace is the most important.
please see below example

In generic KASAN, it gets accurate free-backrace(ptr1).
In tag-based KASAN, it gets wrong free-backtrace(ptr2). It will make
programmer misjudge, so they may not believe tag-based KASAN.
So We provide this patch, we hope tag-based KASAN bug report is the same
accurate with generic KASAN.

---
    ptr1 = kmalloc(size, GFP_KERNEL);
    ptr1_free(ptr1);

    ptr2 = kmalloc(size, GFP_KERNEL);
    ptr2_free(ptr2);

    ptr1[size] = 'x';  //corruption here


static noinline void ptr1_free(char* ptr)
{
    kfree(ptr);
}
static noinline void ptr2_free(char* ptr)
{
    kfree(ptr);
}
---


