Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8559C282E3
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 21:22:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7806A20815
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 21:22:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kcR3EHVi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7806A20815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BEC9F6B000D; Sun, 26 May 2019 17:22:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9D886B000E; Sun, 26 May 2019 17:22:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A8C9F6B0010; Sun, 26 May 2019 17:22:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 45A9C6B000D
	for <linux-mm@kvack.org>; Sun, 26 May 2019 17:22:24 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id d8so376517lfa.21
        for <linux-mm@kvack.org>; Sun, 26 May 2019 14:22:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=vtj4XT/ZctSQODcPHrULbEup14IpWl4DXPhGkbiblZ8=;
        b=m8c/dBwkBRVvOyIOC4BSz7MijnblltxGVrNrbuYr19CcSbv7NjA9FVU2OhSYDD20xl
         BBwCgy/XTLDVqZ2BZ2azaEqiunD47o3DuIXVROEOfJ1EZjqyjBN1Pta1ygaWvGNO4QOW
         CeR6XtK3jDMbkRJnp49XIZ/HIp3r3ZBpfSm0pRs0xY1zSGCcxWnjZ3By3omLpzlktzhm
         4UV3DJt1PM4t0aljHA9oG+a2XL1TQ868yrHu7gyQKOFo0JI7wyVtZVUccOVvjWFhO6Ac
         t0T1SvEDomKN7PGqMApXTYr/gmnWJe+89V+R3pgM1nS+72n3Wteidag+9i26av/92Bey
         Gh5w==
X-Gm-Message-State: APjAAAWrdEbg0bd2DLqvbm4FEhB1EsNnmcFOcDW10uReAWovPjWtW8X9
	AVYAV8wQKS8aJ+LIRPk7avhDxbPtvsYtV3ltYVhAZ/Q/kolKrbtQL/G51gxCWMB4NhpjY9YZiIt
	C2/8gYGByWqWbAjV6STX8857f5v/wuVuLOUnvsb/XRca+URIm4tSq69gmrJYH8ht8vA==
X-Received: by 2002:ac2:418c:: with SMTP id z12mr26942115lfh.0.1558905743543;
        Sun, 26 May 2019 14:22:23 -0700 (PDT)
X-Received: by 2002:ac2:418c:: with SMTP id z12mr26942097lfh.0.1558905742663;
        Sun, 26 May 2019 14:22:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558905742; cv=none;
        d=google.com; s=arc-20160816;
        b=W9IelyZwmVxDDTOgLsri8LfHAe0aJHTe7XtV3VZns98VGDvWbY82No4qHChNaxFrjc
         2hg3Koq0ymo0krn4BpBq/8+WbzShTeqZckMYKf+alWyEio2ovxBO3xCgim/bgycVD9oP
         dwgwl7NjBcJrJscGXYTktiQe6RAeu/ZmUtlMpLYeiO5uEP9vJqAhgkhEMmDcROQTnKk6
         UYCGSlbc0eQQ+Z79ZLiXtyHPonHBS3G/vNE0QI+/gA4KfvBiCcJX8+6PkrmADuKfRXmR
         DOoDuRP2Q/Y0xpcao32ysDIj+ispfWLN622m4DYWzH8IZY6l+lb3bAcsBmoALDU9U/HI
         vEVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=vtj4XT/ZctSQODcPHrULbEup14IpWl4DXPhGkbiblZ8=;
        b=j7DNbeJkAN5upuPNSvADdxx1QF9sjKP9wmMtOBXMvYjY106g14N+k9UGEDCfrcLX+n
         sOjZlkOMFuF08Toww2GYYs/AeT0CQrngllS8wiYUnDT/EqZg9yHDElZvoP69Y8lq2NYf
         6mqaKdnbCau+uVmBwdd1RbgLCQ6AFrMtffZ0TZFAtXXU2sOjXbhWJ1ZqiY+GtPEC3HIp
         yBcxz0iggHNuQz3fxzzuZ+AbtkG7VsLJbRY8Z0SYlvXryIqprCLXa2fmFTURVEjuesLv
         GmMzsVGrs7+lDAFv6YH/H3Zj0aylQHcEHSTC8xxzrCp8BVYeWmeqjyhHfre93Mdxr1hs
         XMBA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kcR3EHVi;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q23sor4167733ljg.18.2019.05.26.14.22.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 26 May 2019 14:22:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kcR3EHVi;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=vtj4XT/ZctSQODcPHrULbEup14IpWl4DXPhGkbiblZ8=;
        b=kcR3EHViTkCoCb1N2awgeF9OeRkJWwcfKpP07EdHbgyQFo8vKpDK0aRXM3GwhZPsaj
         Z0ntvNWKQGs9mtvVsyfw3I+9a7Jc2eTG4JvkKEsa2afeWbWuiQHpxAhZ4v/H1nY/eK/0
         bRq0tZqa2NrOSVYRjTyw6PdpDSymSqWnk+ZYABf64kbagoHIhSDdtxhjrwfPM+dL9dwA
         pl5BmPtTUEeag4LXamYdkIQkCOknqfDbZQJfQCKPIHkVhpIrBNVtVmOqzYfp1FZ/EkIb
         nR29zqmU2Il2oqY0oTm/4AIf4+o9BVd3tY5nUfIJPT5HawBq8EWTenEaljGBnrKD4sNB
         3Ttg==
X-Google-Smtp-Source: APXvYqzar+sCX4oRkXtYVKukzADiEbq3x2cKytb+az/edc4sgrVA4QR/aBDDj3wxFRa5uyMImh0XsA==
X-Received: by 2002:a2e:90d1:: with SMTP id o17mr45693469ljg.187.1558905742256;
        Sun, 26 May 2019 14:22:22 -0700 (PDT)
Received: from pc636.lan (h5ef52e31.seluork.dyn.perspektivbredband.net. [94.245.46.49])
        by smtp.gmail.com with ESMTPSA id y4sm1885105lje.24.2019.05.26.14.22.21
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 May 2019 14:22:21 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>,
	Uladzislau Rezki <urezki@gmail.com>,
	Hillf Danton <hdanton@sina.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: [PATCH v2 0/4] Some cleanups for the KVA/vmalloc
Date: Sun, 26 May 2019 23:22:09 +0200
Message-Id: <20190526212213.5944-1-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Patch [1] removes an unused argument "node" from the __alloc_vmap_area()
function and that is it.

Patch [2] is not driven by any particular workload that fails or so,
it is just better approach to handle one specific split case.

Patch [3] some cleanups in merging path. Basically on a first step
the mergeable node is detached and there is no reason to "unlink" it.
The same concerns the second step unless it has been merged on first
one.

Patch [4] moves BUG_ON()/RB_EMPTY_NODE() checks under "unlink" logic.
After [3] merging path "unlink" only linked nodes. Therefore we can say
that removing detached object is a bug in all cases.

v1->v2:
    - update the commit message. [2] patch;
    - fix typos in comments. [2] patch;
    - do the "preload" for NUMA awareness. [2] patch;

Uladzislau Rezki (Sony) (4):
  mm/vmap: remove "node" argument
  mm/vmap: preload a CPU with one object for split purpose
  mm/vmap: get rid of one single unlink_va() when merge
  mm/vmap: move BUG_ON() check to the unlink_va()

 mm/vmalloc.c | 116 +++++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 90 insertions(+), 26 deletions(-)

-- 
2.11.0

