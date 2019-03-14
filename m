Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 260C7C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 21:48:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC1802186A
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 21:48:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="P8+mCjAr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC1802186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0EF7C6B0003; Thu, 14 Mar 2019 17:48:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09E9F6B0005; Thu, 14 Mar 2019 17:48:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA9506B0006; Thu, 14 Mar 2019 17:48:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id C21296B0003
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 17:48:57 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id 35so6724095qty.12
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 14:48:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=DOKQl77tlcKdRXwv3KLrLHAh/2xmuI5xRqwzoMDlSx4=;
        b=pqT525Re1xQALzj3AZ+QsNdWbifnKEwVjXfhNivAjy21NJAzyxOSWFRNrC1vS/x9vQ
         RlDTRjNCcl/xKFIPibOVdz8o4f/MUa0qO2k5AOecBZAZ3gqTRovlR1RSwwi35M4Ok2VS
         dkHHy33RN+/ZLsbYx/xXGv39HWnUdZq8kOvGNhWrkyy+5kpyCuH61S0z8v4w7eKnjN9R
         mg1bemfckcSdZuRsHGhorBZEZVzUQizSXp9dZ15gnD+FYZYg4N3huhcmAeVtGqSyGseL
         YL53oE2ypmKWn+609czlmnDZ324mxmc1wzoQNNlhNyhQoFC3MbwPJiI4GquAkfGrA8i2
         WP3w==
X-Gm-Message-State: APjAAAWT6IeQ7CxeP3qfoTSZk72RRD1Fe3gReobd9RNPsTrn4TQqXL6v
	i1hTsKxbALp5fD3g8kFLeOW0GmlMRMIDdENiYsgrUdi2pvwOwJc3sMGcTb/jnnvmwO/3j911gwW
	fKNueEB9tfDOiOUoL/evZ762KPCX140NYsBsyV89cf54OX+70YkqJUBgYnvmsIm3Cow==
X-Received: by 2002:ac8:a81:: with SMTP id d1mr241325qti.213.1552600137451;
        Thu, 14 Mar 2019 14:48:57 -0700 (PDT)
X-Received: by 2002:ac8:a81:: with SMTP id d1mr241288qti.213.1552600136767;
        Thu, 14 Mar 2019 14:48:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552600136; cv=none;
        d=google.com; s=arc-20160816;
        b=xWmkT2SHTL+mrXep1bhj5Uq7+LrEGtdl3EreoOodcrrbpQlA9fNbH7HyboCMyijuZU
         YRS4WD/Xuf4a01zCbWlEOvMtiDqRiwgDS7SafHbKeAKqnVpD2LJ+AZiSyNaW1XjM0qkd
         j5DY0ygVf4AdPvw2OgsLjH2Yx9F6mH0JTsQ/f38L/NmxKPFAqv3dCs0e+wnJiY1Ng7M5
         uWqplPvKOan0kN/cBnHrR38n1IHW9Cyy3zd83S2jI6ZjN6/hzZE0sVkHHz9AaUCCr7MD
         aH+tUDDODrmwutQbUrcI0I3kw0ucOjtFWuuJ4ht4iA+LbaHLbeIohowhGRsovGEent5H
         Qm0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=DOKQl77tlcKdRXwv3KLrLHAh/2xmuI5xRqwzoMDlSx4=;
        b=aKkvMwUCMyhP+CLwhmjGmoX1D2y7eeoOWpSNJCVlUPo+J93y8Qylmf9tPhZOFFruhW
         GB5jQvvqjrurugoNLFhqkq6WFWcIomOi0QYXcGnvdgYAK6dfYKhig96BmgTERE39mFY2
         X8R1EJYSFLa8CJ7uD5YLweH2g0+UX0RZ1c72mVwSBFfGWlR47jqtjqNqMzprhi1ye9ou
         Fl0tAVeAWypm1VJopvPbFeTjbD0AR9PdIG0oL//079wyZm7PRx0ZRd+Zv8MkFdutHldd
         nOTbfIgrvJAzedk0sf5R2Gm9ZJvYjcM2gJ75W+zRoe9yzkjkO4VBdS4FrpMkprncZElA
         XsLg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=P8+mCjAr;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m188sor130490qkc.80.2019.03.14.14.48.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Mar 2019 14:48:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=P8+mCjAr;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=DOKQl77tlcKdRXwv3KLrLHAh/2xmuI5xRqwzoMDlSx4=;
        b=P8+mCjAr7lnNQFdtsmGnIznAasCG0PZk/LqTaPIFq+05uZ+6It+Fc6FDUHyFSZS1Re
         K0yhwj5maXrCUXYZztGC3lNcRo5TcU6qhPv/FrMsCnLGbuVVKNYuE28NJBvL1R+pyu4X
         uTvHXqrdoFttcV5sLbO77rUiuU2MMH6lT5U1k=
X-Google-Smtp-Source: APXvYqwCxiff+zhOEF5mlXUotlJ7UvJaZgJwyYErpWAp0blmeFVnsQrKonmidZ3DVpwI0ETdoCK0lw==
X-Received: by 2002:a37:83c6:: with SMTP id f189mr397438qkd.196.1552600136409;
        Thu, 14 Mar 2019 14:48:56 -0700 (PDT)
Received: from joelaf.cam.corp.google.com ([2620:0:1004:1100:cca9:fccc:8667:9bdc])
        by smtp.gmail.com with ESMTPSA id o19sm96827qkl.65.2019.03.14.14.48.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 14:48:55 -0700 (PDT)
From: "Joel Fernandes (Google)" <joel@joelfernandes.org>
To: linux-kernel@vger.kernel.org,
	mtk.manpages@gmail.com
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andy Lutomirski <luto@kernel.org>,
	dancol@google.com,
	Jann Horn <jannh@google.com>,
	John Stultz <john.stultz@linaro.org>,
	kernel-team@android.com,
	linux-api@vger.kernel.org,
	linux-man@vger.kernel.org,
	linux-mm@kvack.org,
	Matthew Wilcox <willy@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Shuah Khan <shuah@kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH -manpage 0/2] 
Date: Thu, 14 Mar 2019 17:48:42 -0400
Message-Id: <20190314214844.207430-1-joel@joelfernandes.org>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This documentation is for F_SEAL_FUTURE_WRITE patches that are in linux-next.

Joel Fernandes (Google) (2):
fcntl.2: Update manpage with new memfd F_SEAL_FUTURE_WRITE seal
memfd_create.2: Update manpage with new memfd F_SEAL_FUTURE_WRITE seal

man2/fcntl.2        | 15 +++++++++++++++
man2/memfd_create.2 | 15 ++++++++++++++-
2 files changed, 29 insertions(+), 1 deletion(-)

--
2.21.0.360.g471c308f928-goog

