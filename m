Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F44DC74A5B
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 03:00:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3679520868
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 03:00:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="g0DVxuH0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3679520868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C81AA6B0007; Sun, 14 Jul 2019 23:00:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C2FDB6B0008; Sun, 14 Jul 2019 23:00:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF7886B000A; Sun, 14 Jul 2019 23:00:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 78B296B0007
	for <linux-mm@kvack.org>; Sun, 14 Jul 2019 23:00:16 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id t19so9802129pgh.6
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 20:00:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:dkim-signature:from:in-reply-to
         :references:message-id:date:to:cc;
        bh=eVMFNqocS1hSQF9BsluFJ1Sl6lWDa4cntyQ0D0mmlC8=;
        b=PZTYEl79L/g+1+H/RzbWTC/9uvB6nn3/r/XL7Nf+Lzk7h8PeFB5p6nS0X+CgFcP3lr
         mau33qdK1YISOYWvtrvx0p7EKjkyDAYimXwdi47hfM1GC3rBxzXnt1gn6ax4GzErQDHI
         JN2C5cgqe6mPM1tMNggmq4gE+C1ebpRZOnEBU3a+K+Prilz+3FuY5cbBbu1+wVCFnoyd
         1mPu4KbHiSzWj7xslJnluT8Eru/w1X27Icxj11dYEN/ZIHrNhLJ/N0Xx5rDzDm72dxO4
         2Kl+69fVlkWLWPcBBBqRA9PsSyhYyzuUydH9AVqYYCZhRSvK36ceR8aP8O1xXCYeYVto
         Z2TA==
X-Gm-Message-State: APjAAAWsATp6zNNT9WvN0lb6wdBiLp6Kql9gOFAKxCNQHCckVKURP176
	K9uYghcFpImm7pgxDeAaflwGHgemrYxFKnIIJcwXneLkQWOfEEf/DCiM1VY7+Om/Gi8EAanGCe9
	D6pnnKtI9q3OuBQhSyCp+uSs8i/Tv05UrB+m4Iwu31QzUZCEyoVOMzPwllLWdUImeGQ==
X-Received: by 2002:a17:902:e210:: with SMTP id ce16mr26075560plb.335.1563159615729;
        Sun, 14 Jul 2019 20:00:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzz/39dc+0+dI2TdqqzKgZztL5usQUpOaSZ55pgXRYgHySiefUDPRWzeyiT7vnowglfY8aP
X-Received: by 2002:a17:902:e210:: with SMTP id ce16mr26075499plb.335.1563159615002;
        Sun, 14 Jul 2019 20:00:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563159614; cv=none;
        d=google.com; s=arc-20160816;
        b=vyyw1J1LRiH6uLisUeMXFAsLfZycx8MzDPoZoVTBpYeWMvaPOl/Yhciim+tGA1Ivp4
         MefnyGA2zXjuYEhIukywDO868x2h6+iyOhFO7dAsMyHJw9InP2oaYeyXBy/Ij2bFp4Rd
         p/5ryLQTHZRIsdNUyOtUVZgfIOwNfUOCjEQyT9hQTEFNywuoFuvX+DjwQLuIekhqIiA9
         FgntS+y8hZcx3YZxI0E59mexMa6ZKDIBKcBB7VLr3hN8QSlxBBbr9r7SvVuzzb6WCY48
         dh9QOigtYHJiDQNm8vSUVH1PHpCIjCKtQ7MVJ461677e4GrM2yTIRnPMYwk/CRncaIwH
         KP6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:date:message-id:references:in-reply-to:from:dkim-signature
         :subject;
        bh=eVMFNqocS1hSQF9BsluFJ1Sl6lWDa4cntyQ0D0mmlC8=;
        b=krXh4gzjTd+JgjWS+Hszzqcy6E+ZDgWITvcYya9hk/rk7LCTJGBFpn1OK2RI14vnYP
         jCZyjcD63f1B0STVBpo7N7V2B8LQBvuMS+baJjxxA0MMTFNHAZTehEXRncmspq2DtBjR
         oZlIc6Kv1fmX8oYmCJpscGnLuSfP8cpnmzMtLZauyQX/dhl3lz9u6IaKAFvuACVlFT9B
         byZioxA9x9H2w3xJpuPs0HcrqaIa63wRCvCaz/nwsr+IiFIsuIUgg9bqKyGFDpEA3qDo
         sju4PkA/7Gi/py7KWIHW6g1Z47LHn1MVbc4hV0bQ/vnPCFVNynTQ3avzoXGfOcwxGAIn
         iXXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=g0DVxuH0;
       spf=pass (google.com: domain of pr-tracker-bot@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=pr-tracker-bot@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 123si15112045pgb.374.2019.07.14.20.00.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Jul 2019 20:00:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of pr-tracker-bot@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=g0DVxuH0;
       spf=pass (google.com: domain of pr-tracker-bot@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=pr-tracker-bot@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Subject: Re: [GIT PULL] Please pull hmm changes
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563159614;
	bh=Ar2oLzYPfNRIJ/cKktihwM03Q0D3KOFaf7zQt3uCrhY=;
	h=From:In-Reply-To:References:Date:To:Cc:From;
	b=g0DVxuH0O8BwZfaSxEtLyRsfEYPSCQdWnn2yhetG2F8mg12jeSXAQTnuntXE+E6hh
	 3jRqBcH7Oh1Z/vN6zC0AHX0l+UoWFpMiIlodt+M38nbijWqBr0neCq5SSuXJhz8Czi
	 Qp2nslOyUee5Z2RZI2rVwJKKf+p22oV15OzeaA5A=
From: pr-tracker-bot@kernel.org
In-Reply-To: <20190709192418.GA13677@ziepe.ca>
References: <20190709192418.GA13677@ziepe.ca>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20190709192418.GA13677@ziepe.ca>
X-PR-Tracked-Remote: git://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git
 tags/for-linus-hmm
X-PR-Tracked-Commit-Id: cc5dfd59e375f4d0f2b64643723d16b38b2f2d78
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: fec88ab0af9706b2201e5daf377c5031c62d11f7
Message-Id: <156315961463.2012.6385315659069176378.pr-tracker-bot@kernel.org>
Date: Mon, 15 Jul 2019 03:00:14 +0000
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>,
 "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>, David Airlie <airlied@linux.ie>,
 Daniel Vetter <daniel@ffwll.ch>,
 "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
 "Kuehling, Felix" <Felix.Kuehling@amd.com>,
 "Deucher, Alexander" <Alexander.Deucher@amd.com>,
 "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The pull request you sent on Tue, 9 Jul 2019 19:24:21 +0000:

> git://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git tags/for-linus-hmm

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/fec88ab0af9706b2201e5daf377c5031c62d11f7

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker

