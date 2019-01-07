Return-Path: <SRS0=+lVK=PP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BC0DC43387
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 14:39:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50D842173C
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 14:39:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50D842173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED3EE8E002D; Mon,  7 Jan 2019 09:39:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E82E78E0001; Mon,  7 Jan 2019 09:39:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4C608E002D; Mon,  7 Jan 2019 09:39:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7CBDB8E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 09:39:42 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f31so371641edf.17
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 06:39:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=5tRaWG9w/bpcFZS51x2blm7DQSPjMkRHfXBKvSfmEO4=;
        b=L91Pgg5cLZjoWFq1pvkeV7OxOB0WodVDPjNeNnxQnzgTCvDGNwVaom0eHnxlBGKjxK
         czGD/wB/5xrYGv5hkxS42Vd8dixMWzO/R9wTS8qx9QUazEw3+OV3sBTIoDJlgXoIY2RE
         pDPjYTfTiBgjcTbVX47DC3OBP2FmgcymsmOAFtMBDfcEUYlLcJW5LuKVBB8sX2KOTlUB
         +a3Ov5YQat/N6iEFInBQetGeraes5FDHxEbWYTrSqOzDEvb2e8LpPXb9Anf4zx8FYYXs
         X48l8pHBUHl4bxO0JJ6EQZpxC2iIEQT5fKJO49F6ASs7zFEFC2Z16qFSPOYk+a6hWO3t
         dufQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AA+aEWb0KsXYL3NxKeTXn7KPPLvXNo6C8tcdZfgw2x4bisMhZg0ZNFyo
	BW0/8AWa6r/qzk97RJbdM/j7tmvBW2kQA7/hzHA05aZ21jxsVOzkBZZzogCMPN8w/WB4lr//P/u
	sN0cwVn3McsErgK6JTqFSq4iI83EM8OLOSLQxVOTUpFgSkdcSXxjEHQ2ShBK4uzVwaYoF4Q7+KS
	rwlhXuw4sAGmaB2K/ZO90EdY4wqbB+tMEjGw6h41jIeXDTCOgMqYz1HwPe+uGhA88/D8KJl9kt1
	bEwB4S5fn6YUhDR9FVdvqW25EIpI8WIjdXtIK5o70BzK+Tq5ucRbY7uqTpfTC+XMkXuIlPUsTJV
	8KMdiBvmKa5bUgM1CtLNi2a9bSWI3B1ZFdLf5lI+ZBqrbWc6PjdeQvB3uJxLTy/8/ayVcFBB1Q=
	=
X-Received: by 2002:a50:f489:: with SMTP id s9mr55427723edm.101.1546871982022;
        Mon, 07 Jan 2019 06:39:42 -0800 (PST)
X-Received: by 2002:a50:f489:: with SMTP id s9mr55427663edm.101.1546871981043;
        Mon, 07 Jan 2019 06:39:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546871981; cv=none;
        d=google.com; s=arc-20160816;
        b=WVvfa7T5Cfi2ezrnzCKyTGM18ijZXzU7ZpfjErf2GsGkHCW+JKKLsqkXm7JXpuOa94
         KQAN63FY/RTUJTeGJ7Iv5g/FCzfgeT5yzFUowIwylxL4jDO1RP5ekZgz2gkzoXHTgqYA
         9P1BzueznNHyCKbkh4+sQ+wgeczirelNdQ+p1aoWUs0EjLaVmFE0aQ+wo1gvsPndW1TB
         y56xaL3qmbyflEo4qkmJeXB3vwwGa6IY2yBzPR+Dw9iT/LETCmih74SfaZx230tcxb/6
         vp6kOvDG3SIw+O73A+GdG2wUNS2E/Z/NpVY26wc7wrYLBzIrdOU8aAJ+Lu2w8BH6Evke
         jngQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=5tRaWG9w/bpcFZS51x2blm7DQSPjMkRHfXBKvSfmEO4=;
        b=NNS0a60exWN6l6iIRC9sFPbEu27A+2++0jPfcX3YGLmWxC1n9gRGkoHiUyvrSQ0aoa
         Iv/5kiXjbnVsA2LZ/BfTkYj8Eu3UCsFvtlDHb/YtBO+ORosZ+dLcwMVAKv+dl/rvV3K/
         P3FzpOEhyJoc1sLXwje475+O6981jQ62uCwZjaWlPPg3uUeSPnOuXqfn4R7+QOZUDGbI
         aJP7080xagdm4OWugsJpBbfs5nxiVD62SJ/Gs7dPBt3uYrPTzI+UWiV2U2KUChzbo4Xv
         3Wykml+z95AvYmHggA9MVbDT7rHfYxV4mKD996uugBKVnyU25IHeh5X4mClkK4FNT5v3
         rKhg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f2sor37817818ede.19.2019.01.07.06.39.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 Jan 2019 06:39:40 -0800 (PST)
Received-SPF: pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AFSGD/UbqBj8Yo+QEtRTxDtV5oQIeDDOS6Geta9x8qi72hOl59hF37p6FNT0/XlUN0k1SwWTttTePw==
X-Received: by 2002:a50:a5b8:: with SMTP id a53mr57562641edc.199.1546871980381;
        Mon, 07 Jan 2019 06:39:40 -0800 (PST)
Received: from tiehlicka.suse.cz (prg-ext-pat.suse.com. [213.151.95.130])
        by smtp.gmail.com with ESMTPSA id l18sm29285813edq.87.2019.01.07.06.39.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 06:39:39 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
To: <linux-mm@kvack.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
Subject: [PATCH 0/2] oom, memcg: do not report racy no-eligible OOM
Date: Mon,  7 Jan 2019 15:38:00 +0100
Message-Id: <20190107143802.16847-1-mhocko@kernel.org>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <20190107143800.YDuTjGaFjvNfcK9JoYS5gkj6y9hdaXDMSYdOTJJj5LM@z>

Hi,
I have posted this as an RFC previously [1]. Tetsuo has pointed out some
issues with the patch 1 which I have fixed hopefully. Other than that
this is just a rebase on top of Linus tree.

The original cover:
this is a follow up for [2] which has been nacked mostly because Tetsuo
was able to find a simple workload which can trigger a race where
no-eligible task is reported without a good reason. I believe the patch2
addresses that issue and we do not have to play dirty games with
throttling just because of the race. I still believe that patch proposed
in [2] is a useful one but this can be addressed later.

This series comprises 2 patch. The first one is something I meant to do
loooong time ago, I just never have time to do that. We need it here to
handle CLONE_VM without CLONE_SIGHAND cases. The second patch closes the
race.

Feedback is appreciated of course.

[1] http://lkml.kernel.org/r/20181022071323.9550-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/20181010151135.25766-1-mhocko@kernel.org


