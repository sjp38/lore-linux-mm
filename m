Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B6BEC282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 18:48:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 040F920645
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 18:48:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 040F920645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lwn.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A2186B0005; Fri, 19 Apr 2019 14:48:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 92AC26B0008; Fri, 19 Apr 2019 14:48:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F2316B000A; Fri, 19 Apr 2019 14:48:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5441F6B0005
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 14:48:39 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id u2so3878052pgi.10
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 11:48:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=2aQ4BdT6XhgSx6vzYFq0iRJFqpD82q1LSZyft1PbNhA=;
        b=MctKWW8d/DLjvx6QvPTQQPhoboUOGY8YqfSllwCbLRObly4HvoHG18BtRtA95jc/i0
         aYc4Nw3v1jiV1xMnlkItO630xYdaMQas7KdFM0HjzaX2BTus3pPyZJvZQCJZIWAPWIMr
         wnZxIWNpJ2OTaR2sqchTgb/5uc5dYP0V+gAkPvzWXOSfCyZmnJhT/XKm9q277/yRacKs
         a9i4oFBrFXBmF5AX9uxy/Ln4J3WMJxiabtwaaqFawCl24fFjAvfkug5RBhv9BCR3wnFg
         n2x2/gDVv+iD5QTHOE88NIIdITNMlfsadoH+nRR3bXMyjjjvwVuCX/00xkkMTyT5sQqf
         tuPA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
X-Gm-Message-State: APjAAAUdKEVnI/37WUtEHToJZ1/+rFoyL+NYdRKeiz8UVyfRmRIpmC8c
	wCHGN0go52ewgV82mL0yXui4LicWHEhyWKros/ox/Pl8kalxb+u1AWhByBVS/l3hC3n82Ra4juY
	aCaYu+rsynhFZEb9hqkz8vOXWd8JiqHK2dtOf5BhmmXWeD1WcHEBlZy8wkdyzviosAQ==
X-Received: by 2002:a62:1d94:: with SMTP id d142mr5558484pfd.83.1555699719023;
        Fri, 19 Apr 2019 11:48:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwuDEzIvdBRqwyfZWdeTr7lDIfUX3Bqxd2yPFrPxCco5FZCPAd/1T7DYkIQ4xfPGhsApr+C
X-Received: by 2002:a62:1d94:: with SMTP id d142mr5558457pfd.83.1555699718324;
        Fri, 19 Apr 2019 11:48:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555699718; cv=none;
        d=google.com; s=arc-20160816;
        b=sz/wkGUaXMmH26zCQQ9QhtLsTAgpiuz26Z2fBZ6zzrpa7WHHyFun30SFdidP2HSjzS
         AtqXeWbZYOXOIdzAtM7EfPPqnjX2XzmX/PKOudkgX+YQr8Mf9BfgSS1Q8IeV9jEhhcOQ
         nQGkEHtur26Uri2kBv0SjEkC+Dpa7D04YSb/BVoCeCe4kKsZjL4BDB36diAKmHv4uGOT
         TZLk/qOo4n/NrsQngCrAs0ximZiM45PqZc1r/NhM6AWf2Sxv2SigYQrCRG3E3oCWVOcL
         uOg2yrDvybv6KvQvxYimAiGOpsmh+k+WIt400dQTZBrBxzy9PaMrsroC8uNuMb92Z4Vd
         jVKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=2aQ4BdT6XhgSx6vzYFq0iRJFqpD82q1LSZyft1PbNhA=;
        b=bs5tVhJoF593uqA0hcGcbac1LfnuF2aZyzBUVRtPAfVG1PPcvOs0JRh9WXgYADkyr7
         yTo/XrXLT6x31LBeky59/LjBgyIQHIHESNVqajTDSwDBLK+JKgoikZsvbFDezfTgCloa
         HBofPSB945qQ8Fs9QbhqRyv/1KBi6Kwdx019fiW5l0bwpdZit6nvDICBeM0aTQz2UwkQ
         dV4rLXyEn4TdpumsHlUPP+JT4gecCkxm2GvADOLOobYIshXecnjbCmYEAV2FH4zCgSlf
         Pi6SRwD6bfZvPJjQXx/+Uu03koF+FVA/Il2t70BzhASyx/YPngDNBHlgGTnqkhhNy5oy
         w1jA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id f7si5530261pgq.522.2019.04.19.11.48.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 11:48:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) client-ip=45.79.88.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
Received: from lwn.net (localhost [127.0.0.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by ms.lwn.net (Postfix) with ESMTPSA id 53A34537;
	Fri, 19 Apr 2019 18:48:37 +0000 (UTC)
Date: Fri, 19 Apr 2019 12:48:36 -0600
From: Jonathan Corbet <corbet@lwn.net>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@suse.com, kirill.shutemov@linux.intel.com, ziy@nvidia.com,
 rppt@linux.vnet.ibm.com, akpm@linux-foundation.org,
 linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] doc: mm: migration doesn't use FOLL_SPLIT anymore
Message-ID: <20190419124836.0800991f@lwn.net>
In-Reply-To: <1555618624-23957-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1555618624-23957-1-git-send-email-yang.shi@linux.alibaba.com>
Organization: LWN.net
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 Apr 2019 04:17:04 +0800
Yang Shi <yang.shi@linux.alibaba.com> wrote:

> When demonstrating FOLL_SPLIT in transhuge document, migration is used
> as an example.  But, since commit 94723aafb9e7 ("mm: unclutter THP
> migration"), the way of THP migration is totally changed.  FOLL_SPLIT is
> not used by migration anymore due to the change.
> 
> Remove the obsolete example to avoid confusion.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Zi Yan <ziy@nvidia.com>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Applied, thanks.

jon

