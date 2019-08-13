Return-Path: <SRS0=aN9C=WJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3414C32750
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 07:04:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94399205F4
	for <linux-mm@archiver.kernel.org>; Tue, 13 Aug 2019 07:04:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94399205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=perches.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D2936B0005; Tue, 13 Aug 2019 03:04:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2597F6B0006; Tue, 13 Aug 2019 03:04:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 148B46B0007; Tue, 13 Aug 2019 03:04:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0016.hostedemail.com [216.40.44.16])
	by kanga.kvack.org (Postfix) with ESMTP id DDCF06B0005
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 03:04:35 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 9053C40CA
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 07:04:35 +0000 (UTC)
X-FDA: 75816516510.06.dirt64_7f57ac0b39819
X-HE-Tag: dirt64_7f57ac0b39819
X-Filterd-Recvd-Size: 7375
Received: from smtprelay.hostedemail.com (smtprelay0064.hostedemail.com [216.40.44.64])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 13 Aug 2019 07:04:34 +0000 (UTC)
Received: from filter.hostedemail.com (clb03-v110.bra.tucows.net [216.40.38.60])
	by smtprelay02.hostedemail.com (Postfix) with ESMTP id 86BA53811;
	Tue, 13 Aug 2019 07:04:34 +0000 (UTC)
X-Session-Marker: 6A6F6540706572636865732E636F6D
X-HE-Tag: spot34_7efd70b731944
X-Filterd-Recvd-Size: 5872
Received: from XPS-9350 (cpe-23-242-196-136.socal.res.rr.com [23.242.196.136])
	(Authenticated sender: joe@perches.com)
	by omf02.hostedemail.com (Postfix) with ESMTPA;
	Tue, 13 Aug 2019 07:04:32 +0000 (UTC)
Message-ID: <3078e553a777976655f72718d088791363544caa.camel@perches.com>
Subject: Re: [PATCH v2] kbuild: Change fallthrough comments to attributes
From: Joe Perches <joe@perches.com>
To: Nathan Chancellor <natechancellor@gmail.com>, Nick Desaulniers
	 <ndesaulniers@google.com>
Cc: Nathan Huckleberry <nhuck@google.com>, Masahiro Yamada
 <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, 
 Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, LKML
 <linux-kernel@vger.kernel.org>, Linux Memory Management List
 <linux-mm@kvack.org>, clang-built-linux
 <clang-built-linux@googlegroups.com>,  "Gustavo A. R. Silva"
 <gustavo@embeddedor.com>
Date: Tue, 13 Aug 2019 00:04:30 -0700
In-Reply-To: <20190813063327.GA46858@archlinux-threadripper>
References: <20190812214711.83710-1-nhuck@google.com>
	 <20190812221416.139678-1-nhuck@google.com>
	 <814c1b19141022946d3e0f7e24d69658d7a512e4.camel@perches.com>
	 <CAKwvOdnpXqoQDmHVRCh0qX=Yh-8UpEWJ0C3S=syn1KN8rB3OGQ@mail.gmail.com>
	 <20190813063327.GA46858@archlinux-threadripper>
Content-Type: text/plain; charset="ISO-8859-1"
User-Agent: Evolution 3.30.5-0ubuntu0.18.10.1 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-08-12 at 23:33 -0700, Nathan Chancellor wrote:
> On Mon, Aug 12, 2019 at 04:11:26PM -0700, Nick Desaulniers wrote:
> > Correct, Nathan is currently implementing support for attribute
> > fallthrough in Clang in:
> > https://reviews.llvm.org/D64838
> > 
> > I asked him in person to evaluate how many warnings we'd see in an
> > arm64 defconfig with his patch applied.  There were on the order of
> > 50k warnings, mostly from these headers.  I asked him to send these
> > patches, then land support in the compiler, that way should our CI
> > catch fire overnight, we can carry out of tree fixes until they land.
> > With the changes here to Makefile.extrawarn, we should not need to
> > carry any out of tree patches.
> 
> I think that if we are modifying this callsite to be favorable to clang,
> we should consider a straight revert of commit bfd77145f35c ("Makefile:
> Convert -Wimplicit-fallthrough=3 to just -Wipmlicit-fallthrough for
> clang").

oh bother.

> It would save us a change in scripts/Makefile.extrawarn and
> tying testing of this warning to W=1 will make the build noisy from
> all of the other warnings that we don't care about plus we will need to
> revert that change once we have finished the conversion process anyways.
> I think it is cleaner to just pass KCFLAGS=-Wimplicit-fallthrough to
> make when testing so that just that additional warning appears but
> that is obviously subjective.
> 
> > > You might consider trying out the scripted conversion tool
> > > attached to this email:
> > > 
> > > https://lore.kernel.org/lkml/61ddbb86d5e68a15e24ccb06d9b399bbf5ce2da7.camel@perches.com/
> 
> I gave the script a go earlier today and it does a reasonable job at
> convering the comments to the fallthrough keyword. Here is a list of
> the warnings I still see in an x86 allyesconfig build with D64838 on
> next-20190812:
> 
> https://gist.github.com/ffbd71b48ba197837e1bdd9bb863b85f

> I have gone through about 20-30 of them and while there are a few missed
> conversion spots (which is obviously fine for a treewide conversion),

The _vast_ majority of case /* fallthrough */ style comments
in switch
blocks are immediately before another case or default

The afs ones seem to be because the last comment in the block
is not the fallthrough, but a description of the next case;

e.g.: from fs/afs/fsclient.c:

		/* extract the volume name */
	case 3:
		_debug("extract volname");
		ret = afs_extract_data(call, true);
		if (ret < 0)
			return ret;

		p = call->buffer;
		p[call->count] = 0;
		_debug("volname '%s'", p);
		afs_extract_to_tmp(call);
		call->unmarshall++;
		/* Fall through */

		/* extract the offline message length */
	case 4:

The script modifies a /* fallthrough */ style comment
only if the next non-blank line is 'case <foo>' or "default:'

There are many other /* fallthrough */ style comments
that are not actually fallthroughs or used in switch
blocks so this can't really be automated particularly
easily.

Likely these remainders would have to be converted manually.

> the majority of them come from a disagreement between GCC and Clang on
> emitting a warning when falling through to a case statement that is
> either the last one and empty or simply breaks..
> 
> Example: https://godbolt.org/z/xgkvIh
> 
> I have more information on our issue tracker if anyone else wants to
> take a look: https://github.com/ClangBuiltLinux/linux/issues/636
> 
> I personally think that GCC is right and Clang should adapt but I don't
> know enough about the Clang codebase to know how feasible this is.

I think gcc is wrong here and code like

	switch (foo) {
	case 1:
		bar = 1;
	default:
		break;
	}

should emit a fallthrough warning.

> I just know there will be even more churn than necessary if we have to
> annotate all of those places, taking the conversion process from maybe a
> release cycle to several.

Luckily, there's a list so it's not a hard problem
and it's easily scriptable.

There are < 350 entries, not many really.

btw: What does the 1st column mean?
      
              1 fs/xfs/scrub/agheader.c:89:2: warning: unannotated fall-through between switch labels [-Wimplicit-fallthrough]
           3507 include/linux/jhash.h:113:2: warning: unannotated fall-through between switch labels [-Wimplicit-fallthrough]

Number of times emitted?


