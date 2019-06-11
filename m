Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29AAAC0650E
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 17:44:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3AC220866
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 17:44:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3AC220866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B6826B0010; Tue, 11 Jun 2019 13:44:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63FAE6B0269; Tue, 11 Jun 2019 13:44:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BC156B026B; Tue, 11 Jun 2019 13:44:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EE5F66B0010
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 13:44:57 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id a5so12390817edx.12
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 10:44:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=hDMtzQnuIhuxMRF6VO99xFt+vo02AZ9hmHv493acrYs=;
        b=W+4yBu0a9iP197vG2Qdq6Xbo+kdOwQZkIDUzcJrRHi24nXiSYRJQYWh4s7tcA9+fYQ
         dsHZQHcrviqADUP+wVhyw2bei4qIGhb1a/uJ7+QWtaekG0N/a1lBfaSqfd+evUP4GmVr
         Yuv/Nb5GW2u3E7XJbVXveAKtm1+IRCbkXMNYcKdsGFZ5dXiO7dmmKGV1l1RP8kRCIFt9
         AJCQ23ZEOddfAYtEeiEpvSf6XLLxbpVJwc65v4U7S5JTBLwGXVkoHrl11d64hmRfEfEf
         UxAkCKkneC9ll+LJdP/eADzEtbmtPfIkcym7V+m5lTFvRAxHyzPFc/p7za7eOB9gWAVo
         CGew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWm14NWJ78X8Uuteaj7MGeB123LAGomCFkl+I4rJccckAYd+n8q
	Uh6vF3NVlAsveuJvINevCvbifH/n8Mq7WbqhMEunzn0F3o3HRs7GNA4/RneFAxTmo63CKj2SQEp
	+MQeX2/i/ne2I0sSKc8DqYKB96ToyqVW2LinAV9ifORdJvzA2cAPoOk0n8+gdAOPwLw==
X-Received: by 2002:a50:b665:: with SMTP id c34mr85654780ede.148.1560275097568;
        Tue, 11 Jun 2019 10:44:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxq5AoGM2ivmDJJ/C5lUAgJgHxyddaRUfK6JPASL76Kst3CXEBu94XBoHJvRnkXNlMTynpj
X-Received: by 2002:a50:b665:: with SMTP id c34mr85654720ede.148.1560275096856;
        Tue, 11 Jun 2019 10:44:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560275096; cv=none;
        d=google.com; s=arc-20160816;
        b=C3iZ8VdXsCR/R7jVet5H/dRma3KM1sHjnDtCCok9TusBOQ7UTqZLKUNzi0iUmF9kIT
         lA75OdH5uAuJ8bUZ/0juCQhgkGqTgbe7xCDTpVeRkWEITNy8414VrpkDF4zVWrjvPtND
         4mhlKu8y5Aqa0q3aSGLTlQOEh+WVVSfNNludQTJXaKUmdiPoASZ+QxHCOUfu/+4KBY+D
         B2vi2YcDq1BmWeqiLZP/ZoDcCfZ+48s0gs8LZEN4CV3eGpPwUmikecNIFKH0WMtwh0mE
         NpQEKFLAPwM5mdSnsmiURwpQLlOxF1vIz71znoqtdF5MwQrPljijM5ZxF7KcoLdY8bX8
         DMMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=hDMtzQnuIhuxMRF6VO99xFt+vo02AZ9hmHv493acrYs=;
        b=jxXngxnCdHsEEGZWFaYMDUyQgdssDiDXCMHp5FPLnlSID9/qvJmQjEGwYjKmme5O6y
         3NZwqL/i/KwyjRZKtg+Iqxn59udQSPC2652wjXvj2UdSQJyDnvdXWyPgeFtvfc/jaPtk
         XgLFDNoVHjOFeFF0tJ1LDxz1pBb0eZxbd0baISygY7C0iQ60oGy8DsW7rRf1+IsTVMtW
         1s91L5OSSnOOF2ee8+58hJWNdTtu10ZuaEfRmmBaPYlZOkCcUK1Wfu0NoDbnixFDeAdf
         K1stlIHVrybcsKn+V8pR1zXJjboP7sa/OP2h1KHZC1W3E/1t7M6U2DqEjzDzke5vflsq
         L2sw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id n23si8285173edn.48.2019.06.11.10.44.56
        for <linux-mm@kvack.org>;
        Tue, 11 Jun 2019 10:44:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EFAB0337;
	Tue, 11 Jun 2019 10:44:55 -0700 (PDT)
Received: from mbp (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id CF5C63F73C;
	Tue, 11 Jun 2019 10:44:50 -0700 (PDT)
Date: Tue, 11 Jun 2019 18:44:48 +0100
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
Subject: Re: [PATCH v16 05/16] arm64: untag user pointers passed to memory
 syscalls
Message-ID: <20190611174448.exg2zycfqf4a2vea@mbp>
References: <cover.1559580831.git.andreyknvl@google.com>
 <045a94326401693e015bf80c444a4d946a5c68ed.1559580831.git.andreyknvl@google.com>
 <20190610142824.GB10165@c02tf0j2hf1t.cambridge.arm.com>
 <CAAeHK+zBDB6i+iEw+TJY14gZeccvWeOBEaU+otn1F+jzDLaRpA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+zBDB6i+iEw+TJY14gZeccvWeOBEaU+otn1F+jzDLaRpA@mail.gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 05:35:31PM +0200, Andrey Konovalov wrote:
> On Mon, Jun 10, 2019 at 4:28 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > On Mon, Jun 03, 2019 at 06:55:07PM +0200, Andrey Konovalov wrote:
> > > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > > pass tagged user pointers (with the top byte set to something else other
> > > than 0x00) as syscall arguments.
> > >
> > > This patch allows tagged pointers to be passed to the following memory
> > > syscalls: get_mempolicy, madvise, mbind, mincore, mlock, mlock2, mprotect,
> > > mremap, msync, munlock.
> > >
> > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> >
> > I would add in the commit log (and possibly in the code with a comment)
> > that mremap() and mmap() do not currently accept tagged hint addresses.
> > Architectures may interpret the hint tag as a background colour for the
> > corresponding vma. With this:
> 
> I'll change the commit log. Where do you you think I should put this
> comment? Before mmap and mremap definitions in mm/?

On arm64 we use our own sys_mmap(). I'd say just add a comment on the
generic mremap() just before the untagged_addr() along the lines that
new_address is not untagged for preserving similar behaviour to mmap().

-- 
Catalin

