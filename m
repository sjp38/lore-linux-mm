Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58D60C169C4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 01:43:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18C5C21473
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 01:43:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18C5C21473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3F798E000B; Tue, 29 Jan 2019 20:43:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C5D38E0001; Tue, 29 Jan 2019 20:43:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 866788E000B; Tue, 29 Jan 2019 20:43:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3F8898E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 20:43:38 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id e68so15684666plb.3
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 17:43:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references
         :content-transfer-encoding:mime-version;
        bh=+T2qzCutRl6cqqGqGIFFm6xWINQtkuuNOL9+buQ4RSM=;
        b=F1GsJ081Uwzru78tqHzMwA9Gj2vgXFXNBxkylfShMTQlopFaE32qSp3Ds99b9VIngc
         yeevf6bNTRcTj/fAB2jfrMqCRJLPzvORu3pcCyjaKJFBGXNcPctLqMgWk9xIqIZidwZO
         DSpVLp2I5bB65QwaGuv/pYbqmspdOBVD+Ps9q8xKCkO0weUmkqf+70TqQPgK5V8s8/VR
         r6T9mg/LKHDXoX6NvkYkFYe40nNIGNDY82pvCJJEenzKyUeIu1BM7FkE0dNnha007Wrk
         kXA9FnfS3rgmsUH75RRUIQiWJKc5rV8g2vuHiBziGapg8v6/hmp9r14Z+1IWJvfy9nWg
         PSFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com
X-Gm-Message-State: AJcUukcgcT9Y0KRR8YKBdrxy6/xPWmrtDDitlbvNXejXrjE+iHZ5lHKW
	80sFH4C8M9PVt7SQhcihQqbhxGDHqdsJjz/zVWUhKHIJH9fHo66FIRDl4gZmalodf0PWSEK+M6J
	8oUe7hDsmj/tYRlzp6IKyXJQlEyeYpyfmMdREwggMghfxIYQ3i3Wlp7gy5Kc4wH5VIA==
X-Received: by 2002:a17:902:2:: with SMTP id 2mr29146406pla.228.1548812617919;
        Tue, 29 Jan 2019 17:43:37 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6PH2s/40qmtxi+6P5ksM2r0v+5u3NT97PcDcBpiMRBLqoTopPB0/+m/vo7BZVVVsE71a3R
X-Received: by 2002:a17:902:2:: with SMTP id 2mr29146361pla.228.1548812617037;
        Tue, 29 Jan 2019 17:43:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548812617; cv=none;
        d=google.com; s=arc-20160816;
        b=FH/UcHBwudBdh5cPlAZYEfplZryDsy2ltZ64bz0sMp0GkiCu1pzZpyo/ZhOjNLxHYy
         kiu/QED3VGMQR5+w95aoKlgkGZWnxMTeItOMWLLMtosogbVREhW1cIQiXRaaZ6zAdHPc
         qStGEeK1PpmxtmCYhhXAEdVNvJ7mGnyVh8acLPbYRKHvh+5tUZbs8LKakPlorNGxM5Qi
         adQL7wd79iqybqb31h5jrprCkdRn3LWeVZeP3Y4/6MTpSINh4aLNhMVzby2GMC7cjzvW
         kxSwTTXHrYve3yJVuEZEKSUwwVmPnysskTK6q48TzpAol6jiFgArAEJPil+4SXHOv0w7
         pLGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=+T2qzCutRl6cqqGqGIFFm6xWINQtkuuNOL9+buQ4RSM=;
        b=tisQxtJViX7sSQKvUOQ0C7rjtL/YfGVsRW8u2STnGLmnwnPY2LP3EfoLOB3D1FxA0G
         UZGW3aiPMOWbrpV+41/JZcJjIDCbo9hPQXZ4oRErBV596yTRjNV8nrO9QAMZPTIZDN9u
         EVoK5O18oYu4Udfj1Wwu759YwjcpD4jRR3OiF5XB3XmC6t0vZ9Pta8HxUJtAFf/8B2HC
         vjzcooXPNlkzbtXgLspmrOsKdCGtd6AMOKfat8ViNOikBrv8xF6kLhY6n5nwAiyBrtzR
         RgG1i3tYrOip/wGe/p5/kKO5o0OeBebrQOJeubd9y6mrlkuqXtz3h4fgskNAZ5ZzcovC
         8alQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTPS id 204si82587pfu.273.2019.01.29.17.43.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 17:43:37 -0800 (PST)
Received-SPF: pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) client-ip=210.61.82.183;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com
X-UUID: e0fc40f7579a42c8a52c759f1b901ea8-20190130
X-UUID: e0fc40f7579a42c8a52c759f1b901ea8-20190130
Received: from mtkcas06.mediatek.inc [(172.21.101.30)] by mailgw01.mediatek.com
	(envelope-from <miles.chen@mediatek.com>)
	(mhqrelay.mediatek.com ESMTP with TLS)
	with ESMTP id 1568784036; Wed, 30 Jan 2019 09:43:28 +0800
Received: from mtkcas08.mediatek.inc (172.21.101.126) by
 mtkexhb02.mediatek.inc (172.21.101.103) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Wed, 30 Jan 2019 09:43:27 +0800
Received: from [172.21.77.33] (172.21.77.33) by mtkcas08.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Wed, 30 Jan 2019 09:43:27 +0800
Message-ID: <1548812607.3832.11.camel@mtkswgap22>
Subject: Re: [PATCH v2] mm/slub: introduce SLAB_WARN_ON_ERROR
From: Miles Chen <miles.chen@mediatek.com>
To: Christopher Lameter <cl@linux.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg
	<penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim
	<iamjoonsoo.kim@lge.com>, Jonathan Corbet <corbet@lwn.net>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	<linux-mediatek@lists.infradead.org>
Date: Wed, 30 Jan 2019 09:43:27 +0800
In-Reply-To: <010001689b25e696-3caebea9-56c2-46eb-bb49-34e504a123ee-000000@email.amazonses.com>
References: <1548313223-17114-1-git-send-email-miles.chen@mediatek.com>
	 <20190128122954.949c2e6699d6e5ef060a325c@linux-foundation.org>
	 <0100016898251824-359bbfae-e32b-43a6-8c58-8811a7b24520-000000@email.amazonses.com>
	 <1548748424.18511.34.camel@mtkswgap22>
	 <010001689b25e696-3caebea9-56c2-46eb-bb49-34e504a123ee-000000@email.amazonses.com>
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

On Tue, 2019-01-29 at 19:46 +0000, Christopher Lameter wrote:
> On Tue, 29 Jan 2019, Miles Chen wrote:
> 
> > a) classic slub issue. e.g., use-after-free, redzone overwritten. It's
> > more efficient to report a issue as soon as slub detects it. (comparing
> > to monitor the log, set a breakpoint, and re-produce the issue). With
> > the coredump file, we can analyze the issue.
> 
> What usually happens is that the systems fails with a strange error
> message. Then the system is rebooted using slub_debug options and the
> issue is reproduced yielding more information about the problem.
> 
> Then you run the scenario again with additional debugging in the subsystem
> that caused the problem.

Thanks your comments and patient.

I now understand the difference between us.
I usually enable CONFIG_SLUB_DEBUG=y, CONFIG_SLUB_DEBUG_ON=y and setup
slub_debug by default and do all tests. (eng mode).
Not hit an issue first, then setup slub_debug and reproduce the issue
again.

CONFIG_SLUB_DEBUG is disabled for products.

> 
> So you are already reproducing the issue because you need to activate
> debugging to get more information. Doing it for the 3rd time is not that
> much more difficult.
> 
> None of your modifications will be active in a production kernel.
> slub_debug must be activated to use it and thus you are already
> reproducing the issue.
> 
> > b) memory corruption issues caused by h/w write. e.g., memory
> > overwritten by a DMA engine. Memory corruptions may or may not related
> > to the slab cache that reports any error. For example: kmalloc-256 or
> > dentry may report the same errors. If we can preserve the the coredump
> > file without any restore/reset processing in slub, we could have more
> > information of this memory corruption.
> 
> If debugging is active then reporting will include the accurate slab cache
> affected. The memory layout is already changing when you enable the
> existing debugging code. None of your code runs without that and thus is
> cannot add a coredump for the prod case without debugging.

I usually set slub_debug by default and get the coredump file.

> > c) memory corruption issues caused by unstable h/w. e.g., bit flipping
> > because of xxxx DRAM die or applying new power settings. It's hard to
> > re-produce this kind of issue and it much easier to tell this kind of
> > issue in the coredump file without any restore/reset processing.
> 
> But then you patch does not help in this situation because the code has to
> be enabled by special  slub debug options.
> 
> 
> > Users can set the option by slub_debug. We can still have the original
> > behavior(keep the system alive) if the option is not set. We can turn on
> > the option when we need the coredump file. (with panic_on_warn is set,
> > of course).
> 
> I think we would need to turn on debugging by default and have your patch
> for this to make sense. We already reproducing the issue multiple times
> for debugging. This patch does not change that.
> 
yes. I turn on the debugging by default. Does that make sense now?

Thanks again for your comments.

