Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB3B3C4CECD
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 23:40:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B588206C2
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 23:40:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="i4VgHBmh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B588206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19E7E6B026D; Tue, 17 Sep 2019 19:40:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14E8F6B026E; Tue, 17 Sep 2019 19:40:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B3906B026F; Tue, 17 Sep 2019 19:40:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0062.hostedemail.com [216.40.44.62])
	by kanga.kvack.org (Postfix) with ESMTP id E2A386B026D
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 19:40:26 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 745EA180AD805
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 23:40:26 +0000 (UTC)
X-FDA: 75946034052.22.sun15_5b1ded9684857
X-HE-Tag: sun15_5b1ded9684857
X-Filterd-Recvd-Size: 1910
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 23:40:26 +0000 (UTC)
Subject: Re: [GIT PULL] percpu changes for v5.4-rc1
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1568763624;
	bh=m4VZQRJNxhNh/vWBR0nZ19WBq20PaY34jKQbmAf8Ocw=;
	h=From:In-Reply-To:References:Date:To:Cc:From;
	b=i4VgHBmhPkcz7n56J4J8dL6eFOCQXwVCEWqMnF9LfWld9a6ZDs5R7Y0FLWlwtfa1t
	 M+1gEaz/1IBkMP3Dusw5rWjCbhqM9Vdaktt8WYynuip3bHoA49/KeDu5D4bxJVjtg7
	 /y0GjRB00sGRmYb12o+2LJGg0O6uKewID7NrIhpU=
From: pr-tracker-bot@kernel.org
In-Reply-To: <20190917164300.GA77280@dennisz-mbp.dhcp.thefacebook.com>
References: <20190917164300.GA77280@dennisz-mbp.dhcp.thefacebook.com>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20190917164300.GA77280@dennisz-mbp.dhcp.thefacebook.com>
X-PR-Tracked-Remote: git://git.kernel.org/pub/scm/linux/kernel/git/dennis/percpu.git for-5.4
X-PR-Tracked-Commit-Id: 14d3761245551bdfc516abd8214a9f76bfd51435
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 1902314157b19754e0ff25b44527654847cfd127
Message-Id: <156876362478.26432.1158576179751599537.pr-tracker-bot@kernel.org>
Date: Tue, 17 Sep 2019 23:40:24 +0000
To: Dennis Zhou <dennis@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>,
 Christoph Lameter <cl@linux.com>, 
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000009, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The pull request you sent on Tue, 17 Sep 2019 17:43:00 +0100:

> git://git.kernel.org/pub/scm/linux/kernel/git/dennis/percpu.git for-5.4

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/1902314157b19754e0ff25b44527654847cfd127

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker

