Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EE12C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:35:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB146214AE
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 17:35:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="lcyKxotY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB146214AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 57B066B0007; Tue, 23 Apr 2019 13:35:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5531E6B0008; Tue, 23 Apr 2019 13:35:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46AA16B000A; Tue, 23 Apr 2019 13:35:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id EF2176B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 13:35:45 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id x5so6266491wro.13
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 10:35:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=0lW8tbqTddRuthpqdeLLF9UYeGcIn5hcXfw3DTezumc=;
        b=Ykgtd4X7jsj1x9IgiLhLHnoOymeBbxuaRi0/IWotyWoVeDlnezekNdexNoXZ6C39JL
         fph/uV8UeZ2x2Pxa0sUfE4NGNlDkpyLQiXbZoJkOFTVNkNW9nzS4jCrqxSB4Hu0D61+K
         1wep5HQLifd6FRDEuZjeT9nSbRxD3MbhsrMJcgrsC5sLei9DHKVDI3nEymxqjxqqDnLc
         kn2qprbP5QT8vggpiTc9/DsYDwYzQWUJrsfYZmbr6Xb1089AZzkhnNcfY23v6P3DRmRX
         WA+hQ9KnIIaAgr+ysdQ2Dr4ibF01R8+yPO+kQJIps+KCDiD4u2h4cZeAdVPksI3EFmBa
         ttOA==
X-Gm-Message-State: APjAAAWB+up37+MhFiQBIG07/1ctKBBant0iTBj8DJLpPhHOLdW8D+/P
	G0QE7wdoH2Q6k5rzhSyIvmZGtGH8lLGeMF9UceU0/nFSJCdTQiOM5QYvclZZl6WtJRGi82/v/DQ
	/V4tQOEXP8xG9bO5mBVPR+jWiFFL17v8Z5LZNZXaQw/8FHIv25L4Lm9n42VixEbz46w==
X-Received: by 2002:a1c:2104:: with SMTP id h4mr3208537wmh.146.1556040945439;
        Tue, 23 Apr 2019 10:35:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIx3xsl0EfL2g8EL8ahBAbQsMCAXCNlIwmeaxPHMgqhPeo9knXJvVb+dQwka/REovLKRqR
X-Received: by 2002:a1c:2104:: with SMTP id h4mr3208494wmh.146.1556040944579;
        Tue, 23 Apr 2019 10:35:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556040944; cv=none;
        d=google.com; s=arc-20160816;
        b=MEDx4Sp+JiqtPous6lp5ieXMcakHnBAF3tTqwd79QjT4zXFGl4jZnMTTD+kWr4yFHh
         42ryWqiSVMmYUZ5hkcrdGgVhlk5hconRkRLOvhm+FVUIfR4zQyyVnE2GV7wCIU5BExA1
         CGDAchHZvHEluWcB06iJjbNUosQgVAcrMliSrnRa/AMki0vALonmEbW9zU1uge3U5geh
         R5OZPVo0jNyBiFamusVB6EQTMhFdI4cs7uJQnJ+KhSPhEcl3VRGngGzqGWHlix+DmOan
         e3ytA04+QtQghCYQC4Zep5o+y8E1LQqf3n48rGkizS66QBQLOx1sSFP2+zpHVc0uDoKg
         EYTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=0lW8tbqTddRuthpqdeLLF9UYeGcIn5hcXfw3DTezumc=;
        b=kRMls9oBf9t0j19ucZ4LSf4Oh4MRMnyOYxUByuCqyrkaOWarHvFatf7/jWrop/nhI8
         +1hM6ikCduqYcSBhHYWB2kuKYp3QGtJJ9A91FWSEnvVmYhGIlU3KgMx6xYVzTJyBWPmz
         0VtrxHLrSTvoQap/bYArSDxmpnAb/23t9uzWPKupaBZ8I7GALx59zU70/DfWOlABMr8i
         uarM5MUs+9MNi63uY0RAfzoP6P2tyqYnuRoRViZXFRs5EURygaLpawws2gO6tgBBUxHr
         QoNgn/mWZcLdIq8g88PiCPo/v8P5R7TE2nAEPrBRpoP7Znov4KiL5Fu8x9PWdEIYGftA
         6yXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=lcyKxotY;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id v24si11345911wmc.92.2019.04.23.10.35.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 10:35:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=lcyKxotY;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=0lW8tbqTddRuthpqdeLLF9UYeGcIn5hcXfw3DTezumc=; b=lcyKxotYB9WxRLGq88wyETmzX
	CHxTlNqSxDwnjGi/iUX7VOXSynOIe/toKeJvmexzjiKk5pDHVdKLWVeI6n3RJbBAiMRzeAdU7G5xT
	WSwfKHQqMUJjgZ29BaB92iEPOz8aEaKtw47EylFWGMkWhonOlH3leVRjcXv1Lc3cMvDNBTkasKCG1
	FeMlBSMLatvz5r+md3+mqjPJKUF66uSX/qo1sMdalHd5IFNiNLNZZgcVLfGBDg1Jy0SYCllqRTKYH
	2nIXYiRbsLjhwC+kbeRRmUbSJCtd4DgtFGRE+v1NlDx9TQxFC3RYN8irwEkB5L/caWIccY0Mcv1Im
	gX5UpRiBA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hIzKV-0007VH-0n; Tue, 23 Apr 2019 17:35:39 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id BF08029C30E04; Tue, 23 Apr 2019 19:35:37 +0200 (CEST)
Date: Tue, 23 Apr 2019 19:35:37 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Randy Dunlap <rdunlap@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mark Brown <broonie@kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>, linux-next@vger.kernel.org,
	mhocko@suse.cz, mm-commits@vger.kernel.org,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Josh Poimboeuf <jpoimboe@redhat.com>,
	Andy Lutomirski <luto@kernel.org>
Subject: Re: mmotm 2019-04-19-14-53 uploaded (objtool)
Message-ID: <20190423173537.GI12232@hirez.programming.kicks-ass.net>
References: <20190419215358.WMVFXV3bT%akpm@linux-foundation.org>
 <af3819b4-008f-171e-e721-a9a20f85d8d1@infradead.org>
 <20190423082448.GY11158@hirez.programming.kicks-ass.net>
 <CAHk-=wg_yKXPmkTcHWPsf61BXNLzz9bEUDWboN4QfeHKZsCoXA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wg_yKXPmkTcHWPsf61BXNLzz9bEUDWboN4QfeHKZsCoXA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 09:19:50AM -0700, Linus Torvalds wrote:

> Ack on that patch. Except I think the uaccess.h part should be a
> separate commit: 

Of course, I'll go write proper patches.

