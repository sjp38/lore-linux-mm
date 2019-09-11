Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27F8BC5ACAE
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 20:26:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2B212085B
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 20:26:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oxT+BZVm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2B212085B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D2DB6B0277; Wed, 11 Sep 2019 16:26:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 782B96B0278; Wed, 11 Sep 2019 16:26:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6981A6B0279; Wed, 11 Sep 2019 16:26:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0148.hostedemail.com [216.40.44.148])
	by kanga.kvack.org (Postfix) with ESMTP id 4842A6B0277
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 16:26:45 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id E1BED181AC9C6
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 20:26:44 +0000 (UTC)
X-FDA: 75923773128.03.debt33_57fa6fd14091e
X-HE-Tag: debt33_57fa6fd14091e
X-Filterd-Recvd-Size: 3322
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 20:26:44 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id h195so14423806pfe.5
        for <linux-mm@kvack.org>; Wed, 11 Sep 2019 13:26:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=/UAVegAIhAQSbSpxp8ObJcBzX5BUzT4wfrwqu1iDBBk=;
        b=oxT+BZVm4Jpx0PjvWILzqeEtF1mbhyvkXEf3lhC2bCY8sRmbVDBWqBU7lOF+CiJD01
         XVmySZONj7sivHkdA43Lt/12LXmiNZ9jYQ/QU3+fW1taqFRn7GprRwN1uoRH936ePocu
         WHGvYzzO1YnlKR29pnFLUrmVAvxDwakA1dxUktqhznHs8J3H3Y6rqfgA/yhyQjeTNhtA
         AWmMCDZ5JK74g1+UFJ/kO3AgwJeB+qqM6xcuNrlNvSipgTvK/KQpv7FxGZ6re/HtaL9t
         bucpnOOAs+aojx8Q2A8JrIq3anfFZIfkEy00QrRNUNqLHP0A/TjjF2bVJfA4o4Kjen3U
         R4qw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=/UAVegAIhAQSbSpxp8ObJcBzX5BUzT4wfrwqu1iDBBk=;
        b=gBpiUyYDHFVtO1+hQ21AQFmcHcldInDl8kgo3JWAEIzfq9tz1jbl38+K3RW+Llro9/
         QA2iaq8ChhkK9uL2W182JnblLADN8/6SJErpNs/dbe9TyeM1a5keLRO4z1yyE6047Oqr
         HPw0lLb3Bfhbu3LPE4iyrDUjYKsgKqeHTvgY5EWQZdkgb9rZ+0c7O2E5WzYqLyhzedhm
         8CmA8yEnHuX8xuTx3c+hGAezPRnpGxCYI5OnYnCXdaSVjJS1CAsJL9G4eFXjDJJrJs1j
         w0Lof1zf1rqw7STo0sN7Jsif6QAwO6K1k8/8V3bKsWlWJ2jnY/l96A6YVWuj8EeYjz7b
         shBQ==
X-Gm-Message-State: APjAAAXVczQMzXfC/76gz3jxwCRnojr7hJFYGLSCykIdI8Tc4fHJooIM
	33JS50lDger5IvWZqodK2Fc=
X-Google-Smtp-Source: APXvYqyOwlwOHp7+hXZnTE3WUluW+R15WCGJp4Eo+ix7mwC6XAvc6HKFCgQoHJqj98v4wfUkNiLpvA==
X-Received: by 2002:a62:d45a:: with SMTP id u26mr42945149pfl.137.1568233603357;
        Wed, 11 Sep 2019 13:26:43 -0700 (PDT)
Received: from localhost.localdomain ([1.39.178.185])
        by smtp.gmail.com with ESMTPSA id e10sm33196577pfh.77.2019.09.11.13.26.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 11 Sep 2019 13:26:42 -0700 (PDT)
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org,
	osalvador@suse.de,
	mhocko@suse.com,
	david@redhat.com,
	pasha.tatashin@soleen.com,
	dan.j.williams@intel.com
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH] mm/memory_hotplug.c: s/is/if
Date: Thu, 12 Sep 2019 02:02:34 +0530
Message-Id: <1568233954-3913-1-git-send-email-jrdr.linux@gmail.com>
X-Mailer: git-send-email 1.9.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Corrected typo in documentation.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 mm/memory_hotplug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index dc0118f..5a404d3 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1795,7 +1795,7 @@ void __remove_memory(int nid, u64 start, u64 size)
 {
 
 	/*
-	 * trigger BUG() is some memory is not offlined prior to calling this
+	 * trigger BUG() if some memory is not offlined prior to calling this
 	 * function
 	 */
 	if (try_remove_memory(nid, start, size))
-- 
1.9.1


