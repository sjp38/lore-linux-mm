Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3981C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 00:20:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 816382089E
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 00:20:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="b1PxbkXj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 816382089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 367136B0003; Wed, 22 May 2019 20:20:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F15B6B0006; Wed, 22 May 2019 20:20:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16C216B0007; Wed, 22 May 2019 20:20:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id E669B6B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 20:20:55 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id l37so3776958qtc.8
        for <linux-mm@kvack.org>; Wed, 22 May 2019 17:20:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=kja4wR6FLtasYFQS1xUbhik8iG88bHuMFvf2ArrK0nw=;
        b=b7FANHgCY9qRPmaeZzcHf7G0FQM0GhGlnw1/ICJCLoxJW5nX3jGmHdCa+rFV6iBFP/
         zrQFWRH7nVCxnQOh+LqszxPacQWmjuxvkpIcgjbgrRWXautaxAF7Q2Zrk+C3PF39Qpyq
         wenJg/NF759+dfkq1XiCULuak38xYuL0sW3eUGWQxERjHuNFqhO8sjo8QyAHZU7CobPh
         gm9zKKXfGsw4EfjyL63grLZ9HrK2DIkscCza+0hUYM1AVZdX2ev2k3LWFNrk79K4EAsV
         5GbTp62+iXELVMJSPh4JODjMpmGAZ4c5rq6yolEbmAOW+bS5coUS6MNRIONNGwAqpKs6
         hbkw==
X-Gm-Message-State: APjAAAXZw/puWm4In6ucEUL40kSsFc061FNjcq8iRC2K7ZYULI1lxo5h
	wjBH1Ai07RP76a3EzrQelEnwe25XzG3SGZQKoaHKS7IFiBtfJl4nv29PDYAk7qq2+lRqqqhSgm9
	KievTXP7XaZgABoVq7LPT/3WvisIy72DOEo7gC0hR5p6BB67TURhWu//XGhToprrJNw==
X-Received: by 2002:ac8:5519:: with SMTP id j25mr27888051qtq.131.1558570855678;
        Wed, 22 May 2019 17:20:55 -0700 (PDT)
X-Received: by 2002:ac8:5519:: with SMTP id j25mr27887985qtq.131.1558570854881;
        Wed, 22 May 2019 17:20:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558570854; cv=none;
        d=google.com; s=arc-20160816;
        b=pH+0gkT/uqb5dz9kse56JvhxsY6dz6yVRACoFaMOXpTaXDeMeQy0h9+advOe5ftm6l
         punHqKFRukaSlal+BQT8oRlMa//t+4l5hg3byeH7+wWoinKZs4Jx+7wGpk72+Uws8nlp
         /15pi3lZKyn1F5MNr+jrSOsCMyO9YYeM9nEGaqs0++jFRGKKgOhFI7UcokP9vnTasHp2
         QHzFQAtOj2NX0QuIASzCujtHE9f4KN/0Ki1RRt/H5IPjwhTNCoA4hn5xT9VmuTbUVIPU
         a8ZL4hiKJGOCwXZ5/NQj6vnW0B9EKjbTTHo4k1jUw3okGXyOSjb/qR66j1r1JWpM72Hf
         6vFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=kja4wR6FLtasYFQS1xUbhik8iG88bHuMFvf2ArrK0nw=;
        b=npaysgMTOmldWFX1jMQdPzm/DTemdUqoq5zcVt1wHdLES2vHUOWR+aHKZr9T/1PKQe
         EvYPg2PG6TxC0pHwcRrwe22oOZ0SeZfvwAA5fWaWWgBpEc+oSiqrV4P4yRkKSHaByPt7
         HR3nwCsyD9J5irvtFv65lpd0AHMkvrZf0IJpOhdiKd4DUINIWsmtahyCKAEJnC/Bp6PS
         dNrD0shWkLvmWK3qJwtT/Nysu/XTrIXogA6Q0mhCYodRReox8kIkeho5UrZwnrXuv+p9
         vz8RXhGIVPKbvkAVc53nOsGSf7ZUjIDI+s9L09qe1Dzc7CmJfavqxCAt4W9X6bm5ZuOz
         hDoA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=b1PxbkXj;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z14sor18749193qtj.36.2019.05.22.17.20.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 17:20:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=b1PxbkXj;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=kja4wR6FLtasYFQS1xUbhik8iG88bHuMFvf2ArrK0nw=;
        b=b1PxbkXji6rxJkxXzX+E8hmtsDc4EAG6spndGBpqTY6Mtd1Z82qmKG7IFdzEDWmzKK
         cpfPgmFkndIKUtDn3lZmf4ZAYcKRjit4YkqMU72A44nfyHayfu0+OGxh9SgysS/YRAv2
         RDEnuh2qly9nvvswbClZIbFXuZCzwJj2KYSwWCU/YgJUugR9fRVuJUTKIe2+8zLwiPOj
         anBDeIuRaK3lpaZn56KojfHXM/H6EWmNRZuecl/6erGrJ5dc4+VdWT4yxUQf8Rpv9nUY
         hRDkUmUo3tTzvQuC1Vf8iYC9BBrTle8EWAWahcABrO+2gaF43DLowx5aiqsiUBpSVZlJ
         7EAg==
X-Google-Smtp-Source: APXvYqwzvo9H/aW7qSfx2OQVIHnUtdd1Cyzpi6J44RNo2JLbDhDXh7kfDH2OJy33sD2sQGXynL6VQQ==
X-Received: by 2002:ac8:f71:: with SMTP id l46mr70609860qtk.321.1558570854263;
        Wed, 22 May 2019 17:20:54 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id t30sm15637238qtc.80.2019.05.22.17.20.53
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 22 May 2019 17:20:53 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hTbTZ-0001Zh-03; Wed, 22 May 2019 21:20:53 -0300
Date: Wed, 22 May 2019 21:20:52 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Dave Martin <Dave.Martin@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Will Deacon <will.deacon@arm.com>, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, linux-kselftest@vger.kernel.org,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, Dmitry Vyukov <dvyukov@google.com>,
	Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	linux-arm-kernel@lists.infradead.org,
	Kostya Serebryany <kcc@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>, linux-kernel@vger.kernel.org,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
Message-ID: <20190523002052.GF15389@ziepe.ca>
References: <cover.1557160186.git.andreyknvl@google.com>
 <20190517144931.GA56186@arrakis.emea.arm.com>
 <20190521184856.GC2922@ziepe.ca>
 <20190522134925.GV28398@e103592.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190522134925.GV28398@e103592.cambridge.arm.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 02:49:28PM +0100, Dave Martin wrote:
> On Tue, May 21, 2019 at 03:48:56PM -0300, Jason Gunthorpe wrote:
> > On Fri, May 17, 2019 at 03:49:31PM +0100, Catalin Marinas wrote:
> > 
> > > The tagged pointers (whether hwasan or MTE) should ideally be a
> > > transparent feature for the application writer but I don't think we can
> > > solve it entirely and make it seamless for the multitude of ioctls().
> > > I'd say you only opt in to such feature if you know what you are doing
> > > and the user code takes care of specific cases like ioctl(), hence the
> > > prctl() proposal even for the hwasan.
> > 
> > I'm not sure such a dire view is warrented.. 
> > 
> > The ioctl situation is not so bad, other than a few special cases,
> > most drivers just take a 'void __user *' and pass it as an argument to
> > some function that accepts a 'void __user *'. sparse et al verify
> > this. 
> > 
> > As long as the core functions do the right thing the drivers will be
> > OK.
> > 
> > The only place things get dicy is if someone casts to unsigned long
> > (ie for vma work) but I think that reflects that our driver facing
> > APIs for VMAs are compatible with static analysis (ie I have no
> > earthly idea why get_user_pages() accepts an unsigned long), not that
> > this is too hard.
> 
> If multiple people will care about this, perhaps we should try to
> annotate types more explicitly in SYSCALL_DEFINEx() and ABI data
> structures.
> 
> For example, we could have a couple of mutually exclusive modifiers
> 
> T __object *
> T __vaddr * (or U __vaddr)
> 
> In the first case the pointer points to an object (in the C sense)
> that the call may dereference but not use for any other purpose.

How would you use these two differently?

So far the kernel has worked that __user should tag any pointer that
is from userspace and then you can't do anything with it until you
transform it into a kernel something

> to tell static analysers the real type of pointers smuggled through
> UAPI disguised as other types (*cough* KVM, etc.)

Yes, that would help alot, we often have to pass pointers through a
u64 in the uAPI, and there is no static checker support to make sure
they are run through the u64_to_user_ptr() helper.

Jason

