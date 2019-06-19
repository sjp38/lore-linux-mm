Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26F3FC31E5E
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 15:29:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECF752189E
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 15:29:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECF752189E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84B6F6B0006; Wed, 19 Jun 2019 11:29:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FC6B8E0002; Wed, 19 Jun 2019 11:29:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C4728E0001; Wed, 19 Jun 2019 11:29:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 232716B0006
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 11:29:48 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y24so26682579edb.1
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 08:29:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=eKGn5LLcBuT3iCgZhbQ3TYpAv9mS7PjvVGzmeyR21gE=;
        b=CB54OQ9/Ex2OErfMJm1E4hTep/8o81wjWjK0Z/dFTYFOxkveK4K6sOBIlEvSWJQRXO
         FwyKrUpi5KO8K2MaaaXOosIR+DqDGZ68xHgNFe2/eRO2BZOhwNWm2yX/ZQjeHNZwXG3i
         mnCAjFO3crEe/uV0/ttGDFfj0nfytP7JuY3VqHFY3HBNOid5Xt7Pn98CDbx9G1dLznBw
         jvWgpGqe389BTmvptfndTE0/3FPgM4h/JS/5lZvxl/0Qocu1Yl5UwKfGLmcwcoFs8HO+
         X1PDF2WR4OVxkO8xNLr3xDRTT/EcrV2MR0YeKxOyahUo+pz7p3LhPHyi4M52MRxWzq4Q
         6EOQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAVREIrqsesznwpAULGEYu257s1d+ZDd4f1+s/aZYnxiSArkwFgP
	vWcq+Ml06culZy3KEZKgaJG1AihB0Af6gwlWhqJzfbI1LxXw6FlKvTJ2rTNRkkuu/EaVeLVdtT5
	8aBCD/QbK539DwfKzP5ZZYH8oY8qInHn6aGAiSCG3HuBA3An39rSeZ7k+XeavsTg2ZA==
X-Received: by 2002:a50:a56d:: with SMTP id z42mr113535782edb.241.1560958187728;
        Wed, 19 Jun 2019 08:29:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwaf+GTnpzJvzLmgK9jWyL/fWgl/Vt++U/0AjMb2cbS89UrKYn8a3RhoiOnhI9I1KLkzZeL
X-Received: by 2002:a50:a56d:: with SMTP id z42mr113535701edb.241.1560958186950;
        Wed, 19 Jun 2019 08:29:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560958186; cv=none;
        d=google.com; s=arc-20160816;
        b=sCPM3qWR1k9TRZI4hEOpdA2XUimypjeAPzmx9T7E+8eNzJ32saMzxdkSm6/su1MLJr
         g/JXF3Jwr1RiIkyjT+YXfc4pdMklwbiOkHJAghCnQdP1QUqX75uI+b3ToDw1to3pBACM
         WPxdkTWRGHFB8/PQD3+P2TsW0GuCeEOv87noCY8Lpykl5HJ2/dXQUog6Zhx+eMcmq4we
         86QTgXoDns/mIdnq5GwLNUwZs47ayo412FphuoyxTsUh0JNgA//JFq6HGgFodVfNcx9A
         klQm9IWjMCklDVgt4L1X8+FOiYe260p9+Vj5UuT+zk42wZheQg2s5uSx+IRbIeJw11gY
         HJaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=eKGn5LLcBuT3iCgZhbQ3TYpAv9mS7PjvVGzmeyR21gE=;
        b=MCcgnuh70gl26O4si6xojzHevATdY5qyf8EKeS7nQi/nsDuBe/Ar5iHemvVtwmVv2c
         GeFzOIhp5YiTZc6AxmlDRZDKOHRr/ycT1fxfmYFyACsXX2o/iVAQEdDcCQFe9qNKE8U/
         Fi8wlJaOJepp8QgRX2S574PEZtCAedpm0Y7xWPXxJeJSKJT8aCEd7Vk6aYyMwBH3L9Fc
         qSIu4IcXnYSnVp/+U5SSqXg1UAbh/W/xdk3MthvqNWBXR8aF74GesKfgxNOJQFfsLo5I
         xowx/AxdBU57c6huh5wThAxEoLTMefHopzBkyLIN0PLLWckAfY97+FLlkT/oKQOhCnw8
         NsYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id z11si13167397edh.378.2019.06.19.08.29.46
        for <linux-mm@kvack.org>;
        Wed, 19 Jun 2019 08:29:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EF1DA344;
	Wed, 19 Jun 2019 08:29:45 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 4E94C3F246;
	Wed, 19 Jun 2019 08:29:41 -0700 (PDT)
Date: Wed, 19 Jun 2019 16:29:39 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v17 03/15] arm64: Introduce prctl() options to control
 the tagged user addresses ABI
Message-ID: <20190619152938.GD25211@arrakis.emea.arm.com>
References: <cover.1560339705.git.andreyknvl@google.com>
 <a7a2933bea5fe57e504891b7eec7e9432e5e1c1a.1560339705.git.andreyknvl@google.com>
 <CAAeHK+xvtqALY9DESF048mR17Po=W++QwWOUOOeSXKgriVTC-w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+xvtqALY9DESF048mR17Po=W++QwWOUOOeSXKgriVTC-w@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 04:45:02PM +0200, Andrey Konovalov wrote:
> On Wed, Jun 12, 2019 at 1:43 PM Andrey Konovalov <andreyknvl@google.com> wrote:
> > From: Catalin Marinas <catalin.marinas@arm.com>
> >
> > It is not desirable to relax the ABI to allow tagged user addresses into
> > the kernel indiscriminately. This patch introduces a prctl() interface
> > for enabling or disabling the tagged ABI with a global sysctl control
> > for preventing applications from enabling the relaxed ABI (meant for
> > testing user-space prctl() return error checking without reconfiguring
> > the kernel). The ABI properties are inherited by threads of the same
> > application and fork()'ed children but cleared on execve().
> >
> > The PR_SET_TAGGED_ADDR_CTRL will be expanded in the future to handle
> > MTE-specific settings like imprecise vs precise exceptions.
> >
> > Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> 
> Catalin, would you like to do the requested changes to this patch
> yourself and send it to me or should I do that?

I'll send you an updated version this week.

-- 
Catalin

