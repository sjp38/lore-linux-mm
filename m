Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32345C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 12:54:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C66D6218D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 12:53:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=oneplus.com header.i=@oneplus.com header.b="emltN+uh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C66D6218D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=oneplus.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 857358E00DD; Mon, 11 Feb 2019 07:53:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 741058E0002; Mon, 11 Feb 2019 07:53:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5937E8E00DD; Mon, 11 Feb 2019 07:53:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0BFCD8E0002
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 07:53:58 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id s27so8280506pgm.4
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 04:53:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=c5/8tULImdicr98NRIncbPNoRwDRglDyrOLjBmjMqdI=;
        b=ICOQUSDjMCgVDJyqi78ESe3lmOOGSfdOpl+GFMA9fVtKnPmoO3aDGwilO/Y3Y4zW54
         03uRkTcuQ67+CwEGJMUympFHB099oFgA0bA4WUaNEWmR+F+NcVmdaVg3p+MJ1/xT4UP3
         TQnAqdcx2Ocb+sQv/Ui6fBMGSzgdgzO9s9cEePlV1nubr5Txmll8p4h7tSwgoZkmxo21
         XcPleyFsYB1CMz4iFbU87RzFvnj7P/pNDjUOSRm8x4qW0zFBu6lfJMkzGUoIxf/23S/p
         oJgMM03CQMJ5vLY7I0ZcW4NjMvVMAEkDlvFi4gsz25521G4d9EzVpuOqNGvHdBiAV7H7
         xNMA==
X-Gm-Message-State: AHQUAuaaanIbDotdMTUyxVkSFSi9N/MdoiTex6YgEAyiwD+n1qQ/sqLP
	v+fLxEUqAEoaydzV1yIhPKZoSR4n87iaIH0yxcFVhFm8kzBw9/rPKl1+4nliaKUHVN16BHa0hjm
	HbCBZ67wWJhxS5ILT5+aBjptAXsG4twg21y3fhCtiP5AgM1DBH7OXrMIp1/K03iHW8Q==
X-Received: by 2002:a62:5003:: with SMTP id e3mr37471683pfb.23.1549889637687;
        Mon, 11 Feb 2019 04:53:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbvUpPLC7s7MNcJrp81DN/njG0YY8f/vbRyNIozlbp3d+067nouq57LT8ulANTgVGhC7Ebq
X-Received: by 2002:a62:5003:: with SMTP id e3mr37471598pfb.23.1549889636202;
        Mon, 11 Feb 2019 04:53:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549889636; cv=none;
        d=google.com; s=arc-20160816;
        b=Nookya0sHB/UeN8+r72ViSkT8UlNwQzhLwXaAzRBIXdwfiKI++geCccLJfpDQz+zIJ
         Rf9Kw2WKyxdYFPs/pfjQO1R5jRP7KigL9r+4xUKvOl2CdkgoPmvjPTUw6FqDQt/M5wg0
         2NCwhNhOhTEAHbp6t/3pUQn3ywRhx08s1HHeCIJmYvToFmPW1Rw7YnNLCvIIITRs3Z0J
         FEHqMjhbB2DT0Ch3npUtdOoq4rNHWGVJB5Mle0vIwazTW1VMcknUYhtCdQPDb+yfRXVs
         irtRylmtyECR3ZFY87t5qP560rgTcF623tcVhuuOmZaFTbHmWOYvUkoAF/SbVJj39A83
         5LhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=c5/8tULImdicr98NRIncbPNoRwDRglDyrOLjBmjMqdI=;
        b=RoPOaPy2gL7TZDW9hG4ipasY1Tlpu3+gsJ2quViE8KjFbZpdZTKz/sBLx27cSXop66
         I4mG1euFXoVNuH/Bh8uF0ucUvi9nSxL9XrmhqcYupgl1TC49YGxsb7zMFyjZHQrLhw+b
         D8dndbdna+FHKXIk0czHXwbcsysDIus5kdbUQBkEMjppAJAFL8KRfzhBvV1Hl9Y7weGO
         hmAIrbEl9SKxKvWOWtZj6OxViquLwGMeYxS7Kb1XTK8BgOlonunKD/8BtHoS/Zy2CSWB
         dRu3CAAWLeFjuepkBFyqAZOwqbisfcQx1Nw0Y2XYgf3THpmr10q3J2JgXUyfk14SOxAC
         G8sA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oneplus.com header.s=selector1 header.b=emltN+uh;
       spf=pass (google.com: domain of chintan.pandya@oneplus.com designates 40.107.128.124 as permitted sender) smtp.mailfrom=chintan.pandya@oneplus.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=oneplus.com
Received: from KOR01-PS2-obe.outbound.protection.outlook.com (mail-eopbgr1280124.outbound.protection.outlook.com. [40.107.128.124])
        by mx.google.com with ESMTPS id c24si9986391plo.434.2019.02.11.04.53.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 11 Feb 2019 04:53:56 -0800 (PST)
Received-SPF: pass (google.com: domain of chintan.pandya@oneplus.com designates 40.107.128.124 as permitted sender) client-ip=40.107.128.124;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oneplus.com header.s=selector1 header.b=emltN+uh;
       spf=pass (google.com: domain of chintan.pandya@oneplus.com designates 40.107.128.124 as permitted sender) smtp.mailfrom=chintan.pandya@oneplus.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=oneplus.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oneplus.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=c5/8tULImdicr98NRIncbPNoRwDRglDyrOLjBmjMqdI=;
 b=emltN+uhQ+3Uefdc3z1vujjx8K+UWz1fjypN4QSEWCS8iou/t8FpIfok15f7od4Raxv7uyo1w4DtBfSCZ2T3N2/ecr6C22N8Joqt9x3jUuCWO1rj/xYBAdF6mRW3V71nCw2SBpamAtKPNHulMu/DFus0qHKJVfosIk0GKNSTwnI=
Received: from SL2PR04MB3323.apcprd04.prod.outlook.com (20.177.176.10) by
 SL2PR04MB3081.apcprd04.prod.outlook.com (20.177.177.85) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.22; Mon, 11 Feb 2019 12:53:53 +0000
Received: from SL2PR04MB3323.apcprd04.prod.outlook.com
 ([fe80::c429:c599:d8eb:22ce]) by SL2PR04MB3323.apcprd04.prod.outlook.com
 ([fe80::c429:c599:d8eb:22ce%3]) with mapi id 15.20.1601.023; Mon, 11 Feb 2019
 12:53:53 +0000
From: Chintan Pandya <chintan.pandya@oneplus.com>
To: Linux Upstream <linux.upstream@oneplus.com>, "hughd@google.com"
	<hughd@google.com>, "peterz@infradead.org" <peterz@infradead.org>,
	"jack@suse.cz" <jack@suse.cz>, "mawilcox@microsoft.com"
	<mawilcox@microsoft.com>, "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, Chintan Pandya
	<chintan.pandya@oneplus.com>
Subject: [RFC 1/2] page-flags: Make page lock operation atomic
Thread-Topic: [RFC 1/2] page-flags: Make page lock operation atomic
Thread-Index: AQHUwgjX8ckPmAATi0qcw7UPY7PQxQ==
Date: Mon, 11 Feb 2019 12:53:53 +0000
Message-ID: <20190211125337.16099-2-chintan.pandya@oneplus.com>
References: <20190211125337.16099-1-chintan.pandya@oneplus.com>
In-Reply-To: <20190211125337.16099-1-chintan.pandya@oneplus.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: SG2PR04CA0193.apcprd04.prod.outlook.com
 (2603:1096:4:14::31) To SL2PR04MB3323.apcprd04.prod.outlook.com
 (2603:1096:100:38::10)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=chintan.pandya@oneplus.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-mailer: git-send-email 2.17.1
x-originating-ip: [14.143.173.238]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;SL2PR04MB3081;6:ufHnOd4evZicX6K+KWH+0CRUOIXgqO/uFoboXh85IpiNXjc/PJAsruYDFI0/lJpzkBZ6+4BdqLipqf/NIaAff4EI8tyJfrKHepPTbbVVZKmfEoYJOLk8fXQaAN4gHKXjxiCtFdApqMmlmLTqP/3Y8P/EyHf4ZINDoeQvxoPCchB9OeemW3ncoMFaXBxD4tfzCY/HxfV28FxnJ3a9ZcPuf290/g8iXEgFwVibEM9oj2JfHO4edCwOeSShgHBKVOoUGNl2Ew+ixOhLwZ+bwSzMtNMaRtuCL4Fc5CLchX/8A9eyuDAtgsxWyV37UX7/YcGPwK0ECZvZpNWXl8dOWM/kVWnhy4QI5V0n+ytbSALvJg2+gFSih0E64Ew7PDggB7dDO9CGAEIz8AyUUBgFKE9bZkQzEQg3oaCP1XXerW4tzyLj+Ajxprseyo8T1yKsQ+ARXx3uQ7mbZBF9SJTv7YXAPQ==;5:kPOK74kwSFDWo17Xqv2iybnPCuC2+V3jMKmMoE6ukSjl0Lpkb8koj4GeUK7PWMxiWkGOUa4iOACir/yPgAXsvEvPWqrAjFFvVw8GDfAWDrU3NH/XzaThrmHec2jXHbDokJjgPYRCTnyp8SaUa2HwKVDjQs5jfFhzBkU9yMA2IJAf+waC2kiE8rcKE8KcA3LWFW4Vk1QndutFxgL5azJ3CA==;7:33bdjsGIkRstEJSoYlsv8M4tHjyk6dcYFyMATxQi6gDBCoxe5QnEaWip3mhJBxuN/siHxvWMKR904LmLyqs2FGhmsvVnC6HAKLo0IIp7RQkJrmbbIZNDn+/bP7T5gmEXR0RN7NrXL3rJFZ0CYcTUCQ==
x-ms-office365-filtering-correlation-id: a1035f7b-cb28-4ff0-04a3-08d6901ffa10
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:SL2PR04MB3081;
x-ms-traffictypediagnostic: SL2PR04MB3081:
x-ld-processed: 0423909d-296c-463e-ab5c-e5853a518df8,ExtAddr
x-microsoft-antispam-prvs:
 <SL2PR04MB3081FBE69E131E782CAC47BF91640@SL2PR04MB3081.apcprd04.prod.outlook.com>
x-forefront-prvs: 0945B0CC72
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(376002)(346002)(396003)(136003)(366004)(39860400002)(189003)(199004)(7736002)(81166006)(50226002)(478600001)(8676002)(105586002)(8936002)(66066001)(81156014)(106356001)(1076003)(78486014)(305945005)(14454004)(71190400001)(71200400001)(2906002)(1511001)(36756003)(316002)(110136005)(54906003)(2501003)(2201001)(97736004)(6512007)(52116002)(76176011)(6506007)(386003)(68736007)(14444005)(53936002)(44832011)(6436002)(6486002)(25786009)(2616005)(86362001)(486006)(476003)(4326008)(186003)(26005)(102836004)(11346002)(446003)(6116002)(3846002)(99286004)(256004)(107886003)(55236004);DIR:OUT;SFP:1102;SCL:1;SRVR:SL2PR04MB3081;H:SL2PR04MB3323.apcprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: oneplus.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 eK4N5+v7UcI9xmyqyrj8iMvx5ZkcnVf0qbe2FKduofAB7X7YE5SFZdFgGUDM9TVDVuQmYaZnpJhmRZ65K3BOv9ov1YUB6KYpjYewQDdHaKhCzoJj6aHJZ1KhoTRLjKDneTJgb0bKGWKkwwJtc3b3MMrUJiu8WX6BsJFYKtSBUQTb0ty1w1ZR6/SFm7YsDn8VOLRPnaGQPTQOmQUe2M6aEOpEYThgIa6U7ZI5/Lvk+qMqfIqkzTGkKrNdwJC9MwSxFKdVcosVYqqm/oXEjgM55nczsj11OXJSA7nLZUph4gyO9I/oQSW3NkNFGbWYWsAm/a0xvYuODbU2dIUPQ4eKht4y9mH9h9N4WTHCU6/4em2QuAbSGW3WRx6sxHD4/pSPcjWxoAIUfUKuWUeJFQyYJazW3sdkI8o3kjxcGertbBQ=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: oneplus.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a1035f7b-cb28-4ff0-04a3-08d6901ffa10
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Feb 2019 12:53:51.9403
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 0423909d-296c-463e-ab5c-e5853a518df8
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SL2PR04MB3081
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, page lock operation is non-atomic. This is opening
some scope for race condition. For ex, if 2 threads are accessing
same page flags, it may happen that our desired thread's page
lock bit (PG_locked) might get overwritten by other thread
leaving page unlocked. This can cause issues later when some
code expects page to be locked but it is not.

Make page lock/unlock operation use the atomic version of
set_bit API. There are other flag set operations which still
uses non-atomic version of set_bit API. Bit, that might be
the change for the future.

Change-Id: I13bdbedc2b198af014d885e1925c93b83ed6660e
Signed-off-by: Chintan Pandya <chintan.pandya@oneplus.com>
---
 fs/cifs/file.c             | 8 ++++----
 fs/pipe.c                  | 2 +-
 include/linux/page-flags.h | 2 +-
 include/linux/pagemap.h    | 6 +++---
 mm/filemap.c               | 4 ++--
 mm/khugepaged.c            | 2 +-
 mm/ksm.c                   | 2 +-
 mm/memory-failure.c        | 2 +-
 mm/memory.c                | 2 +-
 mm/migrate.c               | 2 +-
 mm/shmem.c                 | 6 +++---
 mm/swap_state.c            | 4 ++--
 mm/vmscan.c                | 2 +-
 13 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 7d6539a04fac..23bcdee37239 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -3661,13 +3661,13 @@ readpages_get_pages(struct address_space *mapping, =
struct list_head *page_list,
 	 * should have access to this page, we're safe to simply set
 	 * PG_locked without checking it first.
 	 */
-	__SetPageLocked(page);
+	SetPageLocked(page);
 	rc =3D add_to_page_cache_locked(page, mapping,
 				      page->index, gfp);
=20
 	/* give up if we can't stick it in the cache */
 	if (rc) {
-		__ClearPageLocked(page);
+		ClearPageLocked(page);
 		return rc;
 	}
=20
@@ -3688,9 +3688,9 @@ readpages_get_pages(struct address_space *mapping, st=
ruct list_head *page_list,
 		if (*bytes + PAGE_SIZE > rsize)
 			break;
=20
-		__SetPageLocked(page);
+		SetPageLocked(page);
 		if (add_to_page_cache_locked(page, mapping, page->index, gfp)) {
-			__ClearPageLocked(page);
+			ClearPageLocked(page);
 			break;
 		}
 		list_move_tail(&page->lru, tmplist);
diff --git a/fs/pipe.c b/fs/pipe.c
index 8ef7d7bef775..1bab40a2ca44 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -147,7 +147,7 @@ static int anon_pipe_buf_steal(struct pipe_inode_info *=
pipe,
 	if (page_count(page) =3D=3D 1) {
 		if (memcg_kmem_enabled())
 			memcg_kmem_uncharge(page, 0);
-		__SetPageLocked(page);
+		SetPageLocked(page);
 		return 0;
 	}
 	return 1;
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 5af67406b9c9..a56a9bd4bc6b 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -268,7 +268,7 @@ static inline int TestClearPage##uname(struct page *pag=
e) { return 0; }
 #define TESTSCFLAG_FALSE(uname)						\
 	TESTSETFLAG_FALSE(uname) TESTCLEARFLAG_FALSE(uname)
=20
-__PAGEFLAG(Locked, locked, PF_NO_TAIL)
+PAGEFLAG(Locked, locked, PF_NO_TAIL)
 PAGEFLAG(Waiters, waiters, PF_ONLY_HEAD) __CLEARPAGEFLAG(Waiters, waiters,=
 PF_ONLY_HEAD)
 PAGEFLAG(Error, error, PF_NO_COMPOUND) TESTCLEARFLAG(Error, error, PF_NO_C=
OMPOUND)
 PAGEFLAG(Referenced, referenced, PF_HEAD)
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 51a9a0af3281..87a0447cfbe0 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -619,17 +619,17 @@ int replace_page_cache_page(struct page *old, struct =
page *new, gfp_t gfp_mask);
=20
 /*
  * Like add_to_page_cache_locked, but used to add newly allocated pages:
- * the page is new, so we can just run __SetPageLocked() against it.
+ * the page is new, so we can just run SetPageLocked() against it.
  */
 static inline int add_to_page_cache(struct page *page,
 		struct address_space *mapping, pgoff_t offset, gfp_t gfp_mask)
 {
 	int error;
=20
-	__SetPageLocked(page);
+	SetPageLocked(page);
 	error =3D add_to_page_cache_locked(page, mapping, offset, gfp_mask);
 	if (unlikely(error))
-		__ClearPageLocked(page);
+		ClearPageLocked(page);
 	return error;
 }
=20
diff --git a/mm/filemap.c b/mm/filemap.c
index 8e09304af1ec..14284726cf3a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -807,11 +807,11 @@ int add_to_page_cache_lru(struct page *page, struct a=
ddress_space *mapping,
 	void *shadow =3D NULL;
 	int ret;
=20
-	__SetPageLocked(page);
+	SetPageLocked(page);
 	ret =3D __add_to_page_cache_locked(page, mapping, offset,
 					 gfp_mask, &shadow);
 	if (unlikely(ret))
-		__ClearPageLocked(page);
+		ClearPageLocked(page);
 	else {
 		/*
 		 * The page might have been evicted from cache only
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index aaae33402d61..2e8f5bfa066d 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1341,7 +1341,7 @@ static void collapse_shmem(struct mm_struct *mm,
 	new_page->index =3D start;
 	new_page->mapping =3D mapping;
 	__SetPageSwapBacked(new_page);
-	__SetPageLocked(new_page);
+	SetPageLocked(new_page);
 	BUG_ON(!page_ref_freeze(new_page, 1));
=20
=20
diff --git a/mm/ksm.c b/mm/ksm.c
index 31e6420c209b..115091798a6d 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2531,7 +2531,7 @@ struct page *ksm_might_need_to_copy(struct page *page=
,
=20
 		SetPageDirty(new_page);
 		__SetPageUptodate(new_page);
-		__SetPageLocked(new_page);
+		SetPageLocked(new_page);
 	}
=20
 	return new_page;
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 42d8fa64cebc..1a7c31b7d7e3 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1209,7 +1209,7 @@ int memory_failure(unsigned long pfn, int trapno, int=
 flags)
 	/*
 	 * We ignore non-LRU pages for good reasons.
 	 * - PG_locked is only well defined for LRU pages and a few others
-	 * - to avoid races with __SetPageLocked()
+	 * - to avoid races with SetPageLocked()
 	 * - to avoid races with __SetPageSlab*() (and more non-atomic ops)
 	 * The check (unnecessarily) ignores LRU pages being isolated and
 	 * walked by the page reclaim code, however that's not a big loss.
diff --git a/mm/memory.c b/mm/memory.c
index 8b9e5dd20d0c..9d7b107025e7 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3102,7 +3102,7 @@ int do_swap_page(struct vm_fault *vmf)
 			page =3D alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma,
 							vmf->address);
 			if (page) {
-				__SetPageLocked(page);
+				SetPageLocked(page);
 				__SetPageSwapBacked(page);
 				set_page_private(page, entry.val);
 				lru_cache_add_anon(page);
diff --git a/mm/migrate.c b/mm/migrate.c
index 12d821ff8401..1b9ed5ca5e8e 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2037,7 +2037,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct=
 *mm,
 	}
=20
 	/* Prepare a page as a migration target */
-	__SetPageLocked(new_page);
+	SetPageLocked(new_page);
 	if (PageSwapBacked(page))
 		__SetPageSwapBacked(new_page);
=20
diff --git a/mm/shmem.c b/mm/shmem.c
index 8c8af1440184..3305312c7557 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1501,7 +1501,7 @@ static struct page *shmem_alloc_and_acct_page(gfp_t g=
fp,
 	else
 		page =3D shmem_alloc_page(gfp, info, index);
 	if (page) {
-		__SetPageLocked(page);
+		SetPageLocked(page);
 		__SetPageSwapBacked(page);
 		return page;
 	}
@@ -1554,7 +1554,7 @@ static int shmem_replace_page(struct page **pagep, gf=
p_t gfp,
 	copy_highpage(newpage, oldpage);
 	flush_dcache_page(newpage);
=20
-	__SetPageLocked(newpage);
+	SetPageLocked(newpage);
 	__SetPageSwapBacked(newpage);
 	SetPageUptodate(newpage);
 	set_page_private(newpage, swap_index);
@@ -2277,7 +2277,7 @@ static int shmem_mfill_atomic_pte(struct mm_struct *d=
st_mm,
 	}
=20
 	VM_BUG_ON(PageLocked(page) || PageSwapBacked(page));
-	__SetPageLocked(page);
+	SetPageLocked(page);
 	__SetPageSwapBacked(page);
 	__SetPageUptodate(page);
=20
diff --git a/mm/swap_state.c b/mm/swap_state.c
index bec3d214084b..caa652f1d8a6 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -480,7 +480,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry,=
 gfp_t gfp_mask,
 		}
=20
 		/* May fail (-ENOMEM) if radix-tree node allocation failed. */
-		__SetPageLocked(new_page);
+		SetPageLocked(new_page);
 		__SetPageSwapBacked(new_page);
 		err =3D __add_to_swap_cache(new_page, entry);
 		if (likely(!err)) {
@@ -498,7 +498,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry,=
 gfp_t gfp_mask,
 			return new_page;
 		}
 		radix_tree_preload_end();
-		__ClearPageLocked(new_page);
+		ClearPageLocked(new_page);
 		/*
 		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
 		 * clear SWAP_HAS_CACHE flag.
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ead2c52008fa..c01aa130b9ba 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1577,7 +1577,7 @@ static unsigned long shrink_page_list(struct list_hea=
d *page_list,
 		 * we obviously don't have to worry about waking up a process
 		 * waiting on the page lock, because there are no references.
 		 */
-		__ClearPageLocked(page);
+		ClearPageLocked(page);
 free_it:
 		nr_reclaimed++;
=20
--=20
2.17.1

