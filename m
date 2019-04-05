Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB47DC4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 16:15:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AC1721738
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 16:15:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Xm4IYvSh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AC1721738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 009106B000D; Fri,  5 Apr 2019 12:15:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFA506B0266; Fri,  5 Apr 2019 12:15:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEA0D6B0269; Fri,  5 Apr 2019 12:15:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A83216B000D
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 12:15:09 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id n23so4469332plp.23
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 09:15:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:dkim-signature:from:in-reply-to
         :references:message-id:date:to:cc;
        bh=os94rMQjtwtlIWUYY8j+ceVK6d3dtC80R/qZR6kcSjA=;
        b=l+fWIcFynzSpo0MaSkrYspF1p2nh1Zl20I9SYA+fvXkXMagZKa9QKPXexk36IGdJIi
         iZ6ux707C/sNrE3wrFyqrFjewDV1KzHM0KDlksQgqeclu2gnJxCWwXCf8mH2ebgyKHzc
         gZt0RN/rQDqA1IlPE8uAFybU5cJX6faj3gmwjZkDIWsE3N511ovID2vhhMY0x4b9K7lv
         57gMW0cLK6kbaCxwgBBO81EuHSlODvU+WXNd4vCrWiWOLU2X+QzSZZ59v+usPj8oKVYp
         jRldZO6IDJ3OvUsWyqFcWlSeJ3BsL+zC3nnuHuJnphmJN+nvCCSxngkzVMbghKfE3b5e
         Ho9A==
X-Gm-Message-State: APjAAAUgHfjdx0tJNK/hJHkerxr/LWfeqv5kOr5vIfFrpU7JFzTLaWft
	1EL3lG7iH4E+hFWfPDIWJ77rRkL7jCk2W4ew1T9HfwYs2Su9NqgZmAh01RgsZxcaEJm9HCSpP7J
	V6vzA/wHcM4pXdEQRlpLu6GcVyCPUm6Q+IfY/OuK0nta8FWXg6O9AizRxkGF33v9x8g==
X-Received: by 2002:a17:902:241:: with SMTP id 59mr13990100plc.79.1554480908877;
        Fri, 05 Apr 2019 09:15:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLowBEDixWvanrEZ9lKnQlVZVufR0TDSPCmd0lKxvAcZP383EH0XNwu09vkaylRKgFytRa
X-Received: by 2002:a17:902:241:: with SMTP id 59mr13990029plc.79.1554480908230;
        Fri, 05 Apr 2019 09:15:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554480908; cv=none;
        d=google.com; s=arc-20160816;
        b=A2w9OO6MmeX+bUfyhZmkYT9T6H9WoLYfys0XfTl8g1jKoyyOd9wmS4qMZ5KwAkXJh/
         dKLB1TrUVEvPqyMnEmbGXywBDLu58YNjAGPyRNkGlA3qUqwW3pXdzqjFvl9CO9gRd5wy
         yTaqRsb/mLwPkgXjjmgYfAPVk69JVTnmyUxZfiBas6K5LeRgJopqFBhDRQ02pFfXeSUx
         JnOqndiwDGK0or/YaeGtCoF3LxRMfeG81nUNVW8MZZV6977rBcTg5UPby2lXz1oFeTSw
         9MZBHfCM1AaWCELYiggBjx0cOhGeYPQjTrFDV1pJ3P9c6tRgld4CE9IbzqjLm3bJFM1s
         Z+eQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:date:message-id:references:in-reply-to:from:dkim-signature
         :subject;
        bh=os94rMQjtwtlIWUYY8j+ceVK6d3dtC80R/qZR6kcSjA=;
        b=TB2ZRIZwEwgdb4TlH3npAKcF94cKku+w2Sv253zcMH5StZ9+3Lz5RgBbRna3PZPF+8
         7XwjtMsJxGXGNR2CzWQ93ZWll+8+9v04vnNdoaRBRijGbK3p+l61S28QXAaZd319m4CA
         j2YRU7CCcrbLPsvXD9T9EVup2WQUCqJHCX9Kl2/LYG0l5v+GfxcHYkn1YDYv2V9bGwZS
         4YgST3+7qLT6AkPRMoVmT5f6VpKx9PxOdNNA04OgEkGewY3KDlpOwrHzBSDVzBk6zbL2
         8D82uNjhc8Pa2Hu7IuhnJxq/z2S6fJqW0dALQamLIr6o+nku9IcY7XqlPkFlzs+yVElD
         wqFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Xm4IYvSh;
       spf=pass (google.com: domain of pr-tracker-bot@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=pr-tracker-bot@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 91si19602217ple.299.2019.04.05.09.15.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 09:15:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of pr-tracker-bot@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Xm4IYvSh;
       spf=pass (google.com: domain of pr-tracker-bot@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=pr-tracker-bot@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Subject: Re: [GIT PULL] mm/compaction functional fixes for v5.1-rc4
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1554480907;
	bh=plUQlTQPYkaqkLeaXJBwftjiVOKWe9aVbiuiD5rdM4Y=;
	h=From:In-Reply-To:References:Date:To:Cc:From;
	b=Xm4IYvShdWdMhzq0+R0HleCMvmyq+vnL9fsYFAIBE+8ywjzPQBfSAMJMJilt+8ShO
	 oIbko7FmwrreH66p9d3r68HBbjWsf2763H6N4LsBgjyAVDHHtJAz9U5IlQgl3GLUfl
	 +u9F4dJ7mULWS+Ij773H37UYyz5+RI/Wp64t5Ses=
From: pr-tracker-bot@kernel.org
In-Reply-To: <20190405135120.27532-1-mgorman@techsingularity.net>
References: <20190405135120.27532-1-mgorman@techsingularity.net>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20190405135120.27532-1-mgorman@techsingularity.net>
X-PR-Tracked-Remote: git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux.git
 tags/mm-compaction-5.1-rc4
X-PR-Tracked-Commit-Id: 5b56d996dd50a9d2ca87c25ebb50c07b255b7e04
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 7f46774c6480174eb869a3c15167eafac467a6af
Message-Id: <155448090790.31003.17803897978234402483.pr-tracker-bot@kernel.org>
Date: Fri, 05 Apr 2019 16:15:07 +0000
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linus Torvalds <torvalds@linuxfoundation.org>,
 Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Mel Gorman <mgorman@techsingularity.net>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The pull request you sent on Fri,  5 Apr 2019 14:51:18 +0100:

> git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux.git tags/mm-compaction-5.1-rc4

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/7f46774c6480174eb869a3c15167eafac467a6af

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker

