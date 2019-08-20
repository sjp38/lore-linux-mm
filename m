Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0D5DC3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 08:19:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FAAE23A85
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 08:19:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="SmZ/pRAr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FAAE23A85
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D32FA6B0008; Tue, 20 Aug 2019 04:19:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D11FB6B000D; Tue, 20 Aug 2019 04:19:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1FAC6B000E; Tue, 20 Aug 2019 04:19:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0149.hostedemail.com [216.40.44.149])
	by kanga.kvack.org (Postfix) with ESMTP id A05946B0008
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 04:19:10 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 4956B610D
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 08:19:10 +0000 (UTC)
X-FDA: 75842106060.23.nest48_15ca6cc0b3e02
X-HE-Tag: nest48_15ca6cc0b3e02
X-Filterd-Recvd-Size: 3947
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 08:19:09 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id h8so5347159edv.7
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 01:19:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=q2z56NGRuBwQ6OtJWWZ+ElQlv8Da6Bh+gCKkp4IYR4I=;
        b=SmZ/pRArK01I8lgnLa49hGHl9IbRlO4jooOekpAQLUww/NtZzFbMdIf6NslU/Y3SKc
         gCLvUacj0TPK72ol8Q8Xy9ZgNWfki0+DDeENUyIK5fHcnRb+guPbzkfvrrpI3BAbNMmh
         SzIkH2ny+RAPMFrNxXmq4QZ6VxH2OOupC75XY=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=q2z56NGRuBwQ6OtJWWZ+ElQlv8Da6Bh+gCKkp4IYR4I=;
        b=tGh6O+SPCs1TPzTtqhF719Pa52P8BVScufmeRtpxlOeL/ssrfAm0duugGRZeRH+Ngi
         H1bruUtfguAwAyaX3NsjtcxUt3T+JAxAYdUa3xivRVABCa339oDic7KfLu+G/REhymfY
         YiYWtqe34OVrUY0gecFzvgdsuNC7HYAffn+SMiKjYoivVSrhQ8sCKkAEaWRm3H9oP/4W
         06da1gPBR2A7PL4y4aDcIxGTOn+/bJKL3Z+77QkXmgHXlgWQk8oDC9XCM39is4pOD3H/
         Kn9x6JQaWjrO8Kq53jdAuHomfG8B6sE32Q66pGUOjvqpyFy9Y/bnD+qFFk6p9ia9GGnO
         FL0g==
X-Gm-Message-State: APjAAAWnd98SfEFPADnAQaaaqzhNaJhcVQL+16BD5y07bfWUdDVUQzJG
	SUhiAOtGgKp2maFFJdn1NTaYWA==
X-Google-Smtp-Source: APXvYqzDZ+XSiJaUiLyBO6xryISbkppFw3Ap9Zd0Y3Zq1bsN8EUYkCC3bk1FyxoLEsheLO+r1k3c9A==
X-Received: by 2002:a05:6402:155a:: with SMTP id p26mr30221294edx.9.1566289148256;
        Tue, 20 Aug 2019 01:19:08 -0700 (PDT)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id fj15sm2469623ejb.78.2019.08.20.01.19.07
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Aug 2019 01:19:07 -0700 (PDT)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>
Subject: [PATCH 0/4] mmu notifier debug annotations/checks
Date: Tue, 20 Aug 2019 10:18:58 +0200
Message-Id: <20190820081902.24815-1-daniel.vetter@ffwll.ch>
X-Mailer: git-send-email 2.23.0.rc1
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

Here's the respin. Changes:

- 2 patches for checking return values of callbacks dropped, they landed

- move the lockdep annotations ahead, since I think that part is less
  contentious. lockdep map now also annotates invalidate_range_end, as
  requested by Jason.

- add a patch to prime lockdep, idea from Jason, let's hear whether the
  implementation fits.

- I've stuck with the non_block_start/end for now and not switched back t=
o
  preempt_disable/enable, but with comments as suggested by Andrew.
  Hopefully that fits the bill, otherwise I can go back again if the
  consensus is more there.

Review, comments and ideas very much welcome.

Cheers, Daniel

Daniel Vetter (4):
  mm, notifier: Add a lockdep map for invalidate_range_start/end
  mm, notifier: Prime lockdep
  kernel.h: Add non_block_start/end()
  mm, notifier: Catch sleeping/blocking for !blockable

 include/linux/kernel.h       | 25 ++++++++++++++++++++++++-
 include/linux/mmu_notifier.h |  8 ++++++++
 include/linux/sched.h        |  4 ++++
 kernel/sched/core.c          | 19 ++++++++++++++-----
 mm/mmu_notifier.c            | 24 +++++++++++++++++++++++-
 5 files changed, 73 insertions(+), 7 deletions(-)

--=20
2.23.0.rc1


