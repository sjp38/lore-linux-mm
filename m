Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3A01C10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 13:02:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80285206A3
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 13:02:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WVoUkB+u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80285206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02EA86B0007; Tue, 23 Apr 2019 09:02:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 005A16B0008; Tue, 23 Apr 2019 09:01:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE8FC6B000A; Tue, 23 Apr 2019 09:01:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id BDAAF6B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:01:59 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id w1so2398038itk.4
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 06:01:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=bNrkb+RJEvVECppW3MCB++5skMQE0pDsjh32yrvleKw=;
        b=OjS7aUyLNZi+1sVqQIV4glXt/t2i8hL5uoIXR5jHkqY7i95uy2zkuTVvJ3VsqDP1BZ
         +SqHiSt2nI2XdAyvmR7v1650obi1qyls3VufuMEHYsdmqf/OhIPm4E5W+uvH4DBFt1zX
         yq+xak6oXZidCCCBVB3URPOZkPgeYPJAalAKquGRBgd7YvSdpPQqhsMr48Dn2sgZtAq+
         fZTN/GB3FK172IMcgya0YTaSX3bNUH/tg1ZybJes+WzB+Y5Qc7i8Bj07CUVSTgC4YbcO
         MZ8E2iu9rgO54I1xjIdRwNlre/MSUK66qNgrXwX695JwSMhgM34eEzFtKfxMj2MMVuC0
         lSQQ==
X-Gm-Message-State: APjAAAVkM5ks7oA0+JqgJ3jU6rpbGU4aHZFNXceKNurjmvY4DMvuiFMF
	tfD09OWgCxsml5Beb2uDI2i/kAe3f2DlYv0VObZQGXv3c3/4Et/Hba/bxavyf5w9Sg62if+3qlt
	h0c8LntqpHbDlFMlNr9Bi9R0++WY5/Qg8ZJ5+oCT2O2a71JYWQEQ19vJdne1GaIIAOA==
X-Received: by 2002:a24:4acd:: with SMTP id k196mr1887627itb.101.1556024519531;
        Tue, 23 Apr 2019 06:01:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybJ4M4I09ut9rz5ZB1a/7uKhvd9ieh+4Tr2a51CQgUTVZi+NqbBFSP4kubSmrWDKbCnlfI
X-Received: by 2002:a24:4acd:: with SMTP id k196mr1887513itb.101.1556024518357;
        Tue, 23 Apr 2019 06:01:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556024518; cv=none;
        d=google.com; s=arc-20160816;
        b=EmM3TxBmVseQbG6WfCr7cqsW1Ye1PDcn0KexNMWr1XPcYJs8UA8FxnGr89UudFrsRx
         gcX9GbeKFlEWE802tK64vF9WaMngDNHvyjLGHFakYC1bo5WwPzPd2OWgfsPT4KdI3eWT
         hbSJx0IK6uox48uzKWpuaDPfmkA9xMK0/VjUD4ttf91EbpNTB8/ZgkYhNi/uWagVKGuc
         1UXEyN24gK+zFrP0D+WRd430XzI9I9v2Rm+ngGfBoGRwhxGeZ7gl37hOy1mRaSoakpya
         wARyB9bge4zbycn1p2woTUDjtBRDJ4IFJ8VNzH0kXEroUcHb+6BDjWrK1K6OQhVGTztl
         d30w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bNrkb+RJEvVECppW3MCB++5skMQE0pDsjh32yrvleKw=;
        b=EYMPWHavdF6MxXrze45P1KoOYeNkJM6Opiy1aASaXJ7t/k+e9eO3qE8pqkrz2LbuPi
         0cG090qHwaIKAJQfCjEovyjOMcwQCyYJTb/ukRdhwGv2QRuYwY33SSbLNQCvAAIvAbpC
         hXYvJiSTv3FMvm6D9qMq2IT0CVFJBK2sT/3jtcGIAk/n0Xq9ZeDJrhvIKZkXsh7oonWg
         Zs1HX6Kh+qP4b1m3pPro4yU7UTzpvb9deqErBvP4gJ0ppbvBRut+JUmfodkXxa0Kgehg
         hcnpNF4Px9IgFvNSpJdiUHM9X+Co2kNFIwkZzPdxBTY0KNBYj5N6P1hq48s0zf8DO2qc
         RNrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=WVoUkB+u;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [205.233.59.134])
        by mx.google.com with ESMTPS id 4si10060463itx.113.2019.04.23.06.01.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 06:01:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) client-ip=205.233.59.134;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=WVoUkB+u;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 205.233.59.134 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=bNrkb+RJEvVECppW3MCB++5skMQE0pDsjh32yrvleKw=; b=WVoUkB+umnQYCnRaiIeFTDR1P
	kiyrLTncTCAtEGSlhK0om1qqZqC5CJUcRmuyylcGoMEj64UbaBu1wIFAnXnvprKeSbwzC92zqflRg
	Ait3bOL42fHBCgQO4eX4mQ3ggTR0W5bTAyVpZ9Xy0PgdNlxs4fDI2BfVyEaPIgXAiyqBM6r3ywZy1
	4EiMiZgCaryqtmsdgqGOlSCm6+BpSRp4lFsNUNcWkEwqtesrIFXstvc6AsUYg+ca7jS/2pX4JW7Dw
	cwiZZbF6OHyqEREKE5aT4JAwaBcw5s2tIbDhW5tQoTVlL5yuY38Rp4ElJfJTQA3hoThiFG/994qoW
	T4FZeg/Pw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIv3G-0004LR-47; Tue, 23 Apr 2019 13:01:34 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id DAD3E29C22227; Tue, 23 Apr 2019 15:01:32 +0200 (CEST)
Date: Tue, 23 Apr 2019 15:01:32 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Mike Snitzer <snitzer@redhat.com>
Cc: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>,
	Linux Doc Mailing List <linux-doc@vger.kernel.org>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>,
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
Message-ID: <20190423130132.GT4038@hirez.programming.kicks-ass.net>
References: <cover.1555938375.git.mchehab+samsung@kernel.org>
 <cda57849a6462ccc72dcd360b30068ab6a1021c4.1555938376.git.mchehab+samsung@kernel.org>
 <20190423083135.GA11158@hirez.programming.kicks-ass.net>
 <20190423125519.GA7104@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190423125519.GA7104@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 08:55:19AM -0400, Mike Snitzer wrote:
> On Tue, Apr 23 2019 at  4:31am -0400,
> Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > On Mon, Apr 22, 2019 at 10:27:45AM -0300, Mauro Carvalho Chehab wrote:
> > 
> > >  .../{atomic_bitops.txt => atomic_bitops.rst}  |  2 +
> > 
> > What's happend to atomic_t.txt, also NAK, I still occationally touch
> > these files.
> 
> Seems Mauro's point is in the future we need to touch these .rst files
> in terms of ReST compatible changes.
> 
> I'm dreading DM documentation changes in the future.. despite Mauro and
> Jon Corbet informing me that ReST is simple, etc.

Well, it _can_ be simple, I've seen examples of rst that were not far
from generated HTML contents. And I must give Jon credit for not
accepting that atrocious crap.

But yes, I have 0 motivation to learn or abide by rst. It simply doesn't
give me anything in return. There is no upside, only worse text files :/

