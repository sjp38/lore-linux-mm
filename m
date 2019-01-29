Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 850FCC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 07:53:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B4DC2177E
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 07:53:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B4DC2177E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8A528E0002; Tue, 29 Jan 2019 02:53:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D39968E0001; Tue, 29 Jan 2019 02:53:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4EE38E0002; Tue, 29 Jan 2019 02:53:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8423C8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 02:53:53 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id l76so16272700pfg.1
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 23:53:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references
         :content-transfer-encoding:mime-version;
        bh=qj1WTzUupQDTUvo33lKDCW8heb3e9/5rpSCHgbR9lf8=;
        b=eI/4sQCA2SegUcRH/1F2K3UPFeeR01s8DdUzGrIVWvzf8s8Y4mLMw2ClITp4+eHecJ
         cF731zdQ7QIiZfsfG9tV+B3v0EwlNzPPKouVT56F8GSrBy+FZVCRJ1RM2EZe/OdYI6vt
         sgmUJTorX7tg9s+7Xwty36JMDzn3jrkOWVQp5o0jglCmQGPkVX8q5589JEkENH+6ereH
         9zD3F35FAOJBljCrG6eFbe0ThF85U8OfTvTz7g76eTtETKJeQIxWy6raSL74wq2w6drh
         b3I7S8ySDxL16esHdGYRuMiDLdhuEGVH7hTOjEg2NU2Qld/xYFg7zp/pA8TBvaHcdjya
         Mvig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com
X-Gm-Message-State: AJcUukdqhboQMciGKxNC6MNGoW1OHkXyNu5BX4OAchf8CtxnUTvbMiqC
	LmWpKglGYccTYYnxevSZmSFadPYOtW6z58R0CYqFBD7rLSlUJT09pPv/1EjBvdMMzRGbNiG5IOA
	D1M+WH4UDZ6woQZ7iF/iFOcv7wqh1CgdO33MxQRR/OAW4tcyUTAs/5ZS6Nnt+Qoa1Mw==
X-Received: by 2002:a65:41c2:: with SMTP id b2mr22507132pgq.67.1548748433174;
        Mon, 28 Jan 2019 23:53:53 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4vdbw9OLgGbngNOjXLfRNnrwhmDj6PLERWqpva1ZjVgCkJE3M8TTJ4Hb3pBaap7saidLAZ
X-Received: by 2002:a65:41c2:: with SMTP id b2mr22507107pgq.67.1548748432373;
        Mon, 28 Jan 2019 23:53:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548748432; cv=none;
        d=google.com; s=arc-20160816;
        b=ABt9/6Hxwq2G1gquMM/a397FEle1ESN3nxDlQTgE34IcknhhXMonfxSAwzy7KErKQw
         xzJPeMEXmlc5tlrKSYpZRm2FexmQdQWx0kHQuHfzkXTU53YMNmBy2b2ycH8bnSG2P7HI
         AjQgRpzJf+8AvflJgBnwncwCFGehKK3DL5MLcfJqLWPc8tI/YAcDwuGcSso3nPiZXD5b
         25xiQjX4gQ5KQSXMzzcI9SovXGT8vaH0dhmy3iFdXVPPd4WtGZ12zq8mzktREiBw6fQo
         wjabQb2MejbfUTgmw3pX3Lz35IlVTV6/nA1QRkUqj4oe+eagi6LDt7Xia7w1lsdGOH9l
         ieEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=qj1WTzUupQDTUvo33lKDCW8heb3e9/5rpSCHgbR9lf8=;
        b=YS/glSiDl1r18wbOHmZBdanFGMF0IFVT+rRzlbqOQ3GN8IqVeRsv7btUeaaPJvZdUo
         9O1yMxBKHHCtVvlTe4ZAu0TRH/E/CyZbemOEfmAbOZ9JtfPjCbfBkpaFkor6I/WmB07O
         KJ4Uyz/k4sZbr+LpOFE89qyu4YbjnllIuLDkBXYYLJEXLQQO9KcqIbJj3DpHEfBIavSr
         dAkgrSxXdxtmgLHnLB0H0JaYHgcMk0Sz3ZCu/dJ17TXQMXHRsJPQmBSc0X7BuKydwA1t
         mYicnrOcHfpCm9S62r9oqM+7/mLb/nMROGp5i3+IYiDvOhVc6nZXgNKyW6WFHV9D1BTQ
         fSnw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTPS id p4si30316376pgm.342.2019.01.28.23.53.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 23:53:52 -0800 (PST)
Received-SPF: pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) client-ip=210.61.82.183;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com
X-UUID: e8a2e2ae80eb48a2b6588bf2cc31fd75-20190129
X-UUID: e8a2e2ae80eb48a2b6588bf2cc31fd75-20190129
Received: from mtkcas09.mediatek.inc [(172.21.101.178)] by mailgw01.mediatek.com
	(envelope-from <miles.chen@mediatek.com>)
	(mhqrelay.mediatek.com ESMTP with TLS)
	with ESMTP id 1798808927; Tue, 29 Jan 2019 15:53:46 +0800
Received: from MTKCAS06.mediatek.inc (172.21.101.30) by mtkexhb01.mediatek.inc
 (172.21.101.102) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Tue, 29 Jan
 2019 15:53:44 +0800
Received: from [172.21.77.33] (172.21.77.33) by MTKCAS06.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Tue, 29 Jan 2019 15:53:44 +0800
Message-ID: <1548748424.18511.34.camel@mtkswgap22>
Subject: Re: [PATCH v2] mm/slub: introduce SLAB_WARN_ON_ERROR
From: Miles Chen <miles.chen@mediatek.com>
To: Christopher Lameter <cl@linux.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg
	<penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim
	<iamjoonsoo.kim@lge.com>, Jonathan Corbet <corbet@lwn.net>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	<linux-mediatek@lists.infradead.org>
Date: Tue, 29 Jan 2019 15:53:44 +0800
In-Reply-To: <0100016898251824-359bbfae-e32b-43a6-8c58-8811a7b24520-000000@email.amazonses.com>
References: <1548313223-17114-1-git-send-email-miles.chen@mediatek.com>
	 <20190128122954.949c2e6699d6e5ef060a325c@linux-foundation.org>
	 <0100016898251824-359bbfae-e32b-43a6-8c58-8811a7b24520-000000@email.amazonses.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.2.3-0ubuntu6 
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
X-MTK: N
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-01-29 at 05:46 +0000, Christopher Lameter wrote:
> On Mon, 28 Jan 2019, Andrew Morton wrote:
> 
> > > When debugging slab errors in slub.c, sometimes we have to trigger
> > > a panic in order to get the coredump file. Add a debug option
> > > SLAB_WARN_ON_ERROR to toggle WARN_ON() when the option is set.
> > >
> > > Change since v1:
> > > 1. Add a special debug option SLAB_WARN_ON_ERROR and toggle WARN_ON()
> > > if it is set.
> > > 2. SLAB_WARN_ON_ERROR can be set by kernel parameter slub_debug.
> > >
> >
> > Hopefully the slab developers will have an opinion on this.
> 
> Debugging slab itself is usually done in kvm or some other virtualized
> environment. Then gdb can be used to set breakpoints. Otherwise one may
> add printks and stuff to the allocators to figure out more or use perf.
> 
> 
> What you are changing here is the debugging for data corruption within
> objects managed by slub or the metadata. Slub currently outputs extensive
> data about the metadata corruption (typically caused by a user of
> slab allocation) which should allow you to set a proper
> breakpoint not in the allocator but in the subsystem where the corruption
> occurs.
> 
Thanks for your comments. The real problems the change can help are:

a) classic slub issue. e.g., use-after-free, redzone overwritten. It's
more efficient to report a issue as soon as slub detects it. (comparing
to monitor the log, set a breakpoint, and re-produce the issue). With
the coredump file, we can analyze the issue.

b) memory corruption issues caused by h/w write. e.g., memory
overwritten by a DMA engine. Memory corruptions may or may not related
to the slab cache that reports any error. For example: kmalloc-256 or
dentry may report the same errors. If we can preserve the the coredump
file without any restore/reset processing in slub, we could have more
information of this memory corruption.

c) memory corruption issues caused by unstable h/w. e.g., bit flipping
because of xxxx DRAM die or applying new power settings. It's hard to
re-produce this kind of issue and it much easier to tell this kind of
issue in the coredump file without any restore/reset processing.

Users can set the option by slub_debug. We can still have the original
behavior(keep the system alive) if the option is not set. We can turn on
the option when we need the coredump file. (with panic_on_warn is set,
of course).

