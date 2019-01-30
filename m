Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D94A1C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:53:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BEC420989
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:53:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BEC420989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1A8C8E0007; Wed, 30 Jan 2019 13:53:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC91B8E0001; Wed, 30 Jan 2019 13:53:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C8FE48E0007; Wed, 30 Jan 2019 13:53:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 99F3E8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 13:53:09 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id w18so631914qts.8
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 10:53:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=C6vW8O0qegeYHJxpGeRT9gI7yIyMcGg27AnulN/+5Qo=;
        b=WF0+BhV9aKoblC7QqKXUKxZnhzr9clbfJzLu0Xx+JR0nJpercjT2Cq0MFdMNahbXnn
         GCf+Hgp7zg0Y5AUKBF87uK370D1OGSF4qt8kKX+h6zyiU5XKoo9eyw0v0xP2/A8pRuq8
         dOH5SRU4woAOtsJnhRpEyIpajeDSP+tpuPPAEN/Nn340P7Nl/6Cfxra0UM+mv0rudw1a
         pjWkVdPGxX6Jj33VGiSFTBeBU4LB5wrD0HEVM/95mhfmlOqcNuL66p/7P9YDwr5y6Qys
         YVQF1PRekcyTB2F2c6XiO6aqmSJcsPN0TtSbO1RGfkkicvQPhAxQcieU8NWKvdx/YKQW
         hjnQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukeBnqr7BdFsrhMXrhbmXHTcvE58KYsb/8OiVEvhicEEv7PxllXx
	d3D4aVLy4cHCsWGsFR1EP1Mhn/HC37iKYiolyu4RYSnZAgubtsS21KNk7OGnnJehutKhgMI4JTO
	8ukbJS967QErCwKiAb98R5MQByORvIkgz7K7Re3cS8f/4KRpK5qFPliwjTrfYTn9wag==
X-Received: by 2002:a37:bd47:: with SMTP id n68mr28381701qkf.203.1548874389293;
        Wed, 30 Jan 2019 10:53:09 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6afcUF2ASbJckvEAchtsXZidFURqap2sSsxhXnJ0aUN1vCEOtvd6hg0cE1xMJDAgIWjKum
X-Received: by 2002:a37:bd47:: with SMTP id n68mr28381666qkf.203.1548874388625;
        Wed, 30 Jan 2019 10:53:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548874388; cv=none;
        d=google.com; s=arc-20160816;
        b=GfaANdmW9rjIPJ3bgaTbNClRCnlqge3/u5Vh1N9kLDTwjWdZq2ANr/ScWo5eT1cC4e
         4yuyf7+HhwU40d87JE0ony1+z1YYPgqwPpUe9Q0EFULb5lwG1aU8UdR8sFx9Ofj2JyyV
         mN8qLhj05uZQ3zHjw9X769k8oaTCyn9VIlmMV65fXyNSkeYil9yG0c0FmHj3JV8YZa+h
         X8xN81fpIQ/VaaREcKsx7Tgpas4ftQnswFIFBiiZ6ZwRIPt0Jt5ZlyZ6Zp0n8glKCUoC
         6AYt3Nk8raIy6V9OxanHIf62E1vokIcRFS/i/+hX7YqYePXPH6A24KJAG0O875jHSbWd
         ibyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=C6vW8O0qegeYHJxpGeRT9gI7yIyMcGg27AnulN/+5Qo=;
        b=b1ZOPBe1dZs79/SH9nC5YiCabDDpfRqzomF1ODCerje1c2/ySFT/MjKATWafXgDxuw
         lq6oVPvJxsajII00qnTKkLKGa5yMiqJI17DNbXKd95oegsG/wuCNGKZfYC95HiGYRzod
         GVWqqGokogbqNt66O3Y2imsO2/yY8Bt26iI7hXD3gV28Z83dDz+IhuVdk9bAa0XT4jCQ
         l4pEXMbY23IQOqP7y1r/kSaKmlk0n/0NKnRYggT/6RCTJSFb4gdS8gyfAmLQ+bjKU5A5
         SKgTo/XIN9JN4jPuFOrFBzHmHKWds25yRNoRVkCUmeUbhpKhoBynWOncIw4rwLTxk+Dw
         N9qw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 16si1391734qvl.219.2019.01.30.10.53.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 10:53:08 -0800 (PST)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1F1B37AE8B;
	Wed, 30 Jan 2019 18:53:07 +0000 (UTC)
Received: from llong.com (dhcp-17-59.bos.redhat.com [10.18.17.59])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E2A925D6A6;
	Wed, 30 Jan 2019 18:53:02 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-doc@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jan Kara <jack@suse.cz>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@kernel.org>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Larry Woodman <lwoodman@redhat.com>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	"Wangkai (Kevin C)" <wangkai86@huawei.com>,
	Michal Hocko <mhocko@kernel.org>,
	Waiman Long <longman@redhat.com>
Subject: [RESEND PATCH v4 0/3] fs/dcache: Track # of negative dentries
Date: Wed, 30 Jan 2019 13:52:35 -0500
Message-Id: <1548874358-6189-1-git-send-email-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 30 Jan 2019 18:53:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

 v3->v4:
  - Drop patch 4 as it is just a minor optimization.
  - Add a cc:stable tag to patch 1.
  - Clean up some comments in patch 3.

 v2->v3:
  - With confirmation that the dummy array in dentry_stat structure
    was never a replacement of a previously used field, patch 3 is now
    reverted back to use one of dummy field as the negative dentry count
    instead of adding a new field.

 v1->v2:
  - Clarify what the new nr_dentry_negative per-cpu counter is tracking
    and open-code the increment and decrement as suggested by Dave Chinner.
  - Append the new nr_dentry_negative count as the 7th element of dentry-state
    instead of replacing one of the dummy entries.
  - Remove patch "fs/dcache: Make negative dentries easier to be
    reclaimed" for now as I need more time to think about what
    to do with it.
  - Add 2 more patches to address issues found while reviewing the
    dentry code.
  - Add another patch to change the conditional branch of
    nr_dentry_negative accounting to conditional move so as to reduce
    the performance impact of the accounting code.

This patchset addresses 2 issues found in the dentry code and adds a
new nr_dentry_negative per-cpu counter to track the total number of
negative dentries in all the LRU lists.

Patch 1 fixes a bug in the accounting of nr_dentry_unused in
shrink_dcache_sb().

Patch 2 removes the ____cacheline_aligned_in_smp tag from super_block
LRU lists.

Patch 3 adds the new nr_dentry_negative per-cpu counter.

Various filesystem related tests were run and no statistically
significant changes in performance outside of the possible noise range
was observed.

Waiman Long (3):
  fs/dcache: Fix incorrect nr_dentry_unused accounting in
    shrink_dcache_sb()
  fs: Don't need to put list_lru into its own cacheline
  fs/dcache: Track & report number of negative dentries

 Documentation/sysctl/fs.txt | 26 ++++++++++++++++----------
 fs/dcache.c                 | 38 +++++++++++++++++++++++++++++++++-----
 include/linux/dcache.h      |  7 ++++---
 include/linux/fs.h          |  9 +++++----
 4 files changed, 58 insertions(+), 22 deletions(-)

-- 
1.8.3.1

