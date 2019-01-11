Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64767C43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 13:55:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2027420870
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 13:55:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2027420870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=collabora.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2F788E0005; Fri, 11 Jan 2019 08:55:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B06068E0001; Fri, 11 Jan 2019 08:55:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F4DD8E0005; Fri, 11 Jan 2019 08:55:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4561D8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 08:55:40 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id d6so4601338wrm.19
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 05:55:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=fUNKPyT/0KmlvckTjo8vIOM7Owd2YAVExcf53xKwmDo=;
        b=OOyUjOUwr7m7Ub1Kp59aiCB4t46HQWwSTiNToDm+X6m/DfUG0JHaPJclzurnHmBKoq
         TuwqusilmO7t0o6i1YlNXc+ZvKeubUKC4ljp+hfY424ySv7lfX/o+juVXIhE0Loh8pRz
         3QdJQs+9Dkh89UfOeViF2Xl6/Jd4luESgpXjkyObrBeC3YAjhS/b2qFJiecv8W2A9IE9
         gqHooslOKzvgnhFxcJ0qeoH07hfY1SIAjWxVO/1nKfM8xGqtYaxQiyw8l+9+8gE8j6h8
         mPj+A2ti3FehZ3Nrzlcm2Ui91ko9NjGDIbTbDB3qqWkQ+3cIm06N+P20lFCSxDES8gMV
         yH4A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of gael.portay@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=gael.portay@collabora.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
X-Gm-Message-State: AJcUukdrioLU/iALaVp/8pI7PebZfZq3xZfJxcvQfeR3PxuZvf/uMvtP
	6Uj16mVpIu50p4NQ0m2aLt8uW7nHvEgzHCgmDWtwRT85uaa7WepgMzvAHmJespSjkCxfu96wwDY
	ycjrGv8uRcmLqPlXLR0fsCSksvbl7VGxbTXjrmWcjS1/8FGHRISWxiT8q5CBh9mJBgg==
X-Received: by 2002:a1c:3282:: with SMTP id y124mr2517890wmy.134.1547214939773;
        Fri, 11 Jan 2019 05:55:39 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6sLBbs0NI+EkglrDTMha+v3tc/VJGBELWZe+utVLpyadcjqidYakwl2nBUngqbPIPtZGhW
X-Received: by 2002:a1c:3282:: with SMTP id y124mr2517855wmy.134.1547214938935;
        Fri, 11 Jan 2019 05:55:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547214938; cv=none;
        d=google.com; s=arc-20160816;
        b=0f1/JSmDnufBFrpCi4WKVBg/OU3oWQkS8EmmfAmf9dKl9UP4s9/PzjVsjutGwGLo1Y
         4lti7qpPGOgDBX6fccvcyOk1sMq/QjdU9ykx/q7/Q03KFzPjoiIz4McuJWA7NNWpm3e8
         WoS0ooVlGTIiMJgcWvzB3TQj/PHd9HYmdnM1SCGMj7g95wdiecdvoQggeVkxoE2tPIHi
         34MnG56cNAigEDFxG+cVx/CyLTaloOtPWxp/zbrlDH2wsK6Jp7AF+o8aKD233/bwImHd
         u7S2rEq4nmRCs6IqzN5WANTN9iBSUepz1ZtvMPV73r8CIL1qw4spepGjHdSc6W6Du8ML
         E9Nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=fUNKPyT/0KmlvckTjo8vIOM7Owd2YAVExcf53xKwmDo=;
        b=AHTtxSskQunC14d6EY+6LtLhTlmRyPB/sz9v5OPr2xFrxjUYkbTS8orReKrKrHBsgn
         MvKxzPF25Fbsx0b5RE45V58XrLwXBxFVxZ7ZVtHl4Bds7Si6VY2N7u9HblxRRTBCTPEo
         OwEC+yMG8i07U96u7EFjETYak87f3asVfc6IbgAeuze0p/fpz3R2As6XTda0a411pLZi
         pLPDxQ9AQ6wZieY2VmapHYp+V3f77xOxrTdVvPTdzfsxzcgqmxu5hMS6HIqouiNFJuiT
         BAxJ1CH+tlTdtBtIXvahT3KcYiUd3gBsSGV34iR+RJwXvwwLFDibY7qKFwJ1yxlkJ8m2
         Sa0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of gael.portay@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=gael.portay@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [46.235.227.227])
        by mx.google.com with ESMTPS id b84si13275605wme.1.2019.01.11.05.55.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 11 Jan 2019 05:55:38 -0800 (PST)
Received-SPF: pass (google.com: domain of gael.portay@collabora.com designates 46.235.227.227 as permitted sender) client-ip=46.235.227.227;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of gael.portay@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=gael.portay@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from [127.0.0.1] (localhost [127.0.0.1])
	(Authenticated sender: gportay)
	with ESMTPSA id DDD5A27ED74
Date: Fri, 11 Jan 2019 08:55:39 -0500
From: =?utf-8?B?R2HDq2w=?= PORTAY <gael.portay@collabora.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Laura Abbott <labbott@redhat.com>,
	Alan Stern <stern@rowland.harvard.edu>, linux-mm@kvack.org,
	usb-storage@lists.one-eyed-alien.net
Subject: Re: [usb-storage] Re: cma: deadlock using usb-storage and fs
Message-ID: <20190111135538.iv3vvashdnis5b2s@archlinux.localdomain>
References: <20181216222117.v5bzdfdvtulv2t54@archlinux.localdomain>
 <Pine.LNX.4.44L0.1812171038300.1630-100000@iolanthe.rowland.org>
 <20181217182922.bogbrhjm6ubnswqw@archlinux.localdomain>
 <c3ab7935-8d8d-27a0-99a7-0dab51244a42@redhat.com>
 <593e3757-6f50-22bc-d5a9-ea5819b9a63d@oracle.com>
 <da35de2c-b8ad-9b01-b582-8f1f8061e8e1@redhat.com>
 <20190107181355.qqbdc6pguq4w3z6u@archlinux.localdomain>
 <302af0f5-bc42-dcb2-01e3-86865e5581e2@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <302af0f5-bc42-dcb2-01e3-86865e5581e2@oracle.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.001690, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111135539.8gSMcJsYjzc5hryWJAUmeVMo7FJ2gQJZD-bsjz0G-uA@z>

Mike,

On Mon, Jan 07, 2019 at 06:06:21PM -0800, Mike Kravetz wrote:
> On 1/7/19 10:13 AM, Gaël PORTAY wrote:
> > (...)
> > 
> > I have also removed the mutex (start_isolate_page_range retunrs -EBUSY),
> > and it worked (in my case).
> > 
> > But I did not do the proper magic because I am not sure of what should
> > be done and how: -EBUSY is not handled and __GFP_NOIO is not honored. 
> 
> If we remove the mutex, I am pretty sure we would want to distinguish
> between the (at least) two types of _EBUSY that can be returned by
> alloc_contig_range().  Seems that the retry logic should be different if
> a page block is busy as opposed to pages within the range.
> 
> I'm busy with other things, but could get to this later this week or early
> next week unless someone else has the time.

Thank you.

To not hesitate to ping me if you need to test things.

Regards,
Gael

