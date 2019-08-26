Return-Path: <SRS0=haCV=WW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 343CAC3A5A6
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 20:14:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B83B1217F5
	for <linux-mm@archiver.kernel.org>; Mon, 26 Aug 2019 20:14:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="KsRq9jvc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B83B1217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B8BE6B0274; Mon, 26 Aug 2019 16:14:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26A9B6B0275; Mon, 26 Aug 2019 16:14:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 180DD6B0276; Mon, 26 Aug 2019 16:14:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0128.hostedemail.com [216.40.44.128])
	by kanga.kvack.org (Postfix) with ESMTP id EB4B56B0274
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 16:14:33 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 9E288180AD802
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 20:14:33 +0000 (UTC)
X-FDA: 75865681626.24.wound20_44d7d891bb83e
X-HE-Tag: wound20_44d7d891bb83e
X-Filterd-Recvd-Size: 3842
Received: from mail-ed1-f67.google.com (mail-ed1-f67.google.com [209.85.208.67])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 26 Aug 2019 20:14:32 +0000 (UTC)
Received: by mail-ed1-f67.google.com with SMTP id z51so28084980edz.13
        for <linux-mm@kvack.org>; Mon, 26 Aug 2019 13:14:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=MEWFNP9G9XRQyNplR93hNjA88jcDbmmCg7h8xD2JEzU=;
        b=KsRq9jvc8+HnjknGWkm6taWVUdOk9oNM+c04XJIBVUYGcOP0MJNkQx9WOTX/WpSWMR
         VDHNqXxPNfx5r7fkM9tldZ4RH+WNleFaR3gLttKhoLCHbB76RNSX9LZcPAWgXMLWGZdX
         CA567cCQXUiG7iZja4mZg3jSGGXg0k9TiOMdw=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=MEWFNP9G9XRQyNplR93hNjA88jcDbmmCg7h8xD2JEzU=;
        b=lLqyJlh7jkCU638T+ah1RhwPznsyXBT/IYUEb9O+k7Y5N9By+KEND6yKTI5tddtCEs
         7Kn4IuuUnPfEKsGDPTFv0PUpvqTSx9Zx37FL8AAMZ8nEIUKBwIqHfGLb4cxoaoXUV5tG
         WpD0Nn+/0wzu8sXsvKwN0au+AIVq0PxCOWCSj1fWaXfIC5kLyWZ8LAi44LQ+mAt3InI4
         18pLGYOwZUSxCTvSuFG12zgL6NGA4w+LbFKZ6oqPcQcBY0K1T5WUWfhK6avqk8A5zdrj
         +2HAnJTf15XdIVzro8l6RZ+httRIgYde1haDVZ6lQA+udFGXTQZDtLoFpLuTbRZntgj+
         dlvA==
X-Gm-Message-State: APjAAAVqAaLLCFvN4DRdW09qlkMtbKXwG+HFdpZSPWWSuIpmPzXQCknY
	HSeGq+3SrzMLnTBz1fyiNJVJHw==
X-Google-Smtp-Source: APXvYqxLqEPD0/LdFMncbAYamThZ56ARg99koHGS0Ym61r97PqUdd+AzAX9vwScKfOBYaciZi35XAg==
X-Received: by 2002:a50:cc99:: with SMTP id q25mr20152694edi.207.1566850471666;
        Mon, 26 Aug 2019 13:14:31 -0700 (PDT)
Received: from phenom.ffwll.local (212-51-149-96.fiber7.init7.net. [212.51.149.96])
        by smtp.gmail.com with ESMTPSA id j25sm3000780ejb.49.2019.08.26.13.14.30
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 26 Aug 2019 13:14:30 -0700 (PDT)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>
Subject: [PATCH 0/5] mmu notifer debug annotations
Date: Mon, 26 Aug 2019 22:14:20 +0200
Message-Id: <20190826201425.17547-1-daniel.vetter@ffwll.ch>
X-Mailer: git-send-email 2.23.0
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

Next round. Changes:

- I kept the two lockdep annotations patches since when I rebased this
  before retesting linux-next didn't yet have them. Otherwise unchanged
  except for a trivial conflict.

- Ack from Peter Z. on the kernel.h patch.

- Added annotations for non_block to invalidate_range_end. I can't test
  that readily since i915 doesn't use it.

- Added might_sleep annotations to also make sure the mm side keeps up
  it's side of the contract here around what's allowed and what's not.

Comments, feedback, review as usual very much appreciated.

Cheers, Daniel

Daniel Vetter (5):
  mm, notifier: Add a lockdep map for invalidate_range_start/end
  mm, notifier: Prime lockdep
  kernel.h: Add non_block_start/end()
  mm, notifier: Catch sleeping/blocking for !blockable
  mm, notifier: annotate with might_sleep()

 include/linux/kernel.h       | 25 ++++++++++++++++++++++++-
 include/linux/mmu_notifier.h | 13 +++++++++++++
 include/linux/sched.h        |  4 ++++
 kernel/sched/core.c          | 19 ++++++++++++++-----
 mm/mmu_notifier.c            | 31 +++++++++++++++++++++++++++++--
 5 files changed, 84 insertions(+), 8 deletions(-)

--=20
2.23.0


