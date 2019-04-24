Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAAFFC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 22:46:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9788F214C6
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 22:46:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9788F214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E642B6B0005; Wed, 24 Apr 2019 18:46:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E14E16B0006; Wed, 24 Apr 2019 18:46:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D2AB76B0007; Wed, 24 Apr 2019 18:46:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A79326B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 18:46:28 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id b12so12723160pfj.5
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 15:46:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=J2yLksByTGqGnfyPKOUKaClVqqEkMDyH728QW2cZHQ8=;
        b=TatQ8vo6eyg7lVgNezW1DUJhG6O28HzwwSWreR4TpA4s1LeV1zKeFg9+/Izdhee2Kl
         2ePVjtNUBprPhPIivsJ2mmnLDWUde7tl7Py0bRmPwXyU1lWgZ+u8BgsuqPPZou1yMP1w
         2RC15Z9+CAZ9qjiwSd+fORgxoFx0+p65XEnVnnWmHQzFywHJqElpKlYEOSE75Y4SPKT+
         3fzegHCUVOA+962OMSXjWU4ELl3Wn1HnK7rIcedfkh7QB2/OqqHgaHqP1I8Y+47Gx646
         JeONKQ7QfdZtzw80IphPOPIEM53KC3/xxTn9vKGvlMKD6PYDAsKT7OWd6EAWT3hhgUA5
         IKiw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAUcc/GPP8gSEVxzTrHXgx2WYbTddZT/ayHJtwnuCoSitJF/PTZk
	8SHPxSNBM8+0RAOeAPHKUk+OQoiH95FE7W4lJVbPV+QRydaXLyCXy1Q+SVJMtrfHcSI2zURUmF7
	KNZn4b7itAT9rv+tdl02Zdpbm/RM9I5TxUYmo6hQhMQqHDjHOv4lMgkJEjQ7eSOu4Yw==
X-Received: by 2002:a65:51c9:: with SMTP id i9mr33688615pgq.187.1556145988334;
        Wed, 24 Apr 2019 15:46:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3qXRj3cX57RlPLzaHU/WuN5ZudCaGFmQC7CLESAbI39IQ67QfkIiTuQXQmE3qSREL1NYR
X-Received: by 2002:a65:51c9:: with SMTP id i9mr33688574pgq.187.1556145987548;
        Wed, 24 Apr 2019 15:46:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556145987; cv=none;
        d=google.com; s=arc-20160816;
        b=l4Z/hV47+dSFE3aL4dhvZtUDJLhoDZLAKdwv4R8KSEbm2iMLArHki8I+YgshUCjJo3
         3GBs8TRpr2zf7tA3ECsfTdC3+uJQSPSotZM/cTcEKhVJvhteqm0YRSsHyvTX2Up6XNYh
         w1LdYrpUo29gIKZxHx/PfQG9dJO1QT9E8HMsugjzt24aD4xg5S1ZGcosJDK4I04sBC8Z
         LX/2DOrdQk5stRwh84juxUP3SQEQDmZ1QdSLFiA9N231bKkxKiokJNgAFZsCxeafPez3
         HTVqFxFJ7UCEwzjDvgfs+82Z9nT45p5r489neMHT8IABqaFw+DjPNTIPit/ogRBdmCxi
         bJ2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=J2yLksByTGqGnfyPKOUKaClVqqEkMDyH728QW2cZHQ8=;
        b=GkYXSHY9MyIieYNHMJHiBGs5l7DDOpEyLBwvoRt2dHOKqK3H6pRvDFqKG9L668xj73
         CMIg9lU/ufKqn6cSz62EDkhLjcHp9CoKM+dTK8ekbZKIJLvtY3bM+0PBZT8Wi5MKSZ73
         YW97MU72FvNxXadSB8325Xk751BtZ3CAymiVlrjkBZUVO62OYbOAZyuRBqYPdIOpHp+K
         zLssWDwn3j7EJvMv7GLP0NBDwYIWTcfQMAEWUqtyM7Bj2gw5072rQBVxGS6rgRd2qvxy
         yEeKrV/kT+Hhk5Cp2aEhHLB0rE7NSvs3uC2dheXQI3ttL7YxSscIKpUByjM+QeJ3Tbhv
         bHIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z11si18478060pgu.285.2019.04.24.15.46.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 15:46:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 66179B49;
	Wed, 24 Apr 2019 22:46:25 +0000 (UTC)
Date: Wed, 24 Apr 2019 15:46:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/2] mm/page_alloc: fix never set ALLOC_NOFRAGMENT flag
Message-Id: <20190424154624.f1084195c36684453a557718@linux-foundation.org>
In-Reply-To: <20190424090403.GS18914@techsingularity.net>
References: <20190423120806.3503-1-aryabinin@virtuozzo.com>
	<20190423120806.3503-2-aryabinin@virtuozzo.com>
	<20190423120143.f555f77df02a266ba2a7f1fc@linux-foundation.org>
	<20190424090403.GS18914@techsingularity.net>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Apr 2019 10:04:03 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:

> On Tue, Apr 23, 2019 at 12:01:43PM -0700, Andrew Morton wrote:
> > On Tue, 23 Apr 2019 15:08:06 +0300 Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> > 
> > > Commit 0a79cdad5eb2 ("mm: use alloc_flags to record if kswapd can wake")
> > > removed setting of the ALLOC_NOFRAGMENT flag. Bring it back.
> > 
> > What are the runtime effects of this fix?
> 
> The runtime effect is that ALLOC_NOFRAGMENT behaviour is restored so
> that allocations are spread across local zones to avoid fragmentation
> due to mixing pageblocks as long as possible.

OK, thanks.  Is this worth a -stable backport?

