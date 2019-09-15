Return-Path: <SRS0=FJsX=XK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.1 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65323C4CECD
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 21:38:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F058320692
	for <linux-mm@archiver.kernel.org>; Sun, 15 Sep 2019 21:38:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="prXjSPs1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F058320692
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B4976B0003; Sun, 15 Sep 2019 17:38:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 364086B0006; Sun, 15 Sep 2019 17:38:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 255DA6B0007; Sun, 15 Sep 2019 17:38:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0005.hostedemail.com [216.40.44.5])
	by kanga.kvack.org (Postfix) with ESMTP id 0741B6B0003
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 17:38:29 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 8A6664857
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 21:38:29 +0000 (UTC)
X-FDA: 75938469138.22.crime67_4a165330d5818
X-HE-Tag: crime67_4a165330d5818
X-Filterd-Recvd-Size: 4217
Received: from mail-pg1-f194.google.com (mail-pg1-f194.google.com [209.85.215.194])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 15 Sep 2019 21:38:28 +0000 (UTC)
Received: by mail-pg1-f194.google.com with SMTP id i18so18425243pgl.11
        for <linux-mm@kvack.org>; Sun, 15 Sep 2019 14:38:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=koJcYOUTlP8dmjZ2X7GWHStdMBs1e8qInHJs23SEU3A=;
        b=prXjSPs1he8jMpxQzp/JwdtNAB4dE1suvhQ71t179GrGEpSqVdjZALzQgMU/YoMiAY
         elr7+CrXRuhoMYPFvZGuyIDp+MeRnpqlMX5YOqGmDdImMf3aYtwEDhLY3lJldR9ueytZ
         vrXlfqj3YH7HxFXqs24ZhMca+S3jHjmswT38WSJbbFFvUKfV7/qjciF2YPK9HBfCBZ/a
         l7hWTUZ/hv1myKLJr6XvRDedsA8r13PuvVhE8vlMWBjMrccdxK/7V1I9B3rR5sn7xsJB
         HZf/ZVkuHA6VVT4Qm+PrEKJycRHgvnFit+gp6I1ufmXhz6TNnS7G2s1m0NW7CHBw21FR
         GsnA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:in-reply-to:message-id
         :references:user-agent:mime-version;
        bh=koJcYOUTlP8dmjZ2X7GWHStdMBs1e8qInHJs23SEU3A=;
        b=uTOg8hg8fG/+ePDHr63rp4Kh9ff4HZXUWAdXHNvnXZn1XR3sAizTiqQ6ptoVo28PXl
         6kfGiim1Uw/rCBpo2Trorrzcq7mtNPKH0f0AvXYJkSgBFaAt0pWwdNGeXGGPi58WFt0x
         6myFK2PeljLdrzOmgmjwVT7CPB6JNgTvXXIqFgo3StZvP1507QFR5ECUxeCwBvnA0CmM
         WHeZz7ZkaY6dnQzbHej2b3m44EI+NLyS9hprx/Hpjd/YsVmCc9CWNsQ3i/XbYFtJQ+rV
         TDjvc7Y/rokDnri7aLqaBM+QC5TsdXan1lH3pqYnEBdcAdn4DvNXC53PNfeDf6SmUV2F
         /q0w==
X-Gm-Message-State: APjAAAV6kyuXM2Odwz7Bvg8T2SPdalc93W3i+4vZrsjSiimpS0Z/WG2A
	l8SQfRrmHlM4xp7zOhiGUuPsiw==
X-Google-Smtp-Source: APXvYqzNarxIva02YWlxMrwRpeLEs7i1/GwMyAXJCKbgqHN6c1bbiwVZI2WqapUbJF3mVll7erc55A==
X-Received: by 2002:a63:550a:: with SMTP id j10mr1174836pgb.369.1568583507616;
        Sun, 15 Sep 2019 14:38:27 -0700 (PDT)
Received: from [2620:15c:17:3:3a5:23a7:5e32:4598] ([2620:15c:17:3:3a5:23a7:5e32:4598])
        by smtp.gmail.com with ESMTPSA id j9sm9816411pff.128.2019.09.15.14.38.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Sep 2019 14:38:26 -0700 (PDT)
Date: Sun, 15 Sep 2019 14:38:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
X-X-Sender: rientjes@chino.kir.corp.google.com
To: Pengfei Li <lpf.vector@gmail.com>
cc: akpm@linux-foundation.org, vbabka@suse.cz, cl@linux.com, 
    penberg@kernel.org, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, guro@fb.com
Subject: Re: [RESEND v4 1/7] mm, slab: Make kmalloc_info[] contain all types
 of names
In-Reply-To: <20190915170809.10702-2-lpf.vector@gmail.com>
Message-ID: <alpine.DEB.2.21.1909151410250.211705@chino.kir.corp.google.com>
References: <20190915170809.10702-1-lpf.vector@gmail.com> <20190915170809.10702-2-lpf.vector@gmail.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000480, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Sep 2019, Pengfei Li wrote:

> There are three types of kmalloc, KMALLOC_NORMAL, KMALLOC_RECLAIM
> and KMALLOC_DMA.
> 
> The name of KMALLOC_NORMAL is contained in kmalloc_info[].name,
> but the names of KMALLOC_RECLAIM and KMALLOC_DMA are dynamically
> generated by kmalloc_cache_name().
> 
> This patch predefines the names of all types of kmalloc to save
> the time spent dynamically generating names.
> 
> Besides, remove the kmalloc_cache_name() that is no longer used.
> 
> Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Roman Gushchin <guro@fb.com>

Acked-by: David Rientjes <rientjes@google.com>

It's unfortunate the existing names are kmalloc-, dma-kmalloc-, and 
kmalloc-rcl- since they aren't following any standard naming convention.

Also not sure I understand the SET_KMALLOC_SIZE naming since this isn't 
just setting a size.  Maybe better off as INIT_KMALLOC_INFO?

Nothing major though, so:

Acked-by: David Rientjes <rientjes@google.com>

