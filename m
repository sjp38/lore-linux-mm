Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF1A0C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:31:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9EABE217D9
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 16:31:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9EABE217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lwn.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EE886B000A; Tue, 23 Apr 2019 12:31:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29E446B000C; Tue, 23 Apr 2019 12:31:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 118CB6B000D; Tue, 23 Apr 2019 12:31:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C8C186B000A
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:31:23 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s22so10654312plq.1
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:31:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=mJbG0Lrs3tIzOF1o3QpW56PWhl0dYmYu/GLcncNgKi4=;
        b=MJR0TLbKjH7XygvjVpD332MZ/2q5DbkCxmbj3f6K0/NIVnzevmsxlv9tcufe9E7PD4
         Prt6DhqXJGK9ihcaih9//BgHZKbwAdTsPHZhrgHNjd7MuiqyRHmt5GP3WvAnJflgP6Gw
         uc+Db3dyCshopZXqLxxMFZCRLrcDH/hqlAFKgE1hvf2seEMKZ6bqTypkTsIRcrXNOR45
         oY8aLet/0xro+3jjykf4QMnNRRj7SXO2Hc4wr0F1oi1a7bM+YqwBQelv8txSQYAaf3fU
         Qrlp0xT6x0/e+PgqR69t8LIBtYJfT/HH6kw5RXNDcdynWPLnnDxL/XsVrvPM5hyfH1kZ
         zfbQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
X-Gm-Message-State: APjAAAUhxDsWKyrRSrf08pvd8bDKy5Ru9/C0F4YMYLA6F18U1UKtNlG7
	FphK9vJyTOxD2KyLarg/e3/cfZc0q7kmsJZGcZum6iZXxy8WGkRKkXUYKwllz8FzZagx2vCW9aL
	qeGkc+fASY5bMtSk8/BIWcKRnc4dZJIXJkHIhHwrhNDOrAW8ZrM0VWQj0jhvUOKWykw==
X-Received: by 2002:a17:902:3324:: with SMTP id a33mr27266218plc.186.1556037083485;
        Tue, 23 Apr 2019 09:31:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCvJiOk+9OxMKXyzxO2qd+ta4o81AmHQt7O+f6r1XoxBhAFCs48nYQjIvRsy6jrt5yXS4A
X-Received: by 2002:a17:902:3324:: with SMTP id a33mr27266132plc.186.1556037082593;
        Tue, 23 Apr 2019 09:31:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556037082; cv=none;
        d=google.com; s=arc-20160816;
        b=A5Z+9AEcebY5otSSpixy0r4T8gVagTtozaJc7t/ijmG4fr2UChISZpoHhcBW7LOP8b
         AEzznkqclgOB4ij9rqAPw7ma1P8nNutVYydzuWdnH+fwqITaQN1drS4nhohQhzjdzjgw
         aVEErpAMvkvM23mkAaHTMj3ruNPsqUMI97qf5KNXHTsyFAA9ciqdvwVZ7CpEnL7uE7M8
         sIwdDQF0TjNRgkaqP/VxuH9rQogFtvJr3/rmrv8nI5Eex3GwgzdawdfwFGdErJj/7U0X
         5gXq7QBQP2WK3z+oUXMcoUr+YRW1zPSdwbpAox2yhNf//hEvj63iXFRgRILIIpJXS7zo
         cZfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=mJbG0Lrs3tIzOF1o3QpW56PWhl0dYmYu/GLcncNgKi4=;
        b=NESnLh7JJt1U3Iy+S1u33FLHsXHU1CwN9QIObnkXDuRzo4n4L8ElbvAxsqjSnwhGiK
         JQbf8PBky9Ejbc8tPwbNpz4lCKNpNwPfL+duteey9GyoUHPkV60us9yFKFfCSZ23nDv+
         nIfKLgKH0Sc9kQ5qbnWey9yvDv6sYHdu7cvhfb6A25uauvcP6BxdyTUPFKeQAwfXRPsu
         lcwoBpVSBxByekB+XFrsX8CWUZXwv8G7h1Cwusafpb1f/4eywPbSk/EOkYimdhbhmc72
         alzxBaMLsiJP794cQUCpRxCmUM4uYONV8Opjs5Gh8e/nzkWBYT1QRHdSif3zGRGKYCYu
         vIIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id z2si14888897pgp.239.2019.04.23.09.31.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 09:31:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) client-ip=45.79.88.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of corbet@lwn.net designates 45.79.88.28 as permitted sender) smtp.mailfrom=corbet@lwn.net
Received: from localhost.localdomain (localhost [127.0.0.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by ms.lwn.net (Postfix) with ESMTPSA id 448882DD;
	Tue, 23 Apr 2019 16:30:57 +0000 (UTC)
Date: Tue, 23 Apr 2019 10:30:53 -0600
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
Message-ID: <20190423103053.07cf2149@lwn.net>
In-Reply-To: <20190423130132.GT4038@hirez.programming.kicks-ass.net>
References: <cover.1555938375.git.mchehab+samsung@kernel.org>
	<cda57849a6462ccc72dcd360b30068ab6a1021c4.1555938376.git.mchehab+samsung@kernel.org>
	<20190423083135.GA11158@hirez.programming.kicks-ass.net>
	<20190423125519.GA7104@redhat.com>
	<20190423130132.GT4038@hirez.programming.kicks-ass.net>
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

On Tue, 23 Apr 2019 15:01:32 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> But yes, I have 0 motivation to learn or abide by rst. It simply doesn't
> give me anything in return. There is no upside, only worse text files :/

So I believe it gives even you one thing in return: documentation that is
more accessible for both readers and authors.  More readable docs should
lead to more educated developers who understand the code better.  More
writable docs will bring more people in to help to improve them.  The
former effect has been reported in the GPU community, where they say that
the quality of submissions has improved along with the docs.  The latter
can be observed in the increased number of people working on the docs
overall, something that Linus noted in the 5.1-rc1 announcement.

Hopefully that's worth something :)

Thanks,

jon

