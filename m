Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2ACDC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 10:33:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6904C21479
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 10:33:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6904C21479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F27336B0007; Wed,  8 May 2019 06:33:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED6936B0008; Wed,  8 May 2019 06:33:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9F3F6B000A; Wed,  8 May 2019 06:33:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8426B0007
	for <linux-mm@kvack.org>; Wed,  8 May 2019 06:33:12 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c1so15580628edi.20
        for <linux-mm@kvack.org>; Wed, 08 May 2019 03:33:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kHKXOE0hd25mZipRI/XQORTPma8qf63F5MXrMGRmQjc=;
        b=rqE0GRUgjdYPX6y9u61wsyRRLGs/KrNoASFYlrHeekXqyud9h2Kgjx25XBVXcapczA
         G0Jno8ktKNHVSVOdmQYcJwSjokQUR7Ok6kPFCA/0j5Xd1c4Qcryd6l889vJavJsOruhd
         ZB4GqotICj0utFunsRgrcL2SJAul1LOM2fcCKatewJs+u5xWzRv9kkt8hj7lg0Ktoqma
         OLvWMRtBeN0kwwD5lOKKJmt/MEMK5ZNUAqhTRl0gWHl/Q1Zwdb2jAEpWlANLpT2I4AJ7
         Z2ZOCH7J9gv06OXwIKYkvvm/1QYi3F8QTiEVDLvxI4kgaEr24QIKHuN04YceBk1tXNGK
         vcfQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAXGM2/DSJwufas6kSvk4xFoEkqtFzg0aD5bJRV+fJ6N714feGRg
	Hp2ICoW7HupbMYJHcQYUXesv7K2kxyj/YydiGCv82b4sXJo4P0pamxTeoIBzuFenFcg3kXmV8Zx
	p67JugdFXLfW6wsf/eySLyxD3P5PW4PyxgAfW7wCLr5Z2oMJRqsZYDSDOT0uKUfVZMg==
X-Received: by 2002:a17:906:1e89:: with SMTP id e9mr14663965ejj.161.1557311592141;
        Wed, 08 May 2019 03:33:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy26UaPSAYK6UauKpNvy7qOgRRIAjdttdKH15qGh3bXR8Nd39I1OAMyZI1QRb7HRAVurQzz
X-Received: by 2002:a17:906:1e89:: with SMTP id e9mr14663900ejj.161.1557311591066;
        Wed, 08 May 2019 03:33:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557311591; cv=none;
        d=google.com; s=arc-20160816;
        b=OHtfFEm2MV/Kz6bfBtC+Dw8o29W+eR2As7e35KgpeJWsRUmK+ez31iGhHByOocPQyO
         jv49KVlbYQVR/OOUpsztBpoz7+E+xxr40XyC125IrfaSIPae6gXuZMUJQblo0CBDRjbz
         7zzlp/VnYx4hM4dZF8t1Cc9u87CsNhSBP5N0KdhfK6iqtH4XS4saNDQ0qAHhkyOKZGfs
         R5jzRTgGGzm/l/nKKUra9FuqkubaiJMuVeWHh/Cqb3pl3vcdd0IC/G3Pz73ZA4u5vatF
         OmBNGY7Pey5cQ/2opt7Hd/FA/hj+JHy6XUlXdZY1uT8FM1yfkD9uRM7bs6IO6ycdlrpE
         tm3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kHKXOE0hd25mZipRI/XQORTPma8qf63F5MXrMGRmQjc=;
        b=LU1wxbI+gS0h5A3SA8fbjIMzhcMIRY5cL7K4TxJhGTl/5X03MtsYXzYiG/F3y/xRT/
         pnmdFLo+RNh0rIP7IC5vcW3C+56qUUC3xtVB5rnQ8i7kQb7OHcGn/DrUn9DqreRiiMry
         Y08FM4dniy+HEnYoAl+aQa00nBePd5e0Ue/OpjkJi/fBMdt5O+KHZs7htP7Mw1MWgKP/
         oH3gFaVkj8iS+7bokPierBMLgMwSxbQMzPxZ08hQj3zYQ5Zgm2GbVsqxdLyczhN7t5xe
         3WWbE5eKsgw8eMCKTYTcGdbVYDYVXJZ/JIQ2CDtVhxRe4ukRujXIVUHgfS1KoijAYMqo
         ptHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id gz22si5361025ejb.181.2019.05.08.03.33.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 03:33:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) client-ip=81.17.249.8;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 8DC9E98817
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:33:10 +0000 (UTC)
Received: (qmail 30530 invoked from network); 8 May 2019 10:33:10 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 8 May 2019 10:33:10 -0000
Date: Wed, 8 May 2019 11:33:08 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Dexuan Cui <decui@microsoft.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>, Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Roman Gushchin <guro@fb.com>, Hugh Dickins <hughd@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	"dchinner@redhat.com" <dchinner@redhat.com>,
	Greg Thelen <gthelen@google.com>,
	Kuo-Hsin Yang <vovoy@chromium.org>
Subject: Re: isolate_lru_pages(): kernel BUG at mm/vmscan.c:1689!
Message-ID: <20190508103308.GF18914@techsingularity.net>
References: <PU1P153MB01693FF5EF3419ACA9A8E1FDBF3B0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <PU1P153MB01693FF5EF3419ACA9A8E1FDBF3B0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 01, 2019 at 11:49:10PM +0000, Dexuan Cui wrote:
> Hi,
> Today I got the below BUG in isolate_lru_pages() when building the kernel.
> 
> My current running kernel, which exhibits the BUG, is based on the mainline kernel's commit 
> 262d6a9a63a3 ("Merge branch 'x86-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip").
> 
> Looks nobody else reported the issue recently.
> 

That is missing some fixes that were merged for 5.1, particularly
6b0868c820ff ("mm/compaction.c: correct zone boundary handling when
resetting pageblock skip hints"). Can you try reproducing this under 5.1
at least?

-- 
Mel Gorman
SUSE Labs

