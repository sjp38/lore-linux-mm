Return-Path: <SRS0=mZRB=PG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACBE8C43387
	for <linux-mm@archiver.kernel.org>; Sat, 29 Dec 2018 01:31:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67B6A218FE
	for <linux-mm@archiver.kernel.org>; Sat, 29 Dec 2018 01:31:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="oWZw0X59"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67B6A218FE
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE6808E0055; Fri, 28 Dec 2018 20:31:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D43C18E0001; Fri, 28 Dec 2018 20:31:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0C6F8E0055; Fri, 28 Dec 2018 20:31:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 74B3A8E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 20:31:58 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id b8so24685811pfe.10
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 17:31:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=jCn6C/cpRHtM9VQxY+22Xn56ZeUCdkzguW82dVDfWug=;
        b=jnR+KrF0852/jztgQNP9zOaHIiqheMNe5dwJMHTVkQadvagcC1ahBwa9LA4TeaT1jE
         +P/20/dTCxy2eaKPvrojEQqUqfqNYhq7gyLG7MeYFPYJ6QTGzfnW7vzlKKg23/2I+P1g
         +8+oRtcNX1AvBMCaC06RcMMhoQwvUmos9+fGQY9SzWUVa5PLz5mSgWO9HMFDjLcQnCEe
         bCXUR76cWJKB+9sEZ8Bb1mMLswrboEkDNv1EUkA9a9g3cgYJleVrlk5vfbD8n6sXIjos
         OHJohZhvYrGjQ/MTX6nCfjShjK70b7ClHJ3te4rI59tnNRXE0HEZ5rKXFwP24bFykhYD
         KEHA==
X-Gm-Message-State: AA+aEWaKT47+aiBHOvIJRTvK40U4JSXLyvitzckfXv53tnM0Dw/funze
	pLRWxI7AnvZBYdirK4TeB/rxAPFQmkH3z6c5UVinQrH7E3KLn7ukyLT4HbOF4m9PsVQjlg9ZeLq
	cCMvJO0xKT9iU0Wd4gdgI83uZN0zCtdvXoh37MOtmIeCjv6flEPQmT7/JC/bnwKjG6Wg5F2eHfG
	DRDunACEhvBRaAfD93k2p/7E1FzAPktcIrwGxHWXKwlahri5R18iUwcvsCCSODTbZ/jyzxsopxr
	O+0+Uirn5llYbnixUXwoBoBcRbx4gl0aei76UblzLcfzPcUn7BK/wjbp91FdlGkczQE32w1GvtM
	l2TVzFf8+hSM2OpslVRDwdo/5TS89uhzQJ6UwVtf4I8hKGxdBDpJvB7+uRYh+JojH9ftaPvfy71
	y
X-Received: by 2002:a62:c613:: with SMTP id m19mr30387088pfg.207.1546047117956;
        Fri, 28 Dec 2018 17:31:57 -0800 (PST)
X-Received: by 2002:a62:c613:: with SMTP id m19mr30387049pfg.207.1546047117150;
        Fri, 28 Dec 2018 17:31:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546047117; cv=none;
        d=google.com; s=arc-20160816;
        b=k+K6BPkS6l7d+3wQHNGL0otJrIzU921u8ilrWgJM8vD+uB+53yxERfnGDhg13RH/tz
         /Z8Vv/zLearosVqtXH8TRPKmvJ9Oa4Db2tQoPGb49Ka+llEZYXvxDtmLitQQcPkkHkSJ
         vJwbnhdNK09aifUg+0fYiRgJaIKYJhP7LHm95G0R0rdG+Yu3M3jc/Q6wjayncc/rmdeP
         RjKrZHYqbU2O5P6S7EIlru7AXdD/AUY+rTtXBZpyO+gPn/EtiKTCBt6cmn3BoCyuPcvN
         ZEj7SZx1kit8d8T/wbH/vcEBPhh00nHSZgW+XBY/Cc2bAiNIbbCwCq9ImutXc3lUcixl
         N+yA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=jCn6C/cpRHtM9VQxY+22Xn56ZeUCdkzguW82dVDfWug=;
        b=IAuL1fr3/vslgNqEs/UfD85zgwUKld76bYZx3XWD+aQcAH31R3rwL39YES8Z9AbZVT
         Ab4LDX5LjYoYqtUyz6VCBKP3uz1m6HeOoFu5mif9aEZk4QjYmTwCiSgxJuMafbbYQXrs
         gsqcPPVz3Tv5mqR4ggf3KNT0jEh/dop9C9cZKd7NQf/AC2FZJL7IF3kr3R4HXWc2AsuS
         Q8Z9SJHgWyFfrFVbhSC9glnThTWDo3fINX+dTHRaOwXhxKI1KMuoKo/8sCLsojX6ZjeE
         y5LW0tcESpRE+AQvKFRvygpxxZK4PtLgVIbg0Kk2fwXRKX2ldE9AftLR0aKMiFJyFQwY
         sifw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oWZw0X59;
       spf=pass (google.com: domain of 3jm4mxagkcksdslvppwmrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3jM4mXAgKCKsdSLVPPWMRZZRWP.NZXWTYfi-XXVgLNV.ZcR@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id v20sor5331060pgo.22.2018.12.28.17.31.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Dec 2018 17:31:57 -0800 (PST)
Received-SPF: pass (google.com: domain of 3jm4mxagkcksdslvppwmrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=oWZw0X59;
       spf=pass (google.com: domain of 3jm4mxagkcksdslvppwmrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3jM4mXAgKCKsdSLVPPWMRZZRWP.NZXWTYfi-XXVgLNV.ZcR@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=jCn6C/cpRHtM9VQxY+22Xn56ZeUCdkzguW82dVDfWug=;
        b=oWZw0X59mBgdk8cEHTvD73zbKXKCYhLL4ihzdBP1B+abwCrZZrRxPH9mQ77369eLc5
         i/L6QPcKcCEJuOqRkMvL94x9fmmXFhR8ADtmXqh0Fr1LYndK6ZgQZXW9fzzAkLGjqch0
         A0a8iunsmq2eiIPriGrm0mAbYCJID1ctyfiz5hgu/fvv9GHGTHaFcnUMlaF8USWx+sdb
         vYEWgoICKdl6xN4iSB+rEXyZr7VVESWAxSdck3rEdb6/frweUGnaqbMErjJ9w84amCNm
         ct99MgKNuXyHeRipm/rVz7RfdspV+sOod4b5U4J3lhEAnq4iXygvARafU8dFuDP7Fp77
         vabw==
X-Google-Smtp-Source: ALg8bN5AHRIe6jH1ZAHDzOHvD4iJTPGLBhxndrma8kZubs7W9wNjBNoBepBopB0KsdmeyudMuKPsujqEwtslqg==
X-Received: by 2002:a63:3f41:: with SMTP id m62mr13692380pga.8.1546047116752;
 Fri, 28 Dec 2018 17:31:56 -0800 (PST)
Date: Fri, 28 Dec 2018 17:31:47 -0800
Message-Id: <20181229013147.211079-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.20.1.415.g653613c723-goog
Subject: [PATCH] percpu: plumb gfp flag to pcpu_get_pages
From: Shakeel Butt <shakeelb@google.com>
To: Tejun Heo <tj@kernel.org>, Dennis Zhou <dennis@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181229013147.gcGcC-AmuQ0qo15taGsYWMJhkS4jBiQ8S0F68OPAZGQ@z>

__alloc_percpu_gfp() can be called from atomic context, so, make
pcpu_get_pages use the gfp provided to the higher layer.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 mm/percpu-vm.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/percpu-vm.c b/mm/percpu-vm.c
index d8078de912de..4f42c4c5c902 100644
--- a/mm/percpu-vm.c
+++ b/mm/percpu-vm.c
@@ -21,6 +21,7 @@ static struct page *pcpu_chunk_page(struct pcpu_chunk *chunk,
 
 /**
  * pcpu_get_pages - get temp pages array
+ * @gfp: allocation flags passed to the underlying allocator
  *
  * Returns pointer to array of pointers to struct page which can be indexed
  * with pcpu_page_idx().  Note that there is only one array and accesses
@@ -29,7 +30,7 @@ static struct page *pcpu_chunk_page(struct pcpu_chunk *chunk,
  * RETURNS:
  * Pointer to temp pages array on success.
  */
-static struct page **pcpu_get_pages(void)
+static struct page **pcpu_get_pages(gfp_t gfp)
 {
 	static struct page **pages;
 	size_t pages_size = pcpu_nr_units * pcpu_unit_pages * sizeof(pages[0]);
@@ -37,7 +38,7 @@ static struct page **pcpu_get_pages(void)
 	lockdep_assert_held(&pcpu_alloc_mutex);
 
 	if (!pages)
-		pages = pcpu_mem_zalloc(pages_size, GFP_KERNEL);
+		pages = pcpu_mem_zalloc(pages_size, gfp);
 	return pages;
 }
 
@@ -278,7 +279,7 @@ static int pcpu_populate_chunk(struct pcpu_chunk *chunk,
 {
 	struct page **pages;
 
-	pages = pcpu_get_pages();
+	pages = pcpu_get_pages(gfp);
 	if (!pages)
 		return -ENOMEM;
 
@@ -316,7 +317,7 @@ static void pcpu_depopulate_chunk(struct pcpu_chunk *chunk,
 	 * successful population attempt so the temp pages array must
 	 * be available now.
 	 */
-	pages = pcpu_get_pages();
+	pages = pcpu_get_pages(GFP_KERNEL);
 	BUG_ON(!pages);
 
 	/* unmap and free */
-- 
2.20.1.415.g653613c723-goog

