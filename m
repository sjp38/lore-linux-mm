Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91309C04AA8
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 21:37:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CC3D20651
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 21:37:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="MIuqm2d8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CC3D20651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE6136B0005; Wed,  1 May 2019 17:37:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D96EA6B0006; Wed,  1 May 2019 17:37:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C86436B0007; Wed,  1 May 2019 17:37:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 92D406B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 17:37:17 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id b8so146292pls.22
        for <linux-mm@kvack.org>; Wed, 01 May 2019 14:37:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=mSSNwGMhoyWQ5375GOOf/uQ74wm3NC5DdejM1nUCyb8=;
        b=l+IYF51rfAxjEYerOYud8oBbKbNcyNtK0Lrr/+x1w8kq2dv0TtOj/PV8ZSqye3J6re
         3Fwu5cL8d+DaJJZcPdE+5s95PIiwRSZJlPCbgOsUDsUTJvAcVxEQon5CZVLSL86J7OBZ
         QZ/3BaZHmRoZQ4FrHWOdloqFhcMHmKx3sXhTxHaMdQhJa/fsytxchjhpMDcDqULH3d10
         gSI9wInO34qEga8y3Ll7oT7yqMFRVgjTjoT8/JDg/J5aa126XwDp+pgtwarlCBFa+KDK
         87tL6UxGq7pzdyNg0O/cTgmrMHJSjxfgRGqygPjk0PAFWfpg88kigBxayN0VViyF+0Cf
         3wYQ==
X-Gm-Message-State: APjAAAV2yS/qw7tNJM1OApkY9/5yYmewVhto2UQpNGawRg7HtLcQ1dCJ
	tdwd3ZKXq1QZ1qN6vMnnrlK+yKe+xuIXN8uypaUCkdGsHPuGaXvgdixop+tDSu71TfQnfBJ8EWc
	GErT3+7iK0128U4KiOhmN81IvvRPfAj3fxFuvDgtRpageUAkbAdPiBAsl1TQ0Gx6ukg==
X-Received: by 2002:a63:e110:: with SMTP id z16mr257905pgh.165.1556746637087;
        Wed, 01 May 2019 14:37:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwC0YXvmj2PKwTIWejlGYZ32TnF5P9BRFu0yJFjYr1OtMtUQP7gc/QkpYxQSCnNc6d/q76G
X-Received: by 2002:a63:e110:: with SMTP id z16mr257857pgh.165.1556746636354;
        Wed, 01 May 2019 14:37:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556746636; cv=none;
        d=google.com; s=arc-20160816;
        b=NSZi0yRw1IC7D+H1tcr7odn1Ob8no/nERJsTmfwa0sOqnWuI7aQ04ga42ZVp8Og8y0
         2CXFUmo2iyGwgpHDA6EZ+d37AmfFjBg2gxM3Y3w9WP8KtVzxDlgSSypD2DegqGyc3voV
         a2uphFeisIGTwJNYNHe35mlDO6zVe7IZ5JIoqvuDX3PsRYwPgCRwQFCjckpyuHSMOPb5
         px/Twb90b3s2u1+b5xntAFnyTlIhsiD23AX2n2LL+BhizaZ/M/cpuRc16/6XaioPL8n2
         o7MavwbRPPlR6Jiw7x2DFBnNL2XpBWiNS0N/SaBle5jTFQsg3j+XirOUt3JHTSBqBN+/
         hvzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=mSSNwGMhoyWQ5375GOOf/uQ74wm3NC5DdejM1nUCyb8=;
        b=Tz1vm4NVch71XzlIeLVqckpttxyNdEUFeDsDiAmmV0Ho3ANN17f4NwtX/MySffuqce
         pdniiUfXKxvFaavjj5vEqO/2/rRYT7JSQF4S7xmerjqoFvL/339AgM3TwKm76f54mk+7
         4yBRUhmuKaaiD04IzsUxqQG9iLsvpFc90rRLzrdoQX2LRHxGRi0E0OHnbinI+DvtRoAE
         JK3qdyvYM7I6ULHAn/hp1adht8isq34YU18n96x4Uzz8dvkzlEs4E/AKMdwA2LAjV8tv
         ePIA2LQEwXAFPBCnph/jp3W8C0dGq5kDYqLwXLhB3uE7cmksirhRqUu9VXThEPq/uayc
         qFkA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MIuqm2d8;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a5si41132353plm.171.2019.05.01.14.37.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 01 May 2019 14:37:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=MIuqm2d8;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=mSSNwGMhoyWQ5375GOOf/uQ74wm3NC5DdejM1nUCyb8=; b=MIuqm2d8VU91YVOYxQcFgYL/Y
	EgDLKBirDKGYVS8njJgpYjtO0nte87j6Ureh+xG2CF5T2Ak8YrJbr83WEXXC+C+tTFi8xsnB+Y9c3
	r45yrTeiKPEenIPh4ig1Xr8nS9WWtgeMINKNXgliuECdMmLwjA7kFxRGEHUcMTOLCD5nCgQmzc3o8
	jtrfYtmcawNX95xG97tIjmlWld/5sAZjcOmVNeBzBf7MMo70X6/C5dGhmpRUBL3+YN9uEjqooL0tJ
	tBgUgyclGQsdLK4AlU/9oDbbodCn/5XNg6XvTLtHj3S1ycFFHTl3jvKDc/a5JiC2ReoJZu1F+B4/k
	aQPeDuoWA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hLwub-0000lV-Nw; Wed, 01 May 2019 21:37:09 +0000
Date: Wed, 1 May 2019 14:37:09 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Subject: Re: [PATCH] binfmt_elf: Extract .note.gnu.property from an ELF file
Message-ID: <20190501213709.GD28500@bombadil.infradead.org>
References: <20190501211217.5039-1-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190501211217.5039-1-yu-cheng.yu@intel.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 01, 2019 at 02:12:17PM -0700, Yu-cheng Yu wrote:
> +++ b/fs/Kconfig.binfmt
> @@ -35,6 +35,10 @@ config COMPAT_BINFMT_ELF
>  config ARCH_BINFMT_ELF_STATE
>  	bool
>  
> +config ARCH_USE_GNU_PROPERTY
> +	bool
> +	depends on 64BIT

I don't think this is right.  I think you should get rid of the depends line
and instead select the symbol from each of argh64 and x86 Kconfig files.

