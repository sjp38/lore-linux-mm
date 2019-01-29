Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA413C282C7
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 03:46:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF45E2175B
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 03:46:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF45E2175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mediatek.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2358D8E0002; Mon, 28 Jan 2019 22:46:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1BD018E0001; Mon, 28 Jan 2019 22:46:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 085F88E0002; Mon, 28 Jan 2019 22:46:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B423F8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 22:46:03 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id r9so15787709pfb.13
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 19:46:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references
         :content-transfer-encoding:mime-version;
        bh=uIOdpABK+KWz0Ov8vP0byx8Zltq05uoyA1KXJEKJv/w=;
        b=KCUFDGLXJiR47sDrNM1OqP2a50l2bAP/kgI9QwyzbZ7mCYsqq/Pw9N1GpsobVNtcYz
         zCR6qb87+Gv0irebRble3z0L6lIKT1NGn/GjbaU+VPZHxhot+Yl8xJGbZVjoiotBRluP
         0O7z7IkcmhQJ7RApx+mXu79cut/OVZqvxIAQJJnNcARI+hCM9d6kZKBXbI5obEMXCtKf
         GOOm7K8RGzaqVBPWzNbsWC4XUo0E+dAFTxb/FOrNL7O7vTgPPJhlDBFsY4NzPzh7YGBI
         eR6PMuQq2TqOoy2Cq57whv8GGjdg24ye39mxsS6yyU37YaSX1N6c9WuIz3RA5rBs3BB2
         O3+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com
X-Gm-Message-State: AJcUukfJdARkj/Tm4UkVmB3DPH3t+QNIQ50CKEXyKKmSJgaebOpVxiNE
	bhANG62pyAYRY44x5rKobz/Yq82R7QEN5AvpN37y0ED+TsEV3i5MJue84QAsJZJ2jIE03b+ygi+
	VJEs5OQy9nWdbyj+WXHvv/jPv6/yzV6D9OTCDq/m6ytgkqsWTem8aj7mrVTNZyN1Kfw==
X-Received: by 2002:a62:be0c:: with SMTP id l12mr23922609pff.51.1548733563397;
        Mon, 28 Jan 2019 19:46:03 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6vCiaPg6ErTokWkrndkVBhiFOrL64hAa6Ut1NzPz/U58eWo4guH8bh0EA52kuiGmnczM+h
X-Received: by 2002:a62:be0c:: with SMTP id l12mr23922573pff.51.1548733562641;
        Mon, 28 Jan 2019 19:46:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548733562; cv=none;
        d=google.com; s=arc-20160816;
        b=pO/LBAKXLsmXuwepYtNfhXm/cPX5SGj9KmexT4/ugfXkZOS2QMTT30D2chTYOuDsHM
         lnAnPfq/SSFYBvNrHZHocjM+BjRUjYgrlhBnTROhs3fsCfaZrp/G6OBgMY6O00rIFlNX
         9dp9pPrzJGraHxhCZkZKdWVmBQXxUGztSCLlMGqktkxmJD3ZgrPywNgt3GlA9tfU6YE+
         8jei0fOAnwENXK4sQln9dAH+Gq5fSGhrGsuaoDNyTsy6juXIitzYh/wInalmSbO7ghUZ
         0HTcUD5YHzAZS0adwU0GhO3loq49DgghkXBWwZjQsQVdKJN7EWTFYnVXY/8yo6nTP0CW
         nDCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=uIOdpABK+KWz0Ov8vP0byx8Zltq05uoyA1KXJEKJv/w=;
        b=sli8kcMwbCG/eTwFsCL4fFxYldIAsyOBY7AwivbOWn7QtTkqiEWox15QVCDfE24uZE
         ekx1zxfNOg1Idmtanc4ixvOdjP0IsuMd0ku2cav+A5rsTR/DVch1BKXPcMWBSAdvjzT4
         EDJDF1+/MJdYRX4VB8sk9V7fbtgyAO1m9Fftu/YVPHihGCLEBVfyZ9RZ9QEph/eGELQn
         dtBI995+esgCutWjD7AtrSlh9S/kifm6FjH1uNs5xq7cP/+7roYFCV6CkzJD69218Fvn
         1l6yp3rMreg7X0nOCeHtY6rKfvt1XlKDluU76bHqUP7mSmAtlxTNxhWT2czcEhV0+loN
         Gzjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTPS id j24si30512015pgh.362.2019.01.28.19.46.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 19:46:02 -0800 (PST)
Received-SPF: pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.184 as permitted sender) client-ip=210.61.82.184;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of miles.chen@mediatek.com designates 210.61.82.184 as permitted sender) smtp.mailfrom=miles.chen@mediatek.com
X-UUID: a032271e0a8644039eaab1da89e4fc61-20190129
X-UUID: a032271e0a8644039eaab1da89e4fc61-20190129
Received: from mtkcas06.mediatek.inc [(172.21.101.30)] by mailgw02.mediatek.com
	(envelope-from <miles.chen@mediatek.com>)
	(mhqrelay.mediatek.com ESMTP with TLS)
	with ESMTP id 1622491935; Tue, 29 Jan 2019 11:45:58 +0800
Received: from mtkcas08.mediatek.inc (172.21.101.126) by
 mtkexhb01.mediatek.inc (172.21.101.102) with Microsoft SMTP Server (TLS) id
 15.0.1395.4; Tue, 29 Jan 2019 11:45:57 +0800
Received: from [172.21.77.33] (172.21.77.33) by mtkcas08.mediatek.inc
 (172.21.101.73) with Microsoft SMTP Server id 15.0.1395.4 via Frontend
 Transport; Tue, 29 Jan 2019 11:45:57 +0800
Message-ID: <1548733557.9796.13.camel@mtkswgap22>
Subject: Re: [PATCH v2] mm/slub: introduce SLAB_WARN_ON_ERROR
From: Miles Chen <miles.chen@mediatek.com>
To: David Rientjes <rientjes@google.com>
CC: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton
	<akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
	<linux-mediatek@lists.infradead.org>
Date: Tue, 29 Jan 2019 11:45:57 +0800
In-Reply-To: <alpine.DEB.2.21.1901281739230.216488@chino.kir.corp.google.com>
References: <1548313223-17114-1-git-send-email-miles.chen@mediatek.com>
	 <alpine.DEB.2.21.1901281739230.216488@chino.kir.corp.google.com>
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

On Mon, 2019-01-28 at 17:41 -0800, David Rientjes wrote:
> On Thu, 24 Jan 2019, miles.chen@mediatek.com wrote:
> 
> > From: Miles Chen <miles.chen@mediatek.com>
> > 
> > When debugging slab errors in slub.c, sometimes we have to trigger
> > a panic in order to get the coredump file. Add a debug option
> > SLAB_WARN_ON_ERROR to toggle WARN_ON() when the option is set.
> > 
> 
> Wouldn't it be better to enable/disable this for all slab caches instead 
> of individual caches at runtime?  I'm not sure excluding some caches 
> because you know they'll WARN and trigger panic_on_warn unnecessarily is 
> valid since it could be enabled for that cache as well through this 
> interface.

We can enable this option only for specific slab(s).
e.g., slub_debug=W,dentry
or
enable this option for all slabs
e.g., slub_debug=W

