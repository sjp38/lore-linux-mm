Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A6FBC10F00
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 16:30:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5604218AE
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 16:30:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="0WT5rtTI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5604218AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 195678E0006; Thu, 28 Feb 2019 11:30:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16E978E0007; Thu, 28 Feb 2019 11:30:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 034018E0006; Thu, 28 Feb 2019 11:30:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB3D78E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 11:30:48 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id r67so18005300ywd.4
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 08:30:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=q68vDKJoy4wkBVCCNbeXOOo5XkzY9NuLFWEJjvpu9MI=;
        b=seLSNgcvsRMePtZ/SCTYQCqWPuelcN8QoiJUwSDLfC6Z8RUxM7hrY+eweBj2SLeCL6
         TB+rO3Eq1JImBMAtVoLFTXAavRSZYAASHvIel/nBAYgjtqHS6co4O2Qp6/z7RE93NNkv
         2F51XYS2ZfZbxWUw+W5Azf5POjn5hjRm2PVkg2sth5st/BZ8eW1krLrc9lyXqn1xmuVN
         8Nl9JseD9nOe/DHbYaVoGSTDeFXsl533a0kSqkSnbGAH8UtnjxtN+3GhdzdizulkckEd
         NsZhio8C0fEIduQFjK3RpZyU04w1BGqf0VTTVFZxeAXEGtq8g4BMEo2cL0xg80RGKarK
         Ac9A==
X-Gm-Message-State: APjAAAV4GhQMPaV9tJ0bLqhvYh6CWLlksdDJwu0Sm1XuOcFUvLXL+UTt
	oyeBmUMbdXWq7JTAWVD8spWw82I82S0DPiGJgA1iG8bGoDrEVK15VY+2TTMFp5dVJ2b8sl2CG3N
	3YbpfwuAiABhjW/1v+NWlqpELYM2C5D6dqBrPS5wOY8/qIxdvxMrjo7OuVXSfWR9YwDJxqQg8Ut
	tiqOpThS6PJfFbzL+2zCqWnxHnvwPMQ73fhQ+feL9ZApmM69eGR3ZQM6EHrcAFrLXQpUwHXfaPU
	ZQ2RW3bMvSmUFcfC1zFCFB5gj4WrC/eY69kl7fYqtABVO3HPn2HaRmrR9w/xY+kGDe220/NtSBn
	8lH1TP0dlJq4iQoQeo7NK7irWh0oPejqhcTasUt9z9VaLIizkSI/WTAt0PMiYclYfRUKOgoShYd
	0
X-Received: by 2002:a25:42d8:: with SMTP id p207mr183082yba.279.1551371448517;
        Thu, 28 Feb 2019 08:30:48 -0800 (PST)
X-Received: by 2002:a25:42d8:: with SMTP id p207mr183018yba.279.1551371447662;
        Thu, 28 Feb 2019 08:30:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551371447; cv=none;
        d=google.com; s=arc-20160816;
        b=zYtjJYdmbzAyEY93QtMHI2XL7YdfPxUUZReUhAKo90xGGYsomyZ0d09ckjCg6KVFmr
         ZxiK9+vFJcsAj/W99Q4Q3SfxXGUEsw/Q3G9RvIr+jk5sVH1VQvekfJTgssYl/rFJ1vg/
         tXR9wWu/sdbU+lXPInguxq9/n5ODRDdOfVwoZDMnxcd8d0oRIs0D0c82MP5fq1zUu/p0
         pZs8F/pt4hx7QPb1uFce2vB1Z7sGmTlADJ1FWFucuOKg4E6cvbTsnfY2JTQeHkY4hp46
         XycLZScrnWmF8/b1rrPN7TPdxih4xDHL8y2+Eenuqe4bD6RIBvuL3wXqO0C3FA9V2A2E
         +qNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=q68vDKJoy4wkBVCCNbeXOOo5XkzY9NuLFWEJjvpu9MI=;
        b=cgj/l0aa4vq1i4P4mpThDkVfuoOLmzVCyApncutz92GK84MPcB0k+YlW1jQPiZSk/2
         OfqfLhTGMvvVudLaHJPs6hQ/94m8L9/ljD5LirdzuGH5pGl596Tzt0XNK/ygSGAmgULU
         dbaitFZ3xo23mn/mNpO6TiVSpl+U3vVzamYgFnB6qJDXfHbbnYPrBdb/JuYN1yKumzhT
         +wvD+/cQAWMi6VtjR0ojzTF8Tp0fN1Cdw8Q9zlsy+jHwlyl/XExrG9zU2f3V3KIVHW+f
         EQ2XvROVz6V6hUBKQ3+hNDFnrCD3hrkQTekiw8xjyEfjx7iUZ6728i4O7SNVhnbBNqqd
         /y4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=0WT5rtTI;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g18sor3671011ywe.145.2019.02.28.08.30.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 08:30:45 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=0WT5rtTI;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=q68vDKJoy4wkBVCCNbeXOOo5XkzY9NuLFWEJjvpu9MI=;
        b=0WT5rtTI1WKxMYjRHLUdNtdc8IsHgN6ifmKk4VfIC2ys+4BaRMElBPNWBkf1sY9V2U
         DBgNNGgwSI8YyW0YqocogXheOlD1uDjEimiRXYZJFO7GLlIfOGc7HZOuSUQbFN0Wgl1d
         eJLi29oGq6b4efRD83YQPz5IeBD+wxIvU7zwz00xHyxcAQHlzkPJtLGBmEugCfx+CAo/
         t9J/UmkKoI48HsTy46tNW8AazNXmo6bE09T4Z3Do/iURkSM9AcI7iW/B04LO2pfr8aNp
         KuY3Qr8xk08bXRBFWC7Pt7v78/5OFVDijamJDggw/hKAruJeHvrhKmbmi12rUfPQd8zW
         1FFg==
X-Google-Smtp-Source: AHgI3IZ6bGtIf2tq3DoaxA0LIWJUB3eGOgT9AKeaRU8ncx3MetLp/EgLeJPv1RfxuCwzXTOtLICJWw==
X-Received: by 2002:a81:3d48:: with SMTP id k69mr6149601ywa.313.1551371445217;
        Thu, 28 Feb 2019 08:30:45 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::3:da64])
        by smtp.gmail.com with ESMTPSA id 142sm5053954ywl.31.2019.02.28.08.30.44
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Feb 2019 08:30:44 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>,
	Roman Gushchin <guro@fb.com>,
	linux-mm@kvack.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: [PATCH 3/6] mm: memcontrol: replace node summing with memcg_page_state()
Date: Thu, 28 Feb 2019 11:30:17 -0500
Message-Id: <20190228163020.24100-4-hannes@cmpxchg.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190228163020.24100-1-hannes@cmpxchg.org>
References: <20190228163020.24100-1-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Instead of adding up the node counters, use memcg_page_state() to get
the memcg state directly. This is a bit cheaper and more stream-lined.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d85a41cfee60..e702b67cde41 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -746,10 +746,13 @@ static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg,
 			unsigned int lru_mask)
 {
 	unsigned long nr = 0;
-	int nid;
+	enum lru_list lru;
 
-	for_each_node_state(nid, N_MEMORY)
-		nr += mem_cgroup_node_nr_lru_pages(memcg, nid, lru_mask);
+	for_each_lru(lru) {
+		if (!(BIT(lru) & lru_mask))
+			continue;
+		nr += memcg_page_state(memcg, NR_LRU_BASE + lru);
+	}
 	return nr;
 }
 
-- 
2.20.1

