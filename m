Return-Path: <SRS0=7HIe=WT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E94A3C3A5A2
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 16:32:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B966A22CEC
	for <linux-mm@archiver.kernel.org>; Fri, 23 Aug 2019 16:32:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B966A22CEC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 41E376B04A9; Fri, 23 Aug 2019 12:32:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3CF476B04AB; Fri, 23 Aug 2019 12:32:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E4A26B04AC; Fri, 23 Aug 2019 12:32:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0007.hostedemail.com [216.40.44.7])
	by kanga.kvack.org (Postfix) with ESMTP id 07D646B04A9
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 12:32:56 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id B12D882437D7
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 16:32:56 +0000 (UTC)
X-FDA: 75854236752.13.pull25_8dcb572fd0e55
X-HE-Tag: pull25_8dcb572fd0e55
X-Filterd-Recvd-Size: 3562
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 23 Aug 2019 16:32:54 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2435328;
	Fri, 23 Aug 2019 09:32:53 -0700 (PDT)
Received: from arm.com (usa-sjc-imap-foss1.foss.arm.com [10.121.207.14])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7280E3F246;
	Fri, 23 Aug 2019 09:32:51 -0700 (PDT)
Date: Fri, 23 Aug 2019 17:32:49 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	Szabolcs Nagy <szabolcs.nagy@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH v9 3/3] arm64: Relax
 Documentation/arm64/tagged-pointers.rst
Message-ID: <20190823163247.GG27757@arm.com>
References: <20190821164730.47450-1-catalin.marinas@arm.com>
 <20190821164730.47450-4-catalin.marinas@arm.com>
 <20190821173352.yqfgaozi7nfhcofg@willie-the-truck>
 <20190821184649.GD27757@arm.com>
 <20190822155531.GB55798@arrakis.emea.arm.com>
 <20190822163723.GF27757@arm.com>
 <20190823161912.GJ29387@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190823161912.GJ29387@arrakis.emea.arm.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 23, 2019 at 05:19:13PM +0100, Catalin Marinas wrote:
> On Thu, Aug 22, 2019 at 05:37:23PM +0100, Dave P Martin wrote:
> > On Thu, Aug 22, 2019 at 04:55:32PM +0100, Catalin Marinas wrote:
> > > On Wed, Aug 21, 2019 at 07:46:51PM +0100, Dave P Martin wrote:

[...]

> > > > sigaltstack() is interesting, since we don't support tagged stacks.
> > > 
> > > We should support tagged SP with the new ABI as they'll be required for
> > > MTE. sigaltstack() and clone() are the two syscalls that come to mind
> > > here.
> > > 
> > > > Do we keep the ss_sp tag in the kernel, but squash it when delivering
> > > > a signal to the alternate stack?
> > > 
> > > We don't seem to be doing any untagging, so we just just use whatever
> > > the caller asked for. We may need a small test to confirm.
> > 
> > If we want to support tagged SP, then I guess we shouldn't be squashing
> > the tag anywhere.  A test for that would be sensible to have.
> 
> I hacked the sas.c kselftest to use a tagged stack and works fine, the
> SP register has a tagged address on the signal handler.

Cool...

[...]

> > > > There is no foolproof rule, unless we can rewrite history...
> > > 
> > > I would expect the norm to be the preservation of tags with a few
> > > exceptions. The only ones I think where we won't preserve the tags are
> > > mmap, mremap, brk (apart from the signal stuff already mentioned in the
> > > current tagged-pointers.rst doc).
> > > 
> > > So I can remove this paragraph altogether and add a note in part 3 of
> > > the tagged-address-abi.rst document that mmap/mremap/brk do not preserve
> > > the tag information.
> > 
> > Deleting text is always a good idea ;)
> 
> I'm going this route ;).

[reply deleted]

Cheers
---Dave

