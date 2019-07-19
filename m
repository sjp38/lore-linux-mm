Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31F2FC76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:02:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91E8A21850
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:02:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="nbhu0qyg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91E8A21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49B2B8E0005; Fri, 19 Jul 2019 00:02:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 471BE8E0001; Fri, 19 Jul 2019 00:02:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 339918E0005; Fri, 19 Jul 2019 00:02:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id EF8E08E0001
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:02:10 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x10so17914942pfa.23
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:02:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=63j+qOtSj7B52TrYDueZlOawTDgIg+N3a6voRDB1pkk=;
        b=aezd4e5cLiNNl5yJzDca3tsySv4PV0xBF3ObPoaE9dEpVNcNhxt1JGTrg+3Ggti7sL
         A3d89tPzDxT73xaHuaTP3i26bWAsf5P/4Th3xa90MEs6vHVEnmLYryklRzjEtDf3z3ei
         jGFlbnyz1oqNQopF0+Hkm/Mz9fAl0SCr5xODqijTerQd+7R3rihp68CelSBsxqihN+mz
         nV14JGMXcKUYxQqT1bMaSosWphBHz/plqvWaSEYIsF7MWgA93ysfEYWlvovrhcnob8dQ
         iWu1DWA0mLwljfq6nV+V+dkkv2H97ij1c+lFeru4p79TTI5ZrloUAR9tF2ICiBWEVR+0
         ubsA==
X-Gm-Message-State: APjAAAUefCPY+N2jLzxGBmbLgZc2yf+utuEZc98zOR9DsaffUpb/0ZFO
	Db/aauXp1LjZgRyjsHz0nPTVhpVI468Ni7pjE0jkHVzqzULD3ZLU3HmdH12Koj/w1aQtZpCYHkS
	gYPUM2+IB8ANhETlZO4QAeKTrR1yekmc3aLT6ay78+nQABTnYPi1DBgMvRCMkGAJ/gg==
X-Received: by 2002:a17:902:61:: with SMTP id 88mr51706469pla.50.1563508930645;
        Thu, 18 Jul 2019 21:02:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFRP5uF60NTxOEMNVC22MEB3rMuB/xlgQyu94yNd51DAMUdhY2l8/k9p341Zj6Zahf2ltg
X-Received: by 2002:a17:902:61:: with SMTP id 88mr51706410pla.50.1563508929958;
        Thu, 18 Jul 2019 21:02:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563508929; cv=none;
        d=google.com; s=arc-20160816;
        b=HQtCicEUgLFKOZDbnvPER1aBLlxH5uXJDtsUq3yk08hBa5VGKQQG8C+lx412nrZMpc
         rQbesDAr3gdiIsDy+QPbKiW2Ggd1wEknzW5OqOQLktju+tp/YIQkJJwLc7uSQa1loG2Q
         x0XAAvuI57DlBBcXlDHkEMgrUY6+1PSWoUsRXmfYjd/4ak7jIzxDBhyOh35wyQ35XX+K
         6Aqr8dp25a41R0Jq+Ov4kqtlL7O1MM+PGLFZBxv1EFhfnRKv+Mh9iUcxXcOEIwqnsKuC
         R1lNvD3ixKzR6bQls/SoR1fyoWe9Fapjh7slVjCwzkWmQW33mxueEmuS5ktiUToNGPOF
         IaYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=63j+qOtSj7B52TrYDueZlOawTDgIg+N3a6voRDB1pkk=;
        b=C7vV4mWDthw6Lho5KKjmVMVBKuQ9z0eVK2F/wINrZGaSzwNPvIFQE3wdvRrhk1gM4q
         Al79cHLalnSE9SSoYPAtL7O9jaclQgYNdD2rJR3Y17vE5JwsAPniB02GeA1517ZJLlvU
         pIY2E57k2rv5iEhP9IbO2Ogs0PKnvmiNNJbt/pftqNrYa66PGbR7nnWN1GuzsL18lHd8
         /Qf/IcTpLtj7qTLEvjA+QdCgvEWpN6XKwwK7CaKsvuaUmsPRmmQLLouXb4JsH4S7/L6g
         d8rhien5saJMfeP5MdpvXw6GzZrDtJteGO2sXzf+dSp7RY6lY/jUEnIiZ+Cdqdotu9vF
         bGvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=nbhu0qyg;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p93si120482pjp.66.2019.07.18.21.02.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:02:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=nbhu0qyg;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B3D7121850;
	Fri, 19 Jul 2019 04:02:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563508928;
	bh=HQrvNFEnxnjgzUQx9V4YPtTFsDvuJV/3ioxb0Fb6eWs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=nbhu0qygy3Y8xM+Xjbu3ijacmDU/iyroXXEVprvcHKKrey4Q+i3KeSnFgC5NBzWcy
	 Vf1MltgdjGm4G+YhbCv38twAnTi2n9TIQh+BZlaFkHmPTpvrCX+btfPSoeqx967Qwu
	 jcw+Mi1Vp6CSzpJor+68P2JSH9lTGNXLChnEdKPA=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.2 162/171] mm/mmu_notifier: use hlist_add_head_rcu()
Date: Thu, 18 Jul 2019 23:56:33 -0400
Message-Id: <20190719035643.14300-162-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719035643.14300-1-sashal@kernel.org>
References: <20190719035643.14300-1-sashal@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>

[ Upstream commit 543bdb2d825fe2400d6e951f1786d92139a16931 ]

Make mmu_notifier_register() safer by issuing a memory barrier before
registering a new notifier.  This fixes a theoretical bug on weakly
ordered CPUs.  For example, take this simplified use of notifiers by a
driver:

	my_struct->mn.ops = &my_ops; /* (1) */
	mmu_notifier_register(&my_struct->mn, mm)
		...
		hlist_add_head(&mn->hlist, &mm->mmu_notifiers); /* (2) */
		...

Once mmu_notifier_register() releases the mm locks, another thread can
invalidate a range:

	mmu_notifier_invalidate_range()
		...
		hlist_for_each_entry_rcu(mn, &mm->mmu_notifiers, hlist) {
			if (mn->ops->invalidate_range)

The read side relies on the data dependency between mn and ops to ensure
that the pointer is properly initialized.  But the write side doesn't have
any dependency between (1) and (2), so they could be reordered and the
readers could dereference an invalid mn->ops.  mmu_notifier_register()
does take all the mm locks before adding to the hlist, but those have
acquire semantics which isn't sufficient.

By calling hlist_add_head_rcu() instead of hlist_add_head() we update the
hlist using a store-release, ensuring that readers see prior
initialization of my_struct.  This situation is better illustated by
litmus test MP+onceassign+derefonce.

Link: http://lkml.kernel.org/r/20190502133532.24981-1-jean-philippe.brucker@arm.com
Fixes: cddb8a5c14aa ("mmu-notifiers: core")
Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/mmu_notifier.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 513b9607409d..b5670620aea0 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -274,7 +274,7 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 	 * thanks to mm_take_all_locks().
 	 */
 	spin_lock(&mm->mmu_notifier_mm->lock);
-	hlist_add_head(&mn->hlist, &mm->mmu_notifier_mm->list);
+	hlist_add_head_rcu(&mn->hlist, &mm->mmu_notifier_mm->list);
 	spin_unlock(&mm->mmu_notifier_mm->lock);
 
 	mm_drop_all_locks(mm);
-- 
2.20.1

