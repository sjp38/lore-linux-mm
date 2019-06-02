Return-Path: <SRS0=2YS/=UB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8590DC282DC
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 11:29:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CE99278F7
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 11:29:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CE99278F7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=users.sourceforge.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCE8E6B000E; Sun,  2 Jun 2019 07:29:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C7F676B0010; Sun,  2 Jun 2019 07:29:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B94F96B0266; Sun,  2 Jun 2019 07:29:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8550D6B000E
	for <linux-mm@kvack.org>; Sun,  2 Jun 2019 07:29:14 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id bb9so9616065plb.2
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 04:29:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:from:to:cc:subject:in-reply-to:references:user-agent
         :mime-version;
        bh=kV2+J0tBfMNuj8rjueqANgfAQptwBdgKKZh/a8slWow=;
        b=h7kyLHa87wssvR8RZ+fOoY5syevkZKglgfN+VHNv2MpSBJ2b2RwtwFB7HF4u+PQwgc
         vKlpCuFkJuLLFUJZefRtvGB2Ax/QpYkAhulaXujruy3m2LPGqvrHuXNlTuu3WPhdzvaW
         YDc//6sCa2G2kaWHvD9PLnhtP42mhczT1zZsCHj/xFhqi14d9abrLIO86xnL5fvh0o/7
         VGXwpN7NWyJUU3JzksKf0L1yQ25UuYL5Ds2GxB88FFnol8S7uZDp/lXNfCs/aP9CTQcN
         g8zSKkxVkkav71in2iZrQZoLpfN8Mbg8iy7iPtGnFSocSogIKzB7NUCfe9IEhj+O2Edj
         Uopg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning ysato@users.sourceforge.jp does not designate 202.224.55.14 as permitted sender) smtp.mailfrom=ysato@users.sourceforge.jp
X-Gm-Message-State: APjAAAUo7Cfr0cbsurM3gyXymm3hRAFbWUBvrEGj1HjEbRFgBVGbGXPU
	xGVB8qJYsBIleUCXRXKCO1SdnHKm3YuJ3p3cmsfJ2dpL1+kxdAib2fk50j4sw8ETHiKlxOvmWbl
	Q9F+egaDftyKEKGid+gQGBnmM7dvizsaaMa5l0su+dVI41MERAXV53nrChXYmRCs=
X-Received: by 2002:a17:90a:9201:: with SMTP id m1mr22542324pjo.38.1559474954060;
        Sun, 02 Jun 2019 04:29:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8ZbvNwglyCkWA/FpLigzQBXb1AhwDYFxUqWrxqjq5+SQCF3rTsuDivXXqYaOXllt1SNIv
X-Received: by 2002:a17:90a:9201:: with SMTP id m1mr22542237pjo.38.1559474953094;
        Sun, 02 Jun 2019 04:29:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559474953; cv=none;
        d=google.com; s=arc-20160816;
        b=zT54fR+jkGOMbIhqNJXhtRr0QfToowHA5hgKCFsLCJt24TpEH8JuG8+rGLHBEfdCh4
         u5bxu++lq/suiL0aJXsmC/oXPp/x1dS0Pq861nJEOzZJZ0yi41IC6WXc1qQqJFvLFML4
         tQ6dM2ZzQ2m+3oPuvCtAnEqJwweOzxLflkShpZWEVDeJ9fUXH7v4TarPdcRomIX09iAM
         +gzFs+N0AoXcJ14m6wZKp5XVeYEfxFfgmwKg0GI8/N2qQ3rlLO49iYnyTajpPR7zPtb1
         1OVCCYPFgVzn95dkpfVNtHxTmZd/vXW9NgSEVSgoIUWeeEav2hkAATkDkpNPVlPknYUQ
         AGpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:in-reply-to:subject:cc:to:from
         :message-id:date;
        bh=kV2+J0tBfMNuj8rjueqANgfAQptwBdgKKZh/a8slWow=;
        b=1LRTN8egF9FY28CG8c6Ay9p1h6lLUJJ+yfBedjNxIpXjiXzG1RWqtAvT+ErrM4QaXG
         3u8gXKE/X8RpNoy1yvSirl4v3RwC7/7ACZ15yzR12fHQ/nsXYfUS+Zul9ict/2IqGzsB
         Hw1lcn1si4YH0KG51TbpKFkibyC8miALNWopPmoya+xzRbCCAEZ9mngrRgEiY/bYyYPc
         kLRZuPvo85G1mMn+USQtv5yWWH4wCDvXOQp008/nHIc5Gr3BPGrnQT8LcON5ZjrdwMqj
         KZndhtX61naRc1DjB6vnkItSZlrwoceed48oYZ0A/VmNTjBRVOXHXIL1G6XrnLQ6Pdqm
         fIDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning ysato@users.sourceforge.jp does not designate 202.224.55.14 as permitted sender) smtp.mailfrom=ysato@users.sourceforge.jp
Received: from mail02.asahi-net.or.jp (mail02.asahi-net.or.jp. [202.224.55.14])
        by mx.google.com with ESMTP id i11si4657355pfa.240.2019.06.02.04.29.12
        for <linux-mm@kvack.org>;
        Sun, 02 Jun 2019 04:29:12 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning ysato@users.sourceforge.jp does not designate 202.224.55.14 as permitted sender) client-ip=202.224.55.14;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning ysato@users.sourceforge.jp does not designate 202.224.55.14 as permitted sender) smtp.mailfrom=ysato@users.sourceforge.jp
Received: from h61-195-96-97.vps.ablenet.jp (h61-195-96-97.ablenetvps.ne.jp [61.195.96.97])
	(Authenticated sender: PQ4Y-STU)
	by mail02.asahi-net.or.jp (Postfix) with ESMTPA id F02EF3ED0A;
	Sun,  2 Jun 2019 20:29:09 +0900 (JST)
Received: from yo-satoh-debian.ysato.ml (ZM005235.ppp.dion.ne.jp [222.8.5.235])
	by h61-195-96-97.vps.ablenet.jp (Postfix) with ESMTPSA id 51A19240085;
	Sun,  2 Jun 2019 20:29:09 +0900 (JST)
Date: Sun, 02 Jun 2019 20:29:08 +0900
Message-ID: <87y32kp6nv.wl-ysato@users.sourceforge.jp>
From: Yoshinori Sato <ysato@users.sourceforge.jp>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Randy Dunlap <rdunlap@infradead.org>,
	kbuild test robot <lkp@intel.com>,
	kbuild-all@01.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	"Sasha Levin (Microsoft)" <sashal@kernel.org>,
	Rich Felker <dalias@libc.org>,
	linux-sh@vger.kernel.org
Subject: Re: [linux-stable-rc:linux-5.0.y 1434/2350] arch/sh/kernel/cpu/sh2/clock-sh7619.o:undefined reference to `followparent_recalc'
In-Reply-To: <20190602174314.09f5f337@canb.auug.org.au>
References: <201905301509.9Hu4aGF1%lkp@intel.com>
	<92c0e331-9910-82e9-86de-67f593ef4e5d@infradead.org>
	<20190531100004.0b1f4983@canb.auug.org.au>
	<871s0cqx33.wl-ysato@users.sourceforge.jp>
	<20190602174314.09f5f337@canb.auug.org.au>
User-Agent: Wanderlust/2.15.9 (Almost Unreal) SEMI-EPG/1.14.7 (Harue)
 FLIM/1.14.9 (=?ISO-8859-4?Q?Goj=F2?=) APEL/10.8 EasyPG/1.0.0 Emacs/25.1
 (x86_64-pc-linux-gnu) MULE/6.0 (HANACHIRUSATO)
MIME-Version: 1.0 (generated by SEMI-EPG 1.14.7 - "Harue")
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 02 Jun 2019 16:43:14 +0900,
Stephen Rothwell wrote:
> 
> [1  <text/plain; US-ASCII (quoted-printable)>]
> Hi Yoshinori,
> 
> On Sun, 02 Jun 2019 16:13:04 +0900 Yoshinori Sato <ysato@users.sourceforge.jp> wrote:
> >
> > Since I created a temporary sh-next, please get it here.
> > git://git.sourceforge.jp/gitroot/uclinux-h8/linux.git tags/sh-next
> 
> I have added that tree to linux-next from tomorrow.  However, thet is
> no sh-next tag in that tree, so I used the sh-next branch.  I don't
> think you need the back merge of Linus' tree.

Oh sorry. I created sh-next branch in this git repository.

> Thanks for adding your subsystem tree as a participant of linux-next.  As
> you may know, this is not a judgement of your code.  The purpose of
> linux-next is for integration testing and to lower the impact of
> conflicts between subsystems in the next merge window. 
> 
> You will need to ensure that the patches/commits in your tree/series have
> been:
>      * submitted under GPL v2 (or later) and include the Contributor's
>         Signed-off-by,
>      * posted to the relevant mailing list,
>      * reviewed by you (or another maintainer of your subsystem tree),
>      * successfully unit tested, and 
>      * destined for the current or next Linux merge window.
> 
> Basically, this should be just what you would send to Linus (or ask him
> to fetch).  It is allowed to be rebased if you deem it necessary.
> 
> -- 
> Cheers,
> Stephen Rothwell 
> sfr@canb.auug.org.au
> [2 OpenPGP digital signature <application/pgp-signature (7bit)>]
> No public key for 015042F34957D06C created at 2019-06-02T16:43:14+0900 using RSA

-- 
Yosinori Sato

