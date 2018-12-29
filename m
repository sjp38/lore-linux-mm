Return-Path: <SRS0=mZRB=PG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03F61C43387
	for <linux-mm@archiver.kernel.org>; Sat, 29 Dec 2018 01:56:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1ADA2087F
	for <linux-mm@archiver.kernel.org>; Sat, 29 Dec 2018 01:56:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="mlJ42Wmk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1ADA2087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A72F8E0057; Fri, 28 Dec 2018 20:56:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 457418E0001; Fri, 28 Dec 2018 20:56:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 346548E0057; Fri, 28 Dec 2018 20:56:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id 08EF98E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 20:56:04 -0500 (EST)
Received: by mail-vs1-f69.google.com with SMTP id g79so12800591vsd.6
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 17:56:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=8Befy3R1F0eWwTQ9Ik5Xd4dXNM48kHZxmA2Si2BNh00=;
        b=ZDwjJ6dcCqWBZPp4NpNywtATELqnQ8mIS6aBqadrOmOHUgWvzDjcHcrKCpy8NfrU4M
         Q5pq8cjaExKVpWRy9/QroIWgktHvvCGJeiMwGS2nZgUqgFwTGp9r1FbpIJMi1we+Gb0x
         e5KqlphF3ms8646uA8QhnlCMPMFc1oi1EE5y1fiTkORDPxOSPHL/hLf6isXKbGDLUSBR
         L5PaFbtE5QNQmJPv/I4Zx/1DZn7w83xaJpfPRiIlvLm66WdQ2MmBHi4PVslpHRnbseis
         gSX187Mh9Kp/RfgYGknNX7T8aaHR3Fry5kYoTvKoFxCjCcwnBHBgHUMQAVr3JPokjrJj
         zfnQ==
X-Gm-Message-State: AA+aEWZeWp2U2B5oAki0HoHxfB9TIAaRmop9TaCLNBuVwRq/PflIPcyr
	mfujnOzhyykfiG15s0NHBK4cOn8DpwSOWkt9V4eL+lPz90q/EhBfJ2Rot3A9crmA5CoyjRiZFOE
	1N+zIWisOISVuCed6h4ekyW19109rY+axQRtxxmDj3N0sw96lXLBJYxw1+cDZugKSZJX5sT8NnB
	rcaggNyFzJmc+Ztt2VyMPnMOTTVpJjYy5SZCHe1wGgcArzltEyKqUx4lyhwuQ+0nEDnr+Cxes0U
	bs2kPOAkGaNrJIQavL2Ola8lJE/kIDKIbkVYc/P90M157Cp7ymxWnFQkZeSvTXdWxrqbTqpPEUe
	KfvkazJYlQTEhCWV6szorea+K/0M+7w1D5fqShLCyqp1AO0/g5zhif+LiUqRpFnugZOhHO5Rim7
	m
X-Received: by 2002:a67:848a:: with SMTP id g132mr11982846vsd.222.1546048563557;
        Fri, 28 Dec 2018 17:56:03 -0800 (PST)
X-Received: by 2002:a67:848a:: with SMTP id g132mr11982837vsd.222.1546048562820;
        Fri, 28 Dec 2018 17:56:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546048562; cv=none;
        d=google.com; s=arc-20160816;
        b=KNIGd0u9kOEFS+1zcBr2pDyUIPG6Tbg2RQbTM6+hPdTnzEicIs+F/5hvDC+Iujmfel
         Lcwjgwag6KmQoNOXXJfi/PEsLw4HdpI+uU3M0kmISbtdckpb3tSlDuLsb2S0NmoYVOmP
         N5XPkDuWkVsFEcnBhfVmx1b4VPX/X+yabs3TZzcbM44TIbaSYAR7tHwmlQO9ILnA9N2W
         SIwvtwATlw6HevKtwFmsY9ynTyGVInbMl9BMMl1YkfWvhg8dZfPDltcc3iB9uV/x/YpE
         OqaxT3dnaW66SVAl7FsF8bGoZMuAD95NSDiyj2ItIoNwwldfH7N4Yr3NoDrD1S+eExxH
         dqZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=8Befy3R1F0eWwTQ9Ik5Xd4dXNM48kHZxmA2Si2BNh00=;
        b=trSwQw2TgrgHiWSKaeoXP2/6S+r7nGu1LjFQCL2KA/yWHkepkZTeuHp2YDiU6uehfR
         nr2Z+wnR4KOcOUUMwEzuAQvZ/hItmjLDKCGPNekQ91a0xuHW7mMVli6Fg9oPqr8q6tOo
         fH11sQa5jr7PFS6ZZyE3EA0lgknkl8Di4RRnswMvCrnQmXUwAtaJ6BR/A3NwhkR7C2o4
         wW6THajKdP/C++ZxU3gamzFfb3EfnN5YFCjrjoZPEPMa8CCV5E39/l+bJe6zLDFIxPZ9
         gar/M5p3nvLIhB8sYZXWb+hXy8oOdxnJZu3Ax4dUoJcz2t7ovYy5/s4+8PdRqAqD1PKj
         cliw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mlJ42Wmk;
       spf=pass (google.com: domain of 3mtqmxagkcf0nc5f99g6bjjbg9.7jhgdips-hhfq57f.jmb@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3MtQmXAgKCF0NC5F99G6BJJBG9.7JHGDIPS-HHFQ57F.JMB@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id c13sor25672218vso.80.2018.12.28.17.56.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Dec 2018 17:56:02 -0800 (PST)
Received-SPF: pass (google.com: domain of 3mtqmxagkcf0nc5f99g6bjjbg9.7jhgdips-hhfq57f.jmb@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mlJ42Wmk;
       spf=pass (google.com: domain of 3mtqmxagkcf0nc5f99g6bjjbg9.7jhgdips-hhfq57f.jmb@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3MtQmXAgKCF0NC5F99G6BJJBG9.7JHGDIPS-HHFQ57F.JMB@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=8Befy3R1F0eWwTQ9Ik5Xd4dXNM48kHZxmA2Si2BNh00=;
        b=mlJ42Wmk0g/Zww+wc3HKcPht3SrNzqwN2DG+h/dsO09sj927qHH3eGiBy5Afo0HNo+
         bctv4+9wDrgDHLfhKzOle+rQcSOTFC0RASt9EBC/uogrRZFx/sO0wPjCbVOu6ptOVQA1
         f2V8aAOHMjsUORgJNd2eNlQMHwPFkzur8+Jsa6NWt658Ye45a196pTY9ereEh52XKGpm
         O8uQ02a5qG23Qsspm3RQ9yfkWrCRbXIknMpk7rXJZDffpoUn7ReZGDuBFkJHz33bzVwA
         ihk4ppGr4T4pvA8ZIR3hRYGfRMAhkA8qXYEdyV8hNUUe0H0f0jYRaO1Zil0L63knZ6JP
         a6qg==
X-Google-Smtp-Source: AFSGD/VUJwpoOtcwDGOTLEovtGTpiu3z/uEmvt2SuY6ZhBZkmc3qpn4Xtk6Krlw43FVtamVlIIGJZy76b0CO6A==
X-Received: by 2002:a67:6948:: with SMTP id e69mr25271286vsc.25.1546048562499;
 Fri, 28 Dec 2018 17:56:02 -0800 (PST)
Date: Fri, 28 Dec 2018 17:55:24 -0800
Message-Id: <20181229015524.222741-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.20.1.415.g653613c723-goog
Subject: [PATCH] netfilter: account ebt_table_info to kmemcg
From: Shakeel Butt <shakeelb@google.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>, 
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Roopa Prabhu <roopa@cumulusnetworks.com>, 
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, Michal Hocko <mhocko@suse.com>, 
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, netfilter-devel@vger.kernel.org, 
	coreteam@netfilter.org, bridge@lists.linux-foundation.org, 
	linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>, 
	syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181229015524.U5NpnsBE9h3zgv_sL98m5KhA2p6s_D8ugChk_XSuX_M@z>

The [ip,ip6,arp]_tables use x_tables_info internally and the underlying
memory is already accounted to kmemcg. Do the same for ebtables. The
syzbot, by using setsockopt(EBT_SO_SET_ENTRIES), was able to OOM the
whole system from a restricted memcg, a potential DoS.

Reported-by: syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com
Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
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

