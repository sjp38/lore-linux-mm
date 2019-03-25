Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EEE6C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 22:56:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDEF9206C0
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 22:56:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDEF9206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FE966B0010; Mon, 25 Mar 2019 18:56:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60ECC6B0266; Mon, 25 Mar 2019 18:56:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 32AC16B0269; Mon, 25 Mar 2019 18:56:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 048C66B0010
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 18:56:42 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id n10so11831681qtk.9
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 15:56:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=kBGdiOKZc7RwoAm8pyb1Q6kZSuajgrm1PhUmnXdI0ts=;
        b=GT9zlpPlEf0ehkvhqZcCf/EnJD3YsmFBqClG0Ei7qiceS5DcJjJqTdXKCmfAOo90Rd
         H8CkfVi2lYYoL8z1DbWuSLbucqe/xmpQ2mjtu8Wyz9WemFiIwAct1N4Yp/ezFayiPsJE
         Y0Xox1xnGalt+iVGCmWxrSh5C9Mt/iAuy71YqIfv+ulELoczGrYCSmPTeRx+JNC14eeN
         Hi+zVxESf8hDf0M1QCCo0pocUV7Q8kQ42+kdlJZKg3unN7o8SFA2HjMyFOpbeTE6lxaW
         dEcBnQFhT7yglgcoNoAqk2bivR2kQSfL+ZRt4xEbgwbNklFTPSLgsCbF8V0IQQ5/Tj7g
         YSkw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX195DVZyjDnqvYzAJPMn9bDn66tS0mFTgYmeTHLQhxHkHKpfUD
	k8FPuuwQ1PLT4s4HGagSqlj9oGQdSjs6wbsEp50HJCL6/ZTnOLVPw25p4kQAaZeHjs6dsIWRNQw
	FyIA6mrdV2KbTaTH9tgamvPAltWV2fELaUmcC5YwdArvDJVBM7/Lgtzz2+3F0eRf9uw==
X-Received: by 2002:ac8:2d94:: with SMTP id p20mr23386129qta.62.1553554601781;
        Mon, 25 Mar 2019 15:56:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyw9RDk/Qjve40Nl0ScjAB3ucAzl4W0Zpuuji9aPPvwfP7H+Vm1qPPlW15xs9/+9w30/JZZ
X-Received: by 2002:ac8:2d94:: with SMTP id p20mr23386101qta.62.1553554601274;
        Mon, 25 Mar 2019 15:56:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553554601; cv=none;
        d=google.com; s=arc-20160816;
        b=DO2QEiBCZSCamtd0Jm1wKh++xoN2eInbhGjdpmzZws2KQFjUSy0rK8XVNecpt7x+wV
         jAJJAAucehWapuAAswlXCwQxb/d0/4PI3NwW24QM00K2neRv0xYXgzJlGqORcTPN6WQH
         aFXNj9F+qBv59CWUHl6GUswih6wnKdFkFb5+ubyph6TELH1sdO6hHMV9UCEVUzbg2usI
         zjxzexvynLuwiGqfynajpshlcW+B9YTtQA4fj7iunWimkzkw3KAqaDOkgVFv7oXCM+Yh
         jAeS6l7CwcdZmhJnneMB5tCOuPSbNVtMuNeePcOxl0ekDb2nFyQEhoaHHby1LZaDw/9m
         ECGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=kBGdiOKZc7RwoAm8pyb1Q6kZSuajgrm1PhUmnXdI0ts=;
        b=rEsR6rpozIOdAyFT1Zrqde+6twiV4EX1vF+r/d4f0B6jaHb01k4HOEieqkQjyyF/KS
         zRpbOmaE6yPXU6RQ4dZgTBFXjOKNsGCqap5NUDdopi4xGRx7zps1pFeOfo7pBsDod3ru
         SPUzuq+PPuI4OrURbvbys4dU+hrl68gKYrIXzzJD7rf0FDyUJTbPld95/Id6THbDlG46
         GZ26/bDZkov0KIgJyTmVBZNRr/gGD58UZv+GsxF+hVexhdD45wxi1oMKBq50bsy3ySXp
         9DaXwi1uWDhNusBU+sHx2sUgOgb9+KMJoayAMqmWAScntldsoQHumNeWib7LkJtA2gzr
         m84g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i19si2173758qvg.35.2019.03.25.15.56.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 15:56:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 41D86308338F;
	Mon, 25 Mar 2019 22:56:40 +0000 (UTC)
Received: from sky.random (ovpn-120-118.rdu2.redhat.com [10.10.120.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D933B5B6BF;
	Mon, 25 Mar 2019 22:56:36 +0000 (UTC)
From: Andrea Arcangeli <aarcange@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	zhong jiang <zhongjiang@huawei.com>,
	syzkaller-bugs@googlegroups.com,
	syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Peter Xu <peterx@redhat.com>,
	Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH 0/2] userfaultfd: use RCU to free the task struct when fork fails
Date: Mon, 25 Mar 2019 18:56:34 -0400
Message-Id: <20190325225636.11635-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Mon, 25 Mar 2019 22:56:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

this fixes a race condition between memcg and UFFD_EVENT_FORK that was
reproduced on aarch64 with qemu with syzkaller.

While at it I also added more WRITE_ONCE in places that shall use it
(in theory) against the rcu_deferenfence issued in the in
rcu_read_lock critical section.

Andrea Arcangeli (2):
  userfaultfd: use RCU to free the task struct when fork fails
  mm: change mm_update_next_owner() to update mm->owner with WRITE_ONCE

 kernel/exit.c |  6 +++---
 kernel/fork.c | 34 ++++++++++++++++++++++++++++++++--
 2 files changed, 35 insertions(+), 5 deletions(-)

