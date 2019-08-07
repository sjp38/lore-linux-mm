Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD014C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 19:00:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0AAC21EF2
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 19:00:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="YlgkEarD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0AAC21EF2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FD526B0007; Wed,  7 Aug 2019 15:00:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 287146B0008; Wed,  7 Aug 2019 15:00:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1274A6B000A; Wed,  7 Aug 2019 15:00:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB4056B0007
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 15:00:40 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 65so53574515plf.16
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 12:00:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ffPtFma0ynnYbg79ruyQpLlhb0Qy2mS6FwTYq/42PQM=;
        b=A+sF5MU7idHIYImsrekr1frbioseAN+Cvt3jWmq7NtK2eBHLOutIbcSG3HT99Qe0sv
         MwBGwFYEP/g9LgNiqXFY3uFacWWQTOe+P1MbcJKPX7rt+XS+PejyNhTqKwMXegDtRxG5
         dsBPFoyB7vn1qJWGoik5lY+sWmC3FPGSfo1gNgNDN9ohVXEx1pJDAD4K5QL9yrkIs9Yn
         3/QdiIMXq/c4caM/hhk1Pt+jimj5M1vzccbHZIdby7goBNje8tjnRcbsXR4XFMBJKYiG
         k7ES98VTfJug3wEXjZmQlDVzOhB72vnCdEZB9OYAw2bp4+YSBgNolTHu8rOBd9moK8Xd
         Sa8g==
X-Gm-Message-State: APjAAAX35jOgAZviZTcdEP7XzjB1jeI8BCDHVYf9+7gKHl/q2WAQQNJc
	BVOsPEONYkIV3w/KvUFAxoqv+G4RwpiHJqpH8zDZ9NLJ+il4BI/ov1Eyp4BM7irroyUW3wtEsGK
	g19j1oyFn8BcVPLPLDQOOU7vHtxOf/mAxA5px6skGZlU1nSDtcWN6ZATY8LhiHT14XA==
X-Received: by 2002:a17:90a:898e:: with SMTP id v14mr1317163pjn.119.1565204440161;
        Wed, 07 Aug 2019 12:00:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgiEW3+96kJJAAd7khf4ePkSeZ/SazBr83uTCBkmBi9d6PVXFaa6QTnbPo2CadgXrexPkR
X-Received: by 2002:a17:90a:898e:: with SMTP id v14mr1317074pjn.119.1565204439312;
        Wed, 07 Aug 2019 12:00:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565204439; cv=none;
        d=google.com; s=arc-20160816;
        b=PkVOhD4Z8Doko1JKf2isnqqCBH7BjbYEUP+FOAJKVJWYsrVG9DajV8SnI41UfdcJwq
         LCARTbIbZbjA2cPqSlwNIjZ9HNrT33pLpG7VGGaty8tQ8fJ5G6lSVNobUrOapzhJAhoX
         cGeBwFMX2jJaP5CTHYLKNiI/7VcBnmnA5a4ZsTxRCnHLDhJ/PQXqIOMA0pEEoSvOoWvA
         IFIWMghENtY5hjpiaksFWqr1pRbUU2RhYAQdR2XhLiKk/WSLl6oPm9Ul3a6uWNTGF88P
         5WtrNrhQ3eggdR8TX9ykW8IDg5DKKTiLuJ4SOHjSmv0r8ItcmYbXN9NzOhLnrp30YpPu
         Hr0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ffPtFma0ynnYbg79ruyQpLlhb0Qy2mS6FwTYq/42PQM=;
        b=d9IiN3uidHMV7WS6HxpJUGQ7rZ/qvICKE1naIcjc1geh3PwIbK3NuDWbB6BQL1fXw5
         Nj+gtLPcqu0vnII1y8eghPMP133cbeFTdJFTyTYTXigpEOIM5VUiRve9XGIO+LwGa2wK
         T9FZzozXvg3efmreMeuk86YRjxmW2TuLq3kYTkztoIyZJ+kYCB3QJuS+PDOmQPzu3Jsr
         bSuaPcMi89VozMv8MA0KHjwv1LwmVQQVucBHXtzZe4Q2T55Buy9XaVxcS+lK4Kmx/G7p
         TBfloQs3PLFhlHa6IMPm1y5jtS5Blm29/3Zd0EeZ+5TdH4uW5OvGkp9NUmUdnFym+vLx
         gQtw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=YlgkEarD;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u46si50288426pgn.578.2019.08.07.12.00.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 12:00:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=YlgkEarD;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8554B21EF2;
	Wed,  7 Aug 2019 19:00:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565204438;
	bh=H8GQL47oZOjHGMHt6mc7yPh3DyXvvruf/VfI2fdq1XA=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=YlgkEarDGN0iPkWPaV/pbw5ncD7rQmx4yJoKPQ9nlm4ouA1+CTa9RxYW+98Vy24gI
	 qJ6E09hPzeZhxEQ6ywpXQDT2SLGtRgRNv3zVoSJY1Fz2VgEHGrOKuc89UnlAoTAMXS
	 uihlSf1Qg+aa309BG0I7DD0CeJ2fpdTb3Y3u8rXk=
Date: Wed, 7 Aug 2019 12:00:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Tejun Heo <tj@kernel.org>
Cc: axboe@kernel.dk, jack@suse.cz, hannes@cmpxchg.org, mhocko@kernel.org,
 vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org,
 linux-block@vger.kernel.org, linux-kernel@vger.kernel.org,
 kernel-team@fb.com, guro@fb.com
Subject: Re: [PATCH 2/4] bdi: Add bdi->id
Message-Id: <20190807120037.72018c136db40e88d89c05d1@linux-foundation.org>
In-Reply-To: <20190807183151.GM136335@devbig004.ftw2.facebook.com>
References: <20190803140155.181190-1-tj@kernel.org>
	<20190803140155.181190-3-tj@kernel.org>
	<20190806160102.11366694af6b56d9c4ca6ea3@linux-foundation.org>
	<20190807183151.GM136335@devbig004.ftw2.facebook.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 Aug 2019 11:31:51 -0700 Tejun Heo <tj@kernel.org> wrote:

> Hello,
> 
> On Tue, Aug 06, 2019 at 04:01:02PM -0700, Andrew Morton wrote:
> > On Sat,  3 Aug 2019 07:01:53 -0700 Tejun Heo <tj@kernel.org> wrote:
> > > There currently is no way to universally identify and lookup a bdi
> > > without holding a reference and pointer to it.  This patch adds an
> > > non-recycling bdi->id and implements bdi_get_by_id() which looks up
> > > bdis by their ids.  This will be used by memcg foreign inode flushing.
> > 
> > Why is the id non-recycling?  Presumably to address some
> > lifetime/lookup issues, but what are they?
> 
> The ID by itself is used to point to the bdi from cgroup and idr
> recycles really aggressively.  Combined with, for example, loop device
> based containers, stale pointing can become pretty common.  We're
> having similar issues with cgroup IDs.

OK, but why is recycling a problem?  For example, file descriptors
recycle as aggressively as is possible, and that doesn't cause any
trouble.  Presumably recycling is a problem with cgroups because of
some sort of stale reference problem?


