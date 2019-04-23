Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 006F5C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 08:32:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A95EA20843
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 08:32:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="wtcLR00S"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A95EA20843
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 62AE06B0006; Tue, 23 Apr 2019 04:32:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DA136B0007; Tue, 23 Apr 2019 04:32:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47A2C6B0008; Tue, 23 Apr 2019 04:32:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 279636B0006
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 04:32:26 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id y10so3950333ioj.7
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 01:32:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=mVbTPadcqfIC9mixerPpd69JlL1rVPk8BX8DnNvgvak=;
        b=SQa0qmB1PX1l78A+E9yuBMMEyYVziH2K+gcDcsd1C06F39B1k9Hryg76jZef47eN2O
         bLVQYTfU0NH4bl6JSMHHPrPt12P6mpTGzS1hNf+TU28H240ZW3lERS9ActR2QGEg/4cM
         cWShYGxqCod8F3kZevsBIHKio8Wuv2ZEBZHIzGzSeAHHJH9oHelp1VR6Pdq2/tVcmXzP
         xNKhU9yVNsegI2fLuOFfwiAqmuzigDVy0cPEuya3chBbDJkM/Yx/laKgTTeSUZ3U+Rht
         aWkzwglyCRtgvh3a4bc4L+liOWxRZUrqgVzOoOEPPlk82NQJF0koI9rlhqx0jwJLUTtp
         XpAQ==
X-Gm-Message-State: APjAAAUnnh57WTdMsu6i6VmjefUxwUiNeca/EBqZFKl2axftyJfoTpQU
	052Z2LaH3/jZHSDCWYE2P4sxoJ84pRIUbEgFMGULO1diAnnzdvgN5PWo4Ptl4F5k4B7vK+KOCaC
	rRkUetjAwRHTZLneVuqX51ks+dXZvldojZJ6amZaDqF10MD+cmLttHvNPuJMBPUY1kA==
X-Received: by 2002:a02:1649:: with SMTP id a70mr16972843jaa.116.1556008345889;
        Tue, 23 Apr 2019 01:32:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdS9QEbH2jl+tViIE/CtXQnSiS4FrKDCuABocsvkMuMkF2k15IypLqUj/b/sPJiBYDyiX4
X-Received: by 2002:a02:1649:: with SMTP id a70mr16972813jaa.116.1556008345189;
        Tue, 23 Apr 2019 01:32:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556008345; cv=none;
        d=google.com; s=arc-20160816;
        b=aMtaoqXP6ROiUzhdwJyalxu9AJpdEQp3NqvTql7UwSNI03xlntdcGrHxrso5l+J2Uh
         kL1WkKpzVzeCAedk4lKH2oePM+SrU8jmwsH7HuDoPhhLi79SOv1fl9Ju3pm0VeCDEXET
         d9MzeBiEfFiDqL0IJLyxHZiXq0+Q5951fL+n4bi5EYSigaj6J8ptp2KawVx/Rp5fJro8
         Ib22MbM9Zp6MIpW3mcAWTr2zwjVNBrgeoY7PaOl0Ta36GzExSK4OtlJleP5BU3/kJsuY
         faryC9Y8MRrcXFsIZKlkFZnqcRuq9viCWaYxq6NnjYcKyvLwqv+c15XypFACmCvYB8uv
         TM6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=mVbTPadcqfIC9mixerPpd69JlL1rVPk8BX8DnNvgvak=;
        b=lSrqwqg1GslV5v6vYVYElUVt9/oPHI8C+73uB+IXcPA1+Ryq5fxsksuJgB3C9nTTU9
         iyOxDUTF67iZiesXITpJ6AT4uTHyhMQiGC0mpxmjBfyvj3CWAVBEQa2t+yQQ0sisx6ab
         nNkUoLMKVRaormbHTk4vxT789i8GhDNJwDQPPd3RDmbbcoJ+v5v1IeuixF6EyRnBhquS
         B18dveRVZ4nyIHD6InWdNy/JXagRpFcX5J20Ye2bhJOAGn9w23lGzfnj0IaQbjv4JiKh
         3F+mwv3RpPV/0VzmBtENRN2laWcz9/0A1uFVflwekfuIL82nNKvSXq2FuFU/1DarVrs4
         O2Ig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=wtcLR00S;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [205.233.59.134])
        by mx.google.com with ESMTPS id u14si9755340itb.54.2019.04.23.01.32.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 01:32:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) client-ip=205.233.59.134;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=wtcLR00S;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=mVbTPadcqfIC9mixerPpd69JlL1rVPk8BX8DnNvgvak=; b=wtcLR00S2SyaNSHW4W8YJVLlo
	O+xbXpGju2AS15n0RmT22PNWFPgguiraXkdz7fTJOOPFCelJgRckZD0/2ZuE5op1dhFB31L2Ux4Ze
	01lbzR2iOYjQ3s5bFQe0H6jR2yRtfoA9auKWa+hqqZAoYDA+4QO6IOvxFPGmNu1KYOUdAu9Smvfih
	bfDZX+lBlu9XddXeAz50OuhzynHVc2qNrk6xzn2OJuiCWDCSuOHf0ablqILz4HnjnmIrjKhnwvtVI
	f2hObf07+j4H1ytWJzP6eiFop3mnBtxtn6MgoVhsIhyBGhkKYWLd+Q/sSRXuYtDP18GWF7fFzmPne
	zpUrj3YTA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIqq0-00012o-Ks; Tue, 23 Apr 2019 08:31:36 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 6323E29B47DC6; Tue, 23 Apr 2019 10:31:35 +0200 (CEST)
Date: Tue, 23 Apr 2019 10:31:35 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Cc: Linux Doc Mailing List <linux-doc@vger.kernel.org>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Kurt Schwemmer <kurt.schwemmer@microsemi.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>,
	dm-devel@redhat.com, Kishon Vijay Abraham I <kishon@ti.com>,
	Rob Herring <robh+dt@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <maxime.ripard@bootlin.com>,
	Sean Paul <sean@poorly.run>, Ning Sun <ning.sun@intel.com>,
	Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Andrea Parri <andrea.parri@amarulasolutions.com>,
	Boqun Feng <boqun.feng@gmail.com>,
	Nicholas Piggin <npiggin@gmail.com>,
	David Howells <dhowells@redhat.com>,
	Jade Alglave <j.alglave@ucl.ac.uk>,
	Luc Maranget <luc.maranget@inria.fr>,
	"Paul E. McKenney" <paulmck@linux.ibm.com>,
	Akira Yokosawa <akiyks@gmail.com>,
	Daniel Lustig <dlustig@nvidia.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andreas =?iso-8859-1?Q?F=E4rber?= <afaerber@suse.de>,
	Manivannan Sadhasivam <manivannan.sadhasivam@linaro.org>,
	Cornelia Huck <cohuck@redhat.com>, Farhan Ali <alifm@linux.ibm.com>,
	Eric Farman <farman@linux.ibm.com>,
	Halil Pasic <pasic@linux.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Harry Wei <harryxiyou@gmail.com>,
	Alex Shi <alex.shi@linux.alibaba.com>,
	Jerry Hoemann <jerry.hoemann@hpe.com>,
	Wim Van Sebroeck <wim@linux-watchdog.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
	x86@kernel.org, Russell King <linux@armlinux.org.uk>,
	Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>,
	"James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>,
	Helge Deller <deller@gmx.de>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>, Guan Xuetao <gxt@pku.edu.cn>,
	Jens Axboe <axboe@kernel.dk>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Arnd Bergmann <arnd@arndb.de>, Matt Mackall <mpm@selenic.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Corey Minyard <minyard@acm.org>,
	Sumit Semwal <sumit.semwal@linaro.org>,
	Linus Walleij <linus.walleij@linaro.org>,
	Bartosz Golaszewski <bgolaszewski@baylibre.com>,
	Darren Hart <dvhart@infradead.org>,
	Andy Shevchenko <andy@infradead.org>,
	Stuart Hayes <stuart.w.hayes@gmail.com>,
	Jaroslav Kysela <perex@perex.cz>,
	Alex Williamson <alex.williamson@redhat.com>,
	Kirti Wankhede <kwankhede@nvidia.com>,
	Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Kees Cook <keescook@chromium.org>, Emese Revfy <re.emese@gmail.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org,
	devicetree@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-fbdev@vger.kernel.org, tboot-devel@lists.sourceforge.net,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org,
	kvm@vger.kernel.org, linux-watchdog@vger.kernel.org,
	linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	linux-block@vger.kernel.org, linux-crypto@vger.kernel.org,
	openipmi-developer@lists.sourceforge.net,
	linaro-mm-sig@lists.linaro.org, linux-gpio@vger.kernel.org,
	platform-driver-x86@vger.kernel.org,
	iommu@lists.linux-foundation.org, linux-mm@kvack.org,
	kernel-hardening@lists.openwall.com,
	linux-security-module@vger.kernel.org
Subject: Re: [PATCH v2 56/79] docs: Documentation/*.txt: rename all ReST
 files to *.rst
Message-ID: <20190423083135.GA11158@hirez.programming.kicks-ass.net>
References: <cover.1555938375.git.mchehab+samsung@kernel.org>
 <cda57849a6462ccc72dcd360b30068ab6a1021c4.1555938376.git.mchehab+samsung@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cda57849a6462ccc72dcd360b30068ab6a1021c4.1555938376.git.mchehab+samsung@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 22, 2019 at 10:27:45AM -0300, Mauro Carvalho Chehab wrote:

>  .../{atomic_bitops.txt => atomic_bitops.rst}  |  2 +

What's happend to atomic_t.txt, also NAK, I still occationally touch
these files.

