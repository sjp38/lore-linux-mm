Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03F2EC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 17:07:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9EF382238C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 17:07:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9EF382238C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAEF06B0006; Thu, 25 Jul 2019 13:07:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5C686B0007; Thu, 25 Jul 2019 13:07:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D273E8E0002; Thu, 25 Jul 2019 13:07:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3936B0006
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 13:07:27 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r21so32525791edc.6
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 10:07:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3L0nD4ecoq5g5sCDVJ0NUCXQMT5H1kQvqBp5vknREYI=;
        b=Jz8xJry8zOG3r5LtEh+kBJs7C7DPHhRFahN+et1Ds009zMnHgX4RRFOukVKkdNg/O5
         CjL9dIiRLcLSq5g7ykXGK3+bm0xCVITBcW5WPT2ISIpSXEenUEzpORyyYIht0RKxHj2q
         nu1SAcathtOI/eJJkSAOKIrQLl1JpU7JAgjwJZTBEEk2ySoxqhHwe47mstGY1ooi0VXx
         9byyycnp71BYOBE80gWoHHncaeDyXQ1XsthrOpsUTtLI/9mHfzs7XTr98kJ/7SPz/aEw
         fNZPe1oFDMJQq6JEPHSQO2piB6vNhkzjrQ6K21xzlhrpIY3p87ynMlwfwIWMXlgruc8F
         /Stw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAW6PLS6CN1F7eYJ0oR1afNayYZonh1E11VYk4LY4QmwDjyQAA6h
	bYnW6egK7nWrzQoMtWvAQsbGutjjtvbHyAfETHGJSyqiHeNoj7fgmgSUeuWD4EDwdlxfA7QSuJB
	EtuVNjrEVetGQRacI66+aVQTmQM66YoJ/qHmYbrFz8/Qb70pLop9viE9CPkCcZocn5Q==
X-Received: by 2002:a17:906:19cc:: with SMTP id h12mr1328843ejd.304.1564074447115;
        Thu, 25 Jul 2019 10:07:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiR2o331t3FOhAohABT3bbejcWcmn0RcS69betob/Oy/jfXUiPi3PbByBbwpuLpuQrCzje
X-Received: by 2002:a17:906:19cc:: with SMTP id h12mr1328775ejd.304.1564074446351;
        Thu, 25 Jul 2019 10:07:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564074446; cv=none;
        d=google.com; s=arc-20160816;
        b=CYFEe9eBXzmkoKF5D3F4d/bcocN21ib5J5iHsBr9Y7OTEdyNtqRey1gRPYhQtcty/Q
         XZoSF3FnTMRMQXu2O7bWpW7uqLN/bvSW8/nisXmom95e3fF3DQ6O731Pwrzt0VKN3FkE
         zC5fP4q0hqBIoOqcU1JwetnIT/MVMqpazMctNVdz4AreBJnAhE7Qvopu077YMrpEQBBo
         PyO0dGOrvJtFk3+SBMWCgkEP3mycoEnnlwLByUJAFnVkbBUTS6pOPku4gr/JcfBLG785
         yAOHtyeoV9Q5WGIM2D/6Chy897xDepXwxPbRkYYxf2Zztpf1wB6BRug0aIuSr1I13v9N
         Nzkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3L0nD4ecoq5g5sCDVJ0NUCXQMT5H1kQvqBp5vknREYI=;
        b=ea4guw/3DxEvhF1DJ3UQCv8W4Z6e9fX4dI1JeE7DsC3pnhy4UICxol0nJpEV7fpYi9
         wgb/W3kGCcibOwfnubqLeQ6sleAgaJzpJFFoG5M7Ve75vNRzzmFuCpVelQ4h0c1PuA+M
         Z+wjv3lluAxWTcmmHfeGhdCgarrIJlB7Ixdmc8Exrw8suVWgOQZ6N3shU1GGZcpy14Cy
         O8Rd5L3AfCCGqHYSCs6GutZniOqV+bGlpH9wkNHc7rUjGRhPJfux88/Lq+z4JJBc3Tqu
         vwkGnjgFDlbEEYyMbbbV2DemQ49dFq7P6ut+ddpqRZrqNyXVYxb7IlZ+d8vk5goibtxW
         Siig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id l58si11677100edc.150.2019.07.25.10.07.25
        for <linux-mm@kvack.org>;
        Thu, 25 Jul 2019 10:07:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 5C96A174E;
	Thu, 25 Jul 2019 10:07:25 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3EFD23F71A;
	Thu, 25 Jul 2019 10:07:23 -0700 (PDT)
Date: Thu, 25 Jul 2019 18:07:21 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Mark Rutland <mark.rutland@arm.com>, x86@kernel.org,
	Kees Cook <keescook@chromium.org>,
	Sri Krishna chowdary <schowdary@nvidia.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Mark Brown <Mark.Brown@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Steven Price <Steven.Price@arm.com>,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [RFC] mm/pgtable/debug: Add test validating architecture page
 table helpers
Message-ID: <20190725170720.GB11545@arrakis.emea.arm.com>
References: <1564037723-26676-1-git-send-email-anshuman.khandual@arm.com>
 <1564037723-26676-2-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1564037723-26676-2-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 12:25:23PM +0530, Anshuman Khandual wrote:
> +#if !defined(__PAGETABLE_PMD_FOLDED) && !defined(__ARCH_HAS_4LEVEL_HACK)
> +static void pud_clear_tests(void)
> +{
> +	pud_t pud;
> +
> +	pud_clear(&pud);
> +	WARN_ON(!pud_none(pud));
> +}

For the clear tests, I think you should initialise the local variable to
something non-zero rather than rely on whatever was on the stack. In
case it fails, you have a more deterministic behaviour.

-- 
Catalin

