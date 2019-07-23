Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EBD6C7618B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 12:49:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA8F421903
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 12:49:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="SxAiEfbM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA8F421903
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CB916B0007; Tue, 23 Jul 2019 08:49:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 453978E0003; Tue, 23 Jul 2019 08:49:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CE548E0002; Tue, 23 Jul 2019 08:49:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id B70426B0007
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 08:49:35 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id 17so9299139ljc.20
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 05:49:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=zurua77u+0xi6TbhWif5eKYYbACOpA6ckuYdIyXtbcw=;
        b=MlLZAZRYBsGZCmmH7h1WsyMUIlFFL9VcJXbqZHBKrT9+Y+4unZFEoPinUfzZZA+GuQ
         nC6/fSTXXj0anOX7zZIWksZNgCU/wGmeRiBkGpBG71kdf0nplnVluM8Nvp9mYyUJFfDs
         VON+mCy9El+2DOfZJyKHaNBwb0mepNC/IecHymVsreiiIMlmeIMy7ItsH7c5x4rj8kdQ
         c9A7afRca1Pq0fSY6VEyEoXtDr5znizuJ2UEoNZXxObAoSdH6Q9jKFHPGeQMoHIf1UFT
         PMSmE9ECBuwh1LrGVNNt7LzsvHmhLcIKpSpYMCigNqdxRj/2Yv9ZnDIohEdRg+qgXX5G
         FNzw==
X-Gm-Message-State: APjAAAUg9+zRZcTgDKexHPbjNMq3zd+YpDcJQx+xM6Zbv56dvRgvD+Ab
	M7bRogyeB47c4sBGZ0tdUSb4Z0eMXl9vAnJlAEzVudah0vmja7GOlzTkb5cpLVNd/9342g9zx8f
	u38PbcNuK7nkw6Meu8ZNHEmaw8JAlvA71DXaWkAn6hosmqaaCLBORif07tK89Eeql9A==
X-Received: by 2002:a2e:8944:: with SMTP id b4mr15309609ljk.154.1563886175001;
        Tue, 23 Jul 2019 05:49:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx828/Bqgzo0fCO/OHHGt4UIIV1UWstyH/ca5DCvHnlwirUie/J3DJgJvdYMb9BYoewU1oz
X-Received: by 2002:a2e:8944:: with SMTP id b4mr15309563ljk.154.1563886173780;
        Tue, 23 Jul 2019 05:49:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563886173; cv=none;
        d=google.com; s=arc-20160816;
        b=LBORbf7GQTGtdm/4nR2lMpGfSiQknX4ANETb7jBfd1R8pR2zhnpbrCX/1elj8IPVP0
         +wy+T4IdYFMA1BLH825+xlTUAeUdTYqTz3gudq+Ovj/AbzJQC1Xuv/9qwQlrOtuVocPr
         htTDHWRROEikJsGs2hY9DcsaApyJEXQOZTnDyFhsTSWabNrsWD6O7pQKOyxltUywpGCL
         s8ZxWxuBcgYvYxTyAxly4laiaO5Uo4s+XS1vw0YJFipQoIibjq7T6hBGseW7MuszjyUU
         OwSJZtVj+Rh7VEf76+1jRrH++hHTs4lGf8D0fpAsiqUQ8oWpNGlZ4CwLILOZxDshqSyv
         SLlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :to:from:subject:dkim-signature;
        bh=zurua77u+0xi6TbhWif5eKYYbACOpA6ckuYdIyXtbcw=;
        b=o7GmUVc2w/SrP7c3c/U12daFQBB7FWTlIK9g2OBv1vJGgg6KqdNDrK4y3MLItQb1ON
         lh+pCgnC1eq1FAnE3s4fzeIjj3EB4WkYE0sXeomZ8LLBXXCxXOuVdPJtwcYsZzc3iEai
         tQJtlh2v/b4Q2XY3wern2ASGsxawKhh7xLA9uGo6umnLyaKvzdjsrd15bMlMHmKHeZDx
         N0JxvhTaS1tYO0EGObo+g1KdYxVsFnh0XDu1d8bBYQigieI3ISpIEA1DjbBf7qHOu+nD
         H8TAcBkCHPQFqDRhQH7Ztp1dV3AwNEzFJS2Qkse0Vo73Sth9PDK6u+I1DJWJ1HfcI6gV
         K/+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=SxAiEfbM;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1o.mail.yandex.net (forwardcorp1o.mail.yandex.net. [95.108.205.193])
        by mx.google.com with ESMTPS id o194si32322909lfa.67.2019.07.23.05.49.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 05:49:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) client-ip=95.108.205.193;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b=SxAiEfbM;
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 95.108.205.193 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp2j.mail.yandex.net (mxbackcorp2j.mail.yandex.net [IPv6:2a02:6b8:0:1619::119])
	by forwardcorp1o.mail.yandex.net (Yandex) with ESMTP id 1C2922E14BD;
	Tue, 23 Jul 2019 15:49:33 +0300 (MSK)
Received: from smtpcorp1p.mail.yandex.net (smtpcorp1p.mail.yandex.net [2a02:6b8:0:1472:2741:0:8b6:10])
	by mxbackcorp2j.mail.yandex.net (nwsmtp/Yandex) with ESMTP id fmQPnrek3M-nWNePTP1;
	Tue, 23 Jul 2019 15:49:33 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1563886173; bh=zurua77u+0xi6TbhWif5eKYYbACOpA6ckuYdIyXtbcw=;
	h=Message-ID:Date:To:From:Subject;
	b=SxAiEfbMTe6g9rgjKAYpYyEw55A0/Cpf/8g/VkVC2mITNAE9pvdqSLU2VYWVp8Lkl
	 0Pbz4BSHklhJhaDSvJbL/2kwJxymf9bSMWsd/Qj9XGAs1qI+mLpTe+FsKgU2gWpDM7
	 PWIgws5dlKgyWtMCh/8WPswvwbcAOiLtGgIAc8wg=
Authentication-Results: mxbackcorp2j.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:38b3:1cdf:ad1a:1fe1])
	by smtpcorp1p.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id TrvRdaTa6V-nW6KTqe5;
	Tue, 23 Jul 2019 15:49:32 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH] mm/backing-dev: show state of all bdi_writeback in debugfs
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 23 Jul 2019 15:49:32 +0300
Message-ID: <156388617236.3608.2194886130557491278.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently /sys/kernel/debug/bdi/$maj:$min/stats shows only root bdi wb.
With CONFIG_CGROUP_WRITEBACK=y there is one for each memory cgroup.

This patch shows here state of each bdi_writeback in form:

<global state>

Id: 1
Cgroup: /
<root wb state>

Id: xxx
Cgroup: /path
<cgroup wb state>

Id: yyy
Cgroup: /path2
<cgroup wb state>

...

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 mm/backing-dev.c |  106 +++++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 93 insertions(+), 13 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index e8e89158adec..3e752c4bafaf 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -45,7 +45,7 @@ static void bdi_debug_init(void)
 static int bdi_debug_stats_show(struct seq_file *m, void *v)
 {
 	struct backing_dev_info *bdi = m->private;
-	struct bdi_writeback *wb = &bdi->wb;
+	struct bdi_writeback *wb = v;
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 	unsigned long wb_thresh;
@@ -65,43 +65,123 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 			nr_dirty_time++;
 	spin_unlock(&wb->list_lock);
 
-	global_dirty_limits(&background_thresh, &dirty_thresh);
-	wb_thresh = wb_calc_thresh(wb, dirty_thresh);
-
 #define K(x) ((x) << (PAGE_SHIFT - 10))
+
+	/* global state */
+	if (wb == &bdi->wb) {
+		global_dirty_limits(&background_thresh, &dirty_thresh);
+		wb_thresh = wb_calc_thresh(wb, dirty_thresh);
+		seq_printf(m,
+			   "BdiDirtyThresh:     %10lu kB\n"
+			   "DirtyThresh:        %10lu kB\n"
+			   "BackgroundThresh:   %10lu kB\n"
+			   "bdi_list:           %10u\n",
+			   K(wb_thresh),
+			   K(dirty_thresh),
+			   K(background_thresh),
+			   !list_empty(&bdi->bdi_list));
+	}
+
+	/* cgroup header */
+#ifdef CONFIG_CGROUP_WRITEBACK
+	if (bdi->capabilities & BDI_CAP_CGROUP_WRITEBACK) {
+		size_t buflen, len;
+		char *buf;
+
+		seq_printf(m, "\nId: %d\nCgroup: ", wb->memcg_css->id);
+		buflen = seq_get_buf(m, &buf);
+		if (buf) {
+			len = cgroup_path(wb->memcg_css->cgroup, buf, buflen);
+			seq_commit(m, len <= buflen ? len : -1);
+			seq_putc(m, '\n');
+		}
+	}
+#endif /* CONFIG_CGROUP_WRITEBACK */
+
 	seq_printf(m,
 		   "BdiWriteback:       %10lu kB\n"
 		   "BdiReclaimable:     %10lu kB\n"
-		   "BdiDirtyThresh:     %10lu kB\n"
-		   "DirtyThresh:        %10lu kB\n"
-		   "BackgroundThresh:   %10lu kB\n"
 		   "BdiDirtied:         %10lu kB\n"
 		   "BdiWritten:         %10lu kB\n"
 		   "BdiWriteBandwidth:  %10lu kBps\n"
+		   "BdiAvgWriteBwidth:  %10lu kBps\n"
 		   "b_dirty:            %10lu\n"
 		   "b_io:               %10lu\n"
 		   "b_more_io:          %10lu\n"
 		   "b_dirty_time:       %10lu\n"
-		   "bdi_list:           %10u\n"
 		   "state:              %10lx\n",
 		   (unsigned long) K(wb_stat(wb, WB_WRITEBACK)),
 		   (unsigned long) K(wb_stat(wb, WB_RECLAIMABLE)),
-		   K(wb_thresh),
-		   K(dirty_thresh),
-		   K(background_thresh),
 		   (unsigned long) K(wb_stat(wb, WB_DIRTIED)),
 		   (unsigned long) K(wb_stat(wb, WB_WRITTEN)),
 		   (unsigned long) K(wb->write_bandwidth),
+		   (unsigned long) K(wb->avg_write_bandwidth),
 		   nr_dirty,
 		   nr_io,
 		   nr_more_io,
 		   nr_dirty_time,
-		   !list_empty(&bdi->bdi_list), bdi->wb.state);
+		   wb->state);
 #undef K
 
 	return 0;
 }
-DEFINE_SHOW_ATTRIBUTE(bdi_debug_stats);
+
+static void *bdi_debug_stats_start(struct seq_file *m, loff_t *ppos)
+{
+	struct backing_dev_info *bdi = m->private;
+	struct bdi_writeback *wb;
+	loff_t pos = *ppos;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(wb, &bdi->wb_list, bdi_node)
+		if (pos-- == 0)
+			return wb;
+	return NULL;
+}
+
+static void *bdi_debug_stats_next(struct seq_file *m, void *v, loff_t *ppos)
+{
+	struct backing_dev_info *bdi = m->private;
+	struct bdi_writeback *wb = v;
+
+	list_for_each_entry_continue_rcu(wb, &bdi->wb_list, bdi_node) {
+		++*ppos;
+		return wb;
+	}
+	return NULL;
+}
+
+static void bdi_debug_stats_stop(struct seq_file *m, void *v)
+{
+	rcu_read_unlock();
+}
+
+static const struct seq_operations bdi_debug_stats_seq_ops = {
+	.start	= bdi_debug_stats_start,
+	.next	= bdi_debug_stats_next,
+	.stop	= bdi_debug_stats_stop,
+	.show	= bdi_debug_stats_show,
+};
+
+static int bdi_debug_stats_open(struct inode *inode, struct file *file)
+{
+	struct seq_file *m;
+	int ret;
+
+	ret = seq_open(file, &bdi_debug_stats_seq_ops);
+	if (!ret) {
+		m = file->private_data;
+		m->private = inode->i_private;
+	}
+	return ret;
+}
+
+static const struct file_operations bdi_debug_stats_fops = {
+	.open		= bdi_debug_stats_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
 
 static void bdi_debug_register(struct backing_dev_info *bdi, const char *name)
 {

