Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C2A0C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 18:22:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3E2B208E4
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 18:22:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="0M9zA+Se"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3E2B208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99EA86B0003; Tue, 23 Apr 2019 14:22:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94F5A6B0005; Tue, 23 Apr 2019 14:22:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CBF16B0007; Tue, 23 Apr 2019 14:22:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5985D6B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 14:22:14 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id i1so13775120ioq.9
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:22:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=tDH07UaRkoqsqDsQ9nKKmzIwATHiDTHAVgfMDiCFrRE=;
        b=fAzHToXmrtdTWSa3aEfCnhDRaWqlRXubrQrRieIxLW7ZmB+xbPpv5cKvlEauQBkkfG
         Zt6XdB8hw/kucuSLrw9/OIyRRNR7rb5uLOaEZdhRGLpIFereVFbMJlAT/6XyzfYtD9no
         nIWBucGu9oBzFJyavjv3Rq8B3yTnVvb8Arv4u30SjpsAGL2sUaNqncCznK3q78zk9oRX
         m93KUdYI6OeIKEB7AKXrNC7tdRsUCOBTskOEHrc4f8fZI/0r979MJ7VR5gb7hmDdDjwR
         WhcndB2OT0IsbEw9rcor1JlmL+tS1fo/j0iXC41kzBFCRp3FAnXS2A5+Lif28g+4cLfi
         oPWA==
X-Gm-Message-State: APjAAAUFzEyNri4zmTohWewMsFrElWzMjyN1nPLokuEuM13G4SKfX5q/
	gokCRMQEtqyYY3zowyKj4cJr7Dg9w0OPZuSCXTPRs1EKcfucIZjrX367Ap2P3b4IAP3QGFvoS0o
	tIEonF+w2iRUuIvmkPkhfROXzMJivnd1c2z4PIZjKyp/I2RTnotBG1EcwlkxA2xlPTA==
X-Received: by 2002:a24:5f90:: with SMTP id r138mr3244442itb.43.1556043734039;
        Tue, 23 Apr 2019 11:22:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxD5YV4ut1kpewXxf3gO6RwWtQoOiddNYADnmrPExa3MERQusa4Qz4VD6SDtr1g/MaiIUNu
X-Received: by 2002:a24:5f90:: with SMTP id r138mr3244394itb.43.1556043733410;
        Tue, 23 Apr 2019 11:22:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556043733; cv=none;
        d=google.com; s=arc-20160816;
        b=S+tgRWb9r6aR4l+khWXCQMSlgWZ2EbgfjScNyWVoHdIsHig8437oD3gMsDLgr7AFrz
         Br37KT9zRHvWVORiEzWzKA23WebFiH6UWrDc4nj56KoH0df5PqPB+Sa1y17cV5GDvc4L
         YS+lEd6Habed5SsfLZ61d3lWsIMQ1t0wx8xPDxHSUfInZnobh+Zdt/fscKJFtxMCkdjk
         8UBcJlN+smOUhMaPjNicShzxrVbGfMs0rHC2dQXxXavqyvzoV3GhWgRAvG+to/cX7vRR
         MDpuHIwcK3Wk59rBI5Pn8+yvbTtkr7crcoooLYT9WB0K10dLvnHhI77FfzXnNyTj32uj
         C8lg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=tDH07UaRkoqsqDsQ9nKKmzIwATHiDTHAVgfMDiCFrRE=;
        b=oKmEhtrVGn9kdHBsjF3RrzfsF0+iWI8n4hf5syhlLI73YASK2N9hFdXhSRc++A5amt
         L4g5u7Ahgx63jOFebBOAKFlkuoQ0y2p9nex+FgQFHp3iUVNcfqJKJT8KeHrwEsCXGkyN
         6nuAsR3B2j7Xizymorv0n43ZqgxqEhK+sGxsy/8SPyYmUkFy1v2J3yXAXYtNLUHHAth1
         FrIjt83wK9YJKfrvlLVmRJqA4fNM1y3mV3CUJCl/G0KFjYvaedmdV9g3wFD1rHYtRICD
         Qw2xVaBf3125ERAUKS8N1H/ZJes7hwAWsVa/ZAVtAdBTi+KkFrWpZMp34qBbCduGNFtX
         CNTw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=0M9zA+Se;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [205.233.59.134])
        by mx.google.com with ESMTPS id k4si6631395iol.74.2019.04.23.11.22.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 11:22:13 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) client-ip=205.233.59.134;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=0M9zA+Se;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=tDH07UaRkoqsqDsQ9nKKmzIwATHiDTHAVgfMDiCFrRE=; b=0M9zA+SeZDEm2OrrPspNGemgW
	C9gLVCPujevruD4S5Y8vXwoP92a/CHKv+nCfLYuIgl5ZoxoDmxlrytjIEn1XkhN+qh78lRoQCTeH6
	5GEMrVxgUw3eTOt7UZZYBb5dSDCexoTYnLY64BUjJQdZptvF5N71QexSA9jLZ0JNFSNPTTqYFNB64
	wXTtOqi5+fbX6mFFQr7iQcaf/0gEhCG1actdEg6bXiiCn4DGvQKLJb9PxlOOl7cTBnIFeoc0aYB2V
	lrwoOszNRl50IdkSPqQIyP5/wSEER59oGyhMg6yb9WHBUHvKPTuZ1YxuY3bIEnpaTYAJECW41Ga0D
	G0Ekfiq6Q==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hJ039-00085e-18; Tue, 23 Apr 2019 18:21:47 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id AC25C29AC07B4; Tue, 23 Apr 2019 20:21:43 +0200 (CEST)
Date: Tue, 23 Apr 2019 20:21:43 +0200
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
Message-ID: <20190423182143.GL12232@hirez.programming.kicks-ass.net>
References: <cover.1555938375.git.mchehab+samsung@kernel.org>
 <cda57849a6462ccc72dcd360b30068ab6a1021c4.1555938376.git.mchehab+samsung@kernel.org>
 <20190423083135.GA11158@hirez.programming.kicks-ass.net>
 <20190423125519.GA7104@redhat.com>
 <20190423130132.GT4038@hirez.programming.kicks-ass.net>
 <20190423103053.07cf2149@lwn.net>
 <20190423171158.GG12232@hirez.programming.kicks-ass.net>
 <20190423115349.589c3d50@lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190423115349.589c3d50@lwn.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 11:53:49AM -0600, Jonathan Corbet wrote:
> > Look at crap like this:
> > 
> > "The memory allocations via :c:func:`kmalloc`, :c:func:`vmalloc`,
> > :c:func:`kmem_cache_alloc` and"
> > 
> > That should've been written like:
> > 
> > "The memory allocations via kmalloc(), vmalloc(), kmem_cache_alloc()
> > and"
> 
> Yeah, I get it.  That markup generates cross-references, which can be
> seriously useful for readers - we want that.

The funny thing is; that sentence continues (on a new line) like:

"friends are traced and the pointers, together with additional"

So while it then has cross-references to a few functions, all 'friends'
are left dangling. So what's the point of the cross-references?

Also, 'make ctags' and follow tag (ctrl-] for fellow vim users) will get
you to the function, no magic markup required.

> But I do wonder if we
> couldn't do it automatically with just a little bit of scripting work.
> It's not to hard to recognize this_is_a_function(), after all.  I'll look
> into that, it would definitely help to remove some gunk from the source
> docs.

That would be good; less markup is more.

