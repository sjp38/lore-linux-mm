Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE124C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 21:59:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40D1B2192C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 21:59:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="PB+lXIeI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40D1B2192C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A235E8E0002; Fri, 15 Feb 2019 16:59:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D2DC8E0001; Fri, 15 Feb 2019 16:59:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E9948E0002; Fri, 15 Feb 2019 16:59:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 62E5C8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 16:59:46 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id r187so6880171ywb.16
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 13:59:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding:dkim-signature;
        bh=Qu+coBJ2GPpmDNq7bGYcXprtJ7GYulceQg6ivelIbvY=;
        b=X+TXNgC7Z/2WB9nnvVZLq5ihap05SrFDxkXgw6hBNqH6gAXqCcTd1l0Z77+2cwqiKp
         Tv6BA49Pm4YCtX3kZVQKe6/o5T5Cgjxv8ZgSzkTJcS+85W4YLWdcnkBZOQ+FKsen2wZk
         3Vj2UZ3Eonglno0BNVVf9/SbXSa+/1Ecw1jmigWaTvTFNjlrtJdioQnakDEU0FSk3NQ3
         uzkJAHKBFGBBeMcB9gnO1rXL/U6g0bhZq4TbK8cAIdCZ9deF6xUVtsE8vYORCBhPwnjc
         oCj76uzyFgYj00Ck7THRilkt31p4a3kCR3RfGt23bE7i7DsPYxdA/7+lpy2v0aGOx7OB
         tOAg==
X-Gm-Message-State: AHQUAuZDgZIDXKtboKlCTTrd/pNGJ9sEg1yo2EN45YYTfoceJ0aXo6Td
	Fp049spdAoy2VWf8Fwd0VBPJucWbbgaCyXjDC+1DxJU9jwtEUQCME5El7I8hmXE/4+VTs59swRz
	KFI5hiE0ERu/r201aQlhVQF9aT3Weo8Y9zdLc5o43VSenpsCUwIxzx2enGlhK6gBVHA==
X-Received: by 2002:a81:4ccf:: with SMTP id z198mr10128694ywa.457.1550267986095;
        Fri, 15 Feb 2019 13:59:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib0zzU/fqDQnPgNf+lhi5oaGWY5ApBtl3V1Oa6RHkEub4BMWPB5fhqMHijVZUABTPkuiMWo
X-Received: by 2002:a81:4ccf:: with SMTP id z198mr10128659ywa.457.1550267985362;
        Fri, 15 Feb 2019 13:59:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550267985; cv=none;
        d=google.com; s=arc-20160816;
        b=oI5mKUd6eA6XToBXaZJckRg60yM1h504+h8EyOWLuFfcfS5ZcTejqcPYtebjTBMSl/
         2URtiY70vlfs55pIudkjAec9hJ20HAmF7sW4GBO2P2ZaNIlusajMSLfhwSouKHXPbWZt
         uXy7thA+lWoqwoIHBlL8xGVB0nAuKUe0bjuBykoIjAG82CQ+lGZ/IBrCwdJs0KWgEz6l
         6jvxCws9TnnUXu/hvCiHxx4OXbLhSMPmSp/7MmNlNs2WMMX9JDQgaaw9UYzfj5+eDGwR
         Q5VDsx+gRybq5xhdfcKK0Z2kEyYpnwAoHyBNaHkNHCcY/LjVp4PPcoS2eMe8RA0UhrWY
         ASSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:mime-version:message-id
         :date:subject:cc:to:from;
        bh=Qu+coBJ2GPpmDNq7bGYcXprtJ7GYulceQg6ivelIbvY=;
        b=uqpkkHQK2voxfX63pnHX6gSHs0SfA9qOrjRwQuosVGnFZcGb1iviK/1t+cvldKppLg
         teAE3mtSyKFjC1aLZxGLjRSJuFpAdedoW0XvfI27XILQm54jMp97MyXopruE8BzgFsUT
         sNtgZ4dN0nkG+9mG5rM8aNRG19kZT7RxUv+0e8aTmOL3F0w8BLgptpZWYYSHFU8heGZE
         78ohrx6pmGtpo51JJnnXfh3zT4Jrd7r7ehGjjpeDGQL8gBzxmulWlZ+BaV6DLIZ8zYUo
         y4DMalxt6Ynflc3aU946gaCL7YzXMBtw1vL+QEg2z7SQ3wbKD7hg03fty5i/T2kuyRFD
         fs+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=PB+lXIeI;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id n145si3734724yba.166.2019.02.15.13.59.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 13:59:45 -0800 (PST)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=PB+lXIeI;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c6736530000>; Fri, 15 Feb 2019 13:59:47 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 15 Feb 2019 13:59:44 -0800
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 15 Feb 2019 13:59:44 -0800
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Fri, 15 Feb
 2019 21:59:44 +0000
From: <rcampbell@nvidia.com>
To: <linux-mm@kvack.org>
CC: Ralph Campbell <rcampbell@nvidia.com>, Andrew Morton
	<akpm@linux-foundation.org>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?=
	<jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH] mm/hmm: Fix struct hmm memory leak
Date: Fri, 15 Feb 2019 13:59:22 -0800
Message-ID: <20190215215922.29797-1-rcampbell@nvidia.com>
X-Mailer: git-send-email 2.17.2
MIME-Version: 1.0
X-NVConfidentiality: public
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550267987; bh=Qu+coBJ2GPpmDNq7bGYcXprtJ7GYulceQg6ivelIbvY=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:X-NVConfidentiality:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Transfer-Encoding;
	b=PB+lXIeI+8kR1N5br+LHyyqPFmeP35MZ5/OfQx2tARDOF/tIt9rSVSe6lxIpxK/Wn
	 huubc2I3aHbCRE+WEdYZtsGvqEkvVJnWsmbcWh9uJJyNmbNUXpwuLIs6ALdpBpPqvd
	 T5sx8JKT+2IKYfbn/UdqhfE/4nlmBDlWybFfjm9aASKhPuVIDbWX+JWHMVDJ54TUtN
	 tGqHlAdrLw8tctx3Y1Q+2YvHy96cLx49xmTI/g07VyVeuUD+Nn9TcGm4JoxC/z9Hgs
	 4f3zOdUKlKt7UydGEFKd/KFDUxw3uG/UPDi123r59fzM72CKvW8Fs78YFDRWd52InR
	 NWz3oxW0t6mRw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ralph Campbell <rcampbell@nvidia.com>

The patch [1] introduced reference counting on struct hmm and works
fine when calling hmm_mirror_register() and hmm_mirror_unregister().
However, when a process exits without explicitly unregistering,
the MMU notifier callback hmm_release() doesn't release the mirror->hmm
reference and thus leaks the struct hmm allocation.
Fix this by releasing the reference in hmm_release().

[1] https://marc.info/?l=3Dlinux-mm&m=3D154878089214597&w=3D2
    ("mm/hmm: use reference counting for HMM struct")

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 mm/hmm.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/hmm.c b/mm/hmm.c
index 3c9781037918..50523df6ea0c 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -179,6 +179,8 @@ static void hmm_release(struct mmu_notifier *mn, struct=
 mm_struct *mm)
 			mirror->ops->release(mirror);
 			down_write(&hmm->mirrors_sem);
 		}
+		hmm_put(mirror->hmm);
+		mirror->hmm =3D NULL;
 		mirror =3D list_first_entry_or_null(&hmm->mirrors,
 						  struct hmm_mirror, list);
 	}
--=20
2.17.2

