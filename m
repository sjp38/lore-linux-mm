Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D5EEC31E45
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 02:32:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2DC2208CA
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 02:32:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2DC2208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A276A8E0004; Thu, 13 Jun 2019 22:32:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D7A38E0002; Thu, 13 Jun 2019 22:32:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C6A38E0004; Thu, 13 Jun 2019 22:32:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 572628E0002
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 22:32:06 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x9so666568pfm.16
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 19:32:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references
         :content-transfer-encoding:mime-version;
        bh=kTe2vZV0xSZQ1ioxOtwYAy0bK8GedKZIxNZ5CKd9JJs=;
        b=CeF8dQYDOZf75I/QpIvN5Pan0HBl06oXMkEKJinG4rEDH4nMHowMmayzKoWdkY3qP3
         9pzouTHeCb2Id9Oc5gxwljQM3EDRmzDt30SSr9Qc8cvtGem3zsEf7evrBi+ZO3z4ggPz
         /NRoD39Eqg2jecCRTo8z40ITSQOiV4g332o7VltbK/pHVxPprLkYyzYtj2LwgCetMKJe
         TeGqC5vIzZVbb6U1+H/zVWdSIlEAujQ6S3413S+zFc/AE15LHK9mALnTwVBW9I+10XuX
         ARsxEJukCiZ/0GaiUFDOBbtmHg2ORr6QVi+Ga5tpnETTXqgddWPbCE/V104Yc/6vwclY
         P2rQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-Gm-Message-State: APjAAAXB5AcRDWzVK7WJSTau0XaeK6HB+03RqLkSzeSeFjSFhUamc2JB
	h0fO11U8w1mbYB/HWAQNXyXhEv58jEyH/2Go4Y7P0HVjSJkd36iWvr2C8qYaISP/MFZ3qIdiDrc
	qu65VZJJHz/UY4n1QVlCZxJ4C50ljqN4pVTeZzSZRFmDPpuL9/W/oLIPyqGgM6zLspg==
X-Received: by 2002:a17:90a:25e6:: with SMTP id k93mr8756695pje.100.1560479525932;
        Thu, 13 Jun 2019 19:32:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwThrlYE0JkONz2HcVOwqR2WOHCT8MxPntqirkcqfs+BKLM4kVxil07djzEM4fdu30G/mnB
X-Received: by 2002:a17:90a:25e6:: with SMTP id k93mr8756655pje.100.1560479525160;
        Thu, 13 Jun 2019 19:32:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560479525; cv=none;
        d=google.com; s=arc-20160816;
        b=WJJV5mr0AKjvx6bOts0ANE3uxpRWzl0cJlv8wFGiyeos3SFbN8h2oh3aDQPZLp7bSo
         fh6TqejJ14F3gtxRCYmyyBvkoTosZjTnwkT447ao97xqVVE3XvddyLWhJHpnLT5pjQqE
         NoynyJn00kGGNWYIC0Au/eqXfTTn67CddxZCaUt/q1UJ7KLNoY6ueoObEqwyHE2A3+TP
         Qy7iTALR7LI7uFaNHwRJ22pYlrLWjCBearxKPoXRcOf0EPypdT7z9ZX9Q7ZWPx9C6Ctp
         GBA8dtpDoKBV+yeAPm3OXWwMTSsNe3gF9evzZHI3KOkauyG+EVC4LZLUwJKIOsO4j9M6
         UArw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=kTe2vZV0xSZQ1ioxOtwYAy0bK8GedKZIxNZ5CKd9JJs=;
        b=jF0ohicYXzIngPJ85c1/GsnR2nTk+x5RIO7tTw/k4eYCpMTSqMS4Zn8d6suqd7gIG6
         Cw0K6Tr1uAXP7jUk1keYqIi16ZQwsaSVDrFgfjCO5r8i66k0lgIZfg0aJh9ARzaIie1Y
         xFKEepuSS4si16h206CeF43+4MC2sQiKrc1yGTdEhN0I1REWlF82CFtEC8v+25+YiZvc
         ReD0TFBaJEOXqY7q3giYant1zplXbQauuqd0+2Zv4lz579zp/X/rU+drPxUVN5FsRJmB
         s54FEGcWijrC077LeQEQGk5rtNDQ62ZpO5SfApXwE/5h26Q+fuz51kvVDGzSbe1iAIav
         pItg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTPS id y13si1243002pgq.172.2019.06.13.19.32.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 19:32:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) client-ip=210.61.82.184;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of walter-zh.wu@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=walter-zh.wu@mediatek.com
X-UUID: ad556f1f2e36417abf74c4de3c3953c3-20190614
X-UUID: ad556f1f2e36417abf74c4de3c3953c3-20190614
Received: from mtkcas06.mediatek.inc [(172.21.101.30)] by mailgw02.mediatek.com
	(envelope-from <walter-zh.wu@mediatek.com>)
	(mhqrelay.mediatek.com ESMTP with TLS)
	with ESMTP id 589143347; Fri, 14 Jun 2019 10:32:02 +0800
Received: from mtkcas07.mediatek.inc (172.21.101.84) by
 mtkmbs08n2.mediatek.inc (172.21.101.56) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Fri, 14 Jun 2019 10:32:00 +0800
Received: from [172.21.84.99] (172.21.84.99) by mtkcas07.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Fri, 14 Jun 2019 10:32:00 +0800
Message-ID: <1560479520.15814.34.camel@mtksdccf07>
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
Date: Fri, 14 Jun 2019 10:32:00 +0800
In-Reply-To: <1560447999.15814.15.camel@mtksdccf07>
References: <20190613081357.1360-1-walter-zh.wu@mediatek.com>
	 <da7591c9-660d-d380-d59e-6d70b39eaa6b@virtuozzo.com>
	 <1560447999.15814.15.camel@mtksdccf07>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.2.3-0ubuntu6 
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
X-TM-SNTS-SMTP:
	C34F4A9FF25B720FA8D264905C1A23CE1B1F2B5A1E4DE450A529D5CDAA5FBF8F2000:8
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-06-14 at 01:46 +0800, Walter Wu wrote:
> On Thu, 2019-06-13 at 15:27 +0300, Andrey Ryabinin wrote:
> > 
> > On 6/13/19 11:13 AM, Walter Wu wrote:
> > > This patch adds memory corruption identification at bug report for
> > > software tag-based mode, the report show whether it is "use-after-free"
> > > or "out-of-bound" error instead of "invalid-access" error.This will make
> > > it easier for programmers to see the memory corruption problem.
> > > 
> > > Now we extend the quarantine to support both generic and tag-based kasan.
> > > For tag-based kasan, the quarantine stores only freed object information
> > > to check if an object is freed recently. When tag-based kasan reports an
> > > error, we can check if the tagged addr is in the quarantine and make a
> > > good guess if the object is more like "use-after-free" or "out-of-bound".
> > > 
> > 
> > 
> > We already have all the information and don't need the quarantine to make such guess.
> > Basically if shadow of the first byte of object has the same tag as tag in pointer than it's out-of-bounds,
> > otherwise it's use-after-free.
> > 
> > In pseudo-code it's something like this:
> > 
> > u8 object_tag = *(u8 *)kasan_mem_to_shadow(nearest_object(cacche, page, access_addr));
> > 
> > if (access_addr_tag == object_tag && object_tag != KASAN_TAG_INVALID)
> > 	// out-of-bounds
> > else
> > 	// use-after-free
> 
> Thanks your explanation.
> I see, we can use it to decide corruption type.
> But some use-after-free issues, it may not have accurate free-backtrace.
> Unfortunately in that situation, free-backtrace is the most important.
> please see below example
> 
> In generic KASAN, it gets accurate free-backrace(ptr1).
> In tag-based KASAN, it gets wrong free-backtrace(ptr2). It will make
> programmer misjudge, so they may not believe tag-based KASAN.
> So We provide this patch, we hope tag-based KASAN bug report is the same
> accurate with generic KASAN.
> 
> ---
>     ptr1 = kmalloc(size, GFP_KERNEL);
>     ptr1_free(ptr1);
> 
>     ptr2 = kmalloc(size, GFP_KERNEL);
>     ptr2_free(ptr2);
> 
>     ptr1[size] = 'x';  //corruption here
> 
> 
> static noinline void ptr1_free(char* ptr)
> {
>     kfree(ptr);
> }
> static noinline void ptr2_free(char* ptr)
> {
>     kfree(ptr);
> }
> ---
> 
We think of another question about deciding by that shadow of the first
byte.
In tag-based KASAN, it is immediately released after calling kfree(), so
the slub is easy to be used by another pointer, then it will change
shadow memory to the tag of new pointer, it will not be the
KASAN_TAG_INVALID, so there are many false negative cases, especially in
small size allocation.

Our patch is to solve those problems. so please consider it, thanks.


