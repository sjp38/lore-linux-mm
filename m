Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE4B1C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 18:09:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B4D52087C
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 18:09:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B4D52087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=canonical.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD7608E0005; Thu,  7 Mar 2019 13:09:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A367C8E0002; Thu,  7 Mar 2019 13:09:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9293D8E0005; Thu,  7 Mar 2019 13:09:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3CD0A8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 13:09:33 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id v8so8876064wrt.18
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 10:09:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=msHBAipTtijk0UwIEQstQw/a0b7WTAeEuEqzcOHunh8=;
        b=Kxjqw0x+s9fyausJ20eepqxDppqAn8LTeV5jU5SWhC3pithfYYEJ5HEGt0bDYGK4eR
         avjDjwDPJTRen0rMEJpPte/5okwhQ+3aFKrVjm7J5QRfcceN1OGJBhO77kRi85a8pyW9
         WMzQ75opzIUWQXryyhoHCEjL17HqjxO2YX6gYJXZxQXWBjW4QOuVuNyz+smVY5LtR5z+
         Gckrj8MvDo6N8HaVK8KEQhMS20MgnpbBe+VWvWOREIt1Eg86vcjq+HEHEcUq4MTYAXo1
         Ui2qn47J0x28ePh1/RRLbL/gLKM7PDYc4LJTJ2bjVvR2vNuAd0xrQRmYbp/XrYKMAhQo
         hKnQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
X-Gm-Message-State: APjAAAUw8ZvZm1lRzOJ2JyH9zIIsQVAx2GwU9k6lDXwUqy+y6KpRLKgY
	iiqXZixTRWbl3OxLmsxMBdnZtZVKD25eI9w2Viu8Xt4dksADQwzvJsT/PfMPzXZN+EqvP3KfX4Y
	AowuLzS3sOjGqvI5ZLHSoIeejfQaPVgV/ICv1jKmaM+7W94qo9e9k3lxsgtBvR7EEPUZMEnGO0x
	4FO+avKNrQ3MUzy/TcW57Dav38/2j8raWhw86WVBynnc3z4UMElscE591BBagoaYfeZI3JA/wZW
	wxaFCSnx2r4nggkB/7y29mZEtxd0W81aQZGWX1oIfzltBu/RwHAwu6fLxOalLVfURkFFXrYlJEJ
	8kdTgcvlSRr6XqhLIIxOlu4yXyd6XPNPIBjVCBmC4miNPSyeeB1oCTbtx+sOOaC6ghxTxcz7CLx
	PtnE3yvVZI6u97N9qjMRRjTDRKIeDTWnr4Sf8VfpIS37dDACaQ4FeNLHlUDdmQBIz5V/LTdgHYz
	FyVfWK8jIeOVCxcVBJSbcg2USIJPQjy4Lem2OWON9AJr/smqxnFPsjSORtOEKrDR5igNP00Ybvx
	7EfctHbWKvC+10V7X8YV5hA9p+g4r+RF+H0yzDw3tyC+vNdIdqZC9apYO8R511zdmpVC3Ouj8TI
	Dtfo210Uu51v
X-Received: by 2002:a5d:6b43:: with SMTP id x3mr8465803wrw.76.1551982172478;
        Thu, 07 Mar 2019 10:09:32 -0800 (PST)
X-Google-Smtp-Source: APXvYqzwxHtl/vZzrf1s7w7EQFN0OBHzIJJq/LJCY1BlKDWNLFBk58yNm/JZ79CSWqLqaAg1JkwJ
X-Received: by 2002:a5d:6b43:: with SMTP id x3mr8465699wrw.76.1551982170743;
        Thu, 07 Mar 2019 10:09:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551982170; cv=none;
        d=google.com; s=arc-20160816;
        b=zBj+wcN1YM8NO/rWGQ4GHuZXQSfGaziVoELXNCGo1bcfK3xk1lpEzH7tnmCd10oExU
         ipw+VoG3fGWj644Ar7CxqENRRYrMYKgb91zF6+BoE/eCaU4oCVfEbRZd9JvqBvmm/a6B
         GXElZv8qTgSpJXc2aM7z1NaMsWGr3ESu7BPeHfBrWaIRMfXa1VQpHi1YL5uUz6SeXBWs
         suxlw7jGGYvLpsFKnWP+YC144JmKxM8Y26EkeIFTAcOphHEJf2G7RINlxK3fuWyqgLdS
         mCc7yvaq5/QAyx92Z/HPGpWLgXL/xuekzZRAsybzeeArAs9VQxMS3Zc10FQ6MwUwKsXP
         /ppw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=msHBAipTtijk0UwIEQstQw/a0b7WTAeEuEqzcOHunh8=;
        b=LBv8nIhfyCdJMRgSzM/3NeS223PDS1ZKs1PY78YlTwJBoDpJ8GKRq0YnC2JN2ib0xm
         68XsbAJxb384rlzqGTMhL2y9+HVSA89NN1fzWEoXtfZPxn/D3k5oxItrzYSgmwBufhwb
         zkC/Biymqc6AMycD2rx7O/kyKlzac4wNO/S2tdypueUWuxSKpjPfXbbJhY54LSLKOuYs
         EQbh7BfohMy444hG5V5IehMBUZP9NXOqsOuOiMmk89lu+XU3Ol4ePrdFGF0bmEF9Nm7p
         gZRRmZtuxijUEgEVQNBd8n0lce6FxumXa6tKRAmeLfh+xv8fcaWVQGyxJv9bHM+wBXw4
         JjRg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id x17si3536037wrd.370.2019.03.07.10.09.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Mar 2019 10:09:30 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) client-ip=91.189.89.112;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from mail-wr1-f72.google.com ([209.85.221.72])
	by youngberry.canonical.com with esmtps (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.76)
	(envelope-from <andrea.righi@canonical.com>)
	id 1h1xST-0001kr-Ro
	for linux-mm@kvack.org; Thu, 07 Mar 2019 18:09:29 +0000
Received: by mail-wr1-f72.google.com with SMTP id f5so8963090wrt.13
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 10:09:29 -0800 (PST)
X-Received: by 2002:a1c:48f:: with SMTP id 137mr6282793wme.21.1551982169505;
        Thu, 07 Mar 2019 10:09:29 -0800 (PST)
X-Received: by 2002:a1c:48f:: with SMTP id 137mr6282785wme.21.1551982169309;
        Thu, 07 Mar 2019 10:09:29 -0800 (PST)
Received: from localhost.localdomain (host22-124-dynamic.46-79-r.retail.telecomitalia.it. [79.46.124.22])
        by smtp.gmail.com with ESMTPSA id a74sm7872747wma.22.2019.03.07.10.09.28
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 10:09:28 -0800 (PST)
From: Andrea Righi <andrea.righi@canonical.com>
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
Subject: [PATCH v2 2/3] blkcg: introduce io.sync_isolation
Date: Thu,  7 Mar 2019 19:08:33 +0100
Message-Id: <20190307180834.22008-3-andrea.righi@canonical.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190307180834.22008-1-andrea.righi@canonical.com>
References: <20190307180834.22008-1-andrea.righi@canonical.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
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

Signed-off-by: Andrea Righi <andrea.righi@canonical.com>
---
 Documentation/admin-guide/cgroup-v2.rst |  9 ++++++
 block/blk-throttle.c                    | 37 +++++++++++++++++++++++++
 include/linux/blk-cgroup.h              |  7 +++++
 3 files changed, 53 insertions(+)

diff --git a/Documentation/admin-guide/cgroup-v2.rst b/Documentation/admin-guide/cgroup-v2.rst
index 53d3288c328b..17fff0ee97b8 100644
--- a/Documentation/admin-guide/cgroup-v2.rst
+++ b/Documentation/admin-guide/cgroup-v2.rst
@@ -1448,6 +1448,15 @@ IO Interface Files
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
2.19.1

