Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1755C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 15:18:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A66D823BF4
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 15:18:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A66D823BF4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44C6A6B000E; Wed, 29 May 2019 11:18:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D62A6B0010; Wed, 29 May 2019 11:18:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 29EB46B0266; Wed, 29 May 2019 11:18:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CBD3F6B000E
	for <linux-mm@kvack.org>; Wed, 29 May 2019 11:18:51 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c1so3880789edi.20
        for <linux-mm@kvack.org>; Wed, 29 May 2019 08:18:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lWTJhpT/QMtRMuYaWb1uTML/HkWDJbY7JGiwFaTR5sQ=;
        b=pV8vz9VracNX9i1GtUlObVW5rdZzbAYzmuXSHJyOI2RWjPdkbV3Ui++EP8WeR1ze7u
         HfPR80VMIUq4AJ2iBDxKd2KzYxeeK9ZZfZVzNFExzbq5n/hV0c0erpIpLB3mQqo1I66R
         9u/nxFF1LW1Ju4jxMjRG3gZPmDJFUOJIA5OdNDEEC/af0TempuLYvMvsqbF5CCfTQ/di
         V1oBL+yUtKfkdnjQBE03KrVg9XJuieL8oN30ODFe131xvQ/KGn09yx9SYP4YB1YO6nI/
         jTLws7do2YBBH/Geoqh5h3Y8HO3PEVmej6uROG750xsk/e2S6/4DMTN6R9gNRdPWcVQr
         FhMQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAUhux3tQkv7BInwlvMEfQUpmOLe2Hb1Md7rZqfckdLFisWxBnuS
	GipRulKaeFXSG1wkWNOWWSNibP16I417TJ2pNplCiBx8JXigE1BuVT27IpVQKm9txEbUP3lssx2
	xOJACXjW88ky/zo6cHG8BYCIcSqUs0p9b461OKE+luEHiKEsTIQEGOtHSnc7Nu0+ToA==
X-Received: by 2002:a17:906:3713:: with SMTP id d19mr100383200ejc.194.1559143131369;
        Wed, 29 May 2019 08:18:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyPIGbSwniA8na+ZeVt04WU/ilHmhAwdgDjJkQm3OM5X40w9ct6YLSDP3++P8oYd1jGuU8a
X-Received: by 2002:a17:906:3713:: with SMTP id d19mr100383098ejc.194.1559143130256;
        Wed, 29 May 2019 08:18:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559143130; cv=none;
        d=google.com; s=arc-20160816;
        b=rASpO690hBqQ53XLCaefZ+0aPr/zYkPQPJWGyedFhROooRs4htyc15xN/ZSk2OG5uE
         hxFWuaSeJc9tUBD7SpTgKFwUtqfnJNoxiVj6Ub/pNROL1Jb4rhxEQdaOKEN5l/8xsFjq
         zP4GZ4pTzcF2qrFXGDlMyOla32jxNzER9Ya5HPlPqAB/gERTHlMB5eX1DAQWMJCeRVh7
         DV8gSsHgdog7eVVzCSTWYwuQiwMIzCMcLEwwqmHV/S4ncl7dAZpwO6//2RwsVVEuCc+G
         zImN7D2mAkx3keyXQ4pgzaSxL5g2zt+SMSv/zhCWRbBuh44DuQ2XCq6EI9R25//3x56/
         bnvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lWTJhpT/QMtRMuYaWb1uTML/HkWDJbY7JGiwFaTR5sQ=;
        b=ptWLhoJGbU3rlxLTK+IZFy7OppX2EI3D9X5M1k5fEhIAEdBXBchayW4fa8Irz2oIn8
         r3FrnxnBw7jPNepPDHFyMCEKJmwF9ohR2VNLNoHsVEo3h9bq6Oko2xVeGbz3y9R6HHpB
         1zlZMah1IXBeKg5G6xaMX9zIfLGRJxo0KsCU7QZgydJ0fmgx7LAlnUO3DjFEh7+fSzO9
         xwvApRglLEQ2njPiF2sxXa612MfQux1Yo+sYiW9S8k879E8LeTrjLJeehJVpw98PHzD6
         PPAgATB/UGHw1b8LD2Iv149aXQcRwIUOGRri46UIOZBbzVn3Hr2Ylk7FUZwmrIMf5Zr2
         qOuw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ec4si3964654ejb.68.2019.05.29.08.18.49
        for <linux-mm@kvack.org>;
        Wed, 29 May 2019 08:18:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 95CC8341;
	Wed, 29 May 2019 08:18:48 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D9C163F5AF;
	Wed, 29 May 2019 08:18:42 -0700 (PDT)
Date: Wed, 29 May 2019 16:18:40 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
	Christian Koenig <Christian.Koenig@amd.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
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
	Yishai Hadas <yishaih@mellanox.com>, linux-kernel@vger.kernel.org,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Andrew Murray <andrew.murray@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v15 05/17] arms64: untag user pointers passed to memory
 syscalls
Message-ID: <20190529151839.GF28398@e103592.cambridge.arm.com>
References: <cover.1557160186.git.andreyknvl@google.com>
 <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
 <20190527143719.GA59948@MBP.local>
 <20190528145411.GA709@e119886-lin.cambridge.arm.com>
 <20190528154057.GD32006@arrakis.emea.arm.com>
 <20190528155644.GD28398@e103592.cambridge.arm.com>
 <20190528163400.GE32006@arrakis.emea.arm.com>
 <20190529124224.GE28398@e103592.cambridge.arm.com>
 <20190529132341.27t3knoxpb7t7y3g@mbp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190529132341.27t3knoxpb7t7y3g@mbp>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 02:23:42PM +0100, Catalin Marinas wrote:
> On Wed, May 29, 2019 at 01:42:25PM +0100, Dave P Martin wrote:
> > On Tue, May 28, 2019 at 05:34:00PM +0100, Catalin Marinas wrote:
> > > On Tue, May 28, 2019 at 04:56:45PM +0100, Dave P Martin wrote:
> > > > On Tue, May 28, 2019 at 04:40:58PM +0100, Catalin Marinas wrote:
> > > > 
> > > > [...]
> > > > 
> > > > > My thoughts on allowing tags (quick look):
> > > > >
> > > > > brk - no
> > > > 
> > > > [...]
> > > > 
> > > > > mlock, mlock2, munlock - yes
> > > > > mmap - no (we may change this with MTE but not for TBI)
> > > > 
> > > > [...]
> > > > 
> > > > > mprotect - yes
> > > > 
> > > > I haven't following this discussion closely... what's the rationale for
> > > > the inconsistencies here (feel free to refer me back to the discussion
> > > > if it's elsewhere).
> > > 
> > > _My_ rationale (feel free to disagree) is that mmap() by default would
> > > not return a tagged address (ignoring MTE for now). If it gets passed a
> > > tagged address or a "tagged NULL" (for lack of a better name) we don't
> > > have clear semantics of whether the returned address should be tagged in
> > > this ABI relaxation. I'd rather reserve this specific behaviour if we
> > > overload the non-zero tag meaning of mmap() for MTE. Similar reasoning
> > > for mremap(), at least on the new_address argument (not entirely sure
> > > about old_address).
> > > 
> > > munmap() should probably follow the mmap() rules.
> > > 
> > > As for brk(), I don't see why the user would need to pass a tagged
> > > address, we can't associate any meaning to this tag.
> > > 
> > > For the rest, since it's likely such addresses would have been tagged by
> > > malloc() in user space, we should allow tagged pointers.
> > 
> > Those arguments seem reasonable.  We should try to capture this
> > somewhere when documenting the ABI.
> > 
> > To be clear, I'm not sure that we should guarantee anywhere that a
> > tagged pointer is rejected: rather the behaviour should probably be
> > left unspecified.  Then we can tidy it up incrementally.
> > 
> > (The behaviour is unspecified today, in any case.)
> 
> What is specified (or rather de-facto ABI) today is that passing a user
> address above TASK_SIZE (e.g. non-zero top byte) would fail in most
> cases. If we relax this with the TBI we may end up with some de-facto

I may be being too picky, but "would fail in most cases" sounds like
"unspecified" ?

> ABI before we actually get MTE hardware. Tightening it afterwards may be
> slightly more problematic, although MTE needs to be an explicit opt-in.
> 
> IOW, I wouldn't want to unnecessarily relax the ABI if we don't need to.

So long we don't block foreseeable future developments unnecessarily
either -- I agree there's a balance to be struck.

I guess this can be reviewed when we have nailed down the details a bit
further.

Cheers
---Dave

