Return-Path: <SRS0=q2Op=WO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 655E0C3A589
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 10:16:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 060D321773
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 10:16:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=armlinux.org.uk header.i=@armlinux.org.uk header.b="T+Qa2ujM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 060D321773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=armlinux.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F0696B0008; Sun, 18 Aug 2019 06:16:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 679986B000A; Sun, 18 Aug 2019 06:16:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 518EF6B000C; Sun, 18 Aug 2019 06:16:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0099.hostedemail.com [216.40.44.99])
	by kanga.kvack.org (Postfix) with ESMTP id 2B8716B0008
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 06:16:15 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id BE8C4908F
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 10:16:14 +0000 (UTC)
X-FDA: 75835143468.23.cap71_365bd31aafc5f
X-HE-Tag: cap71_365bd31aafc5f
X-Filterd-Recvd-Size: 4160
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk [78.32.30.218])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 10:16:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=armlinux.org.uk; s=pandora-2019; h=Sender:In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=eI80pY+n2LcdriTG3iXes2m396KdvY2t7uB/aQuv8IQ=; b=T+Qa2ujMwImGwBV5ZZMW9QElR
	1ROMsPYIUnKSa+03tQv+hatImsj6huflHU8bLfJIQwoRHvzHjCMNunJsIvGelUlR/7Ecyx2MIyQpJ
	F1gSPC9chPx22jkcvTJiLw5SHMad/lR6ywCcPVrovZoJ8Sh0e7y3TiNFxpukHBxV9F+T6VFjxVOQY
	n3yRQOaLfcVL/Ta45RL7l3Qz7kOwt/HMIdQ+dEYoQrT7ksdUB8RKmO6YwSAhw7jhwRJ+Qh1CE77JP
	+OYV+E9PTgQ5uT9PFDO5AG6a+jc3akEdA2YJytBqc8sqS61sHF7kbqw30r6PQ/C/WTgzY3zsWN46M
	ZBxl/JVng==;
Received: from shell.armlinux.org.uk ([fd8f:7570:feb6:1:5054:ff:fe00:4ec]:58052)
	by pandora.armlinux.org.uk with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.90_1)
	(envelope-from <linux@armlinux.org.uk>)
	id 1hzIEA-0005Dq-HY; Sun, 18 Aug 2019 11:15:58 +0100
Received: from linux by shell.armlinux.org.uk with local (Exim 4.92)
	(envelope-from <linux@shell.armlinux.org.uk>)
	id 1hzIE3-0003m6-7B; Sun, 18 Aug 2019 11:15:51 +0100
Date: Sun, 18 Aug 2019 11:15:51 +0100
From: Russell King - ARM Linux admin <linux@armlinux.org.uk>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Zhaoyang Huang <huangzhaoyang@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Zhaoyang Huang <zhaoyang.huang@unisoc.com>,
	Rob Herring <robh@kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Doug Berger <opendmb@gmail.com>,
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] arch : arm : add a criteria for pfn_valid
Message-ID: <20190818101551.GN13294@shell.armlinux.org.uk>
References: <1566010813-27219-1-git-send-email-huangzhaoyang@gmail.com>
 <20190817183240.GM13294@shell.armlinux.org.uk>
 <CAGWkznEvHE6B+eLnCn=s8Hgm3FFbbXcEdj_OxCM4NOj0u61FGA@mail.gmail.com>
 <20190818082035.GD10627@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190818082035.GD10627@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 18, 2019 at 11:20:35AM +0300, Mike Rapoport wrote:
> On Sun, Aug 18, 2019 at 03:46:51PM +0800, Zhaoyang Huang wrote:
> > On Sun, Aug 18, 2019 at 2:32 AM Russell King - ARM Linux admin
> > <linux@armlinux.org.uk> wrote:
> > >
> > > On Sat, Aug 17, 2019 at 11:00:13AM +0800, Zhaoyang Huang wrote:
> > > > From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
> > > >
> > > > pfn_valid can be wrong while the MSB of physical address be trimed as pfn
> > > > larger than the max_pfn.
> > >
> > > What scenario are you addressing here?  At a guess, you're addressing
> > > the non-LPAE case with PFNs that correspond with >= 4GiB of memory?
> > Please find bellowing for the callstack caused by this defect. The
> > original reason is a invalid PFN passed from userspace which will
> > introduce a invalid page within stable_page_flags and then kernel
> > panic.

Thanks.

> Yeah, arm64 hit this issue a while ago and it was fixed with commit
> 5ad356eabc47 ("arm64: mm: check for upper PAGE_SHIFT bits in pfn_valid()").
> 
> IMHO, the check 
> 
> 	if ((addr >> PAGE_SHIFT) != pfn)
> 
> is more robust than comparing pfn to max_pfn.

Yep, I'd prefer to see:

	phys_addr_t addr = __pfn_to_phys(pfn);

	if (__pfn_to_phys(addr) != pfn)
		return 0;

	return memblock_is_map_memory(addr);

-- 
RMK's Patch system: https://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 12.1Mbps down 622kbps up
According to speedtest.net: 11.9Mbps down 500kbps up

