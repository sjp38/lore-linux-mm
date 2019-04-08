Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05552C10F13
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 18:58:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B41782087F
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 18:58:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B41782087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50D7F6B0276; Mon,  8 Apr 2019 14:58:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C9BD6B027A; Mon,  8 Apr 2019 14:58:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35DA26B027B; Mon,  8 Apr 2019 14:58:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0D9B26B0276
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 14:58:52 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id 23so12376798qkl.16
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 11:58:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=c8I6QueFedh9dQzEzVr1JqZzF+kYP9LRhwgGGT37ivA=;
        b=oSvuYpHvpoTKjdKodnGd4Ay+r/sfP8dLqdo1WBMN12NUKIgnS1tqNI+8I43IDP7IWt
         rQnkWK1nAFHxuaqiO7zp1/xBexqV6DMGbUPhim0C65SapADVoEpcJDEupCP6NfUVCVmj
         RQSSXBHuUYgnTlrICLUSOj44cuE+LyqHy8W2E6nNSJzzMkRCncUuh0jyPsuAEflnKofg
         vOTO1KbQ5WnZBBZV4FOJFaaWgbJ+k8vNHj7ir/lgecAHHNJQi0eXyJQRmNLWr24fuStK
         Q7NVkPCV/LDD4BYbYMpTNgnS47Jzgq600Or49nrPRATEtEJMJ8u2jshx2f1M9/ro3DlV
         8hig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV/5G8CBuKpewzHoxiMTu2/U8DJYVJab6+5Vo37dIurNLEb9H4c
	BCx3GPIbcUtaoJwrAfmNG3R1iiXFPLrm+sPJXdPwOkHRPoY/zLzY/PPYDeAfQLDMzn88D+TCgS2
	3RcD2Q4LQ630B/qLEWSMV99lhlzSlBGYn0+bQEoBgKw79KRNOSV4847hZ3W9gM80yqA==
X-Received: by 2002:a0c:afae:: with SMTP id s43mr24978900qvc.145.1554749931754;
        Mon, 08 Apr 2019 11:58:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxT9tyepSm3scFeNALF1Xj2eLCeds6ohCovg3gI3+Vcy+JQBv3Q7Ybt8KQ+WJAJXXGPvCet
X-Received: by 2002:a0c:afae:: with SMTP id s43mr24978837qvc.145.1554749930923;
        Mon, 08 Apr 2019 11:58:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554749930; cv=none;
        d=google.com; s=arc-20160816;
        b=hkoqxYHAgrnR7HZHjUI/6m5GOkiFHD/yyPP/tjWim+7j/g+vblPRHi3UcFTwqpjfT6
         owcgcPDhoehfZ2ggCmcGZTAzVxpu6UQqgjWKH0qajWMNRQtf6BuOUPlvJ8iSk316QZPG
         V7zuj2dgRr8U1U+KFRSu9spTr4upU2G8l2YUYhdItW6j6biGt5ABW6BV0USMZXRPvd41
         tqykALypn3nyZlt04G0qf1ZPiH7D44zjylC2jvWfUEuAWoibrfpMtdCBcY21lyFpdkxR
         FnJs1yDd7YP1SDqBBkgIBEzec7PBaIoDcaowXpV0Jji7u04uA2RtTDdQz2rJHApmlcbW
         Of8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=c8I6QueFedh9dQzEzVr1JqZzF+kYP9LRhwgGGT37ivA=;
        b=IGAgLIl0k7b+yUUehqfHtaO6MHrAc9y0CxPHV5t27xrJrS1rLuQBm8FQdC6fXLm1rq
         GzKk/R4QaBT5CYd6YsUIeTt0RLVvygub0iqWKE9SsPxdIygaerT1awHVR2eo7bstWCoU
         mET5bGIhtelRpX6sAkScP9OIXD3xpPuy8bKvQ0Nrv188Z2OoQLHmT0RhJH2tH+A3/dDB
         nIj43cDc7Wb9t0CUWTdk0JjBAPdf8SN9o8WE7fKq2YyGWxl5Qf4EmZMB4ZRHlLaLSFNZ
         4wFQqNs83GxG//5JyD8m+jMDJRs9X5edj8ijngamgNeKhNd2I0RBFcmpj81VBJ6iJZi3
         0KdA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d4si147784qtr.401.2019.04.08.11.58.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 11:58:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D064A307D988;
	Mon,  8 Apr 2019 18:58:49 +0000 (UTC)
Received: from [10.36.116.113] (ovpn-116-113.ams2.redhat.com [10.36.116.113])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 25DE15D719;
	Mon,  8 Apr 2019 18:58:31 +0000 (UTC)
Subject: Re: Thoughts on simple scanner approach for free page hinting
To: Alexander Duyck <alexander.duyck@gmail.com>,
 "Michael S. Tsirkin" <mst@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
 Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com,
 pagupta@redhat.com, wei.w.wang@intel.com,
 Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>,
 dodgen@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 dhildenb@redhat.com, Andrea Arcangeli <aarcange@redhat.com>
References: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>
 <01d5f4e8-742b-33f5-6d91-0c7c396d1cfc@redhat.com>
 <6f097f31-abc7-f56c-199c-dc167331f6b9@redhat.com>
 <20190408141145-mutt-send-email-mst@kernel.org>
 <CAKgT0UekrBHW0LAwGpvJqLFfiw51e=_52858FCr9EW6nirW-QA@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <8032d00d-60f3-6d51-7c08-9f0f4b3e9636@redhat.com>
Date: Mon, 8 Apr 2019 20:58:31 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0UekrBHW0LAwGpvJqLFfiw51e=_52858FCr9EW6nirW-QA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Mon, 08 Apr 2019 18:58:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>>> - Define and use counters corresponding to each zone to monitor the
>>> amount of memory freed.
>>> - As soon as the 64MB free memory threshold is hit wake up the kernel
>>> thread which will scan this xbitmap and try to isolate the pages and
>>> clear the corresponding bits. (We still have to acquire zone lock to
>>> protect the respective xbitmap)
>>
>> So that's 32 pages then? I'd say just keep them in an array,
>> list, tree or hash, bitmap is for when you have nots of pages.
> 
> The xbitmap I think is for the free page tracking. The problem is this
> could build up to tons of pages while we are waiting on hints to
> complete if we have a thread that is dumping a large amount of free
> pages.
> 
>>> - Report the isolated pages back to the host in a synchronous manner.
>>> I still have to work on several details of this idea including xbitmap,
>>> but first would like to hear any suggestions/thoughts.
> 
> I'm still not a fan of trying to keep track of the free page metadata
> in real-time. It is going to be far more expensive to have every free
> and alloc have to update the extra piece of data than to just come
> through after the fact and scan the new pages that have been added.

Tracking metadata separately is a very good starting point. While
integration into core mm in some form e.g. like you describe would be
desirable long term, not messing too much with core-mm is the lower
hanging fruit.

-- 

Thanks,

David / dhildenb

