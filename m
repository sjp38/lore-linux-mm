Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F740C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 22:55:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2386120862
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 22:55:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="KyFd5GNJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2386120862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 994086B0003; Mon, 13 May 2019 18:55:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 91E396B0006; Mon, 13 May 2019 18:55:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7BFEE6B0007; Mon, 13 May 2019 18:55:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4F8E76B0003
	for <linux-mm@kvack.org>; Mon, 13 May 2019 18:55:17 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e16so3387471pga.4
        for <linux-mm@kvack.org>; Mon, 13 May 2019 15:55:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:dkim-signature:from:in-reply-to
         :references:message-id:date:to:cc;
        bh=2XfFOVErCvtSiCuJNCL1VLmjWzldZYKATH6UJBX/sSk=;
        b=abiwmGPCuY3nJQ6kjlhv9e2hvwoAFAfUy8ZZrq+xIg6rR5kmAFdfKbalZ+Jddgn8Ah
         1DLpKqPl2BKua59o2Bl/iLDrcn/QDQBHKUJ7QpHWXBvYA2BhTRjT4PLxQdLFj80A9JFp
         VYC8N7RCRnJ6eT9jiO2BlHnTxZ7p0ri1kCWSoFmCYFFl+5XpdB5Rl0NMQogpetGyBjt/
         CpyfC6o7pYcuTBzK/6oEC9EumGWyDEGqMwhAUQMobT0yarElc6QrdppZfGNm3utHzUqE
         uE+p5XRAvDqAN+pnDSEEvJ0OdVAHigzA3cB6a//1fUo9TVa4JrE6HMv3JNHKjo0coOsK
         HoLA==
X-Gm-Message-State: APjAAAVB1xdkpdG6HsXWqHk+//jmmShvIfVV+Ja4nV+FbOqOK79yjEec
	uWlwyoICsQXWwofsW7riOj5J279fgzPtT7QRNmnAdf1owzu1KQxB42rnk1UXEqNJR/tVYpCZDF+
	A7qQFrN6umyCnklDounezb15hQm0o+KG15sgBo14vGXFCN8hUdu7ck07LdBo08ur3PQ==
X-Received: by 2002:a63:5907:: with SMTP id n7mr34775159pgb.416.1557788116943;
        Mon, 13 May 2019 15:55:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2/OszQQ1yvRcU1EoV+QKeqfIekA9+M8VSSrAj/K5Fz2X/UZwCTAzcRQ34s6Wff0UoX1NQ
X-Received: by 2002:a63:5907:: with SMTP id n7mr34775108pgb.416.1557788116282;
        Mon, 13 May 2019 15:55:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557788116; cv=none;
        d=google.com; s=arc-20160816;
        b=QsDdfvtC+NkSTFAyI47wnJAh6YEOnMWOT2pWmgjJxLFGWZwIqY8KcfygeUAK/gJx4+
         r6y7L3xr9sKvE6+YA7w59uXhnr23Ox0naj+KtxWZ0zBgqDbPmcMudx7LXcxN0j9MKwm8
         GHOFb+8OqzmL5Opg22WtCVleMYPd3aSTYTYRRRBYREYw1BiOWmF5CRd/h0s2ZYCVF8o6
         BSdEfrau2bcHHFx/tG//qxZrlZRyyh51/DPycEg+NloJqdIlwMyzYFtU+D9j602bWAa7
         /Q8c/srQOqCUedVEZpXwbh4YCStcc/JZYs6AN5dJajWv5BJg85/8VrDuF0Rz3p3YhJe5
         QnKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:date:message-id:references:in-reply-to:from:dkim-signature
         :subject;
        bh=2XfFOVErCvtSiCuJNCL1VLmjWzldZYKATH6UJBX/sSk=;
        b=UTSB509ugX0dF8xq6C/QS9gI8mRXwVNsD6VEVok24EPI1wjCvoHB6BDRf9V8rIa0So
         1DW+cxsxFdVCd7TOdpu2eTb6WmkZ3NvVr/wfwsYgKKVCTx2XAj+NP7DKBem42LIW5obP
         xRPRDeO7gM+tV+8A0YlP6MeaqS1qZCuA08LXnVKCRqYoCiC2RAReWHCFbk3bQaoADCXb
         XEwT2/lRrzDmBY5UBHPISSkilqTlm71fa7u+Iv2UalmEaKMO0l51UCeoKTspXJfx0ez0
         LLV6FZ/J2KXbciXQEmv9zrycNFxsrh71hU3k2qj8qbOmEdj0ZPlSFDkSFHxsf0IUqRjl
         EdAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=KyFd5GNJ;
       spf=pass (google.com: domain of pr-tracker-bot@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=pr-tracker-bot@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a25si18462658pff.119.2019.05.13.15.55.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 15:55:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of pr-tracker-bot@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=KyFd5GNJ;
       spf=pass (google.com: domain of pr-tracker-bot@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=pr-tracker-bot@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Subject: Re: [GIT PULL] percpu changes for v5.2-rc1
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557788115;
	bh=zoUDwhLvAd1vhaGU8kBKsxlklp/ynJ4RVpUUR8CYCX0=;
	h=From:In-Reply-To:References:Date:To:Cc:From;
	b=KyFd5GNJcWCd8uLj33Y8/HURKSkaKNmVgzqUOGuiThMNJ7NFnfPjFWziVUxw8TUcz
	 5QPVZ2GhLw5TMrqMA/l2b/qKr3/+eIBQM1UKW6Z6BCW9Rpfx55qGqH2sRjQ2bW63Zx
	 SqsegLhcxqbDzDzUyRphYbsVO/L1NqRixMGDUFis=
From: pr-tracker-bot@kernel.org
In-Reply-To: <20190513185241.GA74787@dennisz-mbp>
References: <20190513185241.GA74787@dennisz-mbp>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20190513185241.GA74787@dennisz-mbp>
X-PR-Tracked-Remote: git://git.kernel.org/pub/scm/linux/kernel/git/dennis/percpu.git for-5.2
X-PR-Tracked-Commit-Id: 198790d9a3aeaef5792d33a560020861126edc22
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 3aff5fac54d722f363eac7db94536bffb55ca43f
Message-Id: <155778811588.1812.12003345020716870482.pr-tracker-bot@kernel.org>
Date: Mon, 13 May 2019 22:55:15 +0000
To: Dennis Zhou <dennis@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>,
 Christoph Lameter <cl@linux.com>, 
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The pull request you sent on Mon, 13 May 2019 14:52:41 -0400:

> git://git.kernel.org/pub/scm/linux/kernel/git/dennis/percpu.git for-5.2

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/3aff5fac54d722f363eac7db94536bffb55ca43f

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker

