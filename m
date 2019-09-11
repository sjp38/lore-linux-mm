Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EE6DC49ED6
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 11:20:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E01D420678
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 11:20:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="gVILecSB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E01D420678
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BD636B0005; Wed, 11 Sep 2019 07:20:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 746716B0006; Wed, 11 Sep 2019 07:20:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E6AE6B0007; Wed, 11 Sep 2019 07:20:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0055.hostedemail.com [216.40.44.55])
	by kanga.kvack.org (Postfix) with ESMTP id 360E86B0005
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 07:20:53 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id BB766BEF3
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 11:20:52 +0000 (UTC)
X-FDA: 75922397544.25.look75_7c00af145133f
X-HE-Tag: look75_7c00af145133f
X-Filterd-Recvd-Size: 3074
Received: from mail-wr1-f67.google.com (mail-wr1-f67.google.com [209.85.221.67])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 11:20:52 +0000 (UTC)
Received: by mail-wr1-f67.google.com with SMTP id l16so24000410wrv.12
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 04:20:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:in-reply-to:references:date:message-id
         :mime-version;
        bh=yEm/6Jz34sEd/TPS+tNQ49kUmKwP86ymVLNzLiSgWtk=;
        b=gVILecSBs6QnwsZ+tVcGKZJzUcdF/4UK/rFxniUgqk+meB/ggS8jm3zvQ5AJCIa1vz
         sDvsgTALWTwzFP8qBeo6KtR11dRAVTEe75Ub4+kCj+RKEGe/e5XPTjaPN/ISbMEiJAmb
         yId7phTTN7WWQGvCZrBW4kWBwVd60Bf3vZzwo=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:in-reply-to:references:date
         :message-id:mime-version;
        bh=yEm/6Jz34sEd/TPS+tNQ49kUmKwP86ymVLNzLiSgWtk=;
        b=FiHzFoMME/xptHUT7PsADGsFjP0MFLWTldwCwGkGEi3ZnCx0vrDuFIYXJ9suQb7AWc
         lavjJxTZMwozoELQnFSCUx+GT92GwjXIHc8M1/m45+ZJ/9VIF8OGNH6cLLttGrUV2R4v
         VT2kLVXitjzkQy6Mw2f33Wikrfs2xybcTbVkypEkJBnCWEU+j0XZr9iyijcYZaVR3P61
         Yeq514fa5LjEgWHm7npD+O1TMUS1HXhweRQs19c6JlEZcq8bc3yJq5dWRklwMCkpAXIH
         bir9pZIeBpU5RLcM3O53+pCeR3losV7O0gPb94jmtyvPYShZ1U30Vo7QauOjqVxs5Vnf
         8QoA==
X-Gm-Message-State: APjAAAW0vEP/+E5Ehi8VTV9aMKSj1S7545HWXbnmVOlwBmi7lH5Uk7az
	SOzY5oJ2YmOhAB4G9Q4efuPWsQ==
X-Google-Smtp-Source: APXvYqz4mviNdySjKkAku5DXmhzwzhVEEIpdN3y03EfYJn20mk48h91uhFgTy4RUInZl9y0ayE/Tmg==
X-Received: by 2002:a05:6000:1632:: with SMTP id v18mr12353420wrb.233.1568200850794;
        Wed, 11 Sep 2019 04:20:50 -0700 (PDT)
Received: from localhost ([148.69.85.38])
        by smtp.gmail.com with ESMTPSA id r9sm35678905wra.19.2019.09.11.04.20.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 11 Sep 2019 04:20:50 -0700 (PDT)
From: Daniel Axtens <dja@axtens.net>
To: Christophe Leroy <christophe.leroy@c-s.fr>, kasan-dev@googlegroups.com, linux-mm@kvack.org, x86@kernel.org, aryabinin@virtuozzo.com, glider@google.com, luto@kernel.org, linux-kernel@vger.kernel.org, mark.rutland@arm.com, dvyukov@google.com
Cc: linuxppc-dev@lists.ozlabs.org, gor@linux.ibm.com
Subject: Re: [PATCH v7 0/5] kasan: support backing vmalloc space with real shadow memory
In-Reply-To: <d43cba17-ef1f-b715-e826-5325432042dd@c-s.fr>
References: <20190903145536.3390-1-dja@axtens.net> <d43cba17-ef1f-b715-e826-5325432042dd@c-s.fr>
Date: Wed, 11 Sep 2019 21:20:49 +1000
Message-ID: <87ftl39izy.fsf@dja-thinkpad.axtens.net>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christophe,

> Are any other patches required prior to this series ? I have tried to 
> apply it on later powerpc/merge branch without success:

It applies on the latest linux-next. I didn't base it on powerpc/*
because it's generic.

Regards,
Daniel

