Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88B2AC742A1
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 23:25:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29FCD2084B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 23:25:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=os.amperecomputing.com header.i=@os.amperecomputing.com header.b="ZTvaGg4y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29FCD2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=os.amperecomputing.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 977798E0101; Thu, 11 Jul 2019 19:25:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94E128E00DB; Thu, 11 Jul 2019 19:25:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 815CF8E0101; Thu, 11 Jul 2019 19:25:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5CED88E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 19:25:47 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id m25so5333328qtn.18
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 16:25:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=xULxKrwm/DZUk8Kcvcen9hZoezlHQR4cyK84iGsY8ZY=;
        b=HRaJc8n+gwObtna7whdVaQPuaWhvZfYgDq5PyaYKPLGIf9Tgu3ROt99mnZnJlQHYX1
         /qWHIlXWhykcx3hfdNncSaMbtpwkSgEujIMCLP99mRvhDU+mhFVSRvandC18g8Ll3aOS
         TmGs63BRkijcv6hkLcQMu9bZ8zaB77w6Z6MMYYhbO73MhsQJnYmeKtXrlKJpjU2hNLzM
         sY4XvkNCnxrucymuSe2nQrUGiQTlDec1+Qx5cuOGdnxi/RLX9X6k75dJq1zad1FDC4ti
         hDUhKp3u25YH6HfSxvSZLE0Hw8Go7yB+tB8HPxUM/Te7vmXV0y9LnPI+LySXwNGfKiID
         YN8w==
X-Gm-Message-State: APjAAAWr9RGEXSz1EYOlK+XFVZ2DUeLIBJFqtUW0S4N6tW/QLB6eh7DT
	R69kTtcsRrli5PmQoufDZC962GO1ZVTm60JwC0XzFP1cg1p39l/YiJ5gVJkkEYNWWUf5edgHe0v
	f5HliJmOHvAriIvhanX9YfmwBguoCiZvVQjbqR6CbmHFM0ntGCQzQMO5FcFlQyfl8YQ==
X-Received: by 2002:ac8:3a63:: with SMTP id w90mr3918468qte.371.1562887547127;
        Thu, 11 Jul 2019 16:25:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaeIXYBhyCXCnlCTrOLFhCfq0xEYVtF71d0b2E082XbU54rxUEylCTOxEZ6040NGtbGUlj
X-Received: by 2002:ac8:3a63:: with SMTP id w90mr3918438qte.371.1562887546514;
        Thu, 11 Jul 2019 16:25:46 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1562887546; cv=pass;
        d=google.com; s=arc-20160816;
        b=cGGAbDikTUWFV6wi238L43WztugRwZ1pQ2xRItfMER0Y+VREkgJ15k2cmI7qBk8oO3
         MsSVX62fd3gbRKish9DcQ9s3wtkQpmqBWQdj2EpD9LN+qVaX2JKnxd9eKD2xS+liBIdJ
         NuT3F30ZJza9REI0GJ87R4yrY24ESLstEol2Uv8F0mMnK2fNXK8w71NUSE63sBfaIjLu
         HkDWfKX6LxYgyRcceJ1Qq909z/JSUGunOtPMADPf/HLYRJcw2/6qM+U7z6mQJ/1B0p3b
         jdMRIfHG6rVt8uDqcoEFoSnj0EnZPtDbCbIL9+Dmz2WqZ82Q/y2ABq06E0TKFkMr/ZeD
         a4nw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from:dkim-signature;
        bh=xULxKrwm/DZUk8Kcvcen9hZoezlHQR4cyK84iGsY8ZY=;
        b=qeunGTjdFbrle5lKcRkhlUZBLY+u5Ts38bVuMQaQnFTfDIGI98VA2jdyyQUKbiV2+P
         og98Z5nOpj2lGIlKhYMzDKUMsup1GvmP+gamtC63pHyQUCdFc1lK4FUakZhy+5YJVDpd
         8IepxEt6DZw6wqCnOAQZyBVgygolyiai/unlZGnajUYtoGLHJ/DZr9B8/QU5B81STDhq
         bSEz8Rp4DaTEPhqQLpjCDf9qvStHO7YEERdlIYyUgkq5ow3C83PXXj8/0zkeE0UR2D+C
         R2uyUUqXyf7JvKMhUSUfE6BpZpBQyY3N0lbYW/VGv8QJjUmvVzIwR4yRMeX6OKppEwbk
         c1JA==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=ZTvaGg4y;
       arc=pass (i=1 spf=pass spfdomain=os.amperecomputing.com dkim=pass dkdomain=os.amperecomputing.com dmarc=pass fromdomain=os.amperecomputing.com);
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.74.102 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-eopbgr740102.outbound.protection.outlook.com. [40.107.74.102])
        by mx.google.com with ESMTPS id k25si3856668qki.139.2019.07.11.16.25.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 11 Jul 2019 16:25:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.74.102 as permitted sender) client-ip=40.107.74.102;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@os.amperecomputing.com header.s=selector1 header.b=ZTvaGg4y;
       arc=pass (i=1 spf=pass spfdomain=os.amperecomputing.com dkim=pass dkdomain=os.amperecomputing.com dmarc=pass fromdomain=os.amperecomputing.com);
       spf=pass (google.com: domain of hoan@os.amperecomputing.com designates 40.107.74.102 as permitted sender) smtp.mailfrom=hoan@os.amperecomputing.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amperecomputing.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Ts6L8iLdOURp8b9hazYgG2uO0Xw6IDj8MpvvOFuz4kKBismBdl9r0KTooSN4anHm/eBPGsAnOdJ56JdDCseXvTP5Av8bj4BkYQtRqjks4zt3SLYl1rdXLqkoMfrxKicwo2QFlKOVpOBwlotIqVQ1dXur84D3gfkP3dTNwJZiPZjk3/FBrc7+ZPH8+qrE6hP23NBn2M/mDk2LgorSbNQbKZgxaP+ebMFK2PfmJywIJA47227WckZxtXQNcbCuK7G6k89lHp6CGYmfqJX8LZ9De4EUXG0Zj3PGh7FFormcYfOSkjMuqEecxVKwyDaP6+Ppb++thXzeyAxkZkr9b1jhNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=xULxKrwm/DZUk8Kcvcen9hZoezlHQR4cyK84iGsY8ZY=;
 b=hqRlh6qKsH4+CajtYrm7ZHmJwnM/SPVgYw0tVK0YwaDt+Mx8e/ZZNmG027PnNnqZoJQpDaTTqrOrsqqPyonEAez/OQ+CDBmWvFdShfJtj/tDRviwdj1qBb6lpYCHmuAM7QXTEBvBATZLCzLMwZ2Avjwx7JcNykT/AoJT7q++LjOOhpD/Flf90G047hjXizWlql5yuMz2YFF0PAc7mKviML7F6K/iDOUx5cykmD2OsKvJOwZPtn87ayzv+zV4OPjhifNNEFGgWbn2BhOMjydVwiKiQpNHENWXPmXiG90bm4+5D7b8qtvQDmVrbbiUAH+CSq/ZxJfYMagKrb0ogfbHkQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=os.amperecomputing.com;dmarc=pass action=none
 header.from=os.amperecomputing.com;dkim=pass
 header.d=os.amperecomputing.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=os.amperecomputing.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=xULxKrwm/DZUk8Kcvcen9hZoezlHQR4cyK84iGsY8ZY=;
 b=ZTvaGg4yvmBsUMWLWTgr/fJWYWY5FDRZXzMIodPPFSejtCyuJVM538sQU7Pes1yrn5i9QbVxDWZmPfudPuh/jrZOr4ZKPfhJ3qwmKu7AqCJ7ILxklZEO86dBZrr4FR0mC4ZO9BbFguRKO36lxkmfNuoXrx/jVhD1KqPmJqxV3ZI=
Received: from BYAPR01MB4085.prod.exchangelabs.com (52.135.237.22) by
 BYAPR01MB5557.prod.exchangelabs.com (20.179.88.205) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2073.10; Thu, 11 Jul 2019 23:25:44 +0000
Received: from BYAPR01MB4085.prod.exchangelabs.com
 ([fe80::9dbb:1b4c:bace:ef80]) by BYAPR01MB4085.prod.exchangelabs.com
 ([fe80::9dbb:1b4c:bace:ef80%7]) with mapi id 15.20.2052.020; Thu, 11 Jul 2019
 23:25:44 +0000
From: Hoan Tran OS <hoan@os.amperecomputing.com>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
	<will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Michal
 Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador
	<osalvador@suse.de>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Mike
 Rapoport <rppt@linux.ibm.com>, Alexander Duyck
	<alexander.h.duyck@linux.intel.com>, Benjamin Herrenschmidt
	<benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael
 Ellerman <mpe@ellerman.id.au>, Thomas Gleixner <tglx@linutronix.de>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter Anvin"
	<hpa@zytor.com>, "David S . Miller" <davem@davemloft.net>, Heiko Carstens
	<heiko.carstens@de.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, Christian
 Borntraeger <borntraeger@de.ibm.com>
CC: "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, "linux-s390@vger.kernel.org"
	<linux-s390@vger.kernel.org>, "sparclinux@vger.kernel.org"
	<sparclinux@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Open Source
 Submission <patches@amperecomputing.com>, Hoan Tran OS
	<hoan@os.amperecomputing.com>
Subject: [PATCH v2 0/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by default
 for NUMA
Thread-Topic: [PATCH v2 0/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by
 default for NUMA
Thread-Index: AQHVOD/24o0J5njgPEqkosNO5sbs8Q==
Date: Thu, 11 Jul 2019 23:25:44 +0000
Message-ID: <1562887528-5896-1-git-send-email-Hoan@os.amperecomputing.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: CY4PR19CA0045.namprd19.prod.outlook.com
 (2603:10b6:903:103::31) To BYAPR01MB4085.prod.exchangelabs.com
 (2603:10b6:a03:56::22)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=hoan@os.amperecomputing.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-mailer: git-send-email 2.7.4
x-originating-ip: [4.28.12.214]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 35488193-dd56-4657-ba35-08d706571887
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR01MB5557;
x-ms-traffictypediagnostic: BYAPR01MB5557:
x-microsoft-antispam-prvs:
 <BYAPR01MB5557DB615599B0BCAFAAF8C8F1F30@BYAPR01MB5557.prod.exchangelabs.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 0095BCF226
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(4636009)(346002)(376002)(39840400004)(136003)(396003)(366004)(189003)(199004)(52116002)(66476007)(66556008)(66946007)(64756008)(66446008)(14454004)(5660300002)(1511001)(6506007)(386003)(71190400001)(71200400001)(6436002)(53936002)(66066001)(102836004)(25786009)(68736007)(6512007)(86362001)(3846002)(14444005)(2616005)(186003)(81166006)(26005)(2906002)(478600001)(4326008)(6486002)(7736002)(305945005)(54906003)(8936002)(110136005)(7416002)(6116002)(99286004)(476003)(316002)(8676002)(107886003)(81156014)(486006)(256004)(50226002)(921003)(1121003);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR01MB5557;H:BYAPR01MB4085.prod.exchangelabs.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:0;
received-spf: None (protection.outlook.com: os.amperecomputing.com does not
 designate permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 LaK2A6JxGVhN9BP+NPmg4P7C+zX5H8qaEDrDEH1OTjGQyXaBI5hT6402K1LX9xPmNoq5oazMmY5arw0GLdnB8GENa/z7AO8Fs7GZtGflMJ4K0wNWFA+m0N0Mz3nNlsTCTmI7tEHP/Lt4+fjddSbZqgAAB9tWq9DpoCpY37T9KsWkEjIECCTtd0s9UQbEi6LvJL5mDutuWokU8Dqx2ATzmqbVFkAGuPjikJIfg/waU+JNVOjIrJS4u+qv3sZGOEZj8wDk1k+y81I6mT56n1mFVvGPwPz5y1CngGy1IBplFtE5Or4yI/J+qkstT0b147auTth+wsUDMPHhdxTnqGw8qnOuBqTJLkWoROmKArfnOr6ICga33jlPOOyiOcsxABVWVCkKVVATxbPp2vHVAeBoa0pIKIea2AicjYztHzcutgQ=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: os.amperecomputing.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 35488193-dd56-4657-ba35-08d706571887
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Jul 2019 23:25:44.3751
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3bc2b170-fd94-476d-b0ce-4229bdc904a7
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: Hoan@os.amperecomputing.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR01MB5557
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In NUMA layout which nodes have memory ranges that span across other nodes,
the mm driver can detect the memory node id incorrectly.

For example, with layout below
Node 0 address: 0000 xxxx 0000 xxxx
Node 1 address: xxxx 1111 xxxx 1111

Note:
 - Memory from low to high
 - 0/1: Node id
 - x: Invalid memory of a node

When mm probes the memory map, without CONFIG_NODES_SPAN_OTHER_NODES
config, mm only checks the memory validity but not the node id.
Because of that, Node 1 also detects the memory from node 0 as below
when it scans from the start address to the end address of node 1.

Node 0 address: 0000 xxxx xxxx xxxx
Node 1 address: xxxx 1111 1111 1111

This layout could occur on any architecture. This patch enables
CONFIG_NODES_SPAN_OTHER_NODES by default for NUMA to fix this issue.

V2:
 * Revise the patch description

Hoan Tran (5):
  mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by default for NUMA
  powerpc: Kconfig: Remove CONFIG_NODES_SPAN_OTHER_NODES
  x86: Kconfig: Remove CONFIG_NODES_SPAN_OTHER_NODES
  sparc: Kconfig: Remove CONFIG_NODES_SPAN_OTHER_NODES
  s390: Kconfig: Remove CONFIG_NODES_SPAN_OTHER_NODES

 arch/powerpc/Kconfig | 9 ---------
 arch/s390/Kconfig    | 8 --------
 arch/sparc/Kconfig   | 9 ---------
 arch/x86/Kconfig     | 9 ---------
 mm/page_alloc.c      | 2 +-
 5 files changed, 1 insertion(+), 36 deletions(-)

--=20
2.7.4

