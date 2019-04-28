Return-Path: <SRS0=7ROk=S6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83B86C43218
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 23:56:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FF2B2067D
	for <linux-mm@archiver.kernel.org>; Sun, 28 Apr 2019 23:56:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="t0IuUsXn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FF2B2067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABD556B0003; Sun, 28 Apr 2019 19:56:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A6D586B0006; Sun, 28 Apr 2019 19:56:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9849F6B0007; Sun, 28 Apr 2019 19:56:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 776056B0003
	for <linux-mm@kvack.org>; Sun, 28 Apr 2019 19:56:34 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id z34so8866708qtz.14
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 16:56:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=yu6NcO6qkqCy2IZdfcCLb2i4aKMiT552Q3oiWALCBq0=;
        b=TPNMaEyrZucD8ejdb+R85Mt0E/CvwMbMIU1QsdrGDpIS5zpXCIgkZlu8+6ssMixmmM
         mp8Z6zrANEkkZgOV3Z23KgyvJCP+1gWVJ93VirbZTdafUJJkGyg04+51dSyTkQ/TmtF5
         NY+e6qB7sr28A4OHz6SxPqu56d6SN2z+xf7D/TehTH0SeL5TiB12TT3Ur00/4Z4a/oWg
         KeccdZmSJ3YUeBlKr0qz2Ah1sz8Ic+Bjl72SFaeMJ/oPjUfu377Hst8lOPd1rxKT0T7H
         X+3AWgO8otO6KGEGjugEMPMWrJh6xd/OMuehbqh/usnrDekI5eych1yNZMkzFm0o7Www
         s8RA==
X-Gm-Message-State: APjAAAXdH+g0e5jU9l1KWDND7pmO32tB2kLHuHNefcVXPIaoi33/Ip7t
	glMaxoF3mM0HD8qMvtb2jtUrF85HCOjeLyxIBGE2yMmOi0okGmlrxmPmmqUfOPHv9NQW/KuTFk0
	F8TEBWSPPfSGYQK34Jlu7XMLUyY5yDi6tZhk2vBngnFIZit8nW6WeadE9wRTaaYAwbA==
X-Received: by 2002:a37:a243:: with SMTP id l64mr28047379qke.235.1556495794256;
        Sun, 28 Apr 2019 16:56:34 -0700 (PDT)
X-Received: by 2002:a37:a243:: with SMTP id l64mr28047352qke.235.1556495793665;
        Sun, 28 Apr 2019 16:56:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556495793; cv=none;
        d=google.com; s=arc-20160816;
        b=oK28HoEEsvGqUjqn9AsR9NVAWiWGplbhP2fQZWLEfspd5/K+g8EBubKCH6ImC1d14c
         islwZjswf06usqMRN5J+BtwfQQH3u0HJocP45076u9CQ8sUd1b7f1h7pQZ8GiZ9WQJ1a
         rCVLdTlGfq95G+EushLHl044f/DDLFyu0mtVaodNX7Rdckx9eqXGIcZ5q535vQdwgR3L
         YmZahYRVRLUexIqR6+z+UfHE6N+AJ5YSgBGwcKcxVp11cgquNF2LX0PlIyFaxueBXe52
         BSnRsfOqnvDnpTM/2EsCwqKxDzIpoBgq8OShglonehYDieBx+ldSGTZQXgJ6HiBYxLyK
         2cZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=yu6NcO6qkqCy2IZdfcCLb2i4aKMiT552Q3oiWALCBq0=;
        b=dzrGI+z428lTZUzU+ylLySHpxGfyblr8cC6SW2Ei+i3ycjZLGkaGQcoNvzcZPTTGyr
         A0Sas2PjrFCYU0OKiHNBZxvAmNsu6DZQji9lpfEOUXRvzkniGMXwYx71GkT8smO/HMlV
         IFQD8qXv4sVXCTo8+rP19xlMutlESsRT2R0DbOfogXFH84jjn0zPQXDUszrbbEFruqCv
         Nr14PTuPhGfeRKEBEZMUSYE5sEnwAm4+bbTOojQp0RzLzgGRE0W/y5FfSaec+G9YnX+3
         EUEJmzL2n2E4B+9cWHUbpOQf3WAEdUQtQDjkOhZApK83ztWT2utBLRyIT9e8mHPT6ZYw
         o+rw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=t0IuUsXn;
       spf=pass (google.com: domain of 3st3gxagkcdigvoysszpuccuzs.qcazwbil-aayjoqy.cfu@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3sT3GXAgKCDIgVOYSSZPUccUZS.QcaZWbil-aaYjOQY.cfU@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id b7sor44426283qtb.63.2019.04.28.16.56.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 28 Apr 2019 16:56:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3st3gxagkcdigvoysszpuccuzs.qcazwbil-aayjoqy.cfu@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=t0IuUsXn;
       spf=pass (google.com: domain of 3st3gxagkcdigvoysszpuccuzs.qcazwbil-aayjoqy.cfu@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3sT3GXAgKCDIgVOYSSZPUccUZS.QcaZWbil-aaYjOQY.cfU@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=yu6NcO6qkqCy2IZdfcCLb2i4aKMiT552Q3oiWALCBq0=;
        b=t0IuUsXn9gaq3SQut1xYfgcWiEy8RtkERl2pBXCiH9XceacJW0QWyY0WBZHCewi6u6
         YRjtmVCPM0+qoQv1Z87j/N+3XJ6aoclitm6grIraYu8Y9Bqhjs/dhYKOjl3kFgZZJthp
         pG7y7jAYeykyDXhBxasCXYScBOh8nNzAxjTMW89k/5W00JPfrgSZ9b5ObblARtA3d0rr
         KacNMeGFpwmM7JL572xU2Rag7vO9sZNeLdQO7gbiSSqb9VOrg7HXmC04PDokV2Tk6AJU
         C6mcwZUohipajKu8TC+IP/nEKyhgdFNNkhV+kO/BxejCC4n5s/0FpqjJ2o1Bvmw+R4+U
         Husw==
X-Google-Smtp-Source: APXvYqwscTyupsIoajguC2ll5HejrseWPsuQsoX13E2On/kwywEZi3TbpJQWePki5zziDZiwfyJTkIrJKlFGbA==
X-Received: by 2002:ac8:33eb:: with SMTP id d40mr25801482qtb.263.1556495793414;
 Sun, 28 Apr 2019 16:56:33 -0700 (PDT)
Date: Sun, 28 Apr 2019 16:56:13 -0700
Message-Id: <20190428235613.166330-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH] memcg, oom: no oom-kill for __GFP_RETRY_MAYFAIL
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The documentation of __GFP_RETRY_MAYFAIL clearly mentioned that the
OOM killer will not be triggered and indeed the page alloc does not
invoke OOM killer for such allocations. However we do trigger memcg
OOM killer for __GFP_RETRY_MAYFAIL. Fix that.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 mm/memcontrol.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2713b45ec3f0..99eca724ed3b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2294,7 +2294,6 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	unsigned long nr_reclaimed;
 	bool may_swap = true;
 	bool drained = false;
-	bool oomed = false;
 	enum oom_status oom_status;
 
 	if (mem_cgroup_is_root(memcg))
@@ -2381,7 +2380,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	if (nr_retries--)
 		goto retry;
 
-	if (gfp_mask & __GFP_RETRY_MAYFAIL && oomed)
+	if (gfp_mask & __GFP_RETRY_MAYFAIL)
 		goto nomem;
 
 	if (gfp_mask & __GFP_NOFAIL)
@@ -2400,7 +2399,6 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	switch (oom_status) {
 	case OOM_SUCCESS:
 		nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
-		oomed = true;
 		goto retry;
 	case OOM_FAILED:
 		goto force;
-- 
2.21.0.593.g511ec345e18-goog

