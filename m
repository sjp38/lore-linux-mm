Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D7BEC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 10:43:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D9592133D
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 10:43:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D9592133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B82046B0003; Thu, 23 May 2019 06:43:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B32266B0006; Thu, 23 May 2019 06:43:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F9B96B0007; Thu, 23 May 2019 06:43:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4FCC06B0003
	for <linux-mm@kvack.org>; Thu, 23 May 2019 06:43:08 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h12so8356958edl.23
        for <linux-mm@kvack.org>; Thu, 23 May 2019 03:43:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gU+3lqsoWF7Hzm+RBc+ukiaSDRZZ3u+etuBmqyigeJ4=;
        b=klAOomUSH5hwnAKvbQEQoOvznjVPZcTemb0NlOmWx5HVhfGlCrcGjSGkBE1K5olJ4A
         O7oIAKzhZNVc4LW2DUTaqGESa+/SoJbqJOG0OVYQ5j+W24xDnJGu0PUhO250i6XibxXn
         mbkgSzJe0mZzBHDpoDUb2efUhJqmOK9J063NdSaA8LvS2clykD0cPVB+gd9BIpTyrZ3d
         eG/9aMLDN/vhsCjKZGfAVdFqFtj5n4mZ9TJLlgmfCoTZp7C0/OF8Z+owyzJwcZVznjnD
         9H/KY94uIX+RsGkCpRBb2DQ6N5Pg0ieiiUbcbKu6pgWk0FV44GQQAKm/gyrgacIf0pUL
         dvMw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAWfJS/MQ7Y2QAL/4DFexgenVTz4lYOOi2UjpQhzRQsJPu4394mt
	i6Tn1TbOjP0P+WiT9ySzUFPAHnBWDbilliIY1q7btSogOeCaag63hc4K2W3mdNQVoE01ZZp4keQ
	F3LR0CFvpcs5nBJOGVjspmL6/jNwMRZwrVLhm83tYg+/9rgX3VF3+iL9r2clVnS1Znw==
X-Received: by 2002:a17:906:7cd2:: with SMTP id h18mr39227665ejp.267.1558608187878;
        Thu, 23 May 2019 03:43:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPh2HltUT4lm9sf+qyA32hJkRdTLCb30Ats66oFswcAcFBKvdMbQUQqGNIF/k0vW2kl3ZW
X-Received: by 2002:a17:906:7cd2:: with SMTP id h18mr39227582ejp.267.1558608186846;
        Thu, 23 May 2019 03:43:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558608186; cv=none;
        d=google.com; s=arc-20160816;
        b=QT68nie1M0liX9K2DPE6RQPn0yIy0VNRCM7o+dnUPXW/7luzxt9ZT5U9g8+IurboWL
         zlkv1KAcPUro6IIrJcKDda4YqGgt9KuWb4geDVQkkvucdjQv+7yGOYqATob6M1V3+wN0
         AQDZ9tnUNHZgGXoik6EDQW3sb7cLvadCOiQ7TiyoR0swlMykyo5bnLDDFDKSsozMqeOB
         XjG2+LtQ0c9lUHG5NadLnUSWgqQdoUC1SkQQ1ueMIq+ptAjkM6DXeYSmi51Lw8e1t/8g
         BURKK+WPEDap4s8sJlPo5Hr9XwS9uleURndgHZiCtmCmO9KUr/unXEkVKQYvtWepxaIx
         /PgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gU+3lqsoWF7Hzm+RBc+ukiaSDRZZ3u+etuBmqyigeJ4=;
        b=tooe3swxOShAvPDwI6V9laUONRR7wlKcz0EtgUMjJHo1EaaTdhct2J5JFEH+OKCdCa
         uBjFrX6la+wxvo67fAyTWwHRAF4DhNZ11jCjtnSkX1kg9OjNac15xitwl52GZ+Jh5osD
         yXxl8rSRANZhGqknSvXy8ppqV3MFYgEOdsAMEELa9jHeymXaEezWCEUbpEWUR2ZvNZkw
         9g4HkA9xvf9U4jkNZUIaqRK7eQRj24ZOqicyQOyjYOS+moL1e1/+VaWtZk+Zpw5ggtuA
         jq0T36OaXMWoTMck2GY+NUgYb5z5QtDEvVU3Rd2G1+4NDAmF/N1X2xZsfsPgBct5y1Jl
         ECCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h36si2833206edb.397.2019.05.23.03.43.06
        for <linux-mm@kvack.org>;
        Thu, 23 May 2019 03:43:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 84A77341;
	Thu, 23 May 2019 03:43:05 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C9A023F718;
	Thu, 23 May 2019 03:42:59 -0700 (PDT)
Date: Thu, 23 May 2019 11:42:57 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
	Christian Koenig <Christian.Koenig@amd.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, Lee Smith <Lee.Smith@arm.com>,
	linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, linux-arm-kernel@lists.infradead.org,
	Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	linux-kernel@vger.kernel.org,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
Message-ID: <20190523104256.GX28398@e103592.cambridge.arm.com>
References: <cover.1557160186.git.andreyknvl@google.com>
 <20190517144931.GA56186@arrakis.emea.arm.com>
 <20190521184856.GC2922@ziepe.ca>
 <20190522134925.GV28398@e103592.cambridge.arm.com>
 <20190523002052.GF15389@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190523002052.GF15389@ziepe.ca>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 09:20:52PM -0300, Jason Gunthorpe wrote:
> On Wed, May 22, 2019 at 02:49:28PM +0100, Dave Martin wrote:
> > On Tue, May 21, 2019 at 03:48:56PM -0300, Jason Gunthorpe wrote:
> > > On Fri, May 17, 2019 at 03:49:31PM +0100, Catalin Marinas wrote:
> > > 
> > > > The tagged pointers (whether hwasan or MTE) should ideally be a
> > > > transparent feature for the application writer but I don't think we can
> > > > solve it entirely and make it seamless for the multitude of ioctls().
> > > > I'd say you only opt in to such feature if you know what you are doing
> > > > and the user code takes care of specific cases like ioctl(), hence the
> > > > prctl() proposal even for the hwasan.
> > > 
> > > I'm not sure such a dire view is warrented.. 
> > > 
> > > The ioctl situation is not so bad, other than a few special cases,
> > > most drivers just take a 'void __user *' and pass it as an argument to
> > > some function that accepts a 'void __user *'. sparse et al verify
> > > this. 
> > > 
> > > As long as the core functions do the right thing the drivers will be
> > > OK.
> > > 
> > > The only place things get dicy is if someone casts to unsigned long
> > > (ie for vma work) but I think that reflects that our driver facing
> > > APIs for VMAs are compatible with static analysis (ie I have no
> > > earthly idea why get_user_pages() accepts an unsigned long), not that
> > > this is too hard.
> > 
> > If multiple people will care about this, perhaps we should try to
> > annotate types more explicitly in SYSCALL_DEFINEx() and ABI data
> > structures.
> > 
> > For example, we could have a couple of mutually exclusive modifiers
> > 
> > T __object *
> > T __vaddr * (or U __vaddr)
> > 
> > In the first case the pointer points to an object (in the C sense)
> > that the call may dereference but not use for any other purpose.
> 
> How would you use these two differently?
> 
> So far the kernel has worked that __user should tag any pointer that
> is from userspace and then you can't do anything with it until you
> transform it into a kernel something

Ultimately it would be good to disallow casting __object pointers execpt
to compatible __object pointer types, and to make get_user etc. demand
__object.

__vaddr pointers / addresses would be freely castable, but not to
__object and so would not be dereferenceable even indirectly.

Or that's the general idea.  Figuring out a sane set of rules that we
could actually check / enforce would require a bit of work.

(Whether the __vaddr base type is a pointer or an integer type is
probably moot, due to the restrictions we would place on the use of
these anyway.)

> > to tell static analysers the real type of pointers smuggled through
> > UAPI disguised as other types (*cough* KVM, etc.)
> 
> Yes, that would help alot, we often have to pass pointers through a
> u64 in the uAPI, and there is no static checker support to make sure
> they are run through the u64_to_user_ptr() helper.

Agreed.

Cheers
---Dave

