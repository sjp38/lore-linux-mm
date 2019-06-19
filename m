Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67D78C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 12:50:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC25B215EA
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 12:50:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amarulasolutions.com header.i=@amarulasolutions.com header.b="dW6rwWu/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC25B215EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amarulasolutions.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BA086B0003; Wed, 19 Jun 2019 08:50:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36AA18E0002; Wed, 19 Jun 2019 08:50:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20B388E0001; Wed, 19 Jun 2019 08:50:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id C5F446B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 08:50:44 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id l9so1306557wrr.0
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 05:50:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Xtb4b1kSnmdV6z5RW+KhyWhbk8J0VV+tx8yXGWcbZHU=;
        b=TTnROwcQV119K6kotb2xHfhxeLdqo9W4Sp1U3UTYORPBjkG2LTb1/qOdN8hhlPUIfC
         ds+AielAJom1wfb2DHup6qUP8hACtJgvbuQOE106EWPVdMSBK1YGEVAboYqAfjobVWDq
         oR8m/wEhYj6A12C4DnmuDRoESxLgEmze88aPGv/Ap3MEwTuqyrcP3qrtkkO/GpJ6aZ4R
         0+0PG5Ce7beR55292H10ZMFNgkmv2GPJmtMsQIEFCP6vV3gi9LeJZVwAuxIBY3/ejRuC
         B75bXnVN8Sur++Q2XPaOh6flLK1iwkkYoBprnmtdgDvDFzJ4S+03FcwtY39csxnu4lpW
         FMDA==
X-Gm-Message-State: APjAAAWawrq8pJs8HE9ZnrNAN11VNvbV/o1NZQo5bjo3B43yvT6co7dx
	6SBvP7PMJREzv+rQaEfeHxKbE2Bjwe1jYf1walxXsRNOyVibFfyf3t+wk0GBm/DQqyabqYqa11t
	CcG4pIX8rdMfgwj12D8uXSYup5o6gfYBdbZwcx2lqnKNEqWV82PE0Sj0ktCQIiCCthw==
X-Received: by 2002:adf:f503:: with SMTP id q3mr20470403wro.43.1560948644213;
        Wed, 19 Jun 2019 05:50:44 -0700 (PDT)
X-Received: by 2002:adf:f503:: with SMTP id q3mr20470359wro.43.1560948643444;
        Wed, 19 Jun 2019 05:50:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560948643; cv=none;
        d=google.com; s=arc-20160816;
        b=nQimg8SplMt0XoW24iGfYX8BP38wlp62ORLK54u79JYjlsOXsbnbE2KwfgOB1/Y+i+
         eyeTcDQFsobBCOmDrj3Kt0Mye7c9+tMJuF/Lxk6tK1UJmuhh9wfXaeyzfoJ1y8Iul7gN
         fK7SHRCg1Y4W8YC4/Le3azsPRwgORtq4phXGc7ywAaeKx5mZdkFiKUQeSFbJk8i97aIK
         6tbD46ffzuIUuitLs9x3JFjLRvoMG/8A1Pzuw3zKzMQAIYA/D4P7PiPbFyJkCwRGTacR
         ltxUNzj+Ydp5qgGt8rwnlMJ+znS7kWzvQHLHpVRY0iedLp6R2tbKuOYhYvzwJBKneHlp
         UPsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Xtb4b1kSnmdV6z5RW+KhyWhbk8J0VV+tx8yXGWcbZHU=;
        b=mLPI/Y4E8nk5Hv3N/5ZmpK7aWhafvGBdwZ+u3OG6ji6ybaQ6hJeBUJMXbIlKESZsMV
         Rq9ZHXDMHbPDIWTtlYMMU61gD4A1Hf/jXQVCgBgl9zdgOOJb2I7wg23QCUE2+IshHiOz
         9Cjo5oMRLXUpeoZgEUMMW2LPzCprFxsLtlBBNZv6PDD2y7x1jjfcxgv7FD4FxflunJXI
         gmZgql1ZrCyb9trImHMUf2MEKPP1+rpFSzsOqCnx/PYwCChz3Vc+v1kelZtnz4MIcgSS
         bPKSJ0CBmY7GPIVkRuO+UxUezJxV4dcDlizDypvRnV9kmZ3mMvjkfM4uZYVHsU63gRxr
         WvDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amarulasolutions.com header.s=google header.b="dW6rwWu/";
       spf=pass (google.com: domain of andrea.parri@amarulasolutions.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andrea.parri@amarulasolutions.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g8sor7062298wrp.5.2019.06.19.05.50.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 05:50:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of andrea.parri@amarulasolutions.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amarulasolutions.com header.s=google header.b="dW6rwWu/";
       spf=pass (google.com: domain of andrea.parri@amarulasolutions.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andrea.parri@amarulasolutions.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amarulasolutions.com; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Xtb4b1kSnmdV6z5RW+KhyWhbk8J0VV+tx8yXGWcbZHU=;
        b=dW6rwWu/BxDcyY37Sf4zZHhk/BxlkdwN5gN343V7zBSAZ0SXuKFyO6NPG58mQ5ktr7
         PN+pIt0Tf0P/O3MDbO5prUrx8y576kfXAtnvM1ptZXz6JvVYc9biiGzrxZO4uaaDBgpE
         KAE0I5m0k/ivEF/VdemPUpTQTc+0vGOjxKUGU=
X-Google-Smtp-Source: APXvYqwrwhHdCyqZaSphz++F46CL3btA19KM3IT0OW+E8P4zQsLmtEh4sw1cdFoR2IThHvbCs9vwSA==
X-Received: by 2002:a5d:40ca:: with SMTP id b10mr26804056wrq.171.1560948642938;
        Wed, 19 Jun 2019 05:50:42 -0700 (PDT)
Received: from andrea (86.100.broadband17.iol.cz. [109.80.100.86])
        by smtp.gmail.com with ESMTPSA id 32sm36970395wra.35.2019.06.19.05.50.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 05:50:41 -0700 (PDT)
Date: Wed, 19 Jun 2019 14:50:34 +0200
From: Andrea Parri <andrea.parri@amarulasolutions.com>
To: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Cc: Linux Doc Mailing List <linux-doc@vger.kernel.org>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Kurt Schwemmer <kurt.schwemmer@microsemi.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Will Deacon <will.deacon@arm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Boqun Feng <boqun.feng@gmail.com>,
	Nicholas Piggin <npiggin@gmail.com>,
	David Howells <dhowells@redhat.com>,
	Jade Alglave <j.alglave@ucl.ac.uk>,
	Luc Maranget <luc.maranget@inria.fr>,
	"Paul E. McKenney" <paulmck@linux.ibm.com>,
	Akira Yokosawa <akiyks@gmail.com>,
	Daniel Lustig <dlustig@nvidia.com>,
	Stuart Hayes <stuart.w.hayes@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Darren Hart <dvhart@infradead.org>,
	Kees Cook <keescook@chromium.org>, Emese Revfy <re.emese@gmail.com>,
	Ohad Ben-Cohen <ohad@wizery.com>,
	Bjorn Andersson <bjorn.andersson@linaro.org>,
	Corey Minyard <minyard@acm.org>,
	Marc Zyngier <marc.zyngier@arm.com>,
	William Breathitt Gray <vilhelm.gray@gmail.com>,
	Jaroslav Kysela <perex@perex.cz>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	"Naveen N. Rao" <naveen.n.rao@linux.ibm.com>,
	Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Masami Hiramatsu <mhiramat@kernel.org>,
	Johannes Thumshirn <morbidrsa@gmail.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	Andreas =?iso-8859-1?Q?F=E4rber?= <afaerber@suse.de>,
	Manivannan Sadhasivam <manivannan.sadhasivam@linaro.org>,
	Rodolfo Giometti <giometti@enneenne.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Thierry Reding <thierry.reding@gmail.com>,
	Sumit Semwal <sumit.semwal@linaro.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Kirti Wankhede <kwankhede@nvidia.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Cornelia Huck <cohuck@redhat.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <maxime.ripard@bootlin.com>,
	Sean Paul <sean@poorly.run>, Farhan Ali <alifm@linux.ibm.com>,
	Eric Farman <farman@linux.ibm.com>,
	Halil Pasic <pasic@linux.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Harry Wei <harryxiyou@gmail.com>,
	Alex Shi <alex.shi@linux.alibaba.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Jerry Hoemann <jerry.hoemann@hpe.com>,
	Wim Van Sebroeck <wim@linux-watchdog.org>,
	Guenter Roeck <linux@roeck-us.net>, Guan Xuetao <gxt@pku.edu.cn>,
	Arnd Bergmann <arnd@arndb.de>,
	Linus Walleij <linus.walleij@linaro.org>,
	Bartosz Golaszewski <bgolaszewski@baylibre.com>,
	Andy Shevchenko <andy@infradead.org>, Jiri Slaby <jslaby@suse.com>,
	linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org,
	linux-arch@vger.kernel.org, platform-driver-x86@vger.kernel.org,
	kernel-hardening@lists.openwall.com,
	linux-remoteproc@vger.kernel.org,
	openipmi-developer@lists.sourceforge.net,
	linux-crypto@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, linux-pwm@vger.kernel.org,
	dri-devel@lists.freedesktop.org, kvm@vger.kernel.org,
	linux-fbdev@vger.kernel.org, linux-s390@vger.kernel.org,
	linux-watchdog@vger.kernel.org, linaro-mm-sig@lists.linaro.org,
	linux-gpio@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v1 12/22] docs: driver-api: add .rst files from the main
 dir
Message-ID: <20190619125034.GA8909@andrea>
References: <cover.1560890771.git.mchehab+samsung@kernel.org>
 <b0d24e805d5368719cc64e8104d64ee9b5b89dd0.1560890772.git.mchehab+samsung@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b0d24e805d5368719cc64e8104d64ee9b5b89dd0.1560890772.git.mchehab+samsung@kernel.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>  rename Documentation/{ => driver-api}/atomic_bitops.rst (99%)

Same here: NAK, this document does not belong to driver-api.

I also realize that, despite previous notices, you keep touching
documentation without even CC-ing the people who care...

  Andrea

