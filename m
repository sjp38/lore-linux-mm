Return-Path: <SRS0=q2Op=WO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.3 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58DD9C3A589
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 19:39:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E80152146E
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 19:39:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IRlwWeQZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E80152146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 573856B0007; Sun, 18 Aug 2019 15:39:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5243A6B000A; Sun, 18 Aug 2019 15:39:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 439E76B000C; Sun, 18 Aug 2019 15:39:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0175.hostedemail.com [216.40.44.175])
	by kanga.kvack.org (Postfix) with ESMTP id 22C3A6B0007
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 15:39:23 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id CA7188248AA6
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 19:39:22 +0000 (UTC)
X-FDA: 75836562564.26.arm60_179fa97c2f127
X-HE-Tag: arm60_179fa97c2f127
X-Filterd-Recvd-Size: 3528
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 19:39:22 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id w16so5844655pfn.7
        for <linux-mm@kvack.org>; Sun, 18 Aug 2019 12:39:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=naezKv10aMe93QkJaQYNNufXPVHrNlb0/A4rCenoqCY=;
        b=IRlwWeQZYx9iGcGsEkQNdgLkIic9P0NR58Vs1G79Xcxg95OVHQNMlZ5yamVnFmGRM7
         spQ8NfmUADs9Nx5u5HMATTQBGi0a6KHjLToJODiK6RqMQY/rDKwhqtuGCrL6qZ7IVbvz
         RzMKA9ie4ZgbOEbQv1HCxCYStLcznKY/NJpgbSr261j27qSP0UxOw8/qrIq2F7Cz4LWm
         A5A1+joPDr3MQbP0gAL2BMz9ShBaqCSnni9B24wwGaWHasFDnA60tM6FQQxLBke75tko
         9QaOWgCy33er+CURO6X/cF9xisoH7MpoDYXg74AZF4YuuXiyGfY/5LUF8gFCATJGyspk
         osRg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=naezKv10aMe93QkJaQYNNufXPVHrNlb0/A4rCenoqCY=;
        b=gWBKH3gCAJZlgJuIC4o5gWiS6sJm5AY1geAYsxZ5n7NafZViv5ZFV7/7StW00YbScK
         cuKiZTiZKHLEeWiQhxn55jXl5ClRq+/ptDKzgQ3CFFlDyl9kFtlIguSd9m1dXf3usouv
         WfZCmmStzz1QkPzOGAXc/Z1Mlse3wMaI+M7JEjrrtWiCRKMLGa82k95D7jnTajmy9AW9
         dGy2LqfFL829ReSYamo2SHp0RD6dURUknELL1ar1A4tE15vmducDB2K2XcljYx+aIZkl
         9CgujOtnK/OdFwx6DRR8JSGYLHMqHucbevHp97yEnCTuYhklVkjNPVaM21yQZzMfkK85
         C0Gg==
X-Gm-Message-State: APjAAAUgvw4V3tsAplLgVzbjvSCDv+Of5s8D0AvI8rsH3fz9db+XYwj1
	7PYE7G4fQ65o/vmLlp5Qvm8=
X-Google-Smtp-Source: APXvYqxcqLH+5v6piWwJE3uUBwPudK1RF5tyx8WTyZiyOikknuiISYNZfwnXF9/2xI39uQhTdqAefQ==
X-Received: by 2002:a17:90a:fe07:: with SMTP id ck7mr17008634pjb.68.1566157161101;
        Sun, 18 Aug 2019 12:39:21 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.36])
        by smtp.gmail.com with ESMTPSA id f63sm18399564pfa.144.2019.08.18.12.39.19
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 18 Aug 2019 12:39:20 -0700 (PDT)
From: Bharath Vedartham <linux.bhar@gmail.com>
To: sivanich@sgi.com,
	jhubbard@nvidia.com
Cc: jglisse@redhat.com,
	ira.weiny@intel.com,
	gregkh@linuxfoundation.org,
	arnd@arndb.de,
	william.kucharski@oracle.com,
	hch@lst.de,
	inux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel-mentees@lists.linuxfoundation.org,
	Bharath Vedartham <linux.bhar@gmail.com>
Subject: [Linux-kernel-mentees][PATCH v6 0/2] get_user_pages changes
Date: Mon, 19 Aug 2019 01:08:53 +0530
Message-Id: <1566157135-9423-1-git-send-email-linux.bhar@gmail.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This version only converts put_page to put_user_page and removes
an unecessary ifdef.=20

It does not convert atomic_pte_lookup to __get_user_pages as
gru_vtop could run in an interrupt context in which we can't assume
current as __get_user_pages does.

Bharath Vedartham (2):
  sgi-gru: Convert put_page() to put_user_page*()
  sgi-gru: Remove uneccessary ifdef for CONFIG_HUGETLB_PAGE

 drivers/misc/sgi-gru/grufault.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

--=20
2.7.4


