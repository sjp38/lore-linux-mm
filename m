Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38672C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:54:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6AA720651
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:54:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6AA720651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lwn.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A2FA6B0003; Tue, 23 Apr 2019 13:54:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82BA36B0005; Tue, 23 Apr 2019 13:54:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A5AF6B000A; Tue, 23 Apr 2019 13:54:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2A2776B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 13:54:20 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id x9so10781228pln.0
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 10:54:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=ti8PeUs+SEtcVpT4jkp4p9ziOXOkaOIVi5KzTFKptXo=;
        b=GmaSrBGdEx4hzvFVTLBRM8grRlebWZ6f13HzpHzopYqkwh9Hel4tsPha8opNrL/F2R
         6lWBDDzRsSmSEbrmSegS6R+q1+K0bsFlACWQaR4xE2lB6sL+VXHnW/iO4eKOpXsvVd+y
         K4WY0guZkGmX2AwQvneS++428PUkRuphlZNGeawNMYC7QcvvFGAfvCqQnMZO+b6ykGuG
         Cy0n1dzgWSPbh8QjminMtkdL1k1eX5shoFcAD+2ymPlYH9KiRC40euIG/TjB1M8jHIzX
         qmyPMu+4arW4hnTDMKaAmUBuQOmQ/35xO8ZQDbVNvpHhZCsKKskafdOlPJM1t6cIXRQW
         hYlg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
X-Gm-Message-State: APjAAAW87SsRNYODjZMm5RqSEY2UvLrZWjLOj7rxFq/2V4CoKtoykoK0
	Q3t/GrraPANatkkBLYkP+DmmpB7kJSBC0MJVXND6QVuhq7cggKKCDpUv1+mST7yzw42vncoAJd6
	mHsrzz2K6Nn7ClFz9vCvY6NoH4AmVChl92ZH13NtizrZ0wpAGVBNswooXcblcjpC3tQ==
X-Received: by 2002:a62:6e05:: with SMTP id j5mr28389993pfc.5.1556042059809;
        Tue, 23 Apr 2019 10:54:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqC/bVP+SOse78uVOou6buew7weUg4UvIgfJ/ILzBEVor6mQWNSuH22VXGaai2WopYJ9+E
X-Received: by 2002:a62:6e05:: with SMTP id j5mr28389923pfc.5.1556042059007;
        Tue, 23 Apr 2019 10:54:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556042059; cv=none;
        d=google.com; s=arc-20160816;
        b=yURrGCJ1wogRcLNLYdSRkaZ31NVR6ES/6s4krM1WPDB8IH2wpXYaLQmpTq9y8T/Sv4
         NerSZGAK6nRaspEUWwDimwLl0vAYb+EHOewTT4uAqYLi94AYuLkzUd1LsrZHHbhn7mCf
         NIZ7so6sPQXuf8DG7o0yfgEZf/rHKdgGvqWzW5BnrHzpJWaqDXlSWhvWbdpELpZyMacd
         g7PBli6beFRT5Cq592feuC8wdwKFDGsNQKdE4FJ9KVPTwPE450vRjOtGxmPYcU1SRc9j
         O0roq094ck37KaJT7ErnRXhNM1Lw1SEDF9ivp1ZyWm6cLgl/al3rdimH4p/MNilDZp6C
         4V0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=ti8PeUs+SEtcVpT4jkp4p9ziOXOkaOIVi5KzTFKptXo=;
        b=W95ZqM9nHl9gVGvsnqauu/dnC+9FLHj1CpalNXVyDHya+24prawq0A2yyTuk10OuKb
         HjCVHAgA111ragUznQ1eBYQIfXCm0A7u9LV6iWxlolLFLJqgFZfocTg3okhX4I5PuPEN
         SmbTR2etVdnHNwEP/8FgTmN9mXzLCWwlHGq/qgy6layf5G0zSC+2zGDEbNhPTCMDNaYe
         swb4l/oNBHCp7oNdgG3zcpzIaipsUMMn5USWjBhd5wPlEz9FyL0g7EEWb2/CBfJMpNyg
         TMwhEqj3SAp3lpMBKiNVtBalR238eJiQ/Pmd8T0e5gQgoLEo+c3p+lP7JoYASHEpI47Z
         whpA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id l59si16071592plb.298.2019.04.23.10.54.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 10:54:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) client-ip=45.79.88.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
Received: from localhost.localdomain (localhost [127.0.0.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by ms.lwn.net (Postfix) with ESMTPSA id 77A672DD;
	Tue, 23 Apr 2019 17:53:53 +0000 (UTC)
Date: Tue, 23 Apr 2019 11:53:49 -0600
From: Jonathan Corbet <corbet@lwn.net>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mike Snitzer <snitzer@redhat.com>, Mauro Carvalho Chehab
 <mchehab+samsung@kernel.org>, Linux Doc Mailing List
 <linux-doc@vger.kernel.org>, Mauro Carvalho Chehab <mchehab@infradead.org>,
 linux-kernel@vger.kernel.org, Johannes Berg <johannes@sipsolutions.net>,
 Kurt Schwemmer <kurt.schwemmer@microsemi.com>, Logan Gunthorpe
 <logang@deltatee.com>, Bjorn Helgaas <bhelgaas@google.com>, Alasdair Kergon
 <agk@redhat.com>, dm-devel@redhat.com, Kishon Vijay Abraham I
 <kishon@ti.com>, Rob Herring <robh+dt@kernel.org>, Mark Rutland
 <mark.rutland@arm.com>, Bartlomiej Zolnierkiewicz
 <b.zolnierkie@samsung.com>, David Airlie <airlied@linux.ie>, Daniel Vetter
 <daniel@ffwll.ch>, Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
 Maxime Ripard <maxime.ripard@bootlin.com>, Sean Paul <sean@poorly.run>,
 Ning Sun <ning.sun@intel.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon
 <will.deacon@arm.com>, Alan Stern <stern@rowland.harvard.edu>, Andrea Parri
 <andrea.parri@amarulasolutions.com>, Boqun Feng <boqun.feng@gmail.com>,
 Nicholas Piggin <npiggin@gmail.com>, David Howells <dhowells@redhat.com>,
 Jade Alglave <j.alglave@ucl.ac.uk>, Luc Maranget <luc.maranget@inria.fr>,
 "Paul E. McKenney" <paulmck@linux.ibm.com>, Akira Yokosawa
 <akiyks@gmail.com>, Daniel Lustig <dlustig@nvidia.com>, "David S. Miller"
 <davem@davemloft.net>, Andreas =?UTF-8?B?RsOkcmJlcg==?= <afaerber@suse.de>,
 Manivannan Sadhasivam <manivannan.sadhasivam@linaro.org>, Cornelia Huck
 <cohuck@redhat.com>, Farhan Ali <alifm@linux.ibm.com>, Eric Farman
 <farman@linux.ibm.com>, Halil Pasic <pasic@linux.ibm.com>, Martin
 Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens
 <heiko.carstens@de.ibm.com>, Harry Wei <harryxiyou@gmail.com>, Alex Shi
 <alex.shi@linux.alibaba.com>, Jerry Hoemann <jerry.hoemann@hpe.com>, Wim
 Van Sebroeck <wim@linux-watchdog.org>, Guenter Roeck <linux@roeck-us.net>,
 Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, "H.
 Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Russell King
 <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Fenghua Yu
 <fenghua.yu@intel.com>, "James E.J. Bottomley"
 <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>,
 Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>,
 Guan Xuetao <gxt@pku.edu.cn>, Jens Axboe <axboe@kernel.dk>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki"
 <rafael@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Matt Mackall
 <mpm@selenic.com>, Herbert Xu <herbert@gondor.apana.org.au>, Corey Minyard
 <minyard@acm.org>, Sumit Semwal <sumit.semwal@linaro.org>, Linus Walleij
 <linus.walleij@linaro.org>, Bartosz Golaszewski
 <bgolaszewski@baylibre.com>, Darren Hart <dvhart@infradead.org>, Andy
 Shevchenko <andy@infradead.org>, Stuart Hayes <stuart.w.hayes@gmail.com>,
 Jaroslav Kysela <perex@perex.cz>, Alex Williamson
 <alex.williamson@redhat.com>, Kirti Wankhede <kwankhede@nvidia.com>,
 Christoph Hellwig <hch@lst.de>, Marek Szyprowski
 <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Steffen
 Klassert <steffen.klassert@secunet.com>, Kees Cook <keescook@chromium.org>,
 Emese Revfy <re.emese@gmail.com>, James Morris <jmorris@namei.org>, "Serge
 E. Hallyn" <serge@hallyn.com>, linux-wireless@vger.kernel.org,
 linux-pci@vger.kernel.org, devicetree@vger.kernel.org,
 dri-devel@lists.freedesktop.org, linux-fbdev@vger.kernel.org,
 tboot-devel@lists.sourceforge.net, linux-arch@vger.kernel.org,
 netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-s390@vger.kernel.org, kvm@vger.kernel.org,
 linux-watchdog@vger.kernel.org, linux-ia64@vger.kernel.org,
 linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org,
 sparclinux@vger.kernel.org, linux-block@vger.kernel.org,
 linux-crypto@vger.kernel.org, openipmi-developer@lists.sourceforge.net,
 linaro-mm-sig@lists.linaro.org, linux-gpio@vger.kernel.org,
 platform-driver-x86@vger.kernel.org, iommu@lists.linux-foundation.org,
 linux-mm@kvack.org, kernel-hardening@lists.openwall.com,
 linux-security-module@vger.kernel.org
Subject: Re: [PATCH v2 56/79] docs: Documentation/*.txt: rename all ReST
 files to *.rst
Message-ID: <20190423115349.589c3d50@lwn.net>
In-Reply-To: <20190423171158.GG12232@hirez.programming.kicks-ass.net>
References: <cover.1555938375.git.mchehab+samsung@kernel.org>
	<cda57849a6462ccc72dcd360b30068ab6a1021c4.1555938376.git.mchehab+samsung@kernel.org>
	<20190423083135.GA11158@hirez.programming.kicks-ass.net>
	<20190423125519.GA7104@redhat.com>
	<20190423130132.GT4038@hirez.programming.kicks-ass.net>
	<20190423103053.07cf2149@lwn.net>
	<20190423171158.GG12232@hirez.programming.kicks-ass.net>
Organization: LWN.net
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-redhat-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Apr 2019 19:11:58 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> When writing, I now have to be bothered about this format crap over just
> trying to write a coherent document.

Just write text, it'll all work out in the end :)

> Look at crap like this:
> 
> "The memory allocations via :c:func:`kmalloc`, :c:func:`vmalloc`,
> :c:func:`kmem_cache_alloc` and"
> 
> That should've been written like:
> 
> "The memory allocations via kmalloc(), vmalloc(), kmem_cache_alloc()
> and"

Yeah, I get it.  That markup generates cross-references, which can be
seriously useful for readers - we want that.  But I do wonder if we
couldn't do it automatically with just a little bit of scripting work.
It's not to hard to recognize this_is_a_function(), after all.  I'll look
into that, it would definitely help to remove some gunk from the source
docs.

jon

