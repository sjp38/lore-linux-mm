Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3AE4C74A54
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70DB021019
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:27:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="k3XXPihT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70DB021019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16E108E00D4; Thu, 11 Jul 2019 10:26:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0858B8E00C4; Thu, 11 Jul 2019 10:26:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3D3C8E00D4; Thu, 11 Jul 2019 10:26:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF3BF8E00C4
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:26:52 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id q26so6963234ioi.10
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:26:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=DxKvEFI9OqvnwAFHfsS7VJpKVi8ynRLOZoMuRYswZIw=;
        b=hzS0W9kl8H4W0BIbCihrcL6W7rq1a5XEo9L1trTWuyzjBWRUzF/MLAfkyAx0kz/SmT
         I5cHdFW9FlaIsGqaVl5KxYpohwkJ5iMaTIqdwgX6dv3kRPzqjeGCjxXHF3npRoTLUqXv
         dLIYE5lLvzooad7la6aSwHwjHQ2oRpNPu1MXldGP78cICJWrfiwtudKyotrQAcN6iiiq
         +XuguJF+TjaTwHVFDycwGlKJXjUZyvQQEshFZX8AQe13z2FYleLsbK2KtsLsba75a/0C
         P4C0Ehg6L8X7qhGuSy4DHraj4bShN7RRmGsDRRNfwN39OeVVysx3jFmeLyzP/fyJIfG+
         RGdQ==
X-Gm-Message-State: APjAAAVEMglRZrqgRQp74NFBzeGqqTuNYHLETW6E4xTCKAy7LyXaHomA
	jnXsRC0VcdyYNy9DGxbWiy25H1/KRHfJxg/D3CT4XR5QLYoGD851tW85RL0AlrV2Ly4J6pAXaSD
	8+/4NZtYFolZ+jRMkJrpQWf21ORA+D3X4BTv3BWz5Wc9rS5QGGLlsls5e3JrDAaiU6w==
X-Received: by 2002:a5d:88c6:: with SMTP id i6mr4767228iol.107.1562855212566;
        Thu, 11 Jul 2019 07:26:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDWC9i/2FMckqlkPq+wiimV4/zWTsZppuFE1stiXkUlvZh91qHeDJUP/UM3Fbj89EgWJ2T
X-Received: by 2002:a5d:88c6:: with SMTP id i6mr4767166iol.107.1562855211889;
        Thu, 11 Jul 2019 07:26:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562855211; cv=none;
        d=google.com; s=arc-20160816;
        b=wtLwY0AABEwrBCYgZHGTpcTvnJ1Q2tzh/23EgKq7Q40KoRNTVY3PglZnUrr01F98lX
         G9ulilWzzqE1QoHYwVTjeqeNKuM3Si/zzxYshylmoEU4aXI5CDPnbFTBH5SJs7FwnU25
         sythw8h+GuHt/1pfTH3BE/N1nAEUIgn8HTMdM9LC69p0CujsF4Se7zsMJV/qj0t6R8bH
         R42aGrGWRE2YK40Up0qOLUnO3k3CPMCs/BVgwZAZ5Cjwu/8SoyUiMUvZ6vvbviOrC42D
         GLQEtzEp5ocNsjdCyvMlMVyLwIqYTy9p2Y7l3LhXcz/Wo+6dGGOXIzXHMP1gRsM2Vg7i
         DKuQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=DxKvEFI9OqvnwAFHfsS7VJpKVi8ynRLOZoMuRYswZIw=;
        b=ihmbYtISGMoPXsjd766ivTBPxuWx4CVRkasa0Fby4XZ2TV+8bJy0tpxwggf39ftLCe
         69A9eB9xPtMTXYoS0HlbxfRj6MaQkWYOW49zM0mfGCbWs0MOOLce+ySRSjZDgWymE87M
         zMWvNxL5zHicx8tdcKsHkW71zpXyLzh9OU5eRc3PdwZeZRyG317MeJF6Sq+OS3RuRpk1
         RROd2PCcLlJWxsiJKr3hwKuBbQ9nVCPeakTukFzD1X2lnX53kh3O7nkfLSCCIAVRZe/z
         Wa/0GUC6T+ynS44ITzuIFBh/mI50Vp6+hWGM5EMIi1/UmvzA2YhLxZo0hJXsSL/ka9eX
         QLjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=k3XXPihT;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id n123si9762546iod.129.2019.07.11.07.26.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:26:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=k3XXPihT;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BEO75F013247;
	Thu, 11 Jul 2019 14:26:41 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=DxKvEFI9OqvnwAFHfsS7VJpKVi8ynRLOZoMuRYswZIw=;
 b=k3XXPihT1uvy+OLIiRmWMdfDXIT+WHMFAjj45U6uCpQ8rV2jfdSnRJmMQA1mV5ALTQyT
 PERU4/YPhFf4ckQAGG2rOQDm5vbl52OROkwzviVZDqxaVQLQCpGKejd6n6Gi8g/OW973
 b1WRq4uNsMv9cAwP/H6vRscq1e3iobbZ324Tq6PgoCdWFemJ/1YPJhNIMn+keJv5JOQh
 Ff8q9kmaJ7pYkwC9amWnZvecFXs6OmpibtOtjhm23oXx9IX6dzIXv0YiCsY7b8cavCtn
 S3SvjejyJfLMAMiB7WwpFazOkLIoHuippfiDTsTbnPYepjTPVENPQMOCjagrpefgERlp TA== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2tjm9r0brp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 14:26:41 +0000
Received: from achartre-desktop.fr.oracle.com (dhcp-10-166-106-34.fr.oracle.com [10.166.106.34])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x6BEPcuA021444;
	Thu, 11 Jul 2019 14:26:37 GMT
From: Alexandre Chartre <alexandre.chartre@oracle.com>
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com,
        alexandre.chartre@oracle.com
Subject: [RFC v2 17/26] rcu: Move tree.h static forward declarations to tree.c
Date: Thu, 11 Jul 2019 16:25:29 +0200
Message-Id: <1562855138-19507-18-git-send-email-alexandre.chartre@oracle.com>
X-Mailer: git-send-email 1.7.1
In-Reply-To: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907110162
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

tree.h has static forward declarations for inline function declared
in tree_plugin.h and tree_stall.h. These forward declarations prevent
including tree.h into a file different from tree.c

Signed-off-by: Alexandre Chartre <alexandre.chartre@oracle.com>
---
 kernel/rcu/tree.c |   54 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 kernel/rcu/tree.h |   55 +----------------------------------------------------
 2 files changed, 55 insertions(+), 54 deletions(-)

diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index 980ca3c..44dd3b4 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -55,6 +55,60 @@
 #include "tree.h"
 #include "rcu.h"
 
+/* Forward declarations for tree_plugin.h */
+static void rcu_bootup_announce(void);
+static void rcu_qs(void);
+static int rcu_preempt_blocked_readers_cgp(struct rcu_node *rnp);
+#ifdef CONFIG_HOTPLUG_CPU
+static bool rcu_preempt_has_tasks(struct rcu_node *rnp);
+#endif /* #ifdef CONFIG_HOTPLUG_CPU */
+static int rcu_print_task_exp_stall(struct rcu_node *rnp);
+static void rcu_preempt_check_blocked_tasks(struct rcu_node *rnp);
+static void rcu_flavor_sched_clock_irq(int user);
+static void dump_blkd_tasks(struct rcu_node *rnp, int ncheck);
+static void rcu_initiate_boost(struct rcu_node *rnp, unsigned long flags);
+static void rcu_preempt_boost_start_gp(struct rcu_node *rnp);
+static void invoke_rcu_callbacks_kthread(void);
+static bool rcu_is_callbacks_kthread(void);
+static void __init rcu_spawn_boost_kthreads(void);
+static void rcu_prepare_kthreads(int cpu);
+static void rcu_cleanup_after_idle(void);
+static void rcu_prepare_for_idle(void);
+static bool rcu_preempt_has_tasks(struct rcu_node *rnp);
+static bool rcu_preempt_need_deferred_qs(struct task_struct *t);
+static void rcu_preempt_deferred_qs(struct task_struct *t);
+static void zero_cpu_stall_ticks(struct rcu_data *rdp);
+static bool rcu_nocb_cpu_needs_barrier(int cpu);
+static struct swait_queue_head *rcu_nocb_gp_get(struct rcu_node *rnp);
+static void rcu_nocb_gp_cleanup(struct swait_queue_head *sq);
+static void rcu_init_one_nocb(struct rcu_node *rnp);
+static bool __call_rcu_nocb(struct rcu_data *rdp, struct rcu_head *rhp,
+			    bool lazy, unsigned long flags);
+static bool rcu_nocb_adopt_orphan_cbs(struct rcu_data *my_rdp,
+				      struct rcu_data *rdp,
+				      unsigned long flags);
+static int rcu_nocb_need_deferred_wakeup(struct rcu_data *rdp);
+static void do_nocb_deferred_wakeup(struct rcu_data *rdp);
+static void rcu_boot_init_nocb_percpu_data(struct rcu_data *rdp);
+static void rcu_spawn_cpu_nocb_kthread(int cpu);
+static void __init rcu_spawn_nocb_kthreads(void);
+#ifdef CONFIG_RCU_NOCB_CPU
+static void __init rcu_organize_nocb_kthreads(void);
+#endif /* #ifdef CONFIG_RCU_NOCB_CPU */
+static bool init_nocb_callback_list(struct rcu_data *rdp);
+static unsigned long rcu_get_n_cbs_nocb_cpu(struct rcu_data *rdp);
+static void rcu_bind_gp_kthread(void);
+static bool rcu_nohz_full_cpu(void);
+static void rcu_dynticks_task_enter(void);
+static void rcu_dynticks_task_exit(void);
+
+/* Forward declarations for tree_stall.h */
+static void record_gp_stall_check_time(void);
+static void rcu_iw_handler(struct irq_work *iwp);
+static void check_cpu_stall(struct rcu_data *rdp);
+static void rcu_check_gp_start_stall(struct rcu_node *rnp, struct rcu_data *rdp,
+				     const unsigned long gpssdelay);
+
 #ifdef MODULE_PARAM_PREFIX
 #undef MODULE_PARAM_PREFIX
 #endif
diff --git a/kernel/rcu/tree.h b/kernel/rcu/tree.h
index e253d11..9790b58 100644
--- a/kernel/rcu/tree.h
+++ b/kernel/rcu/tree.h
@@ -392,58 +392,5 @@ struct rcu_state {
 #endif /* #else #ifdef CONFIG_TRACING */
 
 int rcu_dynticks_snap(struct rcu_data *rdp);
-
-/* Forward declarations for tree_plugin.h */
-static void rcu_bootup_announce(void);
-static void rcu_qs(void);
-static int rcu_preempt_blocked_readers_cgp(struct rcu_node *rnp);
-#ifdef CONFIG_HOTPLUG_CPU
-static bool rcu_preempt_has_tasks(struct rcu_node *rnp);
-#endif /* #ifdef CONFIG_HOTPLUG_CPU */
-static int rcu_print_task_exp_stall(struct rcu_node *rnp);
-static void rcu_preempt_check_blocked_tasks(struct rcu_node *rnp);
-static void rcu_flavor_sched_clock_irq(int user);
 void call_rcu(struct rcu_head *head, rcu_callback_t func);
-static void dump_blkd_tasks(struct rcu_node *rnp, int ncheck);
-static void rcu_initiate_boost(struct rcu_node *rnp, unsigned long flags);
-static void rcu_preempt_boost_start_gp(struct rcu_node *rnp);
-static void invoke_rcu_callbacks_kthread(void);
-static bool rcu_is_callbacks_kthread(void);
-static void __init rcu_spawn_boost_kthreads(void);
-static void rcu_prepare_kthreads(int cpu);
-static void rcu_cleanup_after_idle(void);
-static void rcu_prepare_for_idle(void);
-static bool rcu_preempt_has_tasks(struct rcu_node *rnp);
-static bool rcu_preempt_need_deferred_qs(struct task_struct *t);
-static void rcu_preempt_deferred_qs(struct task_struct *t);
-static void zero_cpu_stall_ticks(struct rcu_data *rdp);
-static bool rcu_nocb_cpu_needs_barrier(int cpu);
-static struct swait_queue_head *rcu_nocb_gp_get(struct rcu_node *rnp);
-static void rcu_nocb_gp_cleanup(struct swait_queue_head *sq);
-static void rcu_init_one_nocb(struct rcu_node *rnp);
-static bool __call_rcu_nocb(struct rcu_data *rdp, struct rcu_head *rhp,
-			    bool lazy, unsigned long flags);
-static bool rcu_nocb_adopt_orphan_cbs(struct rcu_data *my_rdp,
-				      struct rcu_data *rdp,
-				      unsigned long flags);
-static int rcu_nocb_need_deferred_wakeup(struct rcu_data *rdp);
-static void do_nocb_deferred_wakeup(struct rcu_data *rdp);
-static void rcu_boot_init_nocb_percpu_data(struct rcu_data *rdp);
-static void rcu_spawn_cpu_nocb_kthread(int cpu);
-static void __init rcu_spawn_nocb_kthreads(void);
-#ifdef CONFIG_RCU_NOCB_CPU
-static void __init rcu_organize_nocb_kthreads(void);
-#endif /* #ifdef CONFIG_RCU_NOCB_CPU */
-static bool init_nocb_callback_list(struct rcu_data *rdp);
-static unsigned long rcu_get_n_cbs_nocb_cpu(struct rcu_data *rdp);
-static void rcu_bind_gp_kthread(void);
-static bool rcu_nohz_full_cpu(void);
-static void rcu_dynticks_task_enter(void);
-static void rcu_dynticks_task_exit(void);
-
-/* Forward declarations for tree_stall.h */
-static void record_gp_stall_check_time(void);
-static void rcu_iw_handler(struct irq_work *iwp);
-static void check_cpu_stall(struct rcu_data *rdp);
-static void rcu_check_gp_start_stall(struct rcu_node *rnp, struct rcu_data *rdp,
-				     const unsigned long gpssdelay);
+
-- 
1.7.1

