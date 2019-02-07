Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 865D4C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 21:38:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3410D2080A
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 21:38:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="GWcBqi87"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3410D2080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FEC18E006A; Thu,  7 Feb 2019 16:38:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 887FE8E0002; Thu,  7 Feb 2019 16:38:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 778A88E006A; Thu,  7 Feb 2019 16:38:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1DFB88E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 16:38:12 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id b9so480799wrs.2
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 13:38:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=WnJSVzcBaR2Ml0fQy+xhdUpmMXa3f/LpsMqUegcthm8=;
        b=UnvUj2Eb9hESV1LHIde57lvax0ow9XAqErRNlHmQlSDXYhlQYgkXrAlHJoUnVur1RM
         dwt54gThihypr8EF1cYQMAsDpUCghG1/Uj9wVQ/9g8iJ5d/Q4e7a/cjj4hPtGYgbP1Tt
         JFNzZuDlFHJ11Iqxrav9c+gSe4HPYcfybj6k1BJQxY75IEAvaWOxUuazuAiK7KIOVhLY
         TUaScwXECKEVVQAM2EqCYdLOvd3y4elBPbmHTCViYSAulqXR1vJmaWrKqmn06HjMIfjM
         /efYufsy4nMf1oCY/3ojfvJoJ1K9wXzSennahYLN8576AUzpJ5I5Q7iqhaXfxcBAEABS
         /U2A==
X-Gm-Message-State: AHQUAua9FsreoRv+1GbhR80ASnhyWue+vb7QcYfaRmSI3BGDgVPDuNal
	Krq0xEZagMpbSMGMiqBMOIoFvKOFvkF1o6mQGpHeVvqFykZocHSv978EILSl3w4+H68DJ5K/eH3
	6eeF7FGcM0c2uZGGQ3SgHxK7Andwuk+eARE42OXCXnlcHObpcjQnDFzfOKy2MLgMeng/I3dCM1M
	TvBTfJzWvKm/XEtNzEbeDZS+yDehEh+Lh1Yb5QPUGtQjpnWTj/DhrlImco4xk09/4qbGqe9/eLD
	/mDRP8F/zskdY7oGXcUztZin2hgZS73nPdEpBMGZJWq6dg4wlsyNwj0snBnS9afOKcpS9gt064K
	HTAHSJDiICcNlLX1+skm5gG73Atj0zHWkez6INAHJg5BpTf04fr5eWXSonT0MS4jfJd+Vd/W6G9
	x
X-Received: by 2002:adf:eb01:: with SMTP id s1mr5403250wrn.101.1549575491686;
        Thu, 07 Feb 2019 13:38:11 -0800 (PST)
X-Received: by 2002:adf:eb01:: with SMTP id s1mr5403224wrn.101.1549575490931;
        Thu, 07 Feb 2019 13:38:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549575490; cv=none;
        d=google.com; s=arc-20160816;
        b=kdcrHG1O18jtAezpYtqI0uI1CdwT6u9hDi8bVvdLpOOqE2be/2tNoG32jfkpTJWsmV
         70/H058axiOniwVSfNVfLeYreJtRtrDSV3oB0MqiCKtDPxpJ+TkNoc4I1JVog2jkyURg
         sJbZNN6PSy9sqcuv3hsaAyBMwtJlGpsm30/j/0Ezon87GQeP6rYMqUnG1iQlsgt/SlNa
         bH1wUQO4/E4/hUZ4D39XlUjBHd6fO8VSoONgiFj4fkU0LPS4i/LrXGWPtjdwNlyEY7j7
         otudpFj8T7NPn02kHychXsO+IT+2ICNEpsevIPh9cXSp0I7p6KDoC2h6kpuk+fnEr896
         sH6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=WnJSVzcBaR2Ml0fQy+xhdUpmMXa3f/LpsMqUegcthm8=;
        b=A5o4o1Ejx+edi4e5n9+L/+WqOaxGsqS5WKqDVjIGZLLxvfGkAqsz4FR7RMV9yCd4UY
         HTNluJcsJoflgSJX0pq70MoI+kPcA0aMvCNUWd6xPSLzdQZImVCgzP29FVVk9SLyhp8e
         ZZI8VVHkHqXjJ/yvii+cl28bNT/bcm1KXFI9wTjsZH2ibKa0BqwZ2wTkZon9goYdG7ke
         X5bxlAItRTMnXZEACsth72gf+TjEhs09u5MZBdBD6juAdhpwuGKW1cdGgBjGjhMQNv4S
         vT0qhWGWGMxUMO8xLrsRo+Zm3XhlS78ACnJ9uE+gLK4V4oeiCtdRguTvUQTG1jcVymaB
         4uxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=GWcBqi87;
       spf=pass (google.com: domain of ilias.apalodimas@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ilias.apalodimas@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r16sor70046wrl.42.2019.02.07.13.38.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 13:38:10 -0800 (PST)
Received-SPF: pass (google.com: domain of ilias.apalodimas@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=GWcBqi87;
       spf=pass (google.com: domain of ilias.apalodimas@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ilias.apalodimas@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=WnJSVzcBaR2Ml0fQy+xhdUpmMXa3f/LpsMqUegcthm8=;
        b=GWcBqi87bJaH68PfkjvucJavjiroWvmVTdTkCrdKz85n+oB4G3Mo5bLJxKTSU29bmN
         SKspvjMK5CJhzq2WQ6HA10buFgIYH1WhXTfxTVnOZOui4KrtwsdwUPzJwOySJAYUCxbm
         rS6SX1nxTcjOwqwtPrC6lvM49KI6a9qCk+z8hibhK6QGcK+A+TKk6uTh/RT6D5N0zhSL
         GNMOh9XEqbyd8OgM7iWk78ZV0T8e++LlcnTtoJlJUu1xrZqlRrP9oySJWTRN1vJS7ZOE
         slIeeK5c8c8oh5jwYUAu8H88I2PJhqaOCkwEmaIpN7E8ehyA7T6eekcs4b/1Dob/CR5/
         42UQ==
X-Google-Smtp-Source: AHgI3IYRUTO4GPpB9PhrCrsk3FAnMM/rIcMd8TfhXXXnNTziuPlfZ5c6hL9Gzdx6MBZXmV1hxmQFhg==
X-Received: by 2002:a5d:4a4b:: with SMTP id v11mr2431231wrs.186.1549575489954;
        Thu, 07 Feb 2019 13:38:09 -0800 (PST)
Received: from Iliass-MBP.lan (ppp-94-65-225-153.home.otenet.gr. [94.65.225.153])
        by smtp.gmail.com with ESMTPSA id t12sm190819wra.63.2019.02.07.13.38.04
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 13:38:09 -0800 (PST)
Date: Thu, 7 Feb 2019 23:37:58 +0200
From: Ilias Apalodimas <ilias.apalodimas@linaro.org>
To: David Miller <davem@davemloft.net>
Cc: willy@infradead.org, brouer@redhat.com, tariqt@mellanox.com,
	toke@redhat.com, netdev@vger.kernel.org,
	mgorman@techsingularity.net, linux-mm@kvack.org
Subject: Re: [RFC, PATCH] net: page_pool: Don't use page->private to store
 dma_addr_t
Message-ID: <20190207213758.GA10662@Iliass-MBP.lan>
References: <1549550196-25581-1-git-send-email-ilias.apalodimas@linaro.org>
 <20190207150745.GW21860@bombadil.infradead.org>
 <20190207152034.GA3295@apalos>
 <20190207.132519.1698007650891404763.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190207.132519.1698007650891404763.davem@davemloft.net>
User-Agent: Mutt/1.9.5 (2018-04-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi David,

On Thu, Feb 07, 2019 at 01:25I:19PM -0800, David Miller wrote:
> From: Ilias Apalodimas <ilias.apalodimas@linaro.org>
> Date: Thu, 7 Feb 2019 17:20:34 +0200
> 
> > Well updating struct page is the final goal, hence the comment. I am mostly
> > looking for opinions here since we are trying to store dma addresses which are
> > irrelevant to pages. Having dma_addr_t definitions in mm-related headers is a
> > bit controversial isn't it ? If we can add that, then yes the code would look
> > better
> 
> I fundamentally disagree.
> 
> One of the core operations performed on a page is mapping it so that a device
> and use it.
> 
> Why have ancillary data structure support for this all over the place, rather
> than in the common spot which is the page.

You are right on that. Moreover the intention of this change is to facilitate
the page recycling patches we proposed with Jesper. In that context we do need
the dma mapping information in a common spot since we'll need to access it from
drivers, networking code etc. The struct page *is* the best place for that.

> 
> A page really is not just a 'mm' structure, it is a system structure.

Well if you put it that way i completely agree (also it makes our life a *lot*
easier :))


Thanks
/Ilias

