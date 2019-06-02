Return-Path: <SRS0=2YS/=UB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CC3CC282DC
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 07:13:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC95024504
	for <linux-mm@archiver.kernel.org>; Sun,  2 Jun 2019 07:13:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC95024504
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=users.sourceforge.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0EB466B0003; Sun,  2 Jun 2019 03:13:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09BCB6B0005; Sun,  2 Jun 2019 03:13:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECCAF6B0006; Sun,  2 Jun 2019 03:13:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B6A5D6B0003
	for <linux-mm@kvack.org>; Sun,  2 Jun 2019 03:13:12 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 14so7597834pgo.14
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 00:13:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:from:to:cc:subject:in-reply-to:references:user-agent
         :mime-version;
        bh=hoIsIC0OdxCZWAu3i73CuxlwvR004kEXmbYyVxwxMtM=;
        b=hpT4OgHEX+HUgeKR4HfJSYlXH9S4jY7Te/QQM8lCIOcHxgvm+89ba9qduyR2VQ/+IF
         pyj8zRyuZYb4VfnUgf3y2eoZ8B3Q8rrIOSCZNtwdCNcu07pLnBHxW/yDPfn4EuOxIgwQ
         a5Mm9ExmtDWtgVrchyKjJEIaGe2roXrvzmw+DtGd7s5/6dHruoWZqfOZ7IJd0ROHee2t
         AF0e3yl0J3dc23WCkrcI/W50OtEfkwYWRdSRHvYR4PPS1UNB5l8p2XmKYc8VSbwfEL00
         hIMgzq3GhqDYA0wl//K28zLRiPkXS9IE0J522EKrCCwFAaD4Ir2sb8TkXuDKSrNZYmpD
         vWiQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning ysato@users.sourceforge.jp does not designate 202.224.55.15 as permitted sender) smtp.mailfrom=ysato@users.sourceforge.jp
X-Gm-Message-State: APjAAAXyTbfrvXStbUBuQ67O+t3Axa2N99MBEV8nadZca4tv+z+9h6Cu
	DWK12l+vWxtLWUg2QWSlpXvPNxvbkxg/rttliBLpa3vyRvaNBiSzn6zIFnPcpmlaa10kFiFyMGJ
	ZghdegUWgsF0uEqU64kih0OXb5Gbmm5K337l9lyg0Mew+/RBH6fb6bLckVZIeGg0=
X-Received: by 2002:a63:fc55:: with SMTP id r21mr20259888pgk.441.1559459592213;
        Sun, 02 Jun 2019 00:13:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzOb1oUwFduODZEB9jjHk5/+eBSI3S/FA/Jcx2Gr5EhILnA6N2nw5QMjr7NlV5c8ghgCuKT
X-Received: by 2002:a63:fc55:: with SMTP id r21mr20259845pgk.441.1559459591057;
        Sun, 02 Jun 2019 00:13:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559459591; cv=none;
        d=google.com; s=arc-20160816;
        b=L4YZGSk8rxOdmhWvLjgJTY2WunRIPePI9qx9JtZmhaEGdQHDmZfe0/VwqwSFjLY+bN
         aSe5aC+BAmiKX0jqi38IFvEcwJXkSHxKCw0HjwumpE5AOdt3cVabTHtDRGyUrker5a5w
         kebXi2Q6iFw6fsfD7p7fRoR/T4e+YJdwdU44/neaK3lNavnQIFtM06BbcdFqH2GOqHL8
         jFwfkLjrGl4lStzsy9o0LmT0D1bqGhW4X2xtRrnqtfSaMRyhN1U+EH8mLluNKKLaVxif
         YUeBj+MsMcuyOLIgrUbK2WFN+5xfDCts0fF6rITUmnoyxZSRcRmrLWHWkkMSpq6tDgmC
         dG/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:in-reply-to:subject:cc:to:from
         :message-id:date;
        bh=hoIsIC0OdxCZWAu3i73CuxlwvR004kEXmbYyVxwxMtM=;
        b=UWovWicfTB615BJzUUCLEFEiQL75lscBBs3sFzbM+it5wJYXqGqZUMGFYbSELLYI+Q
         ne3+5WuEIOxb8X3lnDUghhDtdjpQXQf6mBjI15++A20JzDJeYpYbNNHX3RavxgXAjBCU
         W0SyyCvdCLn5tLSrjB6lP1j0dS/CP6vCllNOM4BvfNnXQuZ2TWrRB+jo/0nmCCX/It+s
         A09PLrToyTDS30AZk9ghJkbW3XseuoekPtX099j54fW+RhXkkkfoAJZNuIfvC6utP4FS
         4E9etGFHV6T9zHnfDqZh2Z7P4U8dIGfwfNnb8wWvEDusVHigAOZstHdTVro062WTq0ey
         vuJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning ysato@users.sourceforge.jp does not designate 202.224.55.15 as permitted sender) smtp.mailfrom=ysato@users.sourceforge.jp
Received: from mail03.asahi-net.or.jp (mail03.asahi-net.or.jp. [202.224.55.15])
        by mx.google.com with ESMTP id j23si14521195pfh.215.2019.06.02.00.13.10
        for <linux-mm@kvack.org>;
        Sun, 02 Jun 2019 00:13:11 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning ysato@users.sourceforge.jp does not designate 202.224.55.15 as permitted sender) client-ip=202.224.55.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning ysato@users.sourceforge.jp does not designate 202.224.55.15 as permitted sender) smtp.mailfrom=ysato@users.sourceforge.jp
Received: from h61-195-96-97.vps.ablenet.jp (h61-195-96-97.ablenetvps.ne.jp [61.195.96.97])
	(Authenticated sender: PQ4Y-STU)
	by mail03.asahi-net.or.jp (Postfix) with ESMTPA id 6199949B1B;
	Sun,  2 Jun 2019 16:13:07 +0900 (JST)
Received: from yo-satoh-debian.ysato.ml (ZM005235.ppp.dion.ne.jp [222.8.5.235])
	by h61-195-96-97.vps.ablenet.jp (Postfix) with ESMTPSA id CC84E240085;
	Sun,  2 Jun 2019 16:13:06 +0900 (JST)
Date: Sun, 02 Jun 2019 16:13:04 +0900
Message-ID: <871s0cqx33.wl-ysato@users.sourceforge.jp>
From: Yoshinori Sato <ysato@users.sourceforge.jp>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Randy Dunlap <rdunlap@infradead.org>, kbuild test robot <lkp@intel.com>,
 kbuild-all@01.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management
 List <linux-mm@kvack.org>, "Sasha Levin (Microsoft)" <sashal@kernel.org>,
 Rich Felker <dalias@libc.org>, linux-sh@vger.kernel.org
Subject: Re: [linux-stable-rc:linux-5.0.y 1434/2350] arch/sh/kernel/cpu/sh2/clock-sh7619.o:undefined reference to `followparent_recalc'
In-Reply-To: <20190531100004.0b1f4983@canb.auug.org.au>
References: <201905301509.9Hu4aGF1%lkp@intel.com>	<92c0e331-9910-82e9-86de-67f593ef4e5d@infradead.org>	<20190531100004.0b1f4983@canb.auug.org.au>
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

On Fri, 31 May 2019 09:00:04 +0900,
Stephen Rothwell wrote:
> 
> [1  <text/plain; US-ASCII (quoted-printable)>]
> Hi all,
> 
> On Thu, 30 May 2019 07:43:10 -0700 Randy Dunlap <rdunlap@infradead.org> wrote:
> >
> > On 5/30/19 12:31 AM, kbuild test robot wrote:
> > > Hi Randy,
> > > 
> > > It's probably a bug fix that unveils the link errors.
> > > 
> > > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable-rc.git linux-5.0.y
> > > head:   8c963c3dcbdec7b2a1fd90044f23bc8124848381
> > > commit: b174065805b55300d9d4e6ae6865c7b0838cc0f4 [1434/2350] sh: fix multiple function definition build errors
> > > config: sh-allmodconfig (attached as .config)
> > > compiler: sh4-linux-gcc (GCC) 7.4.0
> > > reproduce:
> > >         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
> > >         chmod +x ~/bin/make.cross
> > >         git checkout b174065805b55300d9d4e6ae6865c7b0838cc0f4
> > >         # save the attached .config to linux build tree
> > >         GCC_VERSION=7.4.0 make.cross ARCH=sh 
> > > 
> > > If you fix the issue, kindly add following tag
> > > Reported-by: kbuild test robot <lkp@intel.com>
> > > 
> > > All errors (new ones prefixed by >>):
> > >   
> > >>> arch/sh/kernel/cpu/sh2/clock-sh7619.o:(.data+0x1c): undefined reference to `followparent_recalc'  
> > > 
> > > ---
> > > 0-DAY kernel test infrastructure                Open Source Technology Center
> > > https://lists.01.org/pipermail/kbuild-all                   Intel Corporation  
> > 
> > 
> > The maintainer posted a patch for this but AFAIK it is not merged anywhere.
> > 
> > https://marc.info/?l=linux-sh&m=155585522728632&w=2
> 
> Unfortunately, the sh tree (git://git.libc.org/linux-sh#for-next) has
> been removed from linux-next due to lack of any updates in over a year,
> but I will add that patch (see below) to linux-next today, but someone
> will need to make sure it gets to Linus at some point (preferably
> sooner rather than later).  (I can send it if someone associated with
> the sh development wants/asks me to ...)

OK.
Since I created a temporary sh-next, please get it here.
git://git.sourceforge.jp/gitroot/uclinux-h8/linux.git tags/sh-next

It same host of h8300-next.

> From: Yoshinori Sato <ysato@users.sourceforge.jp>
> Date: Sun, 21 Apr 2019 14:00:16 +0000
> Subject: [PATCH] sh: Fix allyesconfig output
> 
> Conflict JCore-SoC and SolutionEngine 7619.
> 
> Reported-by: kbuild test robot <lkp@intel.com>
> Acked-by: Randy Dunlap <rdunlap@infradead.org> # build-tested
> Signed-off-by: Yoshinori Sato <ysato@users.sourceforge.jp>
> ---
>  arch/sh/boards/Kconfig | 14 +++-----------
>  1 file changed, 3 insertions(+), 11 deletions(-)
> 
> diff --git a/arch/sh/boards/Kconfig b/arch/sh/boards/Kconfig
> index b9a37057b77a..cee24c308337 100644
> --- a/arch/sh/boards/Kconfig
> +++ b/arch/sh/boards/Kconfig
> @@ -8,27 +8,19 @@ config SH_ALPHA_BOARD
>  	bool
>  
>  config SH_DEVICE_TREE
> -	bool "Board Described by Device Tree"
> +	bool
>  	select OF
>  	select OF_EARLY_FLATTREE
>  	select TIMER_OF
>  	select COMMON_CLK
>  	select GENERIC_CALIBRATE_DELAY
> -	help
> -	  Select Board Described by Device Tree to build a kernel that
> -	  does not hard-code any board-specific knowledge but instead uses
> -	  a device tree blob provided by the boot-loader. You must enable
> -	  drivers for any hardware you want to use separately. At this
> -	  time, only boards based on the open-hardware J-Core processors
> -	  have sufficient driver coverage to use this option; do not
> -	  select it if you are using original SuperH hardware.
>  
>  config SH_JCORE_SOC
>  	bool "J-Core SoC"
> -	depends on SH_DEVICE_TREE && (CPU_SH2 || CPU_J2)
> +	select SH_DEVICE_TREE
>  	select CLKSRC_JCORE_PIT
>  	select JCORE_AIC
> -	default y if CPU_J2
> +	depends on CPU_J2
>  	help
>  	  Select this option to include drivers core components of the
>  	  J-Core SoC, including interrupt controllers and timers.
> -- 
> 2.11.0
> 
> -- 
> Cheers,
> Stephen Rothwell
> [2 OpenPGP digital signature <application/pgp-signature (7bit)>]
> No public key for 015042F34957D06C created at 2019-05-31T09:00:04+0900 using RSA

-- 
Yosinori Sato

