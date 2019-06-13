Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 142B7C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:39:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6E332175B
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:39:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6E332175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6BA576B0006; Thu, 13 Jun 2019 11:39:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66B516B0008; Thu, 13 Jun 2019 11:39:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 581DF6B000C; Thu, 13 Jun 2019 11:39:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0AD226B0006
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 11:39:25 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id s7so31330652edb.19
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 08:39:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/MDf/qaOz/y5EFP39x64Pwcdib6+nTdEfv0kmSKwfKM=;
        b=m8TH96XfYtajPl/Y4dTtNJ6QEDQspQcmK9MTb09mV0/xfzxaT0clw9fsjKetMSvY3K
         45CSsz5ZkgqOy/uFGSrMCs3zeScePUIpouJxoqP8C6x6bFcVm6QBhf8yyYnzLDBMgAlu
         VX9r2sWFyxvZUyL63odNGjh8maD+BJ5h4OU5J6xixLoB69uywrlGJ/tztrJ0eoxwjX7D
         p9ETUL8C5IOvHgX61rutmTO1pLx6jCcv6a0i1UkDgHOglsYnBj1jSX1kZYMuhBzNrE0I
         6/vSHz16WL7xd8hZlIS+FWyguopi6i0LqIM53oyTZz2ygxoABiKsJGdKXYtxu6AER+n7
         WYRg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUB0iwVaBghXfMM1WecK+tw2YokpbXWG1SXldU0nodlIqoU0HaN
	KsUlRT70bjvA6OlH/OhSGQYD/yT0OsUV517sppYamiQHmjhI0/JkjiGq87kspaKKSfM7mBZ2c0p
	BntNDlK6TCyEvVrualKjEbmG570azcM+yiVDWvuWFIe3ejzaJBhPj8a8O+XHvFhxVAg==
X-Received: by 2002:a50:b561:: with SMTP id z30mr40707967edd.87.1560440364596;
        Thu, 13 Jun 2019 08:39:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzn0qDXR5OOoeKOJddNQinpD9es9/sfGWeGI+fLone9BY7+S9LIXGpLO7EdWazZN/OF85M
X-Received: by 2002:a50:b561:: with SMTP id z30mr40707882edd.87.1560440363657;
        Thu, 13 Jun 2019 08:39:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560440363; cv=none;
        d=google.com; s=arc-20160816;
        b=pCO5spd22XsHuHWUgOYAOPSPyhIqc0qeZ7JtSvLPZyzZfyzYMgamUB3IIY3rPwGVtz
         y23dSv2xPK6k56A5aybuZyC8mwN2/mrxjKMpCqKPXkk8Kz4vXicw1PjB4ciI77FGSe1k
         j4zIKNLv/REHxODq8o60r8uVpv8425tgM9KQQoM45S3pNAyU8J9a+6NFTGsuvFDRh+YZ
         QR/jB23Bbdn6XG3mAo0zAgP2hS2KckZy+5t6Pz1fprTUxYaBvP6bCyGk5dJVIRxRZpa/
         DPXpC32LbYoByJqLfg2tG3KGmh2xKKYPcw3GmcPFr3z/3+iMHOmP6UHm5SUImV39qJ94
         GvHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/MDf/qaOz/y5EFP39x64Pwcdib6+nTdEfv0kmSKwfKM=;
        b=tEa8NgoCurRE/juwpTMXg0QRy5hQiUwpGw/UzjGPYAGaUzOhAzsl81PbBe87n66MQu
         0JqGbmyFMtbzi+jmI8Ht8fLnq5g19/wHImMfGX6plQTvG8NbtyvpXBj5K8FRk7x8yiVJ
         HzXi2UvGboyXW8VAKTP0t5J4xzyJijtX6tWcQ0V9G0QeXqATmtkZt5DHS4FVFlmlgFXP
         kWG+zc66mmRmvNeIO/8zaNAgwlhhEFPvxpapXxPD0pcANprB74uxuFALBPe/NlcnGrxK
         U+Yv9LhoVFsw4/C9Yn7P9s/IMjI5qtofbt/D3XaOA2HYUAYrlDtrnRp78EjLvTOPvllI
         cHug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id k6si2736240edd.325.2019.06.13.08.39.23
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 08:39:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id CBCF43EF;
	Thu, 13 Jun 2019 08:39:22 -0700 (PDT)
Received: from C02TF0J2HF1T.local (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id EDD3E3F718;
	Thu, 13 Jun 2019 08:39:16 -0700 (PDT)
Date: Thu, 13 Jun 2019 16:39:07 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Dave Martin <Dave.Martin@arm.com>
Cc: linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	Szabolcs Nagy <szabolcs.nagy@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH v4 1/2] arm64: Define
 Documentation/arm64/tagged-address-abi.txt
Message-ID: <20190613153906.GV28951@C02TF0J2HF1T.local>
References: <cover.1560339705.git.andreyknvl@google.com>
 <20190612142111.28161-1-vincenzo.frascino@arm.com>
 <20190612142111.28161-2-vincenzo.frascino@arm.com>
 <20190612153538.GL28951@C02TF0J2HF1T.local>
 <141c740a-94c2-2243-b6d1-b44ffee43791@arm.com>
 <20190613113731.GY28398@e103592.cambridge.arm.com>
 <20190613122821.GS28951@C02TF0J2HF1T.local>
 <20190613132342.GZ28398@e103592.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613132342.GZ28398@e103592.cambridge.arm.com>
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 02:23:43PM +0100, Dave P Martin wrote:
> On Thu, Jun 13, 2019 at 01:28:21PM +0100, Catalin Marinas wrote:
> > On Thu, Jun 13, 2019 at 12:37:32PM +0100, Dave P Martin wrote:
> > > On Thu, Jun 13, 2019 at 11:15:34AM +0100, Vincenzo Frascino wrote:
> > > > On 12/06/2019 16:35, Catalin Marinas wrote:
> > > > > On Wed, Jun 12, 2019 at 03:21:10PM +0100, Vincenzo Frascino wrote:
> > > > >> +  - PR_GET_TAGGED_ADDR_CTRL: can be used to check the status of the Tagged
> > > > >> +                             Address ABI.
> > [...]
> > > Is there a canonical way to detect whether this whole API/ABI is
> > > available?  (i.e., try to call this prctl / check for an HWCAP bit,
> > > etc.)
> > 
> > The canonical way is a prctl() call. HWCAP doesn't make sense since it's
> > not a hardware feature. If you really want a different way of detecting
> > this (which I don't think it's worth), we can reinstate the AT_FLAGS
> > bit.
> 
> Sure, I think this probably makes sense -- I'm still getting my around
> which parts of the design are directly related to MTE and which aren't.
> 
> I was a bit concerned about the interaction between
> PR_SET_TAGGED_ADDR_CTRL and the sysctl: the caller might conclude that
> this API is unavailable when actually tagged addresses are stuck on.
> 
> I'm not sure whether this matters, but it's a bit weird.
> 
> One option would be to change the semantics, so that the sysctl just
> forbids turning tagging from off to on.  Alternatively, we could return
> a different error code to distinguish this case.

This is the intention, just to forbid turning tagging on. We could
return -EPERM instead, though my original intent was to simply pretend
that the prctl does not exist like in an older kernel version.

-- 
Catalin

