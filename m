Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BA64C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 12:12:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E99720645
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 12:12:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E99720645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F12F76B000C; Wed, 29 May 2019 08:12:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC29B6B000D; Wed, 29 May 2019 08:12:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8B456B000E; Wed, 29 May 2019 08:12:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 885676B000C
	for <linux-mm@kvack.org>; Wed, 29 May 2019 08:12:38 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h2so3149490edi.13
        for <linux-mm@kvack.org>; Wed, 29 May 2019 05:12:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/Wuhn5LqusNy/UN1Lqdyf/phpVe4JSLD1UQTmNYzIPw=;
        b=Zo5g10+rMO03x+GA+98Imj3RB3hm5uDNTsPHUA00dpJ5yECNEBphvJJwQOnNOpbHjY
         CZT2xQCPYeJY7otqr/pUb+Qho1TmcrBumfSATvy6lq8nhaEhGzIkuqjKhjiBdA7H8BAP
         Jk1DpyzeN85LFougnZ/O9o41MWUmQY2HikYCxvy5D6Pu1HsbuEbYlyPlI7jAo/tj/kEp
         Kdys3AsapADJVYqjf3unWfykW2bfdX5WfHN8XO+u9wra2HHB643TlGkm0hfA723aZffE
         vPBYh8GKNAGsMU8+N7w+pED6XBxdKQoeI2bJwSzlLryypTSyoBk8sDOCP55OIWSbRrNY
         uw3g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUcFULMoIboZyDCjqAu8nFsCHn54xKJjsteXzKOOPimYpUCyGz5
	Dy5H+TJk83M5gRt48xm7ooHedKXOQw5TXwlOUgPfYTPb+Y8k3v6k4U8xoxd3LoJJK6maIPLVrXS
	rqc/8aFFTw+70/forT35iVEeTZzPZyGwdT7BK6QJQAG9OvdcgCDDhHXYZr4AtEJHUeQ==
X-Received: by 2002:a17:906:4414:: with SMTP id x20mr2820953ejo.199.1559131957968;
        Wed, 29 May 2019 05:12:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIh5SlAtFtJAPYrWphP78DyUIvq4gdKdEEl/QpmwsZJRo1okxt4BPQ4WfBRVsj/lA9QDrz
X-Received: by 2002:a17:906:4414:: with SMTP id x20mr2820785ejo.199.1559131956073;
        Wed, 29 May 2019 05:12:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559131956; cv=none;
        d=google.com; s=arc-20160816;
        b=f3oUoBtSca5W0Y6EX8un/hrP+pS8UR4o/m+CQp1+ym9a1aXhjpJUYPDJXC9i3zl8i6
         UF/hF6yPWeGfej2BRmTo2bp8RMRhjRBvSy+qGGHSlJ55HJVhliAE4um9vdEecIYvnImH
         xzDYNRj66CXb2Jk+W9eqJH0KHu0qPDUJQ5BDFf9ygpM2ktD36X7+E7HOkZKYd1n8hGm+
         r+sHFQXCN2opjxm0mgzs+JrStU/XDWG5t8u9x/3TV9N0/tZTQGF86NQVdfKWjd5BA1l/
         7BKFb+VbbwLEJVXmjaUl7+rO2GDD8ovbNu6P9LcOg4fbj4QYgJtfq/EXzN88TBIBikRh
         2WVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/Wuhn5LqusNy/UN1Lqdyf/phpVe4JSLD1UQTmNYzIPw=;
        b=PwKs4nUrWq61MU/2XMjREiTK7BNf6i4f2tzewtTneixi8/ZoAkvsaMUQdIAHCNt60r
         mo5H6F20oXbfEajD6L6tzePvhFDXlSTO2CrjIwGSyFdFqRLedMeEll4Voh+AyH9n//UH
         nhaJWaeWtc00r6BUf4xC9j+6mwUn3Y0/dQ/iL04wVyU8xX8X4swVAJ7XwkgtZ7bxmvEX
         X1k9BfyRKrCkTzc0nlufJ1sSnjIGsiKgZVCKF+tz+wVyyM2epmypy6GWwhBAh8sJRIqE
         a6svt1xAw0ZNfBbmipp0W9++1JnhjjF4CIWMgeIPSlYaihgGpEdG0iqrvsIQjbSumpf3
         x48w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y16si2679549ejo.172.2019.05.29.05.12.35
        for <linux-mm@kvack.org>;
        Wed, 29 May 2019 05:12:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id DDBEE80D;
	Wed, 29 May 2019 05:12:34 -0700 (PDT)
Received: from mbp (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 9733C3F59C;
	Wed, 29 May 2019 05:12:28 -0700 (PDT)
Date: Wed, 29 May 2019 13:12:25 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Kees Cook <keescook@chromium.org>,
	Evgenii Stepanov <eugenis@google.com>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
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
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Elliott Hughes <enh@google.com>,
	Khalid Aziz <khalid.aziz@oracle.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
Message-ID: <20190529121225.q2zjgurxqnohvmkg@mbp>
References: <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
 <20190521182932.sm4vxweuwo5ermyd@mbp>
 <201905211633.6C0BF0C2@keescook>
 <6049844a-65f5-f513-5b58-7141588fef2b@oracle.com>
 <20190523201105.oifkksus4rzcwqt4@mbp>
 <ffe58af3-7c70-d559-69f6-1f6ebcb0fec6@oracle.com>
 <20190524101139.36yre4af22bkvatx@mbp>
 <c6dd53d8-142b-3d8d-6a40-d21c5ee9d272@oracle.com>
 <CAAeHK+yAUsZWhp6xPAbWewX5Nbw+-G3svUyPmhXu5MVeEDKYvA@mail.gmail.com>
 <20190529061126.GA18124@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190529061126.GA18124@infradead.org>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 11:11:26PM -0700, Christoph Hellwig wrote:
> On Tue, May 28, 2019 at 04:14:45PM +0200, Andrey Konovalov wrote:
> > Thanks for a lot of valuable input! I've read through all the replies
> > and got somewhat lost. What are the changes I need to do to this
> > series?
> > 
> > 1. Should I move untagging for memory syscalls back to the generic
> > code so other arches would make use of it as well, or should I keep
> > the arm64 specific memory syscalls wrappers and address the comments
> > on that patch?
> 
> It absolutely needs to move to common code.  Having arch code leads
> to pointless (often unintentional) semantic difference between
> architectures, and lots of boilerplate code.

That's fine by me as long as we agree on the semantics (which shouldn't
be hard; Khalid already following up). We should probably also move the
proposed ABI document [1] into a common place (or part of since we'll
have arm64-specifics like prctl() calls to explicitly opt in to memory
tagging).

[1] https://lore.kernel.org/lkml/20190318163533.26838-1-vincenzo.frascino@arm.com/T/#u

-- 
Catalin

