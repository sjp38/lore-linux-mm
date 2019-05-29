Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD9EBC28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 21:06:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F906241CB
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 21:06:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Dit7xG7b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F906241CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D1BF6B026A; Wed, 29 May 2019 17:06:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 282806B026D; Wed, 29 May 2019 17:06:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 197FC6B026E; Wed, 29 May 2019 17:06:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id EC0116B026A
	for <linux-mm@kvack.org>; Wed, 29 May 2019 17:06:21 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id w6so2265197qto.18
        for <linux-mm@kvack.org>; Wed, 29 May 2019 14:06:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=kDZhofxy6mufe3ksiaEz/xmHPiYjpnBL8G/C22N/e+4=;
        b=CGgUPKHg4NP1GbLnI0l624X6aeRnUAvfXviAomRQPCWajvUH6ekm0qPNgzlPC9lTiG
         7PHZBUtb9MbZLQm+tx+en1y1R+8BNKQfHa4gf4xIvmH54rHIaJle31GiZv4b3PGVRyyb
         TXnn2DCnXt8f3exNL5ZPj103qoCNSkC/WSnGVCqPK53Rna8W4ecQcYJoDz8UnyyUBVm6
         HT+nMHmXERHAXCNFjU6kpTWm40YYN8gBrz/ensvjwa90dChIU4xOhsJ9wmmPDUYA6CBe
         Eb+en6ll5iOpkLgr+bYhwS4NypizSkHJIZ/FBGFEmrbHuOrOfuEeazuUSKxUJAptEnbA
         4d5A==
X-Gm-Message-State: APjAAAWIB3dgijAif/Uh2hrxWUfJR8CZkrFdaiBSbzdJyKpJ9HRBy9BD
	gLqfIokOPsurlDxxpVg3kncKtcviA5EksiyniTXL9mzcCFSk5kcpXQCUWCpk0YiV9JlIWLMuRTa
	H7S38AfQLOCkSVOQVXl7jV6vxLZN/GTf67o6VCnvv0dHru7zuwSC/HXeahyjphks=
X-Received: by 2002:a0c:9850:: with SMTP id e16mr82771qvd.163.1559163981720;
        Wed, 29 May 2019 14:06:21 -0700 (PDT)
X-Received: by 2002:a0c:9850:: with SMTP id e16mr82700qvd.163.1559163980666;
        Wed, 29 May 2019 14:06:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559163980; cv=none;
        d=google.com; s=arc-20160816;
        b=Hn07+zLQWVnJFxGgkRm/rgahe0VyhyrJtuDIVc456ufXl6mI5BhhYVpShfiVTZv8yk
         MSFqxdzJ0GbrOms4OD24cBH05T72zwfPOIoYAGOIA9k0ScpCSKyUapPcvensTsUapgZD
         rUYpAzvj9uPT7+/Jxz9V1R2EdclB4N7ZijHRw9dzhPPSjHt602fsIUSbZYrrU+LqKuEF
         qZQf+kJAHc5g8eKGYMH8HR1WrmKxaOtjf4gnAoboenWQql3BbBBz3ko0SbBT4RTN3eYE
         NjAnUb4x/pt4sU1s2qbzEfzTW3xnjJG0pXKbKaBcZMaxw0C24jYpRyk1hSqaVXn/N6s9
         sD7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:sender:dkim-signature;
        bh=kDZhofxy6mufe3ksiaEz/xmHPiYjpnBL8G/C22N/e+4=;
        b=ygpWRme7tpSuN1h9XJMIgrmRwP7UCSKNDf81muzQVlUkSmlp+xsVOuUpW0/P7O6oKg
         DUM9XJX+BjSwSJwtlmvuYzF1rsN4vS8MV7hMohD9NkonorBXchkMucWKWnXBVOijBnZr
         +7Wcum7aLQvu8Fw3t6wtMSNY3LPUgAZsYbi0XIZEDP1S3PCHuGO5nn/Dyu1T5h11EBoq
         Nu1V2/WMWOh/H5XPbqQgCVk0onde7HRQHC1+7CDs5BWZ6466pwpwJv93f1lkZo2c9QtZ
         NDk4FzBLf8zgaM//218WneitKoUGOX2O1Nri9R0ZvqgMpBOMpoR++wpbV7YcLON1crhe
         P9sA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Dit7xG7b;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z126sor268115qkc.96.2019.05.29.14.06.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 14:06:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Dit7xG7b;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:mime-version
         :content-disposition:user-agent;
        bh=kDZhofxy6mufe3ksiaEz/xmHPiYjpnBL8G/C22N/e+4=;
        b=Dit7xG7bM1QDMHav6URFGcGdjxjlhT/gUPKBtE42oGWAdDT3YZbeZYtObRKdxM3Bzl
         948MWlm2R8M/jiQ3JTm865KfiiVxQdQ7I2jJeYjwXMGyprW/kwm+lxoQJENyx+w9chzp
         Q7J/+qlmpnu91qGcb7v5KcRxEtAGsWUnJo6l+DzaimKsyCV6YQT/jxCIjc+DPCUQSvLo
         NE+3Pkq6Zj97IW3rf0iK0hqngJK6sWRZ0C8UwndmSJUzEKnqqq22b3CGDW5W3WOGaYK4
         FisXuLDVkP4NSjcjBUz171btDOTsv3tl1Q/2+JLcOv67XlLuB2cvkgcxuHyfk5nAS2p2
         yZXw==
X-Google-Smtp-Source: APXvYqwJkpegnMhQjW+QQW841v8rVagC6Jn6IrcotmLN4smB41C542UQJIDCuIDgyKfrB3TFDcvRrw==
X-Received: by 2002:a05:620a:16c1:: with SMTP id a1mr12635399qkn.269.1559163980173;
        Wed, 29 May 2019 14:06:20 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:849f])
        by smtp.gmail.com with ESMTPSA id w48sm269662qtb.91.2019.05.29.14.06.19
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 14:06:19 -0700 (PDT)
Date: Wed, 29 May 2019 14:06:17 -0700
From: Tejun Heo <tj@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com
Subject: [PATCH for-5.2-fixes] memcg: Don't loop on css_tryget_online()
 failure
Message-ID: <20190529210617.GP374014@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A PF_EXITING task may stay associated with an offline css.
get_mem_cgroup_from_mm() may deadlock if mm->owner is in such state.
All similar logics in memcg are falling back to root memcg on
tryget_online failure and get_mem_cgroup_from_mm() can do the same.

A similar failure existed for task_get_css() and could be triggered
through BSD process accounting racing against memcg offlining.  See
18fa84a2db0e ("cgroup: Use css_tryget() instead of css_tryget_online()
in task_get_css()") for details.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 mm/memcontrol.c |   24 ++++++++++--------------
 1 file changed, 10 insertions(+), 14 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e50a2db5b4ff..be1fa89db198 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -918,23 +918,19 @@ struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
 
 	if (mem_cgroup_disabled())
 		return NULL;
+	/*
+	 * Page cache insertions can happen without an actual mm context,
+	 * e.g. during disk probing on boot, loopback IO, acct() writes.
+	 */
+	if (unlikely(!mm))
+		return root_mem_cgroup;
 
 	rcu_read_lock();
-	do {
-		/*
-		 * Page cache insertions can happen withou an
-		 * actual mm context, e.g. during disk probing
-		 * on boot, loopback IO, acct() writes etc.
-		 */
-		if (unlikely(!mm))
-			memcg = root_mem_cgroup;
-		else {
-			memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
-			if (unlikely(!memcg))
-				memcg = root_mem_cgroup;
-		}
-	} while (!css_tryget_online(&memcg->css));
+	memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
+	if (!css_tryget_online(&memcg->css))
+		memcg = root_mem_cgroup;
 	rcu_read_unlock();
+
 	return memcg;
 }
 EXPORT_SYMBOL(get_mem_cgroup_from_mm);

