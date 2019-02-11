Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45BAFC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 11:38:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0938020838
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 11:38:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0938020838
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DA9E8E00D8; Mon, 11 Feb 2019 06:38:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 887738E00C3; Mon, 11 Feb 2019 06:38:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 776BD8E00D8; Mon, 11 Feb 2019 06:38:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1D9F48E00C3
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 06:38:34 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id p9so1961313wmi.0
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 03:38:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=lObZtTEJDDe8QVAJ0oLiG8K+YMDZ2jmlymn7NJq9+MM=;
        b=YucGIbkpqVUQA1809Z22gSP6XD7ChFWzknad854tvlJumrSki3eUry3FT+0wtBFFSV
         ChyQSzrz6QdZ92ZtDDRjrP7++qY+Ou5ZVb2GZyiHUu6hikQw0CsCmocJUZP4U+JM2Dl4
         AKxM8W/d/auLuxSACimVBEn67VDg2GmOy7vTUIpDCy9juLmdLzxLUBCduq7C9MnlxDix
         U6KciqqN8+ugK/wHFcXV9lr/xCx3hP5WPq7jBHOY3X94IKbrVihpdlXs9Se5a5oYonXZ
         gA5C6PLkuJSDAj4dMNe2CYC+e3a8GIX/0OlySOgl1AtFJ2UU6hTySkTvS2L3x72Byc9E
         LO5A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: AHQUAuZY8KDWcCwmXp0luVg1mYIY5chGbuHrN1hb01odZpBq9PYbFDui
	e3aswMvMlq8a7AwHzdfvCaTNsq8cUJeKA8h4RFeXoum2rq6wh5G3XRGjzYeVzWuOfMU7JAM2xJw
	82nwnxx30K92zGzhOtde5SQLUmdGD9PDXBNMDzVrz9JlKDc0Ecq0dST2WZHEBcPYXXg==
X-Received: by 2002:adf:dfc4:: with SMTP id q4mr5978040wrn.276.1549885113705;
        Mon, 11 Feb 2019 03:38:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbRtIUX0G4NLFIra6AHO8ukP/GCmuiLsaL8DeZhaQgbtBdlZLzGT2kyq/V0Kg+F1Ckxn93M
X-Received: by 2002:adf:dfc4:: with SMTP id q4mr5977970wrn.276.1549885112723;
        Mon, 11 Feb 2019 03:38:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549885112; cv=none;
        d=google.com; s=arc-20160816;
        b=bwGZyMJlM9In5dJZMnV+DZ+j3KdB/fXOiOoK3goOxTm+NrxZu06mkfFtL2pYZt8RXZ
         7azkf1IzXZLVTO8PBqUdWeEMdTXkxRGriGEcS4R04JkkLEiwxelL4m/pFbrqTkMsjI9c
         s+LdGc3H5yWNn2+vUAUbS+8oAgnmeHX369t97lAr+58J5IyeA8WGf1YykJX1FdL6HGZd
         rE2aFYJaFix4mOasuu653QjfJmVMJWcoSWTve1O8xAcP3DUmLQSMz7Gh31RBfCquOoCf
         QjXzruLzQxCn2A7taPTMcyrPd8k+w3ZQiziIuguoFkSQNplMX7vuWxA8aoC94j1oV0/+
         4fAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=lObZtTEJDDe8QVAJ0oLiG8K+YMDZ2jmlymn7NJq9+MM=;
        b=pFxBuTWvMcTkeZP4ZTSeQNgG+cKmw6B4Kh+GVXM7GOqdQgFdtxG2kfk5IrznXLpgAn
         YK+YhoUj1QiIgSuJkVuPeW7MDKTwXi+kg7wUbPRkvUTaCyXpLTvE/b8sT4LVvYS+B01j
         M+yXsvIsc3cpzwJUDsdrOXQcYjiwXUoWg/CTwFSJMsD9atlgpYZW/GZ1PcOFtmnbqgpH
         xP2QCR7d1iEmr+GoTLnCFcHa3DMugeuiTM4PSZxhlPvFjUOcYNE02FXoUGHllrFKmFaD
         0XO9OeOgLNZGHjm+3ap68+jlfKEoSwBGM5OryPHCmNwU8dPbLYeK4sgfohEsHZU3Kj3+
         /x6g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id h19si9210220wme.135.2019.02.11.03.38.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 11 Feb 2019 03:38:32 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from bigeasy by Galois.linutronix.de with local (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1gt9uv-0003KE-St; Mon, 11 Feb 2019 12:38:29 +0100
Date: Mon, 11 Feb 2019 12:38:29 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: [PATCH v2] mm: workingset: replace IRQ-off check with a lockdep
 assert.
Message-ID: <20190211113829.sqf6bdi4c4cdd3rp@linutronix.de>
References: <20190211095724.nmflaigqlcipbxtk@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20190211095724.nmflaigqlcipbxtk@linutronix.de>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Commit

  68d48e6a2df57 ("mm: workingset: add vmstat counter for shadow nodes")

introduced an IRQ-off check to ensure that a lock is held which also
disabled interrupts. This does not work the same way on -RT because none
of the locks, that are held, disable interrupts.
Replace this check with a lockdep assert which ensures that the lock is
held.

Cc: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
v1=E2=80=A6v2: lockdep_is_held() =3D> lockdep_assert_held()

 mm/workingset.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -368,6 +368,8 @@ static struct list_lru shadow_nodes;
=20
 void workingset_update_node(struct xa_node *node)
 {
+	struct address_space *mapping;
+
 	/*
 	 * Track non-empty nodes that contain only shadow entries;
 	 * unlink those that contain pages or are being freed.
@@ -376,7 +378,8 @@ void workingset_update_node(struct xa_no
 	 * already where they should be. The list_empty() test is safe
 	 * as node->private_list is protected by the i_pages lock.
 	 */
-	VM_WARN_ON_ONCE(!irqs_disabled());  /* For __inc_lruvec_page_state */
+	mapping =3D container_of(node->array, struct address_space, i_pages);
+	lockdep_assert_held(&mapping->i_pages.xa_lock);
=20
 	if (node->count && node->count =3D=3D node->nr_values) {
 		if (list_empty(&node->private_list)) {

