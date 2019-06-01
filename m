Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 849EDC04AB6
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 01:18:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28FC226F76
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 01:18:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="hmQkX4Jg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28FC226F76
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D2E46B000E; Fri, 31 May 2019 21:18:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9833E6B0010; Fri, 31 May 2019 21:18:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 823CB6B0266; Fri, 31 May 2019 21:18:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4CB616B000E
	for <linux-mm@kvack.org>; Fri, 31 May 2019 21:18:35 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f8so5866103pgp.9
        for <linux-mm@kvack.org>; Fri, 31 May 2019 18:18:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xiwHH3GnBi+v+dMgVNfePmI+l2It1RAjECSosSRAd3A=;
        b=Gei0BAsuDktaXpmzi7Uk3iF5IEYwpWthiMuYbIh7AQcRK9zWy4fYWJsRCFIqQxmL5k
         OtPEw+NSYtA8JnGnAkAWpMfGzs/s7FfoCLu0eV8X32PJ1/vxRs/ErRUYmUCKtwQCf3LB
         Q2xb8XVkrRoZXMm4J8YrWMfuPAWkhlvSnNlwARa3VYPNgkSbv7Q5fQNT4k5pZ+DcQHuh
         2/XXXYCayGFYjbPK11Qz2m+oWAeWoiOl5y9/EjGpg46XlDXKR7R9NFi40DTRIhyS6OkT
         MwJaaYNpnbWASP0jzaDSjetmOxJEyh6pRuuZElCekZW6AaAnZtLVSAZ4oleytNNaCxW0
         fcqw==
X-Gm-Message-State: APjAAAXr6R8UkdjFArE8HZJ3NjkwqCHNH4WsS+S7BSxe44bwxD/PRUvV
	2NUv3ThO1/+eAb8yRksNbvTzcw3P9naAvYjnEFVtrlbTpxmEugBUGJuVNo8NqfOBV2GpGi2A+Sq
	fB1Q6cX7ASX5g3UJ7DRS3QwcbpgtAifun0tTp2tFR6pTUZoFRGmDNEqKdIguThcAWsw==
X-Received: by 2002:a17:902:ca:: with SMTP id a68mr13428516pla.7.1559351914870;
        Fri, 31 May 2019 18:18:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwM1AdaMdFrjYNG7le3vS7CylRApbjNim0SnNAijrHp+OeIS+k+NCmqePgcFIONfLl9x/85
X-Received: by 2002:a17:902:ca:: with SMTP id a68mr13428467pla.7.1559351913926;
        Fri, 31 May 2019 18:18:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559351913; cv=none;
        d=google.com; s=arc-20160816;
        b=SxluTPZILnj3oJZ9WbQL/Im/Mo3v5s6wND2+ajKWCspi1Zd0fPyUdC4h+QFWhJfSn3
         eUBCgRL9/Jcm8X72KA5mjn/AKsLzcg/dg2xiLCPSx1gu5rxsQIBs/cOZggMD9Seql8Q0
         91XiHoe4r/GGYQvFykn4C604vNFOfubIY6fuGEqAwMQTV87xVQeZExRnCg69ju786RlP
         186Rc9DbapfVr1aJ2eYEQryMdUUxYGgc8trMC4e2W/V/uXaozACpAORUsP+Y3PFBf5C7
         nRuHWEdI1H3iAW1G8dQWltFynUCcb4TEHu3ySyQlmtiEMGfwiNWLsOqz1xbDPl0YSsml
         /M9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=xiwHH3GnBi+v+dMgVNfePmI+l2It1RAjECSosSRAd3A=;
        b=I88YLEwyhUI5KasgNQ6X0ge0spqL7itPHKKvCQgJ5ZRbK6et2tgUepBcvKj0dovKaq
         iyKh36bX/gSUAzaLJ6JwCkX5rQEQWcf+Apo0wqAb2EjlC0nfdpsnnYhqaIqZmaf+qahb
         ZE66YoaOP43apzhQ+7Mur/mN3NwBucZyYIrWtqQu7QPCUYM8lsNLhb8HMsEmVF+A1X7U
         rPmURPrjkrXm+uDImkfMM8lj0HlCwLMApCWnftDxYcCqA9cKFen4KW790YkL59Xb9pdz
         TY7c5B7osxVf+FlUXDCqF6FFcsuvZ7U0vxEi0i8cO4B6w+jSAxY+/Mswwf1j69yctxZU
         GX8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=hmQkX4Jg;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l10si8093468pgk.276.2019.05.31.18.18.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 18:18:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=hmQkX4Jg;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id BAD5426F74;
	Sat,  1 Jun 2019 01:18:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559351913;
	bh=Mw+rwVSb5/LlCGeIAUzZqfm3N9lHZ+uRIKyeNP4lOrc=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=hmQkX4JgC4RQPwCWS/q6Lhztvd36ltD9nSqkvNqDwcDBMkal7ZMQKuGocYdzPTTi6
	 4HPz2jp+h9SSimOqoRsErp/iGmTRfQv94QDo2tDoRmL5FtqaLgcYEii7jT2kHe0iPt
	 0dVdmLkCd4cUB2fzkLts29ZCEQThZy/jQYS9KAG0=
Date: Fri, 31 May 2019 18:18:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Alexander Potapenko <glider@google.com>
Cc: Christoph Lameter <cl@linux.com>, Kees Cook <keescook@chromium.org>,
 Dmitry Vyukov <dvyukov@google.com>, James Morris <jmorris@namei.org>, Jann
 Horn <jannh@google.com>, Kostya Serebryany <kcc@google.com>, Laura Abbott
 <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Masahiro Yamada
 <yamada.masahiro@socionext.com>, Matthew Wilcox <willy@infradead.org>, Nick
 Desaulniers <ndesaulniers@google.com>, Randy Dunlap
 <rdunlap@infradead.org>, Sandeep Patil <sspatil@android.com>,
 "Serge E. Hallyn" <serge@hallyn.com>, Souptick Joarder
 <jrdr.linux@gmail.com>, Marco Elver <elver@google.com>,
 kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
 linux-security-module@vger.kernel.org
Subject: Re: [PATCH v5 2/3] mm: init: report memory auto-initialization
 features at boot time
Message-Id: <20190531181832.e7c3888870ce9e50db9f69e6@linux-foundation.org>
In-Reply-To: <20190529123812.43089-3-glider@google.com>
References: <20190529123812.43089-1-glider@google.com>
	<20190529123812.43089-3-glider@google.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 May 2019 14:38:11 +0200 Alexander Potapenko <glider@google.com> wrote:

> Print the currently enabled stack and heap initialization modes.
> 
> The possible options for stack are:
>  - "all" for CONFIG_INIT_STACK_ALL;
>  - "byref_all" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL;
>  - "byref" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF;
>  - "__user" for CONFIG_GCC_PLUGIN_STRUCTLEAK_USER;
>  - "off" otherwise.
> 
> Depending on the values of init_on_alloc and init_on_free boottime
> options we also report "heap alloc" and "heap free" as "on"/"off".

Why?

Please fully describe the benefit to users so that others can judge the
desirability of the patch.  And so they can review it effectively, etc.

Always!

> In the init_on_free mode initializing pages at boot time may take some
> time, so print a notice about that as well.

How much time?

