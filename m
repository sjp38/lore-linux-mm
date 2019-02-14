Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37A94C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 16:56:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA9AC21928
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 16:56:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA9AC21928
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 999E48E0003; Thu, 14 Feb 2019 11:56:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 920A28E0001; Thu, 14 Feb 2019 11:56:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C2728E0003; Thu, 14 Feb 2019 11:56:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 34AD78E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 11:56:51 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x15so2783275edd.2
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 08:56:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pAf1mLHYfqmCYFgWuUR9tvoict8itE+mbavRajlnKjY=;
        b=P9P1c1JHNYcWyyq7S5U8mcfWttEkZ5zSVSlhclczggac6UM1ZGSkbL7XShWAhY13bz
         ZFvLiYtB4GWAyOUM98GGisL6/4yZP2FH6J6ggT9GvKkss/8eIqVkg7tFZ9Q5mmcNfOw+
         58oqYU7W//xvpQ/1dIkc62/SrqlqqE0AbPXZiTbqb+CjJecD8exCSAox7FZ123/lcNGD
         nGK+6qbah7P/OkrskUQq2A3okanR2yuBLNBiYMpe0bybhyZ4IOXSllggV3G5G601VBjl
         LdkDW+QPjHkhd8hm0dmjI9M9S3Zc5ij11Dyzy8K7puheLZizJSg6sVAkGO/Pd5SqzEeQ
         oCFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: AHQUAuagFcDiHgwVM7NQNi7cy4EtBp/FEJI1+THiMDCLETUWY4C+LnI0
	a1nSrofjoCqWUzgcTDX/Ya3eoTkw1v6MrsPZNmn0fonj9QgUhBjRKi2v/FIa5SehG1qG8MZ6OAI
	yNgoGfUk/UUNCfnLOUg0tIniM+o7MY/9FZj/ckKlJf2LSdY16pf0fwm2j6DBnRKlN6g==
X-Received: by 2002:a17:906:4551:: with SMTP id s17mr3528581ejq.69.1550163410790;
        Thu, 14 Feb 2019 08:56:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZJIdB1SVu0OYKzlhD71umP8ltBDosMCGLHwX+wAp35+8l+xlxIC3JbcQ8pRA2XkktcRBQb
X-Received: by 2002:a17:906:4551:: with SMTP id s17mr3528530ejq.69.1550163409844;
        Thu, 14 Feb 2019 08:56:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550163409; cv=none;
        d=google.com; s=arc-20160816;
        b=cxB4R2UNRlLZMEG5z3Wmo54azr0fns+Ia5PflfN3i93+gJBwdXLslDrzCECgROTZ43
         Nl9AOwn4vqC8PSFV0wXuOyyVf493qFGUNCIFrL2c2Zy11Jfpah2nJXBEv5L9HqlDZ/X3
         9wR8uMR5nkaEuhuKr0EKeyG+azhX07Y5F0IG0Dx5Gs6ZzJbcYc529KroP0rHSpJovY5Z
         mM0Byqd8g3/VOCYk+RyWb+EEEOIOS5NIelOd6mbntknPH094KmI9HBDDEJNlspcPgBmu
         mUdFOz3rFyMZkrOvTKVo3vH7kiPSNrXQU7LjalC9ZIBF8rHXwVfvasGyv7WA53qZvL3J
         F+sw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pAf1mLHYfqmCYFgWuUR9tvoict8itE+mbavRajlnKjY=;
        b=lK3Bi+hfu0oqRnFXkxap+Q8sHtvQwei3pUtuylK/lZqOcBILeOee/+4aCaYxlj3d4D
         nysmeJfTKtRubv7ZJuDh9X08CA2jya8AF/HDG9ir6tAM1yX8+3AAhneLAusomsjKULeD
         LeB9wh5Rj3qAcYeqNwoxsMJ25r0gO7537yqU0Tr96Lg4xB3idvjs/A9woPtGeoa0rxhq
         SkKj/fdI6xJRaBTLm4sAoHSFU8qo7PtmSZvGS5sUI5PX9oPIOBiD7FI4mrP5jkmPHOd2
         /5llygQtrl9EfolCSmFcGREi3gjkq6zqnlD7PVxwivVlqVEtdmNFwp/gsiy7XNxSBo8N
         ZIXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y20si1294160eds.303.2019.02.14.08.56.49
        for <linux-mm@kvack.org>;
        Thu, 14 Feb 2019 08:56:49 -0800 (PST)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C4F6415AB;
	Thu, 14 Feb 2019 08:56:48 -0800 (PST)
Received: from C02TF0J2HF1T.local (unknown [10.37.12.34])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 684BC3F575;
	Thu, 14 Feb 2019 08:56:46 -0800 (PST)
Date: Thu, 14 Feb 2019 16:56:43 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Russell King <linux@armlinux.org.uk>,
	Will Deacon <will.deacon@arm.com>, Guan Xuetao <gxt@pku.edu.cn>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 6/8] initramfs: move the legacy keepinitrd parameter to
 core code
Message-ID: <20190214165642.GB20349@C02TF0J2HF1T.local>
References: <20190213174621.29297-1-hch@lst.de>
 <20190213174621.29297-7-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213174621.29297-7-hch@lst.de>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 06:46:19PM +0100, Christoph Hellwig wrote:
> No need to handle the freeing disable in arch code when we already
> have a core hook (and a different name for the option) for it.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/Kconfig             |  7 +++++++
>  arch/arm/Kconfig         |  1 +
>  arch/arm/mm/init.c       | 25 ++++++-------------------
>  arch/arm64/Kconfig       |  1 +
>  arch/arm64/mm/init.c     | 17 ++---------------
>  arch/unicore32/Kconfig   |  1 +
>  arch/unicore32/mm/init.c | 14 +-------------
>  init/initramfs.c         |  9 +++++++++
>  8 files changed, 28 insertions(+), 47 deletions(-)

For arm64:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

