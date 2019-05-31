Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94939C28CC3
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 08:23:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66682265B0
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 08:23:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66682265B0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rjwysocki.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F16776B0272; Fri, 31 May 2019 04:23:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC6E16B0274; Fri, 31 May 2019 04:23:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB5556B0276; Fri, 31 May 2019 04:23:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 958706B0272
	for <linux-mm@kvack.org>; Fri, 31 May 2019 04:23:58 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id q20so1357764ljg.0
        for <linux-mm@kvack.org>; Fri, 31 May 2019 01:23:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NRq0M3jeXkWvAYi3IkGR65sn+h1ELIta8gnQMWWyE8E=;
        b=V4LlJXn8ZUshHKPctu3uTkj5/R69sJDWn4J3w/4//Z25BXaxO2S2j4Mx+EVJ9s3tYb
         dq89S7BT0sewC0EQ1h/vQpfWKdPygoTkJCjVfm0IdJIhhFTmsw22g8CK/ZEF+HhQNgOs
         ldU+8hqqkOCfo77S+tySGij/O5V1sgc8dlyHNnPYw1SY1qujNQJosimpf8Nrsf1kKUht
         7+JbGTh725p7UbKN1MlciArdYwkTjTXH3BUJzIVlJRtT+78X1JX5E5+A4nsUVvkb7SSa
         0CVAvtSMFKyUK6PGGFxi4DnzIEASE4wqcu7pNCVEVDTqYQ6Q3GeetHfJA/+3wqjVfnAF
         UQmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjw@rjwysocki.net designates 79.96.170.134 as permitted sender) smtp.mailfrom=rjw@rjwysocki.net
X-Gm-Message-State: APjAAAUeS7dDliq9W/AagY2aAPxDMP12mu0+cA9ezcNvkkkoQ2dpK1GL
	MO/TtuweaxiFRv+Rd+qecWklPRpNm1e2hA6Q+wyhLuPCf3ZP+oId+LPSUbLPuRKJ/5l2ZwvmhPD
	RayaxGh5CNHHQvKbdUb975a+EevKjs4ReFKtOWxsBCpHtWpCZGZIFnOyHFzUWezdtzw==
X-Received: by 2002:a2e:2f03:: with SMTP id v3mr5064149ljv.6.1559291037850;
        Fri, 31 May 2019 01:23:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyu2ElUDx6Ig9/5oP9CfT49dz5aTTMe6CveBB87pI5x9wWF0O7jZIAFD+UDufo+dSZ/BMGn
X-Received: by 2002:a2e:2f03:: with SMTP id v3mr5064113ljv.6.1559291037165;
        Fri, 31 May 2019 01:23:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559291037; cv=none;
        d=google.com; s=arc-20160816;
        b=mfl16xwfUVcVo/fwJRpWhV2Ld8AWxEQYl940YPEKDUtDa/qZcSiW5jvbzXQCgyG77I
         KF6mwFyQ94m6l6kVCvZlKN2mGF4BBe+McbAP1FhiPJyN2LX6j/BWu2W4zAjF8X/MpC1J
         1D0lExjSbxqanJZvSOLz5EvEBp9AIyfMHOZshiZzTSQLF/lj1HR6HLp45CSeNsW6O/oM
         EIWSjfLaZb2a6fM/3tVO3FJ7amx1JD4plOE6LMSsTGrFWuspD1qfJgB09txVllU6ROCf
         PIw/chPGK3ICkynhWnBSZBXaZOD5ZIaYoSzpDmnzVokXtW3Dc0+ZWXcBkiPr6IH85ceW
         Ls9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=NRq0M3jeXkWvAYi3IkGR65sn+h1ELIta8gnQMWWyE8E=;
        b=jAW2F4VvPkODxRv28R+fTVwYdr+BgtAgoIhHcsQX2ItmwtmFkkRFF619dki0WbmQWd
         0CMRmgfoiONRhQaQhP2JtibTz+eCzsiUK3oODiTKz77m0J6UzAEh8v2mNEBwW/vaVHdj
         Becifo47awwZJRWrEbZX+DsmXd9HjAPYq0ZpO7WjjqzLeYSpketmKaJKrno9FcqufPHo
         eJ6ZO5LfaIu3bdBRZZ+JcAwJxoQUj8jviN9EbBz8tp6hkw3+Wq9OVXyqvN86r6mGsFui
         BwHPpqy+bPDAVsklgkR2EKIJDx5oB/YxUiyye5ilVT9UeE7uMBcezpywy/itD/A8nTk4
         SZzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjw@rjwysocki.net designates 79.96.170.134 as permitted sender) smtp.mailfrom=rjw@rjwysocki.net
Received: from cloudserver094114.home.pl (cloudserver094114.home.pl. [79.96.170.134])
        by mx.google.com with ESMTPS id a17si2172241lfc.77.2019.05.31.01.23.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 31 May 2019 01:23:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of rjw@rjwysocki.net designates 79.96.170.134 as permitted sender) client-ip=79.96.170.134;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjw@rjwysocki.net designates 79.96.170.134 as permitted sender) smtp.mailfrom=rjw@rjwysocki.net
Received: from 79.184.255.225.ipv4.supernova.orange.pl (79.184.255.225) (HELO kreacher.localnet)
 by serwer1319399.home.pl (79.96.170.134) with SMTP (IdeaSmtpServer 0.83.213)
 id 59d5adea62202d2a; Fri, 31 May 2019 10:23:55 +0200
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-efi@vger.kernel.org, Len Brown <lenb@kernel.org>, Keith Busch <keith.busch@intel.com>, vishal.l.verma@intel.com, ard.biesheuvel@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org
Subject: Re: [PATCH v2 1/8] acpi: Drop drivers/acpi/hmat/ directory
Date: Fri, 31 May 2019 10:23:55 +0200
Message-ID: <4965161.Uu1Nigf0I0@kreacher>
In-Reply-To: <155925716783.3775979.13301455166290564145.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com> <155925716783.3775979.13301455166290564145.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000049, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday, May 31, 2019 12:59:27 AM CEST Dan Williams wrote:
> As a single source file object there is no need for the hmat enabling to
> have its own directory.

Well, I asked Keith to add that directory as the code in hmat.c is more related to mm than to
the rest of the ACPI subsystem.

Is there any problem with retaining it?



