Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56DE6C3A5A1
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 16:37:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04E19206B7
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 16:37:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04E19206B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E74C6B0340; Thu, 22 Aug 2019 12:37:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 397496B0341; Thu, 22 Aug 2019 12:37:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 286486B0342; Thu, 22 Aug 2019 12:37:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0049.hostedemail.com [216.40.44.49])
	by kanga.kvack.org (Postfix) with ESMTP id 082BB6B0340
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 12:37:28 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id A3BC3180AD7C1
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 16:37:28 +0000 (UTC)
X-FDA: 75850619376.27.eggs03_7b688a2bcec4b
X-HE-Tag: eggs03_7b688a2bcec4b
X-Filterd-Recvd-Size: 4641
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 16:37:27 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0F16E28;
	Thu, 22 Aug 2019 09:37:27 -0700 (PDT)
Received: from arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5B9283F718;
	Thu, 22 Aug 2019 09:37:25 -0700 (PDT)
Date: Thu, 22 Aug 2019 17:37:23 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Catalin Marinas <catalin.marinas@arm.com>
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
Message-ID: <20190822163723.GF27757@arm.com>
References: <20190821164730.47450-1-catalin.marinas@arm.com>
 <20190821164730.47450-4-catalin.marinas@arm.com>
 <20190821173352.yqfgaozi7nfhcofg@willie-the-truck>
 <20190821184649.GD27757@arm.com>
 <20190822155531.GB55798@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190822155531.GB55798@arrakis.emea.arm.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2019 at 04:55:32PM +0100, Catalin Marinas wrote:
> On Wed, Aug 21, 2019 at 07:46:51PM +0100, Dave P Martin wrote:
> > On Wed, Aug 21, 2019 at 06:33:53PM +0100, Will Deacon wrote:
> > > On Wed, Aug 21, 2019 at 05:47:30PM +0100, Catalin Marinas wrote:
> > > > @@ -59,6 +63,11 @@ be preserved.
> > > >  The architecture prevents the use of a tagged PC, so the upper byte will
> > > >  be set to a sign-extension of bit 55 on exception return.
> > > >  
> > > > +This behaviour is maintained when the AArch64 Tagged Address ABI is
> > > > +enabled. In addition, with the exceptions above, the kernel will
> > > > +preserve any non-zero tags passed by the user via syscalls and stored in
> > > > +kernel data structures (e.g. ``set_robust_list()``, ``sigaltstack()``).
> > 
> > sigaltstack() is interesting, since we don't support tagged stacks.
> 
> We should support tagged SP with the new ABI as they'll be required for
> MTE. sigaltstack() and clone() are the two syscalls that come to mind
> here.
> 
> > Do we keep the ss_sp tag in the kernel, but squash it when delivering
> > a signal to the alternate stack?
> 
> We don't seem to be doing any untagging, so we just just use whatever
> the caller asked for. We may need a small test to confirm.

If we want to support tagged SP, then I guess we shouldn't be squashing
the tag anywhere.  A test for that would be sensible to have.

> That said, on_sig_stack() probably needs some untagging as it does user
> pointer arithmetics with potentially different tags.

Good point.

> > > Hmm. I can see the need to provide this guarantee for things like
> > > set_robust_list(), but the problem is that the statement above is too broad
> > > and isn't strictly true: for example, mmap() doesn't propagate the tag of
> > > its address parameter into the VMA.
> > > 
> > > So I think we need to nail this down a bit more, but I'm having a really
> > > hard time coming up with some wording :(
> > 
> > Time for some creative vagueness?
> > 
> > We can write a statement of our overall intent, along with examples of
> > a few cases where the tag should and should not be expected to emerge
> > intact.
> > 
> > There is no foolproof rule, unless we can rewrite history...
> 
> I would expect the norm to be the preservation of tags with a few
> exceptions. The only ones I think where we won't preserve the tags are
> mmap, mremap, brk (apart from the signal stuff already mentioned in the
> current tagged-pointers.rst doc).
> 
> So I can remove this paragraph altogether and add a note in part 3 of
> the tagged-address-abi.rst document that mmap/mremap/brk do not preserve
> the tag information.

Deleting text is always a good idea ;)

There are other cases like (non-)propagation of the tag to si_addr
when a fault is reported via a signal, but I think we already have
appropriate wording to cover that.

Cheers
---Dave

