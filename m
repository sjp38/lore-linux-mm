Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBE3BC282DA
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 22:25:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 904BA2064B
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 22:25:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 904BA2064B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FBB26B0005; Tue,  9 Apr 2019 18:25:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AC736B0006; Tue,  9 Apr 2019 18:25:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F05946B0008; Tue,  9 Apr 2019 18:25:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B9DDE6B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 18:25:35 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f7so99690pfd.7
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 15:25:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=HbPhvbGRIumTZA7by03NB+ymvg9sQPiEAiyPZl7uELc=;
        b=pRwwI8iqVmDWyA6JeEyq4vn98nDQA4ZjZfvK5g9tLwl2ndxJalMw7hChqRZ5C1Sc3W
         V41A5elJ1gBwJdY9WXye+J8ccFoJhG1X9YjKo4XwGvk2V8YV9JJRFN3RQq28AqVEYXlR
         Q7S92+ZYCm0hZJhIjphtuMmDK1HVdYLX2NTiVvA+hsZQ17G5BBttfpyFoTU8kMKVhbnH
         29/g7/qtAv9aA1RU/TnS4JoAM3J7s4f60tn7zP/a6NdoJIATGGB+F9+WAWgf1BnxOnad
         mDCpEqbD9W/a4pTvejEw2lf2G6q/h93pyv4m8I7lsxZDJz6k6e1A+8TruDr7myOwXA2B
         U2Sw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAVXxIBVRIjhAAe8B0TCZ0JqhI8nTtk7REAn6wOq7fCcrcw3dtaN
	EFClxb4CAX9S+/wAeBm70xqRSZhr7JzDsNKdfOYQTREGILA9GNO2exuuyFizDEMnZm8Eid11xdm
	006nQKaqoVQBjSQx/+6cnYUgB3acsoLc8BIQ6pnQO92ZWyfDFTlEK3gkvKqNBuHnvmQ==
X-Received: by 2002:a17:902:469:: with SMTP id 96mr39253372ple.46.1554848735358;
        Tue, 09 Apr 2019 15:25:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWZv06z0LFqtxn5g/ojFJvNDm4DxcQLY0ycwgyFT79FSATbNvxl0aohvHwxXdwH/SsdUdf
X-Received: by 2002:a17:902:469:: with SMTP id 96mr39253296ple.46.1554848734497;
        Tue, 09 Apr 2019 15:25:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554848734; cv=none;
        d=google.com; s=arc-20160816;
        b=V/nBhhx4kz/CgSJi3poDu5a45VE8MhKjPb2iGICxlIk+FW6Hm7YW+ZMZVcAO6CVB3D
         yAxHWnAmd9PC+rTzxbk1AxcZtfJAFYkBFiPLoKHHc978WIpp0rEVSnvxGE6iMEsrkBc1
         vtiI9bU1LEdlnFGEFnREFLbkSYRboDzE/0IXYjr7cm1SePr+OKYuwUk+03/1ipqYhV/O
         Kb5msMBm983NfkL81Vtxus6euGPR8+S8UtFKxQAM4sztA6JvEXWdHLL7JHBlO7UbAMSN
         91oQlcbjHvaHLvc6QMoVFdzJUb/q1Z68RcNiEpJ60utqxEjWFvfbMfGbwuf4huAY4wnp
         hisA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=HbPhvbGRIumTZA7by03NB+ymvg9sQPiEAiyPZl7uELc=;
        b=ZZwz87fnv2uRVPhiLqoIlf4LpHJZui0s0tfzkViwvf/i26XAwkVuSCZpIFXgoqCM3k
         nNj4881DdE6MLuLAE1aNVGQampNgLuXUE9gnaSKY297fegZcH66Al87+6Inq3ucv/jN/
         84nMxsigBSZ9Q8pmS4Wzi2dfgTmzUtUz4JLTcEApFT4Hvqtmmrq3J7PfpbQhZXtfmgQc
         VG9Dz7WJBG3aJPdtZuvshaJSstxyHov/ZyZfyptx/n7B2WeZX4Bk9Cvyyd+xAewclo/i
         Pj2+nxfDW99ZhG7xaMiNzwsurnE1FnbAei2zMDaA+Ep9hLSS8jBz2vhfl7qsvUVuZMEZ
         sCew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 91si30788893ple.299.2019.04.09.15.25.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 15:25:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id B3E3F1073;
	Tue,  9 Apr 2019 22:25:33 +0000 (UTC)
Date: Tue, 9 Apr 2019 15:25:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: "Tobin C. Harding" <me@tobin.cc>
Cc: Vlastimil Babka <vbabka@suse.cz>, Roman Gushchin <guro@fb.com>,
 "Tobin C. Harding" <tobin@kernel.org>, Christoph Lameter <cl@linux.com>,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthew Wilcox <willy@infradead.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v5 2/7] slob: Respect list_head abstraction layer
Message-Id: <20190409152532.7f3a8168de2ec49aec152bd6@linux-foundation.org>
In-Reply-To: <20190409200649.GD19840@eros.localdomain>
References: <20190402230545.2929-1-tobin@kernel.org>
	<20190402230545.2929-3-tobin@kernel.org>
	<20190403180026.GC6778@tower.DHCP.thefacebook.com>
	<20190403211354.GC23288@eros.localdomain>
	<63e395fc-41c5-00bf-0767-a313554f7b23@suse.cz>
	<20190409200649.GD19840@eros.localdomain>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 10 Apr 2019 06:06:49 +1000 "Tobin C. Harding" <me@tobin.cc> wrote:

> On Tue, Apr 09, 2019 at 02:59:52PM +0200, Vlastimil Babka wrote:
> > On 4/3/19 11:13 PM, Tobin C. Harding wrote:
> > 
> > > According to 0day test robot this is triggering an error from
> > > CHECK_DATA_CORRUPTION when the kernel is built with CONFIG_DEBUG_LIST.
> > 
> > FWIW, that report [1] was for commit 15c8410c67adef from next-20190401. I've
> > checked and it's still the v4 version, although the report came after you
> > submitted v5 (it wasn't testing the patches from mailing list, but mmotm). I
> > don't see any report for the v5 version so I'd expect it to be indeed fixed by
> > the new approach that adds boolean return parameter to slob_page_alloc().
> > 
> > Vlastimil
> 
> Oh man thanks!  That is super cool, thanks for letting me know
> Vlastimil.

Yes, thanks for the followup.

