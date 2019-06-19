Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 298F8C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 14:14:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD478208CB
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 14:14:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD478208CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lwn.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 418846B0003; Wed, 19 Jun 2019 10:14:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A2418E0002; Wed, 19 Jun 2019 10:14:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 21AD08E0001; Wed, 19 Jun 2019 10:14:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D83736B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 10:13:59 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 21so12358954pgl.5
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 07:13:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=a46pQIiXKdBAQKcXeP0EOWzKyS9ECdFsU4T60UtYFTs=;
        b=By5tJTC/sTcuI7lSGgj7SXMb7+XGDPnw/sQNeKCtlZmUXv+dgXygEKt9uJAqlrd/JV
         uiaKJhdoNJu4MQ08/z7Bm1WBEHhyS7RUcCi19LCMQZiiffHYBkZrx8SCqcM4l/Ndyutj
         Q0/tMJi3YROv1OlgoO8xHd82HdMPfz0Rr6iivK5/3XQq9MWkHaOy2bEsVX4aZWExnvsi
         nVagJlk1dpISqWyjPqlY6bYnjgpjVNw8ldf2U59VRxGlcNa30X1w1TGXO8s0XgQKBMPa
         sSPqJ6xXG8fXWqoNrgLbSecgdRsIiyV4JYkTOajFGm4qVGpjhhcx3NMCEaNcG5WmJlhC
         Qe/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
X-Gm-Message-State: APjAAAXgWA7ooY0Xntor0HmC7ZTIeAb1chxdCBVOd+WB4yYuwyUdB7yq
	t5t4Pn+c/Ao/8jt0sDou/G9dZMOiw0FcgK/eMQypQbvnzoMevhHt2U7FZUnWAnz1cbOqbR33I0+
	/tFU+1t4/7zZYozOPAx1XSrDC1a6Qo6TdwPPp72B+vpV+dGpFD3KfFE/8wfYM3uXOwQ==
X-Received: by 2002:a17:902:e287:: with SMTP id cf7mr28884406plb.32.1560953639467;
        Wed, 19 Jun 2019 07:13:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcnJx0XbEph0UuDKpndb2pIoqtpsySg8NB7QD3ij10h0Ir8Awv/7rWsIQesmDtVl6uaGd/
X-Received: by 2002:a17:902:e287:: with SMTP id cf7mr28884353plb.32.1560953638622;
        Wed, 19 Jun 2019 07:13:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560953638; cv=none;
        d=google.com; s=arc-20160816;
        b=h4u8MiYk5LCoXfSmwJiew14Zws6An1VvbAanMvkDW6mY/Mcda6tK2vd4PzuF71Ab4m
         g0YM27TYU7cEfKS5aLxsrnwkfuxGxm05KAsvQLVfuuaSibPnutONFbnsfZIcYoaYJ13E
         Ct4umM1eQoLa6uUYTduxlBKHjQTa8njdsCEFuCHY2FhAdGTTkGQHwRn3piAactxmGCPA
         z2c+IJAERDl3LqnHGQsBtIvKX/R4MwqNB9f9x4uWh5yMYAM8zx2xZobb6MeAiG2E0Lih
         NkAg9oZA0nGYZtYxhfCycu/lMWzquHLcbPzN2KywAFnVzrDvcd8Hk2GZSyITmeF1I5l8
         Ri2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=a46pQIiXKdBAQKcXeP0EOWzKyS9ECdFsU4T60UtYFTs=;
        b=KdwH1Q9LZwAHR64ZsgNyqCsgw1K9H/q5ZUt5d59Wy5ZqGGT9Af8su+XxwICIdtDx78
         9fFnekgSeV+sY79xMiWJzXRiscw9CxqoGPEfRMyBy3aGCLT1czQUbAfA7R5ZpnANO3Jn
         BhHlCnDouypznSgVWxmcl9m4gzqgHRlva2tp+jMLfUIOkd5tQHlxOv1mzIOStwzcAsMW
         T1wdBOQMcy3tKBmF8AbdSAxigehleJBZmnHaQnpX6Z1Ls3VMSS8Rk0fI4z2yh/ingzSP
         yL5dQJ4V77hY+mY8Fp7iRAz9GKLchOgWWip3zZhKQvifFTcB/erC6FlbO3dJNT+zAdb9
         1UyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id h96si16080978plb.281.2019.06.19.07.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 07:13:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) client-ip=45.79.88.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
Received: from lwn.net (localhost [127.0.0.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by ms.lwn.net (Postfix) with ESMTPSA id 2B4E72E5;
	Wed, 19 Jun 2019 14:13:54 +0000 (UTC)
Date: Wed, 19 Jun 2019 08:13:53 -0600
From: Jonathan Corbet <corbet@lwn.net>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>, Daniel Vetter
 <daniel@ffwll.ch>, Linux Doc Mailing List <linux-doc@vger.kernel.org>,
 Mauro Carvalho Chehab <mchehab@infradead.org>, Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>, Johannes Berg <johannes@sipsolutions.net>,
 Kurt Schwemmer <kurt.schwemmer@microsemi.com>, Logan Gunthorpe
 <logang@deltatee.com>, Bjorn Helgaas <bhelgaas@google.com>, Alan Stern
 <stern@rowland.harvard.edu>, Andrea Parri
 <andrea.parri@amarulasolutions.com>, Will Deacon <will.deacon@arm.com>,
 Boqun Feng <boqun.feng@gmail.com>, Nicholas Piggin <npiggin@gmail.com>,
 David Howells <dhowells@redhat.com>, Jade Alglave <j.alglave@ucl.ac.uk>,
 Luc Maranget <luc.maranget@inria.fr>, "Paul E. McKenney"
 <paulmck@linux.ibm.com>, Akira Yokosawa <akiyks@gmail.com>, Daniel Lustig
 <dlustig@nvidia.com>, Stuart Hayes <stuart.w.hayes@gmail.com>, Thomas
 Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Darren Hart
 <dvhart@infradead.org>, Kees Cook <keescook@chromium.org>, Emese Revfy
 <re.emese@gmail.com>, Ohad Ben-Cohen <ohad@wizery.com>, Bjorn Andersson
 <bjorn.andersson@linaro.org>, Corey Minyard <minyard@acm.org>, Marc Zyngier
 <marc.zyngier@arm.com>, William Breathitt Gray <vilhelm.gray@gmail.com>,
 Jaroslav Kysela <perex@perex.cz>, Greg Kroah-Hartman
 <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>,
 "Naveen N. Rao" <naveen.n.rao@linux.ibm.com>, Anil S Keshavamurthy
 <anil.s.keshavamurthy@intel.com>, "David S. Miller" <davem@davemloft.net>,
 Masami Hiramatsu <mhiramat@kernel.org>, Johannes Thumshirn
 <morbidrsa@gmail.com>, Steffen Klassert <steffen.klassert@secunet.com>,
 Sudip Mukherjee <sudipm.mukherjee@gmail.com>, Andreas =?UTF-8?B?RsOkcmJl?=
 =?UTF-8?B?cg==?= <afaerber@suse.de>, Manivannan Sadhasivam
 <manivannan.sadhasivam@linaro.org>, Rodolfo Giometti
 <giometti@enneenne.com>, Richard Cochran <richardcochran@gmail.com>,
 Thierry Reding <thierry.reding@gmail.com>, Sumit Semwal
 <sumit.semwal@linaro.org>, Gustavo Padovan <gustavo@padovan.org>, Jens
 Wiklander <jens.wiklander@linaro.org>, Kirti Wankhede
 <kwankhede@nvidia.com>, Alex Williamson <alex.williamson@redhat.com>,
 Cornelia Huck <cohuck@redhat.com>, Bartlomiej Zolnierkiewicz
 <b.zolnierkie@samsung.com>, David Airlie <airlied@linux.ie>, Maarten
 Lankhorst <maarten.lankhorst@linux.intel.com>, Maxime Ripard
 <maxime.ripard@bootlin.com>, Sean Paul <sean@poorly.run>, Farhan Ali
 <alifm@linux.ibm.com>, Eric Farman <farman@linux.ibm.com>, Halil Pasic
 <pasic@linux.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Vasily
 Gorbik <gor@linux.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>,
 Harry Wei <harryxiyou@gmail.com>, Alex Shi <alex.shi@linux.alibaba.com>,
 Evgeniy Polyakov <zbr@ioremap.net>, Jerry Hoemann <jerry.hoemann@hpe.com>,
 Wim Van Sebroeck <wim@linux-watchdog.org>, Guenter Roeck
 <linux@roeck-us.net>, Guan Xuetao <gxt@pku.edu.cn>, Arnd Bergmann
 <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, Bartosz
 Golaszewski <bgolaszewski@baylibre.com>, Andy Shevchenko
 <andy@infradead.org>, Jiri Slaby <jslaby@suse.com>,
 linux-wireless@vger.kernel.org, Linux PCI <linux-pci@vger.kernel.org>,
 "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>,
 platform-driver-x86@vger.kernel.org, linux-remoteproc@vger.kernel.org,
 openipmi-developer@lists.sourceforge.net, linux-crypto@vger.kernel.org,
 Linux ARM <linux-arm-kernel@lists.infradead.org>, netdev
 <netdev@vger.kernel.org>, linux-pwm <linux-pwm@vger.kernel.org>, dri-devel
 <dri-devel@lists.freedesktop.org>, kvm@vger.kernel.org, Linux Fbdev
 development list <linux-fbdev@vger.kernel.org>, linux-s390@vger.kernel.org,
 linux-watchdog@vger.kernel.org, linux-gpio <linux-gpio@vger.kernel.org>,
 Linux MM <linux-mm@kvack.org>
Subject: Re: [PATCH v1 12/22] docs: driver-api: add .rst files from the main
 dir
Message-ID: <20190619081353.75762028@lwn.net>
In-Reply-To: <20190619104239.GM3419@hirez.programming.kicks-ass.net>
References: <cover.1560890771.git.mchehab+samsung@kernel.org>
	<b0d24e805d5368719cc64e8104d64ee9b5b89dd0.1560890772.git.mchehab+samsung@kernel.org>
	<CAKMK7uGM1aZz9yg1kYM8w2gw_cS6Eaynmar-uVurXjK5t6WouQ@mail.gmail.com>
	<20190619072218.4437f891@coco.lan>
	<20190619104239.GM3419@hirez.programming.kicks-ass.net>
Organization: LWN.net
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Jun 2019 12:42:39 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> No, the other way around, Sphinx can recognize local files and treat
> them special. That way we keep the text readable.
> 
> Same with that :c:func:'foo' crap, that needs to die, and Sphinx needs
> to be taught about foo().

I did a patch to make that latter part happen, but haven't been able to
find the time to address the comments and get it out there.  It definitely
cleaned up the source files a lot and is worth doing.  Will try to get
back to it soon.

The local file links should be easy to do; we shouldn't need to add any
markup for those.

jon

