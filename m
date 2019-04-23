Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1C42C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:20:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60A1020835
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:20:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="McGNaf3d"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60A1020835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E148F6B0269; Tue, 23 Apr 2019 13:20:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC3B16B026C; Tue, 23 Apr 2019 13:20:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C65366B026F; Tue, 23 Apr 2019 13:20:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 714D16B0269
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 13:20:16 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id u14so15381373wrr.9
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 10:20:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=mwVTpg13SBC97f2USbPraM4nvtlLOXZnOp5nHcgdKwk=;
        b=iDVFEIboKz48l7nAn7SI0Ca2nN5G1tlfsOo9pJo9/wNhwOUQNPHHQVpMY4AMA/TP0n
         qyN/7a/4R3B/Y1HY2FpVPyf8MYEvm6ncAznwAgIVxPMCwpO2FoOKddPaZEV1pgUTc2C8
         omFjJ0prDl4y32iILeQlX4wmDxT/QZIgXw3pVLOvVjIojbu7odISWMuzP3H566cgj5MP
         /qJX8Aq0t6Fsl1YnAfr8rMDNRIjEx2qTInbLnVixTPH182i9BSaGd3iRcg/PSeniceFc
         ZeagI+ljxe7BdflsYcEKsFoOMY8iGow4EXLAqWesrWnkKyK51hxCDk54TGdtkMx4W5hv
         gS2g==
X-Gm-Message-State: APjAAAUAv3IwjGXDboTEJOMfMGxVspf4RVgV+d6F0WYInJHUihRUtkzP
	7XipZR7WYSmq/ERj0Qx0lBglaJj4NYZZb1cX0cOw0lEyAr7sgVnw6bMA2o+wSngYG9TvvuCuRrT
	JIYB8RvT/d4pWoQRuYmUVhtmitGTe33xG4tkLGWYi7JMVM66M3YqTI0dkWx3M/6hPKw==
X-Received: by 2002:a1c:4102:: with SMTP id o2mr2971975wma.91.1556040016002;
        Tue, 23 Apr 2019 10:20:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZ4ThxpSeRdOvkHqpHFjXlCVFs5+0OYE4YzpAQIHGMHQrspbdLeT+XnAwf+zcLq2VYrzjb
X-Received: by 2002:a1c:4102:: with SMTP id o2mr2971882wma.91.1556040014250;
        Tue, 23 Apr 2019 10:20:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556040014; cv=none;
        d=google.com; s=arc-20160816;
        b=zo/MCp42Obw9uMHcG5ND5HUTtqXx0n2Ll6ifJsvfPMdYdgyHLlV9gLhfv8+0sHt1Ym
         0cAVG7prIjtSsKIFaZ0nrkiGc98lTRdbJLa06qGVQQL8kF8LavQA37f7NZhbTut5YpuZ
         LqNRQ2PKT0pMa8tNYiHbp8HnOPPRMj+4191Q/Ch+gT6qtvATByeM3xRsRxg1Q0MU10HY
         v8j0KfTgTxY/hsUeyZxLIepG9nF5E/2yGX7svrAkLvYIF3mtP0zM0Svml/UWEotWjgT/
         svg2zfgfSQF9equN77fn6huqLnHYhgMUix8Z2OV4yQuJW760DSkBjFIr3ytJamCR//O7
         WhrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=mwVTpg13SBC97f2USbPraM4nvtlLOXZnOp5nHcgdKwk=;
        b=xy0we3wjgXm7gcmbIiUM3woC/7YvTJoIf6NjzwRW5PpEFKXQ/6JKlccHP9ZXaGUKwx
         Kx9xfOFKsPKbEGlxCXwW2E260M00DjokbxrNyDSh3qqKGQ2Bymy6oa924iFH/nqFU+eX
         L8L0E3Fm8OqtfdJ9fgNa2IzzOS811Dv0QM41/LcdsIi7RqoZySN+X5If2l6xgbRGDvyi
         /IBrTZKw102FK5+PehinLqeImbhwzRs4MQ8TgBr8Lvr+Hbc6tmI/yxFnbd62uhpQlQXb
         EptTWp+rUsIVA77Gu6gOuMoBo6sbuVSSeqkbHDwTuVYAJR9GL/kVU862fe7IS5u+lHqY
         vKeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=McGNaf3d;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id t1si11349506wrs.98.2019.04.23.10.20.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 10:20:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) client-ip=5.9.137.197;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=McGNaf3d;
       spf=pass (google.com: domain of bp@alien8.de designates 5.9.137.197 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2F10CC005966DC6E23F72562.dip0.t-ipconnect.de [IPv6:2003:ec:2f10:cc00:5966:dc6e:23f7:2562])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id DEF101EC0A7C;
	Tue, 23 Apr 2019 19:20:12 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1556040013;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=mwVTpg13SBC97f2USbPraM4nvtlLOXZnOp5nHcgdKwk=;
	b=McGNaf3dJr2pnuSgxKLdzHDiUmeuMU1w6Z9Q4i61m49AW2HPRaBzWB8EJBztU2o2umPz9H
	HwWZFqAdk5Ab8mSBFnzm96ATsTndVAZBVkf/zrEqMSvZhEmuePqwmEhTycRuvsqoFqm39D
	plTTzIQp0QPM2dINdzvM89Rx4KkUnDs=
Date: Tue, 23 Apr 2019 19:20:06 +0200
From: Borislav Petkov <bp@alien8.de>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jonathan Corbet <corbet@lwn.net>, Mike Snitzer <snitzer@redhat.com>,
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
	Andreas =?utf-8?Q?F=C3=A4rber?= <afaerber@suse.de>,
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
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	Russell King <linux@armlinux.org.uk>,
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
Message-ID: <20190423172006.GD16353@zn.tnic>
References: <cover.1555938375.git.mchehab+samsung@kernel.org>
 <cda57849a6462ccc72dcd360b30068ab6a1021c4.1555938376.git.mchehab+samsung@kernel.org>
 <20190423083135.GA11158@hirez.programming.kicks-ass.net>
 <20190423125519.GA7104@redhat.com>
 <20190423130132.GT4038@hirez.programming.kicks-ass.net>
 <20190423103053.07cf2149@lwn.net>
 <20190423171158.GG12232@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190423171158.GG12232@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 07:11:58PM +0200, Peter Zijlstra wrote:
> I know I'm an odd duck; but no. They're _less_ accessible for me, as
> both a reader and author. They look 'funny' when read as a text file
> (the only way it makes sense to read them; I spend 99% of my time on a
> computer looking at monospace text interfaces; mutt, vim and console, in
> that approximate order).

+1

It is probably fine to stare at them here
https://www.kernel.org/doc/html/latest/ and the end result is good
for showing them in browsers but after this conversion, it is
getting more and more painful to work with those files. For example,
Documentation/x86/x86_64/mm.txt we use a lot. I'd hate it if I had to go
sort out rest muck first just so that I can read it.

I think we can simply leave some text files be text files and be done
with it.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

