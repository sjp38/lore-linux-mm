Return-Path: <SRS0=3rjY=XO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BA3DC4CEC9
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 01:55:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E30E21929
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 01:55:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="TvI5Yotc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E30E21929
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBB9B6B0325; Wed, 18 Sep 2019 21:55:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6B356B0327; Wed, 18 Sep 2019 21:55:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B80CE6B0328; Wed, 18 Sep 2019 21:55:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0131.hostedemail.com [216.40.44.131])
	by kanga.kvack.org (Postfix) with ESMTP id 927276B0325
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 21:55:06 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 3DDB5824CA3E
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 01:55:06 +0000 (UTC)
X-FDA: 75950002212.07.toe84_f6796b75fc47
X-HE-Tag: toe84_f6796b75fc47
X-Filterd-Recvd-Size: 2012
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 01:55:05 +0000 (UTC)
Subject: Re: [GIT PULL] vfs: prohibit writes to active swap devices
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1568858104;
	bh=+nQrQkXOkRxZhzdXX1FnDHOxD+aWBM3cUYJtYy5Em1c=;
	h=From:In-Reply-To:References:Date:To:Cc:From;
	b=TvI5YotcIH3dsA9T3qwczl/QP+D2gyt5w5VOLC8DwVKzb1ZQU5+c5ls58ifV1D/zu
	 NIR2fYiRicQXVfWQ+96gqZVWMsGmNBisSSI008St0CudFfEQPFs4uNMnssbOdKvbbZ
	 fT08Go3HaAwlEhrZmmrUc83rxewcHaWdkx0mU31k=
From: pr-tracker-bot@kernel.org
In-Reply-To: <20190917150608.GT2229799@magnolia>
References: <20190917150608.GT2229799@magnolia>
X-PR-Tracked-List-Id: <linux-fsdevel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20190917150608.GT2229799@magnolia>
X-PR-Tracked-Remote: git://git.kernel.org/pub/scm/fs/xfs/xfs-linux.git
 tags/vfs-5.4-merge-1
X-PR-Tracked-Commit-Id: dc617f29dbe5ef0c8ced65ce62c464af1daaab3d
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: e6bc9de714972cac34daa1dc1567ee48a47a9342
Message-Id: <156885810471.31089.18252628030141305511.pr-tracker-bot@kernel.org>
Date: Thu, 19 Sep 2019 01:55:04 +0000
To: "Darrick J. Wong" <djwong@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
 "Darrick J. Wong" <djwong@kernel.org>, 
 linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org,
 hch@infradead.org, akpm@linux-foundation.org,
 linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
 linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The pull request you sent on Tue, 17 Sep 2019 08:06:09 -0700:

> git://git.kernel.org/pub/scm/fs/xfs/xfs-linux.git tags/vfs-5.4-merge-1

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/e6bc9de714972cac34daa1dc1567ee48a47a9342

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker

