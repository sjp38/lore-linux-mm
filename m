Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77862C76186
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 19:57:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36DC72054F
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 19:57:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="brvTLQ3d"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36DC72054F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C405B8E0003; Mon, 29 Jul 2019 15:57:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF20C8E0002; Mon, 29 Jul 2019 15:57:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE02A8E0003; Mon, 29 Jul 2019 15:57:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 797D98E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 15:57:50 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i2so39167247pfe.1
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 12:57:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=UmO2xIAjaCwnffYwljpeo+rgK2NK3puxkBwVldnUCW4=;
        b=NbpnlSPQYy+w4pLzc6PXZh0CVRCDzS5sxKYbrsG6PsII+Ubk4YQcbQm1zdk1BRDyW7
         cjFNCP/ZaNDsKgVxAzho76ydsx2FdQ9jLWk+7jh/HfDEtKuAFlAzk3DgGVQsh4CtHQAd
         MOuCpQ2dAakFI95IGMxk3q3ynYGnoQZI9vI+G823DcIY0/IHnj4XNdXo1Y2rhuPjtrgd
         u9vf0FcXS6Z2sY/n9WdpLSDb11Vpvl99sfefDlmHb4ui+Idq95AkYqycZgQ01jNwmKji
         GhuPsAyg4ndlixrnkFCY6jX57k+mD3k1HFa9EdN94H/a498WggYDfmaad1BTZg+SlWpf
         pVSg==
X-Gm-Message-State: APjAAAU4c+rbhdMoSC41i3f7ebnmqVg8FYOuP1LuA7dvw248oQvKyFz6
	q5q1IoR5q8vYo/BKZWmzk7lwoydKrPROrjlGmWZHsNQr0oXCPfHafQMv2417+SLJCg2eQJlscZd
	Ai/By2iLo/YdNA7dhD4XaWJDjvRP9HST6jxHbv6dWJfQeP7ZhF8ARY2ZZPepHONmDWQ==
X-Received: by 2002:a63:194f:: with SMTP id 15mr71595770pgz.382.1564430269867;
        Mon, 29 Jul 2019 12:57:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5mxbyMK0p6ltrkba6D0YralHXOzCL0Mbzwmv/hh9bNxtA5abCD5tyyXvFeL86Yu40GkmS
X-Received: by 2002:a63:194f:: with SMTP id 15mr71595734pgz.382.1564430269164;
        Mon, 29 Jul 2019 12:57:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564430269; cv=none;
        d=google.com; s=arc-20160816;
        b=vBsu0QgTIIs1+cqy0rFhf7NqceBbbDBwsdcDo2CDHHoRdLYTxY1RtQnToQahm1RCBn
         UoO07ujRMSaI+X+lBiCRnyIIPjI4P5Vf4cGdPgwelKmYWKzexvsvL3xKD8Wj/UGT9j0v
         M/DRtvFs63ouQi+Ge16sSugmMgD5uKR5kOu07J060an5gTGKsB60mtsRGehRK4BjWyA3
         b6psaKynEG5ey1mGSY/fPImX/cSE1hE7dBFmxfeR1IJZcjnTX9QRWlCeKptalohco+Cr
         jqUujbx1aIY9EMAfyQ3JdeH7MShpmGYUOvPMd65yOCKtekJoTI5466OU3EyWcyKF/vfP
         JciQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=UmO2xIAjaCwnffYwljpeo+rgK2NK3puxkBwVldnUCW4=;
        b=zKoM3koLYLG9XfujVsysUPkrx4PsR5Y3vG95jPotSqmZoCzMIS8p7Crh4WKXkTHwz4
         kJAdnbKuyjkFhyPuEPU2AfPZr9rJ2ZzTwq0yfrlC0zls2+GZyWTtk4bNuUi1HbH7vW6N
         eVESQp4/i5AhnO83SSLOyGEfe8Sb7IwTWG8VOzyD+1RK8vaHk0osTvribgw9w4LhDJcu
         Pi3ctcBTS+0A/N9gbUddzCEqCKOOH4S+0Y372rvSwpATgS+lUaMRcnQ5hAyN7r4sf4E+
         yytaEdbieerjmLrC20wvHFwEnRMbl5QCmctQxKfwj/mvoBH2eVP3YathWxE7ULJoBuBI
         u2mA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=brvTLQ3d;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i36si24866016plb.365.2019.07.29.12.57.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 12:57:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=brvTLQ3d;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 392A6217D7;
	Mon, 29 Jul 2019 19:57:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564430268;
	bh=Aa2gIj8xdhHIpCrPfiCJxrfbEsiESRZUaNjO6jjdaio=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=brvTLQ3dY465JfO+z3L0iZVh2jqQkRCPWznTlE+jMyhKrcO3KaEjw561toHX4MuuS
	 vOs82SEdhwHpVHQ5ViPY4p7n8mlObyBgwqHHO8TZubFFr1iHGYQ+uU31vMm4mgvmDu
	 MS1Tqlc+RIcebF09im977FUSFOeAwGQb10JDUIaQ=
Date: Mon, 29 Jul 2019 21:56:14 +0200
From: Greg KH <gregkh@linuxfoundation.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: lizefan@huawei.com, hannes@cmpxchg.org, axboe@kernel.dk,
	dennis@kernel.org, dennisszhou@gmail.com, mingo@redhat.com,
	peterz@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@android.com, Nick Kralevich <nnk@google.com>
Subject: Re: [PATCH 1/1] psi: do not require setsched permission from the
 trigger creator
Message-ID: <20190729195614.GA31529@kroah.com>
References: <20190729194205.212846-1-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190729194205.212846-1-surenb@google.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 12:42:05PM -0700, Suren Baghdasaryan wrote:
> When a process creates a new trigger by writing into /proc/pressure/*
> files, permissions to write such a file should be used to determine whether
> the process is allowed to do so or not. Current implementation would also
> require such a process to have setsched capability. Setting of psi trigger
> thread's scheduling policy is an implementation detail and should not be
> exposed to the user level. Remove the permission check by using _nocheck
> version of the function.
> 
> Suggested-by: Nick Kralevich <nnk@google.com>
> Signed-off-by: Suren Baghdasaryan <surenb@google.com>
> ---
>  kernel/sched/psi.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

$ ./scripts/get_maintainer.pl --file kernel/sched/psi.c
Ingo Molnar <mingo@redhat.com> (maintainer:SCHEDULER)
Peter Zijlstra <peterz@infradead.org> (maintainer:SCHEDULER)
linux-kernel@vger.kernel.org (open list:SCHEDULER)


No where am I listed there, so why did you send this "To:" me?

please fix up and resend.

greg k-h

