Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FA99C28CC3
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 16:22:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60C1424ADE
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 16:22:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60C1424ADE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08F636B0010; Fri, 31 May 2019 12:22:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 040786B026B; Fri, 31 May 2019 12:22:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E986D6B026C; Fri, 31 May 2019 12:22:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9C9436B0010
	for <linux-mm@kvack.org>; Fri, 31 May 2019 12:22:16 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r5so14640045edd.21
        for <linux-mm@kvack.org>; Fri, 31 May 2019 09:22:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=qnFYsK+J0nNCR7TOrG+LzlPVhmAPoc+xfhUe63xy+70=;
        b=FRVzPO8j//jNRyruKKySwf5XgN8xSwzSJbjIyZbx68nJnatN5Uv4LOIYev85e6u2OH
         RSrqXRAgp1RHnvd8aF8mNhZcDoclGckhLo0Mkp7bbk2sotjA1AbJiqeXainxCOv56zkl
         UDnfoQFFllmoAZoh6J46Bggt+i6yVK1jX5Te+NOjzhEF9NciwIobV737yLs1Y0JxG+iz
         iZk8w7gEJGkEa9xf0blfK6s0Asjtqel8la1PuLQ3coovouRCpknQkxk+fdJNvucm4y2v
         TCf5t6mbqZgMRJ3wz2G92sns6SFVhdRsXRwLg5KsJHJBOqKNDVhPjHDDNfTd9UFyKE3d
         O1NQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAW1B5jOFcDcE40AzEeLOpC+SYY2i2t/7uoyaby8p4YpKmfjjWoJ
	mzfQySkuMs82J4reOlm21N7GMSWKdZfPnxGIw5ipADEl4KSTbjIprI3CO+G4GvuSSCqIrMozt22
	Ek6ygCvuOSP21Tdgi/gNUU0ieR8yPY9mvUZdABfZI5thPM0+FMjcL4FMeerhQPdgkbQ==
X-Received: by 2002:a17:906:261b:: with SMTP id h27mr10048705ejc.97.1559319736193;
        Fri, 31 May 2019 09:22:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLW/fKAs8BrBXcvncP4TforWtXcz64/Ck+LmLPElLNp5pP5WogeRJ6D4paKdUbDAvNw4Tk
X-Received: by 2002:a17:906:261b:: with SMTP id h27mr10048624ejc.97.1559319735414;
        Fri, 31 May 2019 09:22:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559319735; cv=none;
        d=google.com; s=arc-20160816;
        b=BlNkyJCt9T8GDiF4v0VQLOlaP4MFKdTw1/oFRDdPgOp75/cqnBBmZpo8TWFmBLbF1c
         IleAYtHWNzuwVpDIb/t4dENL8IO0ykz5ElRw2hiESWmaG97PWa5l1Fru8l8m7tbvT+qg
         cBhhIPCWmKznMJnuQ421F0aZEltB5CnjUsry9HEH8G8IikJkxn1A7XcjKG9gXTuWtfot
         ZWiWo802BYv1OeGgtIKrCQ98QwnjiZhgMs1y/04wJsDv/CFj7stVMhD5wSXM7TnnWuls
         eZNP1GhZADe55Jfb3KmGCmcBZwPi5+rXWGnqihkc5EHyucbroRowOoqpjqVnFehkaOKU
         mt0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=qnFYsK+J0nNCR7TOrG+LzlPVhmAPoc+xfhUe63xy+70=;
        b=eLldD/mGsguwjgovrCxgo5EdQNUJ+w6wx/UPK8L1SrDdRnzDBxmR7sPOQQVeuUNlsV
         expLpCJvEgHgO3rjtdbx4mLb7dj9gueQ0p3fMJdf38OjGyf4+KbzYjO8u03Upd8v8ru/
         3BBBVpI4ZJkVdJfYEojRHF9Ng/OqtX0cZ3hojWbjcnG9Vo2L2EgWKoPM0KZr4xLrCKR5
         MnyEkAGVSuzfORp8s3tKoOaWDCwFCnZ5zNWJ5iNQaPOmZ6dNNBy0+UmAFKX+fd9HpmT5
         F/Mxpo0GZHEmR0ZbPAu6/LTaHPPr3szidYTFWIGH6wzBERHjKsNYa9TfSaIbHC1rwGJQ
         xxHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q19si1645124edd.425.2019.05.31.09.22.15
        for <linux-mm@kvack.org>;
        Fri, 31 May 2019 09:22:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 72A16341;
	Fri, 31 May 2019 09:22:14 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D9D693F59C;
	Fri, 31 May 2019 09:22:08 -0700 (PDT)
Date: Fri, 31 May 2019 17:22:06 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
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
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v15 17/17] selftests, arm64: add a selftest for passing
 tagged pointers to kernel
Message-ID: <20190531162206.GB3568@arrakis.emea.arm.com>
References: <cover.1557160186.git.andreyknvl@google.com>
 <e31d9364eb0c2eba8ce246a558422e811d82d21b.1557160186.git.andreyknvl@google.com>
 <20190522141612.GA28122@arrakis.emea.arm.com>
 <CAAeHK+wUerHQOV2PuaTwTxcCucZHZodLwg48228SB+ymxEqT2A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+wUerHQOV2PuaTwTxcCucZHZodLwg48228SB+ymxEqT2A@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 31, 2019 at 04:21:48PM +0200, Andrey Konovalov wrote:
> On Wed, May 22, 2019 at 4:16 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > On Mon, May 06, 2019 at 06:31:03PM +0200, Andrey Konovalov wrote:
> > > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > > pass tagged user pointers (with the top byte set to something else other
> > > than 0x00) as syscall arguments.
> > >
> > > This patch adds a simple test, that calls the uname syscall with a
> > > tagged user pointer as an argument. Without the kernel accepting tagged
> > > user pointers the test fails with EFAULT.
> >
> > That's probably sufficient for a simple example. Something we could add
> > to Documentation maybe is a small library that can be LD_PRELOAD'ed so
> > that you can run a lot more tests like LTP.
> 
> Should I add this into this series, or should this go into Vincenzo's patchset?

If you can tweak the selftest Makefile to build a library and force it
with LD_PRELOAD, you can keep it with this patch. It would be easier to
extend to other syscall tests, signal handling etc.

-- 
Catalin

