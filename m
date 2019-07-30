Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEAC2C32750
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 20:40:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D6E921773
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 20:40:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="kCpNm0q+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D6E921773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB23E8E0005; Tue, 30 Jul 2019 16:40:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A62EC8E0001; Tue, 30 Jul 2019 16:40:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9526C8E0005; Tue, 30 Jul 2019 16:40:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6CEF28E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 16:40:19 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id q14so41616885pff.8
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 13:40:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:dkim-signature:from:in-reply-to
         :references:message-id:date:to:cc;
        bh=0U22Gjyt2STZSy/ifEYpLnNL9R6MoKgj6RG19CL8UL8=;
        b=Kv497Bi22CtKBpclUoxZKkJoFcyCNt0E+YD8wG3wd8lal3QG8qts3IpILBYUECKMJc
         3wBUla6XjigzR/UKXg9gKiCX0lNWplAI7ESPjbMd4Uiz5aC79qFyBapJqqWeq+9FfOOt
         wVwxu/H/Fw2VBw4DnsfmRjjFryoz4XSz9L5/17On0Jan8F14PrJ+WdZuyHt42x4/3Lzk
         DlnyGbN3iS1dRIBfmZJ1Cii08wCR2k6vHpQQmOSMwH9ifXQcRB1a2A+XUTSTBFapwDQE
         JTS310YG3ExlCda6O2PElmqSgxT6jNoa2fdYh9XU7bw8UleJOsE+ZRqq7dmlBW9OqVIy
         YxlA==
X-Gm-Message-State: APjAAAX4eLhBeCxSNEAKzaCCPWztKxAoNYc81Qdk/M7W4S5Wp8p/pROJ
	vU8bCWeXZO8YhR9f8vmgLd/0SrnO6Z7V69SucJA1vHOy8MsXCqLDGXNnfCMYQsHBPFp+sGI3p85
	ohBp8lwBR5z6xJvv1Hfjug131x4EC+XP8WiH3dUdmdSIcVhRHWF6g+JJUmhILfcx+Qg==
X-Received: by 2002:a17:902:2ec5:: with SMTP id r63mr115542859plb.21.1564519219078;
        Tue, 30 Jul 2019 13:40:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBZuPwhLrH/9OB2IgB89HV/8EGLksU4kAvP8WWtcvGAH1kEZ/jquW6b3/X6TdpY+CGmGen
X-Received: by 2002:a17:902:2ec5:: with SMTP id r63mr115542815plb.21.1564519218550;
        Tue, 30 Jul 2019 13:40:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564519218; cv=none;
        d=google.com; s=arc-20160816;
        b=Iy+/Lmud2TBfKhSVIiWY+lZdNZcph/2aJp7kmAuRkJj0zWjl4LG6CH48oKJB30mwZ2
         5Wt7koHrQ+piOBOY+5d81By/xFRLIb7iZQRYKSFUaRwUCEFLyT9R5BfAktHsZnG/GPHF
         2GoPT1HWfR+xR7dCKHTCI6CR3JkKhr4LkGxNRywgyM+wScEzVG1NRJWgiMi+Ql93cBCa
         fdT4CAEHw5bzSDBFyAl6x34aIy4IiFcGXQhLmQySFcsg9VRIOcRFVSoqdQ9I3sU65Ywp
         vIvPJkWkUSWMjnUNPujefH+5GD/Ov0WMwYXc8E9BeWP4U8ExST439KshJqFy+TJRDegs
         k9qA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:date:message-id:references:in-reply-to:from:dkim-signature
         :subject;
        bh=0U22Gjyt2STZSy/ifEYpLnNL9R6MoKgj6RG19CL8UL8=;
        b=M3YnyWzJ93AsB/sH34AIXP+BdRKUZIkzVfuK/75QqoU100loTCBrv//qPSRZozS19d
         8O0LkYRrYkZi1JC4xwNTjEGTJFfr6gUsLBeOOYgr6p/8ipkn2tZCmJ3beXv+gJOMK5pu
         QA9ikWg2dbBxKSG5hMdvVlG6ZJkNP6RW/OyIgYak7lrjo/IVDiLJa3aVeZ3IoSQbrux7
         C79BBcdYUFfQEmafJIPdC0dxfHVC56rolBfgs3dAUBsMu8SbKT7h+2k0+SBPEZRZVV/w
         z9ZvX0uqoBCxfsuFImAweopVgqa4o9d3t/xu3UAXzSxNX5TfT5i34CAdR5VU9YtTWQJU
         0nkw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=kCpNm0q+;
       spf=pass (google.com: domain of pr-tracker-bot@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=pr-tracker-bot@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b6si27623542pjz.29.2019.07.30.13.40.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 13:40:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of pr-tracker-bot@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=kCpNm0q+;
       spf=pass (google.com: domain of pr-tracker-bot@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=pr-tracker-bot@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Subject: Re: [GIT PULL] Please pull hmm changes
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564519218;
	bh=rxzvltql7wVZw/jwNUEDC1Qb9+r4GqOzZran/66ezKg=;
	h=From:In-Reply-To:References:Date:To:Cc:From;
	b=kCpNm0q+triJorfoXGYTORFoq/HS39NKRUfUtHqV0M0bRJcVPyTpWj6wG4Bc+zMPL
	 iPZF7bfHnLxay59cZ/uuXJuXD1Oxxoc21SG2T3x8f1Alv0WDzhgnRN9sa7ObvZdPn/
	 xvFeYcKzbG0K102nvvGz5KUQ1Ccb0UsnoeL0IHP0=
From: pr-tracker-bot@kernel.org
In-Reply-To: <20190730115831.GA15720@ziepe.ca>
References: <20190730115831.GA15720@ziepe.ca>
X-PR-Tracked-List-Id: <linux-kernel.vger.kernel.org>
X-PR-Tracked-Message-Id: <20190730115831.GA15720@ziepe.ca>
X-PR-Tracked-Remote: git://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git
 tags/for-linus-hmm
X-PR-Tracked-Commit-Id: de4ee728465f7c0c29241550e083139b2ce9159c
X-PR-Merge-Tree: torvalds/linux.git
X-PR-Merge-Refname: refs/heads/master
X-PR-Merge-Commit-Id: 515f12b9eeed35250d793b7c874707c33f7f6e05
Message-Id: <156451921813.18459.2711445926920761419.pr-tracker-bot@kernel.org>
Date: Tue, 30 Jul 2019 20:40:18 +0000
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
 Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>,
 "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>, David Airlie <airlied@linux.ie>,
 Daniel Vetter <daniel@ffwll.ch>,
 "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
 "Kuehling, Felix" <Felix.Kuehling@amd.com>,
 "Deucher, Alexander" <Alexander.Deucher@amd.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The pull request you sent on Tue, 30 Jul 2019 11:58:37 +0000:

> git://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git tags/for-linus-hmm

has been merged into torvalds/linux.git:
https://git.kernel.org/torvalds/c/515f12b9eeed35250d793b7c874707c33f7f6e05

Thank you!

-- 
Deet-doot-dot, I am a bot.
https://korg.wiki.kernel.org/userdoc/prtracker

