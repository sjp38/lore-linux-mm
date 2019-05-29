Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFBC9C28CC1
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 13:23:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5DA5217D4
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 13:23:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5DA5217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36B486B000D; Wed, 29 May 2019 09:23:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31C646B0010; Wed, 29 May 2019 09:23:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20BE66B0266; Wed, 29 May 2019 09:23:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C92696B000D
	for <linux-mm@kvack.org>; Wed, 29 May 2019 09:23:53 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id l3so3441164edl.10
        for <linux-mm@kvack.org>; Wed, 29 May 2019 06:23:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=euesoUjkSQJ2miEAPNfPDRSCP16azLpN27jylWUcuXQ=;
        b=gAsEpp40zZF6e3FWl6tuYJNYu629ymbPl1MtgJbcm6h8fs42J9rTmfkpBxc3XpkdaU
         ZUpNpjI/FoPpC1qtEPMjvxeGeyZtevKIJIJHV14TsSW7vOUDcwp/TLiqnxBitezhQ5pN
         y+uUvyZlwOQyZxW5TBfKS1Q3ZRzeifJrou7gIZd7siqOsg7wGwjdgOOfkXVRYRkghjDU
         k9Aqm/VNzNXlXFDiIIp3wCKcE4Jj3SKvs1lul931usr4HBubFfCtODIehRQruLRVfrNF
         VPWQ21I+KdiS+DVtyI4w1MxGrpUd+XXOIN0rnz6gvidQhu+KXQ/xIVUvXbThDX9Ia/YE
         crpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUMax+OE1tLeNxI6DbzlbAXFnOu45ALWVUQhwnf5x/9tGKNUrpa
	PMsQVM/7ZJmDlOSejsnoy9+AZ2qrxczKKhLBCh3r3x6Bb385tt4mw8wMJ8iuiygUDnf8XKOkT5l
	6rNgm39QF2h2FXjPYWUNlBiVCXUL1SszESRIrCHNNwKJc/0Pz5gj8ZJXrlAa8+4sc2A==
X-Received: by 2002:a17:906:fc02:: with SMTP id ov2mr39668831ejb.22.1559136233368;
        Wed, 29 May 2019 06:23:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1XSny1luFwML9ARHOzqfk2gJbyahXLESHp4YSDJVoNDoMOhlAQRzmIob5WyiCkubTIzl5
X-Received: by 2002:a17:906:fc02:: with SMTP id ov2mr39668737ejb.22.1559136232220;
        Wed, 29 May 2019 06:23:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559136232; cv=none;
        d=google.com; s=arc-20160816;
        b=L2Ry9B21A6BetNVs4KDHEBrD+5jAtcLcSkX+qc0j6CtZfPsLzLVAePUEtUK/RJDIg8
         nzoiYQ7+bjF2GFnMiauNXGfr1mGWLF07gpQfodSl6nsLCXS2W4lGOp6yqVPbw5GqvHr3
         nsEmpqtDo62qZzEZUSonNy+UsYf/3kDhNVyNL2WCsrTuBaRA0J3d3TmnzzizzJmG6K9k
         0EUkGMLredSB6mDcT+GtuxTL2pMkxHXenzdUVRJTfy/jpNehN1DULIyhCyV3CKgJ7Wf7
         izjR5lQugS7GBxzmoHlOgZxMXkC25C4gKep0oQNudjVDITdY3OwV8QOptWLTLGFA9SrO
         eURw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=euesoUjkSQJ2miEAPNfPDRSCP16azLpN27jylWUcuXQ=;
        b=yezE8G7PA6VN+mEMdVmudBU+6vHGkmBkMt7vM5Dy9sTmKKt0moUZHdQpa0x1ysISUo
         8y81lqyVFF90VV51vJoflwnHN+bDNSi4dntbdIt8a2qT4vhSH/YuKEL3JKyIkQRX+2UD
         LtSkBVnaad9fQ/80sxlx87OS8HDD6ljOFO4tESEbNv4NyA1g3W0zxlYdmCmUya/s07DJ
         pPJsiAFX4ZjOQmukHRymn5gF4bxQ/0BUvrVhZd7+DzNz1NfEwYXkVpbXYh37Tjta1L+U
         jGoZVpikXfVSffxweKwYYyHKNBiCKFutpqm8I6sFBoO3Ph8i3Sfbw8TYH1/LsLKiJoFz
         htDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c47si1268470edc.304.2019.05.29.06.23.51
        for <linux-mm@kvack.org>;
        Wed, 29 May 2019 06:23:52 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E0EF180D;
	Wed, 29 May 2019 06:23:50 -0700 (PDT)
Received: from mbp (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E5BC23F59C;
	Wed, 29 May 2019 06:23:44 -0700 (PDT)
Date: Wed, 29 May 2019 14:23:42 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Dave Martin <Dave.Martin@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Will Deacon <will.deacon@arm.com>, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, linux-kselftest@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, Dmitry Vyukov <dvyukov@google.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	linux-arm-kernel@lists.infradead.org,
	Kostya Serebryany <kcc@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	linux-kernel@vger.kernel.org,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Andrew Murray <andrew.murray@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v15 05/17] arms64: untag user pointers passed to memory
 syscalls
Message-ID: <20190529132341.27t3knoxpb7t7y3g@mbp>
References: <cover.1557160186.git.andreyknvl@google.com>
 <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
 <20190527143719.GA59948@MBP.local>
 <20190528145411.GA709@e119886-lin.cambridge.arm.com>
 <20190528154057.GD32006@arrakis.emea.arm.com>
 <20190528155644.GD28398@e103592.cambridge.arm.com>
 <20190528163400.GE32006@arrakis.emea.arm.com>
 <20190529124224.GE28398@e103592.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190529124224.GE28398@e103592.cambridge.arm.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 01:42:25PM +0100, Dave P Martin wrote:
> On Tue, May 28, 2019 at 05:34:00PM +0100, Catalin Marinas wrote:
> > On Tue, May 28, 2019 at 04:56:45PM +0100, Dave P Martin wrote:
> > > On Tue, May 28, 2019 at 04:40:58PM +0100, Catalin Marinas wrote:
> > > 
> > > [...]
> > > 
> > > > My thoughts on allowing tags (quick look):
> > > >
> > > > brk - no
> > > 
> > > [...]
> > > 
> > > > mlock, mlock2, munlock - yes
> > > > mmap - no (we may change this with MTE but not for TBI)
> > > 
> > > [...]
> > > 
> > > > mprotect - yes
> > > 
> > > I haven't following this discussion closely... what's the rationale for
> > > the inconsistencies here (feel free to refer me back to the discussion
> > > if it's elsewhere).
> > 
> > _My_ rationale (feel free to disagree) is that mmap() by default would
> > not return a tagged address (ignoring MTE for now). If it gets passed a
> > tagged address or a "tagged NULL" (for lack of a better name) we don't
> > have clear semantics of whether the returned address should be tagged in
> > this ABI relaxation. I'd rather reserve this specific behaviour if we
> > overload the non-zero tag meaning of mmap() for MTE. Similar reasoning
> > for mremap(), at least on the new_address argument (not entirely sure
> > about old_address).
> > 
> > munmap() should probably follow the mmap() rules.
> > 
> > As for brk(), I don't see why the user would need to pass a tagged
> > address, we can't associate any meaning to this tag.
> > 
> > For the rest, since it's likely such addresses would have been tagged by
> > malloc() in user space, we should allow tagged pointers.
> 
> Those arguments seem reasonable.  We should try to capture this
> somewhere when documenting the ABI.
> 
> To be clear, I'm not sure that we should guarantee anywhere that a
> tagged pointer is rejected: rather the behaviour should probably be
> left unspecified.  Then we can tidy it up incrementally.
> 
> (The behaviour is unspecified today, in any case.)

What is specified (or rather de-facto ABI) today is that passing a user
address above TASK_SIZE (e.g. non-zero top byte) would fail in most
cases. If we relax this with the TBI we may end up with some de-facto
ABI before we actually get MTE hardware. Tightening it afterwards may be
slightly more problematic, although MTE needs to be an explicit opt-in.

IOW, I wouldn't want to unnecessarily relax the ABI if we don't need to.

-- 
Catalin

