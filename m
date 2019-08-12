Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52993C31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 23:23:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAC3F2075B
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 23:23:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAC3F2075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=perches.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5B2016B0003; Mon, 12 Aug 2019 19:23:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 561616B0005; Mon, 12 Aug 2019 19:23:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4501B6B0006; Mon, 12 Aug 2019 19:23:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0169.hostedemail.com [216.40.44.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1EAD46B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 19:23:31 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 83ED1181AC9AE
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 23:23:30 +0000 (UTC)
X-FDA: 75815354580.20.scene68_1e95e8ff18e3b
X-HE-Tag: scene68_1e95e8ff18e3b
X-Filterd-Recvd-Size: 6703
Received: from smtprelay.hostedemail.com (smtprelay0182.hostedemail.com [216.40.44.182])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 23:23:30 +0000 (UTC)
Received: from filter.hostedemail.com (clb03-v110.bra.tucows.net [216.40.38.60])
	by smtprelay08.hostedemail.com (Postfix) with ESMTP id C1578182CED2A;
	Mon, 12 Aug 2019 23:23:29 +0000 (UTC)
X-Session-Marker: 6A6F6540706572636865732E636F6D
X-HE-Tag: leaf22_1e480bf41a219
X-Filterd-Recvd-Size: 5199
Received: from XPS-9350.home (cpe-23-242-196-136.socal.res.rr.com [23.242.196.136])
	(Authenticated sender: joe@perches.com)
	by omf07.hostedemail.com (Postfix) with ESMTPA;
	Mon, 12 Aug 2019 23:23:27 +0000 (UTC)
Message-ID: <058c848ef329fa68ef40ca58fa6bbd65b97de0e1.camel@perches.com>
Subject: Re: [PATCH v2] kbuild: Change fallthrough comments to attributes
From: Joe Perches <joe@perches.com>
To: Nick Desaulniers <ndesaulniers@google.com>
Cc: Nathan Huckleberry <nhuck@google.com>, Masahiro Yamada
 <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, 
 Nathan Chancellor <natechancellor@gmail.com>, Linux Kbuild mailing list
 <linux-kbuild@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux
 Memory Management List <linux-mm@kvack.org>, clang-built-linux
 <clang-built-linux@googlegroups.com>,  "Gustavo A. R. Silva"
 <gustavo@embeddedor.com>
Date: Mon, 12 Aug 2019 16:23:26 -0700
In-Reply-To: <CAKwvOdnpXqoQDmHVRCh0qX=Yh-8UpEWJ0C3S=syn1KN8rB3OGQ@mail.gmail.com>
References: <20190812214711.83710-1-nhuck@google.com>
	 <20190812221416.139678-1-nhuck@google.com>
	 <814c1b19141022946d3e0f7e24d69658d7a512e4.camel@perches.com>
	 <CAKwvOdnpXqoQDmHVRCh0qX=Yh-8UpEWJ0C3S=syn1KN8rB3OGQ@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
User-Agent: Evolution 3.30.5-0ubuntu0.18.10.1 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-08-12 at 16:11 -0700, Nick Desaulniers wrote:
> On Mon, Aug 12, 2019 at 3:40 PM Joe Perches <joe@perches.com> wrote:
> > On Mon, 2019-08-12 at 15:14 -0700, Nathan Huckleberry wrote:
> > > Clang does not support the use of comments to label
> > > intentional fallthrough. This patch replaces some uses
> > > of comments to attributesto cut down a significant number
> > > of warnings on clang (from ~50000 to ~200). Only comments
> > > in commonly used header files have been replaced.
> > > 
> > > Since there is still quite a bit of noise, this
> > > patch moves -Wimplicit-fallthrough to
> > > Makefile.extrawarn if you are compiling with
> > > clang.
> > 
> > Unmodified clang does not emit this warning without a patch.
> 
> Correct, Nathan is currently implementing support for attribute
> fallthrough in Clang in:
> https://reviews.llvm.org/D64838
> 
> I asked him in person to evaluate how many warnings we'd see in an
> arm64 defconfig with his patch applied.  There were on the order of
> 50k warnings, mostly from these headers.  I asked him to send these
> patches, then land support in the compiler, that way should our CI
> catch fire overnight, we can carry out of tree fixes until they land.
> With the changes here to Makefile.extrawarn, we should not need to
> carry any out of tree patches.
> 
> > > diff --git a/Makefile b/Makefile
> > []
> > > @@ -846,7 +846,11 @@ NOSTDINC_FLAGS += -nostdinc -isystem $(shell $(CC) -print-file-name=include)
> > >  KBUILD_CFLAGS += -Wdeclaration-after-statement
> > > 
> > >  # Warn about unmarked fall-throughs in switch statement.
> > > +# If the compiler is clang, this warning is only enabled if W=1 in
> > > +# Makefile.extrawarn
> > > +ifndef CONFIG_CC_IS_CLANG
> > >  KBUILD_CFLAGS += $(call cc-option,-Wimplicit-fallthrough,)
> > > +endif
> > 
> > It'd be better to remove CONFIG_CC_IS_CLANG everywhere
> > eventually as it adds complexity and makes .config files
> > not portable to multiple systems.
> > 
> > > diff --git a/include/linux/compiler_attributes.h b/include/linux/compiler_attributes.h
> > []
> > > @@ -253,4 +253,8 @@
> > >   */
> > >  #define __weak                          __attribute__((__weak__))
> > > 
> > > +#if __has_attribute(fallthrough)
> > > +#define __fallthrough                   __attribute__((fallthrough))
> > 
> > This should be __attribute__((__fallthrough__))
> 
> Agreed.  I think the GCC documentation on attributes had a point about
> why the __ prefix/suffix was important, which is why we went with that
> in Miguel's original patchset.
> 
> > And there is still no agreement about whether this should
> > be #define fallthrough or #define __fallthrough
> > 
> > https://lore.kernel.org/patchwork/patch/1108577/
> > 
> > > diff --git a/include/linux/jhash.h b/include/linux/jhash.h
> > []
> > > @@ -86,19 +86,43 @@ static inline u32 jhash(const void *key, u32 length, u32 initval)
> > []
> > > +     case 12:
> > > +             c += (u32)k[11]<<24;
> > > +             __fallthrough;
> > 
> > You might consider trying out the scripted conversion tool
> > attached to this email:
> > 
> > https://lore.kernel.org/lkml/61ddbb86d5e68a15e24ccb06d9b399bbf5ce2da7.camel@perches.com/
> 
> I guess the thing I'm curious about is why /* fall through */ is being
> used vs __attribute__((__fallthrough__))?  Surely there's some
> discussion someone can point me to?

AFAIK:

It's historic.

https://lkml.org/lkml/2019/8/4/83

coverity and lint do not support __attribute__((__fallthrough__))
but do support /* fallthrough */ comments in their analysis output.

I prefer converting all the comments to a macro / pseudo keyword.

The cvt_style.pl script does a reasonable job of conversion.




