Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D405FC3A5A3
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 19:06:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98A5022CEA
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 19:06:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=embeddedor.com header.i=@embeddedor.com header.b="ln7FlWdW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98A5022CEA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=embeddedor.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EE916B0008; Thu, 29 Aug 2019 15:06:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 278F76B000C; Thu, 29 Aug 2019 15:06:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 166516B000D; Thu, 29 Aug 2019 15:06:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0239.hostedemail.com [216.40.44.239])
	by kanga.kvack.org (Postfix) with ESMTP id E440F6B0008
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 15:06:09 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 9773D181AC9B4
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 19:06:09 +0000 (UTC)
X-FDA: 75876395658.16.farm41_52d1b8bbb055c
X-HE-Tag: farm41_52d1b8bbb055c
X-Filterd-Recvd-Size: 4069
Received: from gateway33.websitewelcome.com (gateway33.websitewelcome.com [192.185.145.216])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 19:06:08 +0000 (UTC)
Received: from cm12.websitewelcome.com (cm12.websitewelcome.com [100.42.49.8])
	by gateway33.websitewelcome.com (Postfix) with ESMTP id 4300ED982B
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 14:06:08 -0500 (CDT)
Received: from gator4166.hostgator.com ([108.167.133.22])
	by cmsmtp with SMTP
	id 3PkFiyZPliQer3PkGiHtJo; Thu, 29 Aug 2019 14:06:08 -0500
X-Authority-Reason: nr=8
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=embeddedor.com; s=default; h=Content-Type:MIME-Version:Message-ID:Subject:
	Cc:To:From:Date:Sender:Reply-To:Content-Transfer-Encoding:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:
	List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=3+46xOrI9yy3LuOhJZ5rmqfr4aF7buwsYetlbyfyvSU=; b=ln7FlWdWq1Un9s4oy/dP68rvSQ
	TJnWL2hfqTjoz+3qyEAHw1M9p5TVCgHJRS6FIjDUkVoB5Fp1Xg53bPK6GKtekC+PflgtgtZ776Tdy
	N8sXXKpmhMhZTMKYKA1Vm0WRGA/VnWDby8hTFEhZHMK2Eegh8898DUK5y06xj/frawbEm+v6KrZNd
	8a9tJLkqK9os6hZf24ajT6J0HAP6o5V9WF8LEX39ksicjtpwh6M7MaOSRv98v9qJQC6CE2Mkngo7G
	OZzfg+M8OqxIhqsa6eraB1bLfGSd8UwnPQ3fDm1j03dHFO1C3wKWII3ibEx3uYpgAoPHkqdhrkBxA
	aH2p7BdQ==;
Received: from [189.152.216.116] (port=45156 helo=embeddedor)
	by gator4166.hostgator.com with esmtpa (Exim 4.92)
	(envelope-from <gustavo@embeddedor.com>)
	id 1i3PkE-001rxt-Vo; Thu, 29 Aug 2019 14:06:07 -0500
Date: Thu, 29 Aug 2019 14:06:05 -0500
From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
To: Dennis Zhou <dennis@kernel.org>, Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	"Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: [PATCH] percpu: Use struct_size() helper
Message-ID: <20190829190605.GA17425@embeddedor>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.9.4 (2018-02-28)
X-AntiAbuse: This header was added to track abuse, please include it with any abuse report
X-AntiAbuse: Primary Hostname - gator4166.hostgator.com
X-AntiAbuse: Original Domain - kvack.org
X-AntiAbuse: Originator/Caller UID/GID - [47 12] / [47 12]
X-AntiAbuse: Sender Address Domain - embeddedor.com
X-BWhitelist: no
X-Source-IP: 189.152.216.116
X-Source-L: No
X-Exim-ID: 1i3PkE-001rxt-Vo
X-Source: 
X-Source-Args: 
X-Source-Dir: 
X-Source-Sender: (embeddedor) [189.152.216.116]:45156
X-Source-Auth: gustavo@embeddedor.com
X-Email-Count: 4
X-Source-Cap: Z3V6aWRpbmU7Z3V6aWRpbmU7Z2F0b3I0MTY2Lmhvc3RnYXRvci5jb20=
X-Local-Domain: yes
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

One of the more common cases of allocation size calculations is finding
the size of a structure that has a zero-sized array at the end, along
with memory for some number of elements for that array. For example:

struct pcpu_alloc_info {
	...
        struct pcpu_group_info  groups[];
};

Make use of the struct_size() helper instead of an open-coded version
in order to avoid any potential type mistakes.

So, replace the following form:

sizeof(*ai) + nr_groups * sizeof(ai->groups[0])

with:

struct_size(ai, groups, nr_groups)

This code was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
---
 mm/percpu.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 7e2aa0305c27..7e06a1e58720 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -2125,7 +2125,7 @@ struct pcpu_alloc_info * __init pcpu_alloc_alloc_info(int nr_groups,
 	void *ptr;
 	int unit;
 
-	base_size = ALIGN(sizeof(*ai) + nr_groups * sizeof(ai->groups[0]),
+	base_size = ALIGN(struct_size(ai, groups, nr_groups),
 			  __alignof__(ai->groups[0].cpu_map[0]));
 	ai_size = base_size + nr_units * sizeof(ai->groups[0].cpu_map[0]);
 
-- 
2.23.0


