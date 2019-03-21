Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5609DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 21:45:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A3F821916
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 21:45:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A3F821916
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B14176B0003; Thu, 21 Mar 2019 17:45:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC3A06B0006; Thu, 21 Mar 2019 17:45:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B42B6B0007; Thu, 21 Mar 2019 17:45:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 736896B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 17:45:38 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id w134so142439qka.6
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 14:45:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=oVlIazTHKce+tMnlJcR9AELncx++OlgJ6EkW+5kGuBo=;
        b=twE2RaVZzaoslQBgeqsFTBmiwqzwPocQz/HYi+pUpA41M1zd53O+ePkSv62dPAPoJ2
         u33c9nq+o7iG8PQr7JWTFeaLMxwGlSKJWEr1Bpx3WJibt9txj9T3K1NtEH8/Jif71vBb
         koWerM9hNXIdqEIJpwn+v55mdhWC4Ltw5Pl/h2uCiY9Zgw1yJQ1xNRJyg53YpDCE9IYA
         6UABQJ5sWwLGni2VLhEjz1reCU+pPWEVapaWA77thok1U0r1/QyrRrfwfmtw8zKVNtyl
         FaLbyOuVJyMoHSiGdEbrC+bsSnn9uoDvVQEYN2qlxVkrOGJqS50cbNIZzgq1yQw1zjU8
         PZxQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWqVRFCyXh6UweovGolwLivT1w8+ds7Urusf5uddA16AoR6vyaE
	1T9JK4QxB94huHKwe8Z28uJY5hCNC1d7ZpVxD4tDMGDcy8j0vfdfPMu9XG2iM0sD90JKMS+eTM4
	SPtyQC9Y+0v5evFy+d4oJbIMvjJ3+fbQkdt++2ChBuKx1Xmcw4x6LgRr9a5OspGzN6g==
X-Received: by 2002:a37:d150:: with SMTP id s77mr4859951qki.334.1553204738233;
        Thu, 21 Mar 2019 14:45:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDM3c8NhLqx+0LumQRokZFJhMH0m0nDJEG6MnSM0UOVi9rL9FN8DgIwCRg4HIgWu+sL7SD
X-Received: by 2002:a37:d150:: with SMTP id s77mr4859908qki.334.1553204737554;
        Thu, 21 Mar 2019 14:45:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553204737; cv=none;
        d=google.com; s=arc-20160816;
        b=VwbaBY4/Qm+4omNo8WxYI0myCol/6udsYFUKBUdJANowl86mKMqDBi4oXp9My2ZFXI
         PrkMsWirZCwhB7pF6eekczpwzyd4KB/WLtG10nZlXWzEE7GNGFGccOvkMLDJKPi3bGYE
         McqRtXq0L+WYdMCot3t0Dwj3uvelqGqk2KxFoJOvnV5H3aN128hitPS01VSmY4G80dod
         cAZW9/ycSGBYoK0W5EUxTgqVYTs22s3mKngnUd35YR2aLwwbUTwW5Ai8tiijKea+VaY4
         UxFtJaeOnglj1//4a9KfOhiAqtAO6Vm4wZA/+xyCXoFCvwQCbc/Dc33k3Cr2Apxobq4q
         Aywg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=oVlIazTHKce+tMnlJcR9AELncx++OlgJ6EkW+5kGuBo=;
        b=yEEJuxFoofvzcXzU3AHmgimLCJihA4DkoquK8LCNeB89qVoL5G86WNrW45Tt0QSSF7
         Ew5NbLMtz1tplWovVVkHVXpgvxli/C+x8y/0eChVv7sDfhZvN7HfmtTOgb+qatQYlg3/
         LpPQXqY6JcgekwQ8paTWgLZ6BWPCAqAyqVgKQWnJzfSHnKW455wr8Oue2+vvilWCiEbK
         33KVRSLG1BjhAzMqmhEbBx5b9im/P8kIRs+ihuzEp2FH0HKDQOpvO8sf2uZrLYKIOD+7
         8hcMgc+zrihPfWIr3iSFbUGERwqbxIXE4nsGPYpVY7IyAferul6ufE/CFSKzxP6ld8wR
         Tj0A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c6si3858641qtc.307.2019.03.21.14.45.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 14:45:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DA86A59443;
	Thu, 21 Mar 2019 21:45:35 +0000 (UTC)
Received: from llong.com (dhcp-17-47.bos.redhat.com [10.18.17.47])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 845765C8BD;
	Thu, 21 Mar 2019 21:45:27 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	selinux@vger.kernel.org,
	Paul Moore <paul@paul-moore.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@parisplace.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Waiman Long <longman@redhat.com>
Subject: [PATCH 0/4] Signal: Fix hard lockup problem in flush_sigqueue()
Date: Thu, 21 Mar 2019 17:45:08 -0400
Message-Id: <20190321214512.11524-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 21 Mar 2019 21:45:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It was found that if a process has accumulated sufficient number of
pending signals, the exiting of that process may cause its parent to
have hard lockup when running on a debug kernel with a slow memory
freeing path (like with KASAN enabled).

  release_task() => flush_sigqueue()

The lockup condition can be reproduced on a large system with a lot of
memory and relatively slow CPUs running LTP's sigqueue_9-1 test on a
debug kernel.

This patchset tries to mitigate this problem by introducing a new kernel
memory freeing queue mechanism modelled after the wake_q mechanism for
waking up tasks. Then flush_sigqueue() and release_task() are modified
to use the freeing queue mechanism to defer the actual memory object
freeing until after releasing the tasklist_lock and with irq re-enabled.

With the patchset applied, the hard lockup problem was no longer
reproducible on the debug kernel.

Waiman Long (4):
  mm: Implement kmem objects freeing queue
  signal: Make flush_sigqueue() use free_q to release memory
  signal: Add free_uid_to_q()
  mm: Do periodic rescheduling when freeing objects in kmem_free_up_q()

 include/linux/sched/user.h |  3 +++
 include/linux/signal.h     |  4 ++-
 include/linux/slab.h       | 28 +++++++++++++++++++++
 kernel/exit.c              | 12 ++++++---
 kernel/signal.c            | 29 +++++++++++++---------
 kernel/user.c              | 17 ++++++++++---
 mm/slab_common.c           | 50 ++++++++++++++++++++++++++++++++++++++
 security/selinux/hooks.c   |  8 ++++--
 8 files changed, 128 insertions(+), 23 deletions(-)

-- 
2.18.1

