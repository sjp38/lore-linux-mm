Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93281C43444
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 03:14:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31C4A2073F
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 03:14:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="iTqiOAwE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31C4A2073F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E67B8E0057; Wed,  2 Jan 2019 22:14:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7957C8E0002; Wed,  2 Jan 2019 22:14:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6AA9B8E0057; Wed,  2 Jan 2019 22:14:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 41D758E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 22:14:41 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id t18so41051353qtj.3
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 19:14:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=LBYMDCbBA3NW41N7ApDqhkDWIbRHpdiaiS5pDRmTU0c=;
        b=So0sbSjgSP2maw6JUvTdJdDRvLCcYlpjaqupOC5DI+WZzZ4u5VviPku5cxGqHTA79N
         iUlxH3pa8BkAhbkrTQ60Yr2RCVfKH8MnWBbkwg6yipKQ8+HJC527eBjpkFsydMH9TGsQ
         QUxki3Ku1c0h10HizvOvuA3ksCSaOgfi4c+3QZFek6lnwprRTwyf0Fz9+oudbcu1e266
         j+zKa9baVa9dkic9wuPbwjwp9X6gZ9fCV572h7jRb6QdbQlvSPt3O+YyWpwSZdmGB5hA
         mC66vzLXrUm5h/Xa++bBegOXoWe0gCMfvQSxiTv423NwemThz0VdNtwgAQ2X3YXg8/kT
         WjHw==
X-Gm-Message-State: AJcUukcxfRXhLPgOuaBFfXZ1jJjGYAp18C8EP89Vs8w2vvl9An5EbDSi
	FYwac6RuxPqOX9V7FegwmAGM5awMshoN0Fac9cQTG/X5Xk4aH9+Qwl+kMvwJhQ2vQTEGfIXNCgk
	SheMZuN6gxs6QsvkHWzxEecydmxYEBWrwaQqaqAk0zFYLoxVtRr8oOXzgyWKkJcZZnsLNF66O1Q
	Lvb7fkLSmjD/fnPj0pmrL+wggmz09W1ZA8XIvmK7oqU9S4sLDCiK0Lb1we/ao9brFB5us15eQEE
	BFjkXfPKfLtFWrQKBrcCe1moKClCdcM125LQTwGtQNY6eBLaYl5WS74H0tc+y44oKBpNu/rrjM+
	iToR50RwYE9SmkG/Y99DaDA5jyYuacv/1a7WyTdnmmV6qHdzumZL6WLGp/R0cuNr7l1PUk+yjKr
	t
X-Received: by 2002:a37:9841:: with SMTP id a62mr42455966qke.348.1546485280937;
        Wed, 02 Jan 2019 19:14:40 -0800 (PST)
X-Received: by 2002:a37:9841:: with SMTP id a62mr42455941qke.348.1546485280044;
        Wed, 02 Jan 2019 19:14:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546485280; cv=none;
        d=google.com; s=arc-20160816;
        b=r6ACl7Exj/OFyFI6RHxG5LnOcjfdUEnXeSVYPYBGg5+IR4sANp17ljO8JNKHfbeFsf
         VWOtNHa4seauoYUlS4n1sk9sCefFxkk9vYA2CMVl3iHPR9E/0b4AGoq0QrCoRUwyb9/J
         BZkYncLkBZweVab9RdbL45J0HRnLcW+HlHJmg/BaEMD2ysIDvERvMo97iqCAzYKSH6LY
         u2OHpbH/v99Jy6r6bL8BX+za2sAJZxqrIE6Fl6tkCPJqaT3vtdOKkkgjE4oOt65dZeVQ
         EAmhg6Dte63KIiM05ym95POg1GMkjAPY9uDfhNlbLNbL1A3UvbZzUTX8v+S19B/SmP+8
         mGFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=LBYMDCbBA3NW41N7ApDqhkDWIbRHpdiaiS5pDRmTU0c=;
        b=Ta/uNre2fFn0uQ8uJku6aZyPA/L//IXEOdQrrPhqHSJSr/P0Qriybmy7ipLuk69ybO
         q64EQNdqDoqZd2bcL3ykURq0/F1ymgTb4AFfy9G8spcVFqEEFZtYLwhyNPm1G+Dr/UC1
         rSdDQbj8Dm5CobWxFzkhMHF8ooQVrWU/Fn6r3M9jKTcGQCZLJOxznqXlvVsUqFUvEaz1
         ijsiWnQwfwYMoAZSjmBJLa6pSwYcB7hiAKTglgQJFJF01qXKJuEW47Q6TS4oBOook6wT
         P5wdBIpvr4ZJTGVDXfgDWm3mM7iS8wtKz4VT5XRQy+k7emzKjqpKT5OSU6o36TZ+nc73
         mqDg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=iTqiOAwE;
       spf=pass (google.com: domain of 3h34txagkclgqfyiccjzemmejc.amkjglsv-kkityai.mpe@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3H34tXAgKCLgqfYiccjZemmejc.amkjglsv-kkitYai.mpe@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id v5sor47191439qtc.33.2019.01.02.19.14.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 19:14:40 -0800 (PST)
Received-SPF: pass (google.com: domain of 3h34txagkclgqfyiccjzemmejc.amkjglsv-kkityai.mpe@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=iTqiOAwE;
       spf=pass (google.com: domain of 3h34txagkclgqfyiccjzemmejc.amkjglsv-kkityai.mpe@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3H34tXAgKCLgqfYiccjZemmejc.amkjglsv-kkitYai.mpe@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=LBYMDCbBA3NW41N7ApDqhkDWIbRHpdiaiS5pDRmTU0c=;
        b=iTqiOAwEtmzx3502zPCqdPgvcXLNwz4HTbRKYhwJsFyOnPRo/g6n0AILOfliy/qjuL
         3tVx78BpK4nsjlTIuxF54IsHOSC2grti05o7bDgSCF6IsjYm5La1e5Aa/vf4/YLGbQN7
         O9OJsYhIQk2iLMgpyW/GKEOMLdNyOs0lRpjAwNQ1yLwDOtCyRyMk3XMLPjWg6zPu1rdE
         RzlLyI1Vh+bwuVKcEwKMNvQ5XuPQ6t18pzC5zTcH2NEAbR/voOiAIYcB/Kd/VYsMd919
         5I98cCRTXQivucvkT9l7n6EHg8j8iB2+S2Cx3BQOV7xk5ACuqsp9je0gJP0jNNiPWdMc
         X4mA==
X-Google-Smtp-Source: AFSGD/XhD8Zqj94uhrG5IFVMBnwqV8DDYNGWMdHHtQ1uf5iT/YLIKYUBEXhwMnpfIvWyUT6S3kAKUGkH0SeKKQ==
X-Received: by 2002:aed:22cb:: with SMTP id q11mr34452744qtc.31.1546485279505;
 Wed, 02 Jan 2019 19:14:39 -0800 (PST)
Date: Wed,  2 Jan 2019 19:14:31 -0800
Message-Id: <20190103031431.247970-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.20.1.415.g653613c723-goog
Subject: [PATCH v2] netfilter: account ebt_table_info to kmemcg
From: Shakeel Butt <shakeelb@google.com>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Florian Westphal <fw@strlen.de>, Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>, syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com, 
	Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, 
	Roopa Prabhu <roopa@cumulusnetworks.com>, 
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, netfilter-devel@vger.kernel.org, 
	coreteam@netfilter.org, bridge@lists.linux-foundation.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103031431.jCv19dok0XRnV06uAX0M27V-pordMrDIDEmwVdpxwPQ@z>

The [ip,ip6,arp]_tables use x_tables_info internally and the underlying
memory is already accounted to kmemcg. Do the same for ebtables. The
syzbot, by using setsockopt(EBT_SO_SET_ENTRIES), was able to OOM the
whole system from a restricted memcg, a potential DoS.

By accounting the ebt_table_info, the memory used for ebt_table_info can
be contained within the memcg of the allocating process. However the
lifetime of ebt_table_info is independent of the allocating process and
is tied to the network namespace. So, the oom-killer will not be able to
relieve the memory pressure due to ebt_table_info memory. The memory for
ebt_table_info is allocated through vmalloc. Currently vmalloc does not
handle the oom-killed allocating process correctly and one large
allocation can bypass memcg limit enforcement. So, with this patch,
at least the small allocations will be contained. For large allocations,
we need to fix vmalloc.

Reported-by: syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com
Signed-off-by: Shakeel Butt <shakeelb@google.com>
Cc: Florian Westphal <fw@strlen.de>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>
Cc: netfilter-devel@vger.kernel.org
Cc: coreteam@netfilter.org
Cc: bridge@lists.linux-foundation.org
Cc: LKML <linux-kernel@vger.kernel.org>
---
Changelog since v1:
- More descriptive commit message.

 net/bridge/netfilter/ebtables.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 491828713e0b..5e55cef0cec3 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1137,14 +1137,16 @@ static int do_replace(struct net *net, const void __user *user,
 	tmp.name[sizeof(tmp.name) - 1] = 0;
 
 	countersize = COUNTER_OFFSET(tmp.nentries) * nr_cpu_ids;
-	newinfo = vmalloc(sizeof(*newinfo) + countersize);
+	newinfo = __vmalloc(sizeof(*newinfo) + countersize, GFP_KERNEL_ACCOUNT,
+			    PAGE_KERNEL);
 	if (!newinfo)
 		return -ENOMEM;
 
 	if (countersize)
 		memset(newinfo->counters, 0, countersize);
 
-	newinfo->entries = vmalloc(tmp.entries_size);
+	newinfo->entries = __vmalloc(tmp.entries_size, GFP_KERNEL_ACCOUNT,
+				     PAGE_KERNEL);
 	if (!newinfo->entries) {
 		ret = -ENOMEM;
 		goto free_newinfo;
-- 
2.20.1.415.g653613c723-goog

