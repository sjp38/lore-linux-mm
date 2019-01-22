Return-Path: <SRS0=7n0b=P6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5C2DC282C3
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 04:14:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7399320855
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 04:14:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7399320855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D6AD8E0003; Mon, 21 Jan 2019 23:14:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 05B038E0001; Mon, 21 Jan 2019 23:14:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E18258E0003; Mon, 21 Jan 2019 23:14:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9B4998E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 23:14:44 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id p3so14521135plk.9
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 20:14:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references
         :content-transfer-encoding:mime-version;
        bh=i0y7g3bIToGUJAD9mEZBd/6IvIkWm1w7y7JeyJE2u90=;
        b=nvW+QsBY1KlRmlNhMvM4fM4bHEgpTbzGMNOXevs/T3l/vlW2IV5oqIUpV35B1dwfTk
         kB3XXAnL6PvUhdMJW68dGeTPROkQwsmjn9ECEbo6hilmwvtF6K98ZIJKR8mrWag9hEfB
         Zwbiip9QEsV29ZdWQXTW4m9QF/FhlcpzdzYVMSJxpFQAqmMWpGwCfJPexyZu1us1C+au
         JakaiULVKsKmMGvoreeuSHQmZnctSVkz05m2rbudWQw2Lu56qCLJwkfSFC29+Hs2rMYX
         iNHCLS4UcVMPd1EGzBTjzvSknbvOnU18xE3KiTEEp1p2k5ZbK8NbNeiA7iqkd/IqfKS2
         WPnQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com
X-Gm-Message-State: AJcUukcvNZUpQ5f9/Bqd4G8mIpFLM8kqhOuswsGA36VT9tPj7TLstG/v
	XcMrJEeyVjEqIdup6ZIuY2yk+lqNPkxo0jMqq9rL/wtCSulgNldwkdawm0M2wl90tlWjL/3f+r8
	IsFXtwM1yng371HvLh6Rn4WNq1tjHIi6PugezcblXFPMvx1+VQZuPzS/eROl76B9ABA==
X-Received: by 2002:a63:6a05:: with SMTP id f5mr30029213pgc.72.1548130484255;
        Mon, 21 Jan 2019 20:14:44 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5rnfUdld6YpxTGCpy1PGE1OqW+4Sqy1ZHpPKkYfFZjX/Jil0t679dlqLIBXnOscfnL8B1G
X-Received: by 2002:a63:6a05:: with SMTP id f5mr30029185pgc.72.1548130483494;
        Mon, 21 Jan 2019 20:14:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548130483; cv=none;
        d=google.com; s=arc-20160816;
        b=ted6eRtuZhDFSqA2Hp9FYb3vElumHNm5YLvmzAOi5Gn8lp8f4wG5aZ6fkr6iFBVoQM
         mEYD1g+yKi6hSZI0uX+jXdjcAh3kFLEm23OWeVe9Y15ml1PiOEO0E5wB6YgwDjILvEEe
         13Bo3NY8lLiy8NcLORWVxB05cNTlCZRwixTApgZoJ3PLI+IMRyXyQqZfpkCHDoxg7uq5
         3JXRRzLCpaeWh9vqaKmvz3Jg2lYoLd6JtpTPup0WRFMtJHaDo3HV7hMgwtbOi0VjwIDv
         XumCM0bO2FmJRV9OmMB//S1xAqo7Sure/EjJyDc+D1VDO9KZh+fXwM2lAvtwdjCBA1Rz
         sl/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=i0y7g3bIToGUJAD9mEZBd/6IvIkWm1w7y7JeyJE2u90=;
        b=beeEYi+XR/jNA9GcHH2v3+bFrRjn22XTGLAk9AL7Xbw41sXYcBNxiPcoez9AGUUsKW
         j3XuZl+fnJB/iGuUyg6ZRxeeSSdg8Yf3o4QUObZlBjoX8zucJ2uI5yg0ZsIGRJgxfPug
         rghe4naodwDHPHXqDo0fkPXo/0GmWF/HFdFVzlBu1PBTa25RNgMf+i28VZlvGXVcJrlM
         Ggp5KmhAYM2EvN/MYQufwctVPenxSRmDNOsHYI400JakWb9RiyuQC6U4VuMHsilzD0MQ
         pKpx0bVegBxRQjZSTugwTwjXYfOEIp2fsrM0GUwRo2UsLgdiWy8YnQBUHdvG5J2hv2zT
         rCww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTPS id g12si13977781pgh.368.2019.01.21.20.14.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 20:14:43 -0800 (PST)
Received-SPF: pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) client-ip=210.61.82.183;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.183 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com
X-UUID: a458644dd1854e088f11c1ecc95e2c13-20190122
X-UUID: a458644dd1854e088f11c1ecc95e2c13-20190122
Received: from mtkcas09.mediatek.inc [(172.21.101.178)] by mailgw01.mediatek.com
	(envelope-from <miles.chen@mediatek.com>)
	(mhqrelay.mediatek.com ESMTP with TLS)
	with ESMTP id 1906042018; Tue, 22 Jan 2019 12:14:37 +0800
Received: from MTKMBS06N1.mediatek.inc (172.21.101.129) by
 mtkexhb01.mediatek.inc (172.21.101.102) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Tue, 22 Jan 2019 12:14:36 +0800
Received: from mtkcas09.mediatek.inc (172.21.101.178) by
 mtkmbs06n1.mediatek.inc (172.21.101.129) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Tue, 22 Jan 2019 12:14:35 +0800
Received: from [172.21.77.33] (172.21.77.33) by mtkcas09.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Tue, 22 Jan 2019 12:14:35 +0800
Message-ID: <1548130475.7975.74.camel@mtkswgap22>
Subject: Re: [PATCH] mm/slub: use WARN_ON() for some slab errors
From: Miles Chen <miles.chen@mediatek.com>
To: Christopher Lameter <cl@linux.com>
CC: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton
	<akpm@linux-foundation.org>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, <linux-mediatek@lists.infradead.org>
Date: Tue, 22 Jan 2019 12:14:35 +0800
In-Reply-To: <01000168726fcf15-81d8feb3-26f0-44d6-bbd8-62aa149118b5-000000@email.amazonses.com>
References: <1548063490-545-1-git-send-email-miles.chen@mediatek.com>
	 <01000168726fcf15-81d8feb3-26f0-44d6-bbd8-62aa149118b5-000000@email.amazonses.com>
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
Message-ID: <20190122041435.4bJAEl7A_sNR6KTDKQ0LKNIPn69HI4HQcBswI4W0PoY@z>

On Mon, 2019-01-21 at 22:02 +0000, Christopher Lameter wrote:
> On Mon, 21 Jan 2019, miles.chen@mediatek.com wrote:
> 
> > From: Miles Chen <miles.chen@mediatek.com>
> >
> > When debugging with slub.c, sometimes we have to trigger a panic in
> > order to get the coredump file. To do that, we have to modify slub.c and
> > rebuild kernel. To make debugging easier, use WARN_ON() for these slab
> > errors so we can dump stack trace by default or set panic_on_warn to
> > trigger a panic.
> 
> These locations really should dump stack and not terminate. There is
> subsequent processing that should be done.

Understood. We should not terminate the process for normal case. The
change only terminate the process when panic_on_warn is set.

> Slub terminates by default. The messages you are modifying are only
> enabled if the user specified that special debugging should be one
> (typically via a kernel parameter slub_debug).

I'm a little bit confused about this: Do you mean that I should use the
following approach?

1. Add a special debugging flag (say SLAB_PANIC_ON_ERROR) and call
panic() by:

if (s->flags & SLAB_PANIC_ON_ERROR)
     panic("slab error");

2. The SLAB_PANIC_ON_ERROR should be set by slub_debug param.

> It does not make sense to terminate the process here.


Thanks for you comment. Sometimes it's useful to trigger a panic and get
its coredump file before any restore/reset processing because we can
exam the unmodified data in the coredump file with this approach. 

I added BUG() for the slab errors in internal branches for a few years
and it does help for both software issues and bit flipping issues. It's
a quite useful in developing stage.

cheers,
Miles

