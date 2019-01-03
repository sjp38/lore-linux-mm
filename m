Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAC2BC43387
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 01:56:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78FA82073F
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 01:56:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="O+as1x8B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78FA82073F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2558F8E0055; Wed,  2 Jan 2019 20:56:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2034D8E0002; Wed,  2 Jan 2019 20:56:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F3E88E0055; Wed,  2 Jan 2019 20:56:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id DBC868E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 20:56:52 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id j13so22912884oii.8
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 17:56:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=1IEdvSxiiyqFy6UrKVLcrWtjX6CPPhzM2L/LFrcQXhk=;
        b=tuGx9bmb85npZ4wsq4ey30FvoExOwHwGeRDN83jg7XbA/IhIQ158KAiRNmO10qeIYn
         SC5sxWEiC06HHZwzSddkOVvKy4uJr5EaXl87P9li/CRPBVeNJ4L3+3IDjH25jo9vO8fw
         /15pglCvDmES7qGkr9fJ9G4USemcQqa2T9SKkwZ1G6x99/MnmP7h6FHYoN3SyBb/zpgp
         5kmW3gAd8lZDLPVm0xMxHNlh37hr4KaCRgKgNXCE5KEtMg+9Hnma9DZaNx01wg47k6sD
         c2GWQHOU1FdMMODDNFd42oYpBJ53vCfrPISEkauweOqA5HSjEsz1BhDkWLnrhxgyEcFk
         P8uQ==
X-Gm-Message-State: AA+aEWa6Eqd74HK2YJXlVSmYdRFBXJP+LeycTp7OPHlBXC4ogFGC3Vkz
	etvGTpW4b9xiDulnFkF5mj16Qm8ZzrYsdqm0mVrfExUcKm7MYEEeeMlbzJ9XQpjr+ZsbRYF1buE
	9uudWHiRg2uBgPWN44TVHbrdQPMDjNC7RfAL5/Y5B6ZgDw1Oloid57prttBRwBlPKfMwZ2K7gdT
	5VLphNbCFpI+nc3uakuBGe0HPy6Wz/yF1MdEZSDM3hdoHdOiXXrfbSYjQbD1082JmXgvf5nEX9z
	BIknFvsicYUtFQrqmpUdDZsBjZXSq/LNSTmDuovE0qXfsIAyEvgOG9aiNsZfPktOP1Rg93OFeVu
	fNoGC/ZoWgY4Gg3ihNSH5XAYMgNRu1snpuBm9z5kN4dDBsmQIjvRocSxTNhxNlb5DlimbFtTR12
	/
X-Received: by 2002:aca:ef0b:: with SMTP id n11mr29932949oih.116.1546480612620;
        Wed, 02 Jan 2019 17:56:52 -0800 (PST)
X-Received: by 2002:aca:ef0b:: with SMTP id n11mr29932934oih.116.1546480611945;
        Wed, 02 Jan 2019 17:56:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546480611; cv=none;
        d=google.com; s=arc-20160816;
        b=EWLjcfl/1J+XCT8WTHlICzP5KH7mKe06hL9jKPJBHpDCZODmHbVsdpJ9XEtVrTQaKt
         AFsMrBIO7EjHY7NIjc/62mntO8KzSOEBqfjv29zRqyA6jpC4K0j7kdFw59FetncKefWn
         bQi5FkyW5fUR4OuxDIWpSZgFf8IgrnqBGl1it+ucJl31pv9FCLtaUS1KYEqQ1uQBB600
         OBUk6QTp6JD1dFiEk56z1gQVD/Smt+cAYjMnoaxv52rGrKXLaOYfrxmR3KBDW/cpW4aZ
         xcckyc0nwdKpjhvn3w/QASb3n4P/K1yvsn8gmsvkMG7jknTRYjiFet3rfDn2kndbrq8q
         boLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=1IEdvSxiiyqFy6UrKVLcrWtjX6CPPhzM2L/LFrcQXhk=;
        b=uYz8zapamWvrUznmpKzpGrOjR7fhO8EzpPnciYaU0qZKP771czDDNC4WLHvKiEK7Vm
         J7YR8TJ23lD6TVp2mh2izdgBTqmdaKJqGNqKNag/ut0OnnPmqiJZEl41HfeWQGvsX0j/
         PbLi8HzPw7mIs1HfVsmKDizl7oz+4va9IBk7rF/YcY3xXfrTi7tLSQ8j7+IR33lApU9L
         5jOpb2BkJdoTCuHNE/YHvnpsnlsn4/AFLEzx5xUE/8w1DCYWP4IFZDn9YfrUqUVWMi6Z
         kWDiMtVSxa7M/+05s7kLsH74IU7PR9oGqPJ6V7/YBo9tzqgD1G8c3gCS10DQMt+eO0u+
         bZDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=O+as1x8B;
       spf=pass (google.com: domain of 342stxagkcfgi70a44b16ee6b4.2ecb8dkn-ccal02a.eh6@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=342stXAgKCFgI70A44B16EE6B4.2ECB8DKN-CCAL02A.EH6@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id x2sor28012424ota.72.2019.01.02.17.56.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 17:56:51 -0800 (PST)
Received-SPF: pass (google.com: domain of 342stxagkcfgi70a44b16ee6b4.2ecb8dkn-ccal02a.eh6@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=O+as1x8B;
       spf=pass (google.com: domain of 342stxagkcfgi70a44b16ee6b4.2ecb8dkn-ccal02a.eh6@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=342stXAgKCFgI70A44B16EE6B4.2ECB8DKN-CCAL02A.EH6@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=1IEdvSxiiyqFy6UrKVLcrWtjX6CPPhzM2L/LFrcQXhk=;
        b=O+as1x8BbL64S+CFz8r+7ZJq91aRp0KbfX1lcq5FkGxOGbsxhQ/zxsFmi1Vy0Kb5a/
         pJTBwBiURN4IGInYblKKXGfNVjIv4kEhu+kWwCP2Jg244NAdsqt60xBSklLEp9SYFr4R
         XdCHOT9vtQWN03lKDw0YI5Fz8Rf10w7b2rmdLTc9IMOaMxtwMZW9ckjBFAo5TAU8wt+X
         4rysTKaL+ue20yJQZUSBvY1yRsWOLVyzNwde48PuQT/YG/Dhf4F0Sid4n+Pa7c5kYf1j
         qqthVXOSIztPgmDX3ULfduwZkMJxp1KYbknVGEBC315bSoc+XPy4dsrTeU7FDQe82/P3
         hW0A==
X-Google-Smtp-Source: ALg8bN7jWozz13OWzQ+A70JtrRj6cJutBJTH/Gxv95lL+kAkhPL0oDZrRFq/MSfDf+Hs9Q3mRcp4KIw+BwcCqg==
X-Received: by 2002:a9d:ba8:: with SMTP id 37mr34172518oth.31.1546480611663;
 Wed, 02 Jan 2019 17:56:51 -0800 (PST)
Date: Wed,  2 Jan 2019 17:56:38 -0800
Message-Id: <20190103015638.205424-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.20.1.415.g653613c723-goog
Subject: [PATCH] memcg: schedule high reclaim for remote memcgs on high_work
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103015638.AR95q1u-KY5dviJXWX-7u5pu-ud09t7SXDXOFaChI0A@z>

If a memcg is over high limit, memory reclaim is scheduled to run on
return-to-userland. However it is assumed that the memcg is the current
process's memcg. With remote memcg charging for kmem or swapping in a
page charged to remote memcg, current process can trigger reclaim on
remote memcg. So, schduling reclaim on return-to-userland for remote
memcgs will ignore the high reclaim altogether. So, punt the high
reclaim of remote memcgs to high_work.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 mm/memcontrol.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e9db1160ccbc..47439c84667a 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2302,19 +2302,23 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * reclaim on returning to userland.  We can perform reclaim here
 	 * if __GFP_RECLAIM but let's always punt for simplicity and so that
 	 * GFP_KERNEL can consistently be used during reclaim.  @memcg is
-	 * not recorded as it most likely matches current's and won't
-	 * change in the meantime.  As high limit is checked again before
-	 * reclaim, the cost of mismatch is negligible.
+	 * not recorded as the return-to-userland high reclaim will only reclaim
+	 * from current's memcg (or its ancestor). For other memcgs we punt them
+	 * to work queue.
 	 */
 	do {
 		if (page_counter_read(&memcg->memory) > memcg->high) {
-			/* Don't bother a random interrupted task */
-			if (in_interrupt()) {
+			/*
+			 * Don't bother a random interrupted task or if the
+			 * memcg is not current's memcg's ancestor.
+			 */
+			if (in_interrupt() ||
+			    !mm_match_cgroup(current->mm, memcg)) {
 				schedule_work(&memcg->high_work);
-				break;
+			} else {
+				current->memcg_nr_pages_over_high += batch;
+				set_notify_resume(current);
 			}
-			current->memcg_nr_pages_over_high += batch;
-			set_notify_resume(current);
 			break;
 		}
 	} while ((memcg = parent_mem_cgroup(memcg)));
-- 
2.20.1.415.g653613c723-goog

