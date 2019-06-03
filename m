Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6491C28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 13:22:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64A5725C0B
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 13:22:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64A5725C0B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C15B56B0005; Mon,  3 Jun 2019 09:22:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9F6E6B0008; Mon,  3 Jun 2019 09:22:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ADBC86B000A; Mon,  3 Jun 2019 09:22:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 62B6F6B0005
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 09:22:05 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c1so27446528edi.20
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 06:22:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=y0MbUa+6jYb/gyx/+abYxhbC4pqYY4A3l1fofQ8F/vs=;
        b=uaBCZ1r8gMFIMcq8ei4HGTkoHW9EC3XjB1g33HMtb89R+NOKlCqOeOTNM5K3EksqO9
         /jPj8B7bVou/gfeiw19NThQzYqbvpITs5yoX1a+JoktMDWjtevd4tS6AEbmG8IUbT3NB
         b2tntN6Iiai6hbeXQeg9qg8YsIBfZ7/Z8X22+VHAD9dmLYP4fTQqFD+UzLlpkUhopSQ7
         1vI5P1yMQek+GYY2F6tknA3nreGlM75PUZbZuVpdHgyujggI4F6it11rHtdRQTpJFsTP
         vOErupbQyoZ3VvIGf9V37WoVzpy9yUb0lehELwBIeL8zV6/qm8a0ex4LI/4xMMNrT2P0
         ERPA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAUM3wwZJOmJ8elt/0YK3zq3IJ91iuTIX866E3SdGMA+rd+6kT6b
	GGHibKWwyYnqV+YYCv2jI2WBki3pBONpeU4zKDlNRgOmPbACRMmwAdwP9OIbV2Oz15BvlBAq2pV
	sl4an9A4dnKmTNuhGdT8mTbW6KRcoSbnW78jo9tuEMOku55DUuh2RLNnOkC01DYnSAA==
X-Received: by 2002:a17:906:53c1:: with SMTP id p1mr22986668ejo.241.1559568124776;
        Mon, 03 Jun 2019 06:22:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLemC87jGTZRRzClgN2sQr+4Bnn23BoC7bLeKr5Ke4gnLks2eK29aImgJZ5QrGhuppY3tq
X-Received: by 2002:a17:906:53c1:: with SMTP id p1mr22986570ejo.241.1559568123608;
        Mon, 03 Jun 2019 06:22:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559568123; cv=none;
        d=google.com; s=arc-20160816;
        b=BofGBEZ6W/MBEB7wWQ2qsCBs1xFZZLoNaH8a0Uys+P5qyamFOZDilDpP4gBoPiIpa9
         G96ChQyud17lJw1RNnRX9veuOmvkJrblhXtlh2lRG95/dfYMpZZUdAXFxZxIr7uSikXB
         Lim6aALAHLv7j3L4IJjVRLWCdLniQQvkMjU3BgVraR9pEi55nVqEnqbCsSLy6Tche/2c
         ob5Zltj2tu+g1xDmGneHfVmP/ZiaNDFy/5mBrfYnQFaYDfjVR+9dTuZSlYig6kelE/77
         kVfeXgfr7oLNERynyt4ThNq/gGq1tOojngKKS8MZOShkofYZBZZuJ4kIndPBtgOxA7td
         ydxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=y0MbUa+6jYb/gyx/+abYxhbC4pqYY4A3l1fofQ8F/vs=;
        b=CCPok0biLA7pfZ7ZflKor9jraodnHf+WJeb1qnfMvBFR3aQ39pVsTFDJN7uh9a+sXJ
         qUcw2FiYRZ9nGCoHBgcPUs/9THnryu7UjBn4KiOzU8BZM3TAa9/f9mLUWrh74vt1OkpB
         F3muS7S4PBVhviBM7G3ZbUXAmTOV0CFhshIIxbcSNDvfKJtXTEiXju0UWyW6Roh7OOx8
         9xPBWrJ798fuv2cx8/lXHkqsnmorGoFtc848gp+OWdOhBzqBqmRoefQhsTwwvh6RmHsi
         G4vrPstEs+skSarK/r0RHxMXjwK4T8EKPjXpMFyWPm+Fe7yeVxEC6DIrHY8TejG10bNi
         OE9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b15si2590946eje.113.2019.06.03.06.22.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 06:22:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F3037AB91;
	Mon,  3 Jun 2019 13:22:02 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 4B8571E3C24; Mon,  3 Jun 2019 15:22:00 +0200 (CEST)
From: Jan Kara <jack@suse.cz>
To: <linux-ext4@vger.kernel.org>
Cc: Ted Tso <tytso@mit.edu>,
	<linux-mm@kvack.org>,
	<linux-fsdevel@vger.kernel.org>,
	Amir Goldstein <amir73il@gmail.com>,
	Jan Kara <jack@suse.cz>
Subject: [PATCH 0/2] fs: Hole punch vs page cache filling races
Date: Mon,  3 Jun 2019 15:21:53 +0200
Message-Id: <20190603132155.20600-1-jack@suse.cz>
X-Mailer: git-send-email 2.16.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

Amir has reported a that ext4 has a potential issues when reads can race with
hole punching possibly exposing stale data from freed blocks or even corrupting
filesystem when stale mapping data gets used for writeout. The problem is that
during hole punching, new page cache pages can get instantiated in a punched
range after truncate_inode_pages() has run but before the filesystem removes
blocks from the file.  In principle any filesystem implementing hole punching
thus needs to implement a mechanism to block instantiating page cache pages
during hole punching to avoid this race. This is further complicated by the
fact that there are multiple places that can instantiate pages in page cache.
We can have regular read(2) or page fault doing this but fadvise(2) or
madvise(2) can also result in reading in page cache pages through
force_page_cache_readahead().

This patch set fixes the problem for ext4 by protecting all page cache filling
opearation with EXT4_I(inode)->i_mmap_lock. To be able to do that for
readahead, we introduce new ->readahead file operation and corresponding
vfs_readahead() helper. Note that e.g. ->readpages() cannot be used for getting
the appropriate lock - we also need to protect ordinary read path using
->readpage() and there's no way to distinguish ->readpages() called through
->read_iter() from ->readpages() called e.g. through fadvise(2).

Other filesystems (e.g. XFS, F2FS, GFS2, OCFS2, ...) need a similar fix. I can
write some (e.g. for XFS) once we settle that ->readahead operation is indeed a
way to fix this.

								Honza

[1] https://lore.kernel.org/linux-fsdevel/CAOQ4uxjQNmxqmtA_VbYW0Su9rKRk2zobJmahcyeaEVOFKVQ5dw@mail.gmail.com/

