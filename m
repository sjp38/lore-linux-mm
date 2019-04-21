Return-Path: <SRS0=izd7=SX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7862EC10F14
	for <linux-mm@archiver.kernel.org>; Sun, 21 Apr 2019 13:52:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 153ED20859
	for <linux-mm@archiver.kernel.org>; Sun, 21 Apr 2019 13:52:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 153ED20859
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=users.sourceforge.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FE2B6B0003; Sun, 21 Apr 2019 09:52:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D55A6B0006; Sun, 21 Apr 2019 09:52:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C3ED6B0007; Sun, 21 Apr 2019 09:52:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4F7256B0003
	for <linux-mm@kvack.org>; Sun, 21 Apr 2019 09:52:38 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y2so5889287pfl.16
        for <linux-mm@kvack.org>; Sun, 21 Apr 2019 06:52:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:from:to:cc:subject:in-reply-to:references:user-agent
         :mime-version;
        bh=KJ/5mMgktrZEbYGiKpOUu57Gti1Uben4mZN1ElLNLyQ=;
        b=X2VCo3wzSFpAJY7Pvwxv3X3AdhQnkfSeagrDuyJ+XIQ/Hy9lsBC8fFoVrNzAbRm5Ky
         BjdcQdnxa7Uk62OuAaGOJ7vDkMvaWCVzMq+d0ZMx2aQPiX1f4dPBzqphi5wTOnfu1LOg
         Myeb3jLP3b4mPue1Ek6F306gcGks89GvADcocrxbTeCs+liBwZPLRGMadxugcD1Y83SQ
         B9fOIATcppXh++xUOdee8s++W1rP4T8jh1pRRSH3rIVniqi4PsRF4I9SOz6/R5d4BzU/
         ASsXQpJu3RG3r885YjmERgrmiNWcybZH1qCg/rcayHeNOKTX806zRuew83VtcafjCbS6
         bKGw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning ysato@users.sourceforge.jp does not designate 202.224.55.15 as permitted sender) smtp.mailfrom=ysato@users.sourceforge.jp
X-Gm-Message-State: APjAAAVzAzFI8coAAIAg2hhWeGYnzVUYu6S5P5sxetwQqz9SuZGxaeZb
	mrzZLeYsnhoYdhkSUQCyuGJo4bp7XG/I+wvYmclkGGYzSgHZn3Dq3nVyAG40GUjS2a25EL5J7wV
	EXpl4su63SJ8LgasfcAp577urZVC0f2+yay527TpX0WU8yhXAMbacyQft4rLC/Xw=
X-Received: by 2002:a17:902:aa91:: with SMTP id d17mr14766298plr.43.1555854757969;
        Sun, 21 Apr 2019 06:52:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzMTEvjMhOIHlDocU9nTakh1aTHsdLNXXygz9QcS6ajAZv1IJXCWCQTBuT1BrcJe5V4JjIe
X-Received: by 2002:a17:902:aa91:: with SMTP id d17mr14766234plr.43.1555854756966;
        Sun, 21 Apr 2019 06:52:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555854756; cv=none;
        d=google.com; s=arc-20160816;
        b=kGyvS4cac5FC4JCgxcTeboua3uz1pDkiFniohESMs9639A1q9Ygc1gW1QMeSIN/6zQ
         +YE0TTJ8siflL3JFt66rThPizHRInAcSupQ7VZ5uvfpYfhmehS3uhvQlEYSMBGxOuNMU
         LKaQsl0etczZnmPsh10XVIstUm8pS29ImRh0MGIByLBBBJSlSlwxeetQezKmunnv/xlE
         HD4MzH+VqMWB1CFH0eIqayKQ0Qz430W+m62xq/1CX5gD6EdR863CAj3k4oJWpm+gSqMH
         EZJO9pCfbdsWEgHvznbi/TEdT7Nt+hO8FlS/X8kbHs35QqiqHcSW20yZ9w0qd+DRNEEd
         uNBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:in-reply-to:subject:cc:to:from
         :message-id:date;
        bh=KJ/5mMgktrZEbYGiKpOUu57Gti1Uben4mZN1ElLNLyQ=;
        b=09raZPeQcQKSI76sAbOLv0AMjld8GEVv4a+pnUpnbjF4mE3MX+XYqzB8WRWdjdQE8I
         4up3xmKbx4J8iUGTaalD0sqwgmjJmZttPZ2m1L9EzSfXtJ+na9IxlQkHpTkhLYrcAFV5
         jbWCgR/Upr2xPOw8yHQ0q2ysUdfd7jMEigNW3VmqjjpMiHtYXgpjadgpzWiVGjKVMJ1L
         vlQcgwPE/4GuCCst1f2MXme0jKkhAEHiZuvVS9JE7rmbEICcwZHErni6qK6fDbF/8v5R
         KzCnaONraiawzmKb5sbrVb2rkjSY5T9GsvkQwj6qDYTCXdcAPrIyfRku7hNDFdBQ7knm
         dPFg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning ysato@users.sourceforge.jp does not designate 202.224.55.15 as permitted sender) smtp.mailfrom=ysato@users.sourceforge.jp
Received: from mail03.asahi-net.or.jp (mail03.asahi-net.or.jp. [202.224.55.15])
        by mx.google.com with ESMTP id p91si8496462plb.230.2019.04.21.06.52.36
        for <linux-mm@kvack.org>;
        Sun, 21 Apr 2019 06:52:36 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning ysato@users.sourceforge.jp does not designate 202.224.55.15 as permitted sender) client-ip=202.224.55.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning ysato@users.sourceforge.jp does not designate 202.224.55.15 as permitted sender) smtp.mailfrom=ysato@users.sourceforge.jp
Received: from h61-195-96-97.vps.ablenet.jp (h61-195-96-97.vps.ablenet.jp [61.195.96.97])
	(Authenticated sender: PQ4Y-STU)
	by mail03.asahi-net.or.jp (Postfix) with ESMTPA id 629C73E591;
	Sun, 21 Apr 2019 22:52:35 +0900 (JST)
Received: from yo-satoh-debian.ysato.ml (ZM005235.ppp.dion.ne.jp [222.8.5.235])
	by h61-195-96-97.vps.ablenet.jp (Postfix) with ESMTPSA id 00597240082;
	Sun, 21 Apr 2019 22:52:28 +0900 (JST)
Date: Sun, 21 Apr 2019 22:52:28 +0900
Message-ID: <87sgubcvoj.wl-ysato@users.sourceforge.jp>
From: Yoshinori Sato <ysato@users.sourceforge.jp>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: kbuild test robot <lkp@intel.com>,
	kbuild-all@01.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	paul.mundt@gmail.com,
	Rich Felker <dalias@libc.org>,
	Linux-sh list <linux-sh@vger.kernel.org>
Subject: Re: arch/sh/kernel/cpu/sh2/clock-sh7619.o:undefined reference to `followparent_recalc'
In-Reply-To: <fb6880d2-06a4-cec2-e12c-c526d3a4358a@infradead.org>
References: <201904201516.DdPznV5M%lkp@intel.com>
	<fb6880d2-06a4-cec2-e12c-c526d3a4358a@infradead.org>
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

On Sun, 21 Apr 2019 04:34:36 +0900,
Randy Dunlap wrote:
> 
> On 4/20/19 12:40 AM, kbuild test robot wrote:
> > Hi Randy,
> > 
> > It's probably a bug fix that unveils the link errors.
> > 
> > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> > head:   371dd432ab39f7bc55d6ec77d63b430285627e04
> > commit: acaf892ecbf5be7710ae05a61fd43c668f68ad95 sh: fix multiple function definition build errors
> > date:   2 weeks ago
> > config: sh-allmodconfig (attached as .config)
> > compiler: sh4-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
> > reproduce:
> >         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         git checkout acaf892ecbf5be7710ae05a61fd43c668f68ad95
> >         # save the attached .config to linux build tree
> >         GCC_VERSION=7.2.0 make.cross ARCH=sh 
> 
> Hi,
> 
> Once again, the question is the validity of the SH2 .config file in this case
> (that was attached).
> 
> I don't believe that it is valid because CONFIG_SH_DEVICE_TREE=y,
> which selects COMMON_CLK, and there is no followparent_recalc() in the
> COMMON_CLK API.
> 
> Also, while CONFIG_HAVE_CLK=y, drivers/sh/Makefile prevents that from
> building clk/core.c, which could provide followparent_recalc():
> 
> ifneq ($(CONFIG_COMMON_CLK),y)
> obj-$(CONFIG_HAVE_CLK)			+= clk/
> endif
> 
> Hm, maybe that's where the problem is.  I'll look into that more.
>

Yes.
Selected target (CONFIG_SH_7619_SOLUTION_ENGINE) is non devicetree
and used superh specific clk modules.
So allyesconfig output is incorrect.

I fixed Kconfig to output the correct config.

> 
> 
> It would be Good if someone from the SuperH area could/would comment.
> 
> Thanks.
> 
> 
> > If you fix the issue, kindly add following tag
> > Reported-by: kbuild test robot <lkp@intel.com>
> > 
> > 
> > All errors (new ones prefixed by >>):
> > 
> >>> arch/sh/kernel/cpu/sh2/clock-sh7619.o:(.data+0x1c): undefined reference to `followparent_recalc'
> > 
> > ---
> > 0-DAY kernel test infrastructure                Open Source Technology Center
> > https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> > 
> 
> 
> -- 
> ~Randy

-- 
Yosinori Sato

