Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9AAAC10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:12:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 793DA20645
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:12:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ayQa++Pm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 793DA20645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1980D6B0010; Tue, 23 Apr 2019 13:12:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 147F66B0266; Tue, 23 Apr 2019 13:12:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F28E86B0269; Tue, 23 Apr 2019 13:12:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id D27FF6B0010
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 13:12:28 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id c10so3755736ioc.10
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 10:12:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=51+tu1oIqK3EcVYvR3cWej3B+dgWrl4KsImF/EU0eUQ=;
        b=sJ3KYzy4Dq/OQM9EdXmdPGaXjc5cb/7PeNeKdh2YKwR3XVcTPKH1OEfxDWn3r7Oj6/
         hEBofut7+u/PELOrLJr3aeyG7gLjUCY39UrNE7yGjSvawgL98OL9hVX93fuBImP5DzYA
         sCZKil9BWsPaOQ3LdjHxPQJk8wUPqfjm5QvxqHp5EOQTZpY2ZtYtjW7BYwK0Eol5gapW
         KamsCAWK8+MfRrZoAoXneb5DhURQKlPEbM1j4ml0iIduFiuu2ET8V8YKBoqZvzhOgWw9
         IIjFTwqLFpgqa4T4JfEj7zHadqJ7p2cX47y6AFzYG3aWcXkphsHVXewWPcqHUN/YQ3b0
         x7Cw==
X-Gm-Message-State: APjAAAVjmUXvww0Pi1j8+tOh8hNl/1miVz759mnmoB+nRFgxB1zrzN3k
	6pdU+lTifzFK1b/+jDEZDhu7PPwSnaMPe/Fo2UE6DMWRm53IhW/KJ87vxCF5n/ebZZosf5E4oZe
	DQUn6piU15m5637zgdCJ3B4p2waZLb6MkqE+sH5SeEFDKMYpSzNpba4eRyfSpGtt+Lw==
X-Received: by 2002:a24:41a9:: with SMTP id b41mr3198585itd.16.1556039548554;
        Tue, 23 Apr 2019 10:12:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfcxElPrqS795Ckr1HaUeuYMBQgCbH8oOuFXZtMOs6L5dL+4no49ao8bNaBiNqKKvOp70n
X-Received: by 2002:a24:41a9:: with SMTP id b41mr3198530itd.16.1556039547783;
        Tue, 23 Apr 2019 10:12:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556039547; cv=none;
        d=google.com; s=arc-20160816;
        b=0EtV7UvCIHCZygTsjxkNBADV50xMvpUQR0ZR8S5ekeojySCb9Ua0TlKGezc7+tlBWu
         pq8qin0rIz+xMVPe1NxuVHKtMtxZAJkslqJnGRtZeGOKbStG2a8DWgNPieAXCmJj6pem
         tc2qNhRrFdq7VGlg/yKOn7BLi4QBuFrAp4zcECFHdeBsjR3MRsfg6wlZ9xWC/6GXDH4l
         pSWuEcALA4epMMLvYid/dGtQGcLzKs8cYUzDkr8p8ctnHCBIbFzn6Ve+LjXlAp288+zp
         FClzlsed772348CluB7qTLjhcMI8VzafdBjxX6fX2rrvUgo3j1C7h0iwCedzYvR0INDQ
         CLuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=51+tu1oIqK3EcVYvR3cWej3B+dgWrl4KsImF/EU0eUQ=;
        b=hGquZPlDiAh0tcOlNMMm0vLPV3FP0kkCcBDEDhUCuxICAJ4YY8Vp2zksvw2Sho+iER
         4m/jH7t8xiFMnKmIUxMyVzAjTjXt8TsBNn8FvyHlRpfKB3IB/043+ELD7ReIBzV9RQ3x
         ZlJiQIdsimQl3AQGWjbq/n3W1qoyUhi83+JJttxyA9Q1Zm2TRTqy2xn5HhP9oT0bw+WW
         kKann+5HmeAGOyN8CrV+A5mUGrJJZ4A4mU5JzQ8QIcElZVfpinJKNsCfyQkQJSlYmkZc
         plsuBVK6dTWBAo9ymosre5NJZW2IvjlUfe+zwF+v6jabLb9AlSAuF1A2T4Zu5HFGUugk
         aVZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=ayQa++Pm;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [205.233.59.134])
        by mx.google.com with ESMTPS id o8si9923409ito.56.2019.04.23.10.12.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 10:12:27 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) client-ip=205.233.59.134;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=ayQa++Pm;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=51+tu1oIqK3EcVYvR3cWej3B+dgWrl4KsImF/EU0eUQ=; b=ayQa++Pm8jAB/DGkr2mbbcclC
	/k4tQSII0yLIPTBL48Rqm/D3G2BlwYxE1848ZLySXm+r0JHltH+/oRdelw2cgOhI9ivk5BWyctVEA
	9v/YOx2w3H8+aTrAuBEce/jseNwLIMGyRmNYa8XN3Q+YurAiW4EU+UdJIfoxFEcy7KZFgBsYiWw21
	DoBp6lkqkORbhZhYslJhSLqkmg+7NFaAr0c/gOi9+o8DTVLdbjdbBP7Kh7+QfsKF089Vzb+x4Ettb
	zqm1gPYim/3/Ix7PDdSGvW7D4aqlqPE5ylrrzCnDNUDBXhG5MQu36WrvfmP8jpcnWA5Y/Hr1XmK6l
	6Zp/EGN+Q==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIyxd-0007Bj-MN; Tue, 23 Apr 2019 17:12:01 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id D2AC329AC07B5; Tue, 23 Apr 2019 19:11:58 +0200 (CEST)
Date: Tue, 23 Apr 2019 19:11:58 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Mike Snitzer <snitzer@redhat.com>,
	Mauro Carvalho Chehab <mchehab+samsung@kernel.org>,
	Linux Doc Mailing List <linux-doc@vger.kernel.org>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	linux-kernel@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>,
	Kurt Schwemmer <kurt.schwemmer@microsemi.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Alasdair Kergon <agk@redhat.com>, dm-devel@redhat.com,
	Kishon Vijay Abraham I <kishon@ti.com>,
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
Message-ID: <20190423171158.GG12232@hirez.programming.kicks-ass.net>
References: <cover.1555938375.git.mchehab+samsung@kernel.org>
 <cda57849a6462ccc72dcd360b30068ab6a1021c4.1555938376.git.mchehab+samsung@kernel.org>
 <20190423083135.GA11158@hirez.programming.kicks-ass.net>
 <20190423125519.GA7104@redhat.com>
 <20190423130132.GT4038@hirez.programming.kicks-ass.net>
 <20190423103053.07cf2149@lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190423103053.07cf2149@lwn.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 10:30:53AM -0600, Jonathan Corbet wrote:
> On Tue, 23 Apr 2019 15:01:32 +0200
> Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > But yes, I have 0 motivation to learn or abide by rst. It simply doesn't
> > give me anything in return. There is no upside, only worse text files :/
> 
> So I believe it gives even you one thing in return: documentation that is
> more accessible for both readers and authors.

I know I'm an odd duck; but no. They're _less_ accessible for me, as
both a reader and author. They look 'funny' when read as a text file
(the only way it makes sense to read them; I spend 99% of my time on a
computer looking at monospace text interfaces; mutt, vim and console, in
that approximate order).

When writing, I now have to be bothered about this format crap over just
trying to write a coherent document.

Look at crap like this:

"The memory allocations via :c:func:`kmalloc`, :c:func:`vmalloc`,
:c:func:`kmem_cache_alloc` and"

That should've been written like:

"The memory allocations via kmalloc(), vmalloc(), kmem_cache_alloc()
and"

Heck, that paragraph isn't even properly flowed.

Then there's the endless stuck ':' key, and the mysterious "''" because
\" isn't a character, oh wait.

Bah..

