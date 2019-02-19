Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12038C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 15:27:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF12B21738
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 15:27:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Hc7yKF8Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF12B21738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95B4C8E0005; Tue, 19 Feb 2019 10:27:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90F368E0002; Tue, 19 Feb 2019 10:27:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D2F78E0005; Tue, 19 Feb 2019 10:27:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 29A188E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 10:27:46 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id v8so794665wmj.1
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 07:27:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=2q6fbrSJpEIdLncW4UFN3mJBQ17i3z8yQuQeSIDg2n4=;
        b=mzHO+mMzGHFUFZ3FK0mH4tcX3RG6+tpDMthlnaSjbPIoO0faUNsA+Q2rHIp+jk/8ft
         SKwkxoliqTOUCCVGCGC49fLwEU3/tkGD5rYy3xI8WHR7VD30tbSMSvgdW+nFFnq6DnAu
         9KcOkaQQnJSSvIBNXYdz75vWpzL9dp4+0+hFHYsTcFCrO5OBauXqOD38DnHoUgxwLJ9R
         5NuA8klJZCoellygOLnVUuDZFPAdtgxG9/c5cDVAx16bsaj16ObJZDHQDC63Hu1BHhoD
         LLTLK1K2pSBGcuePbny4c3mHSGc7T7jBj8ybvS/GHXjOI70mDrl42GcpP9dIYmkIhHe/
         4xsQ==
X-Gm-Message-State: AHQUAubTT73XX3GWoa3/A74ou9BVluETVr/dHbHvXABd/gz5PwYqjImG
	eKjM3/8oijyyo6QskvKkTKIhpbq2QJQs3mmPDn5qQedASn2UDZBVFzKiJ7m5mURrcxTB3uT/ENK
	eyfjr5Tx7uqWkKIodDTWdrbEY2aWuOFyNQJilF9qgO8K9gocQqMJ7ZsYDZvL6v1zzzmi0RayGVa
	cg9BoX/pALLAXCZ99+O/YB2iYpUNPHRBGmsim84Rh5767NLHeWMFcpd0UOEWOpY1NSfNM7J4Cd2
	6d1vMynqycTc9b9/OfRuUcXvFkABHV5AI1y1AL9QDVq6b2AohvoSvFTnV+y91gtMZVi1t1fh7PP
	7dlhEZOb+49PXWb2nR3DrNTnHyrt6QADIy70RYXlkq+sEaUjfF6U4QQ2CsZdHO/6ZTTmOLiG1HX
	B
X-Received: by 2002:a1c:1dd2:: with SMTP id d201mr3120173wmd.49.1550590065580;
        Tue, 19 Feb 2019 07:27:45 -0800 (PST)
X-Received: by 2002:a1c:1dd2:: with SMTP id d201mr3120120wmd.49.1550590064415;
        Tue, 19 Feb 2019 07:27:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550590064; cv=none;
        d=google.com; s=arc-20160816;
        b=o6v0O7ZEoUhhFTfI7279AQMLNTVL3jr+mQncq/sVlP5dSczum08RefS/qDKuQV+tDe
         DgM48KWvseSKNZEj4ZueLs6w0qIErtLD6XBgzM4Hmllgutw05KyFvp5UcQIHmrD9yvCR
         2YQMA59RfKZtzBEWoZSukIOtSyAaizLXfxaxQvJUB7drqLbcpsI6TnfDY8hGqqxxJiFF
         KAOlVC/401QgfeiICgYHpSdeXPsjn/B7RzdD/u088pUM8CDZMCNuQUuxAaq4vcdTJfeP
         x+anLrrcm/tSp3AvnHpjtfn6o7GN4wtvo8ySKXkFLItNJ4Ik+QGOKR1bWrqfPizL7I83
         QdaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=2q6fbrSJpEIdLncW4UFN3mJBQ17i3z8yQuQeSIDg2n4=;
        b=twKoz8D4uDWp2EFfy9NyJzmgz1AhEj3VtVZ8+L15xGPbReIyoC6IRh/T/Qrne8xNu7
         Zovc2qW3Q0Risyu24b9Xa8kkpwt1XssYXvSGLZYg+NSJ5hhfuv0YUbdyRqXRQoQBFGms
         VVPISg/NgMQI59rC3ioiJL6Elq85E4oWWAsQV8h9PxAga9hvAbwuAr5A5FWPT93/aFiR
         FrhB4ClJIAFC53ZFZrEGYpdMp9CEQv/MzQ2Ebn+IuA2oJZ0Fs0RmRjEzFEI7c1nik+vT
         aj7y03W8MCfeYZ2Sf+gHEY6xuMoY+Up9EYCpakMoL1EU5iuo/uHf8qsF6l5pHPeYwqNW
         5ZYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Hc7yKF8Q;
       spf=pass (google.com: domain of righi.andrea@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=righi.andrea@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v14sor11084138wri.9.2019.02.19.07.27.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Feb 2019 07:27:44 -0800 (PST)
Received-SPF: pass (google.com: domain of righi.andrea@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Hc7yKF8Q;
       spf=pass (google.com: domain of righi.andrea@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=righi.andrea@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=2q6fbrSJpEIdLncW4UFN3mJBQ17i3z8yQuQeSIDg2n4=;
        b=Hc7yKF8Q0KWei9jPYZqwtPGUg6enGpDzAb3GPtEE+uGJT2GIltg9n8oYO6EmU47dnm
         +wYlQ647qj51UGlYZNKeCAdC/Pk0mmoluTHFpcgfSvyMEmQeUgq4AKiVejeZ6dfnPl4m
         rMc4yjeoJI8TOMezjLRVtcmIiw5XFWC3QpxlfLZ8teQOFbg4AbFQwkGBp+rnIwRF3/on
         D/79xbnlJeVugNzjBBwnaDqvY/giTuukLGhCR5ATHdj0LlJe2WxnNXvk35VkbBIHm6jG
         uWEuO55gt+o6aMnwdIRi0a3mwOkcjPyWJl8raBZDs8rP2AGQwOL0p2GaLPU8i5ndeUIc
         /Sog==
X-Google-Smtp-Source: AHgI3IZFIvl6ReS7nWK/NP1LCBsakFB+dO/D+RYZzjjCia5PB7ivC+IK/A1H93SbBT6YSgC2IHc0YA==
X-Received: by 2002:adf:f786:: with SMTP id q6mr4734864wrp.125.1550590063818;
        Tue, 19 Feb 2019 07:27:43 -0800 (PST)
Received: from xps-13.homenet.telecomitalia.it (host117-125-dynamic.33-79-r.retail.telecomitalia.it. [79.33.125.117])
        by smtp.gmail.com with ESMTPSA id v6sm29029503wrd.88.2019.02.19.07.27.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 07:27:43 -0800 (PST)
From: Andrea Righi <righi.andrea@gmail.com>
To: Josef Bacik <josef@toxicpanda.com>,
	Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>,
	Paolo Valente <paolo.valente@linaro.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Jens Axboe <axboe@kernel.dk>,
	Vivek Goyal <vgoyal@redhat.com>,
	Dennis Zhou <dennis@kernel.org>,
	cgroups@vger.kernel.org,
	linux-block@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 2/3] blkcg: introduce io.sync_isolation
Date: Tue, 19 Feb 2019 16:27:11 +0100
Message-Id: <20190219152712.9855-3-righi.andrea@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190219152712.9855-1-righi.andrea@gmail.com>
References: <20190219152712.9855-1-righi.andrea@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add a flag to the blkcg cgroups to make sync()'ers in a cgroup only be
allowed to write out pages that have been dirtied by the cgroup itself.

This flag is disabled by default (meaning that we are not changing the
previous behavior by default).

When this flag is enabled any cgroup can write out only dirty pages that
belong to the cgroup itself (except for the root cgroup that would still
be able to write out all pages globally).

Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
---
 Documentation/admin-guide/cgroup-v2.rst |  9 ++++++
 block/blk-throttle.c                    | 37 +++++++++++++++++++++++++
 include/linux/blk-cgroup.h              |  7 +++++
 3 files changed, 53 insertions(+)

diff --git a/Documentation/admin-guide/cgroup-v2.rst b/Documentation/admin-guide/cgroup-v2.rst
index 7bf3f129c68b..f98027fc2398 100644
--- a/Documentation/admin-guide/cgroup-v2.rst
+++ b/Documentation/admin-guide/cgroup-v2.rst
@@ -1432,6 +1432,15 @@ IO Interface Files
 	Shows pressure stall information for IO. See
 	Documentation/accounting/psi.txt for details.
 
+  io.sync_isolation
+        A flag (0|1) that determines whether a cgroup is allowed to write out
+        only pages that have been dirtied by the cgroup itself. This option is
+        set to false (0) by default, meaning that any cgroup would try to write
+        out dirty pages globally, even those that have been dirtied by other
+        cgroups.
+
+        Setting this option to true (1) provides a better isolation across
+        cgroups that are doing an intense write I/O activity.
 
 Writeback
 ~~~~~~~~~
diff --git a/block/blk-throttle.c b/block/blk-throttle.c
index da817896cded..4bc3b40a4d93 100644
--- a/block/blk-throttle.c
+++ b/block/blk-throttle.c
@@ -1704,6 +1704,35 @@ static ssize_t tg_set_limit(struct kernfs_open_file *of,
 	return ret ?: nbytes;
 }
 
+#ifdef CONFIG_CGROUP_WRITEBACK
+static int sync_isolation_show(struct seq_file *sf, void *v)
+{
+	struct blkcg *blkcg = css_to_blkcg(seq_css(sf));
+
+	seq_printf(sf, "%d\n", test_bit(BLKCG_SYNC_ISOLATION, &blkcg->flags));
+	return 0;
+}
+
+static ssize_t sync_isolation_write(struct kernfs_open_file *of,
+				    char *buf, size_t nbytes, loff_t off)
+{
+	struct blkcg *blkcg = css_to_blkcg(of_css(of));
+	unsigned long val;
+	int err;
+
+	buf = strstrip(buf);
+	err = kstrtoul(buf, 0, &val);
+	if (err)
+		return err;
+	if (val)
+		set_bit(BLKCG_SYNC_ISOLATION, &blkcg->flags);
+	else
+		clear_bit(BLKCG_SYNC_ISOLATION, &blkcg->flags);
+
+	return nbytes;
+}
+#endif
+
 static struct cftype throtl_files[] = {
 #ifdef CONFIG_BLK_DEV_THROTTLING_LOW
 	{
@@ -1721,6 +1750,14 @@ static struct cftype throtl_files[] = {
 		.write = tg_set_limit,
 		.private = LIMIT_MAX,
 	},
+#ifdef CONFIG_CGROUP_WRITEBACK
+	{
+		.name = "sync_isolation",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.seq_show = sync_isolation_show,
+		.write = sync_isolation_write,
+	},
+#endif
 	{ }	/* terminate */
 };
 
diff --git a/include/linux/blk-cgroup.h b/include/linux/blk-cgroup.h
index 0f7dcb70e922..6ac5aa049334 100644
--- a/include/linux/blk-cgroup.h
+++ b/include/linux/blk-cgroup.h
@@ -44,6 +44,12 @@ enum blkg_rwstat_type {
 
 struct blkcg_gq;
 
+/* blkcg->flags */
+enum {
+	/* sync()'ers allowed to write out pages dirtied by the blkcg */
+	BLKCG_SYNC_ISOLATION,
+};
+
 struct blkcg {
 	struct cgroup_subsys_state	css;
 	spinlock_t			lock;
@@ -55,6 +61,7 @@ struct blkcg {
 	struct blkcg_policy_data	*cpd[BLKCG_MAX_POLS];
 
 	struct list_head		all_blkcgs_node;
+	unsigned long			flags;
 #ifdef CONFIG_CGROUP_WRITEBACK
 	struct list_head		cgwb_wait_node;
 	struct list_head		cgwb_list;
-- 
2.17.1

