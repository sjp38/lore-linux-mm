Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83ADBC3A5A2
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 16:19:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32A3E22CEC
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 16:19:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32A3E22CEC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 318596B04A8; Fri, 23 Aug 2019 12:19:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C8156B04A9; Fri, 23 Aug 2019 12:19:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DF326B04AA; Fri, 23 Aug 2019 12:19:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0054.hostedemail.com [216.40.44.54])
	by kanga.kvack.org (Postfix) with ESMTP id F24266B04A8
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 12:19:20 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id AB2FB181AC9B4
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 16:19:20 +0000 (UTC)
X-FDA: 75854202480.02.vase80_170419ccc2101
X-HE-Tag: vase80_170419ccc2101
X-Filterd-Recvd-Size: 4685
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 16:19:18 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EFEE228;
	Fri, 23 Aug 2019 09:19:16 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 4B4F33F246;
	Fri, 23 Aug 2019 09:19:15 -0700 (PDT)
Date: Fri, 23 Aug 2019 17:19:13 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Dave Martin <Dave.Martin@arm.com>
Cc: linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	Szabolcs Nagy <szabolcs.nagy@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org,
	Dave Hansen <dave.hansen@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will@kernel.org>, linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH v9 3/3] arm64: Relax
 Documentation/arm64/tagged-pointers.rst
Message-ID: <20190823161912.GJ29387@arrakis.emea.arm.com>
References: <20190821164730.47450-1-catalin.marinas@arm.com>
 <20190821164730.47450-4-catalin.marinas@arm.com>
 <20190821173352.yqfgaozi7nfhcofg@willie-the-truck>
 <20190821184649.GD27757@arm.com>
 <20190822155531.GB55798@arrakis.emea.arm.com>
 <20190822163723.GF27757@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190822163723.GF27757@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2019 at 05:37:23PM +0100, Dave P Martin wrote:
> On Thu, Aug 22, 2019 at 04:55:32PM +0100, Catalin Marinas wrote:
> > On Wed, Aug 21, 2019 at 07:46:51PM +0100, Dave P Martin wrote:
> > > On Wed, Aug 21, 2019 at 06:33:53PM +0100, Will Deacon wrote:
> > > > On Wed, Aug 21, 2019 at 05:47:30PM +0100, Catalin Marinas wrote:
> > > > > @@ -59,6 +63,11 @@ be preserved.
> > > > >  The architecture prevents the use of a tagged PC, so the upper byte will
> > > > >  be set to a sign-extension of bit 55 on exception return.
> > > > >  
> > > > > +This behaviour is maintained when the AArch64 Tagged Address ABI is
> > > > > +enabled. In addition, with the exceptions above, the kernel will
> > > > > +preserve any non-zero tags passed by the user via syscalls and stored in
> > > > > +kernel data structures (e.g. ``set_robust_list()``, ``sigaltstack()``).
> > > 
> > > sigaltstack() is interesting, since we don't support tagged stacks.
> > 
> > We should support tagged SP with the new ABI as they'll be required for
> > MTE. sigaltstack() and clone() are the two syscalls that come to mind
> > here.
> > 
> > > Do we keep the ss_sp tag in the kernel, but squash it when delivering
> > > a signal to the alternate stack?
> > 
> > We don't seem to be doing any untagging, so we just just use whatever
> > the caller asked for. We may need a small test to confirm.
> 
> If we want to support tagged SP, then I guess we shouldn't be squashing
> the tag anywhere.  A test for that would be sensible to have.

I hacked the sas.c kselftest to use a tagged stack and works fine, the
SP register has a tagged address on the signal handler.

> > > > Hmm. I can see the need to provide this guarantee for things like
> > > > set_robust_list(), but the problem is that the statement above is too broad
> > > > and isn't strictly true: for example, mmap() doesn't propagate the tag of
> > > > its address parameter into the VMA.
> > > > 
> > > > So I think we need to nail this down a bit more, but I'm having a really
> > > > hard time coming up with some wording :(
> > > 
> > > Time for some creative vagueness?
> > > 
> > > We can write a statement of our overall intent, along with examples of
> > > a few cases where the tag should and should not be expected to emerge
> > > intact.
> > > 
> > > There is no foolproof rule, unless we can rewrite history...
> > 
> > I would expect the norm to be the preservation of tags with a few
> > exceptions. The only ones I think where we won't preserve the tags are
> > mmap, mremap, brk (apart from the signal stuff already mentioned in the
> > current tagged-pointers.rst doc).
> > 
> > So I can remove this paragraph altogether and add a note in part 3 of
> > the tagged-address-abi.rst document that mmap/mremap/brk do not preserve
> > the tag information.
> 
> Deleting text is always a good idea ;)

I'm going this route ;).

-- 
Catalin

