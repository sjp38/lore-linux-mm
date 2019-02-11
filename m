Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 900A8C4151A
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 12:53:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21833218D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 12:53:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=oneplus.com header.i=@oneplus.com header.b="ropVOLtH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21833218D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=oneplus.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D77F8E00B4; Mon, 11 Feb 2019 07:53:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9602F8E0002; Mon, 11 Feb 2019 07:53:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DA9A8E00B4; Mon, 11 Feb 2019 07:53:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3605C8E0002
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 07:53:57 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id t26so8224375pgu.18
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 04:53:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=EZuF4W23b2uhObWENz+guU5vojx1VpAvjBe3lioAi5Q=;
        b=N7gW/9hxM4r+WkQ3BY3VBWwzpsLT8lNlb5qEwZVFedApScsdH71Fzvg+TfE1eOpklk
         uGdbYGBCZ3GqXYC07gwHi9ZBobDEsH3vXRPk4g/iMvLfq3Dn5ffZZ1xJ/K6tzA3w7+87
         GVmaIQp28au67lZTitIuVTDvtVilyQ6GTRwVVXvDKSEqPricmJG7gXY5dsQ5zVzrN+GZ
         +DYF6cCL+LJS8MHUCz/73Vy5qetHJb5wgcv8j7ds09DXXIk/Ipo9NVUMi7TSdy/cTN+v
         VlC+6O88bzuHpGLvdznSGZGusfAvFfL2fAvQNpWMBWWkiqQPb+cnUaxrZbIMexi1a+Cv
         6CyQ==
X-Gm-Message-State: AHQUAubTYHjtQ0XZEOhel08+2pW1+FfHXgWOfXlV1pn1MTcJozunQo+w
	kAD2i/+nVbWf+WCa8WsmN1fHpQB0RgDuN7aPEPOTHZZJ+32iCSHum9nkzshdQzLn4dv2SBjwAgn
	LmhB16iWtX8WVP4RK2eTJD0DvMl0RU15kLSPOUrkn6XOfNixH/m3a6ljBRA6SsYmffw==
X-Received: by 2002:a17:902:a50e:: with SMTP id s14mr25675435plq.311.1549889636802;
        Mon, 11 Feb 2019 04:53:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYfPVdhhUSIE3MUw9tOBCw4l39nUvtNg/mt1jV8BAFif7RAtv+nCRY2YDOzcmkDqtfclq+7
X-Received: by 2002:a17:902:a50e:: with SMTP id s14mr25675367plq.311.1549889635654;
        Mon, 11 Feb 2019 04:53:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549889635; cv=none;
        d=google.com; s=arc-20160816;
        b=v80oXoZ5DTB7R+O9RvyVT1pahF9mLuyU7qPXYZNKShRKO6P1zjpDYg2ZkdKDs8+WPZ
         BCu9BjVBZ+hp4434Oo+6F5bWoLyzGgEMDol7q189I5N0Gom77g5cTsiKD7CWenAHdR2q
         OUqdCLEALlyxzXxmzfuRf8AF0IZbWzR4V/lXZsuF4f55rV8MhHSByzVXqeVGhcgnDm+P
         lk0ac9X7vWgz1QAFO+xX2pxgWKXS7bzey4sDjSys0xz028VRTkc76G+6QRwmMV56Sxd1
         U9oijximwQxba5ciI2Woo9KDn8SR7KGoaaXBzbQ7qucoFBhK3A6Dh1UtqWrI7k/wWG/g
         5Mcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from:dkim-signature;
        bh=EZuF4W23b2uhObWENz+guU5vojx1VpAvjBe3lioAi5Q=;
        b=pODL+EqNKgQ4neVKY9wO/IfQ+IJcxQMI2c/eADBEntVjbWGVnWpVgF4sZsmhvXCPMF
         5JoMZDNCs+iXht8tOlwA/c/BYdaWobWRKpyfn/RfWbKQu1DhSo2Dgb2bvGreY75+By83
         Bam029FHGG1Gy+4gpPZJQOJZiF3xpARQH61/d14rgu7WI4r+Rj54AVss8X4vUvSSPNSI
         kmZbJTaeU7g++VYNAjXNIWcJjPTd0KiasgquvnuDVlHw/h3NZbcQOg2wQzpQNHxIAP28
         y/nWy4IcaPzEueos/nSFtCVm8Zf4quV6zz72ijdpn028icq3nTXahaFvVX9gxkqyFpSb
         hWvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oneplus.com header.s=selector1 header.b=ropVOLtH;
       spf=pass (google.com: domain of chintan.pandya@oneplus.com designates 40.107.128.124 as permitted sender) smtp.mailfrom=chintan.pandya@oneplus.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=oneplus.com
Received: from KOR01-PS2-obe.outbound.protection.outlook.com (mail-eopbgr1280124.outbound.protection.outlook.com. [40.107.128.124])
        by mx.google.com with ESMTPS id c24si9986391plo.434.2019.02.11.04.53.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 11 Feb 2019 04:53:55 -0800 (PST)
Received-SPF: pass (google.com: domain of chintan.pandya@oneplus.com designates 40.107.128.124 as permitted sender) client-ip=40.107.128.124;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oneplus.com header.s=selector1 header.b=ropVOLtH;
       spf=pass (google.com: domain of chintan.pandya@oneplus.com designates 40.107.128.124 as permitted sender) smtp.mailfrom=chintan.pandya@oneplus.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=oneplus.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oneplus.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=EZuF4W23b2uhObWENz+guU5vojx1VpAvjBe3lioAi5Q=;
 b=ropVOLtH7M0jqXR1thnZClWpZgVm6V16ZafzmNcg79MEtEI7d7fpLgrhUjVsN18P0tF4HlHNIxhjd1go4h7QUIuW2tMA7i6iTIxwLZDA3G4a9mQa71HfcWIEK55+YfKHWPVLLZ8Lb0WJ/Xug5jRGcz/anNZW+57wBTHz+0YM+9E=
Received: from SL2PR04MB3323.apcprd04.prod.outlook.com (20.177.176.10) by
 SL2PR04MB3081.apcprd04.prod.outlook.com (20.177.177.85) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.22; Mon, 11 Feb 2019 12:53:52 +0000
Received: from SL2PR04MB3323.apcprd04.prod.outlook.com
 ([fe80::c429:c599:d8eb:22ce]) by SL2PR04MB3323.apcprd04.prod.outlook.com
 ([fe80::c429:c599:d8eb:22ce%3]) with mapi id 15.20.1601.023; Mon, 11 Feb 2019
 12:53:52 +0000
From: Chintan Pandya <chintan.pandya@oneplus.com>
To: Linux Upstream <linux.upstream@oneplus.com>, "hughd@google.com"
	<hughd@google.com>, "peterz@infradead.org" <peterz@infradead.org>,
	"jack@suse.cz" <jack@suse.cz>, "mawilcox@microsoft.com"
	<mawilcox@microsoft.com>, "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, Chintan Pandya
	<chintan.pandya@oneplus.com>
Subject: [RFC 0/2] Potential race condition with page lock
Thread-Topic: [RFC 0/2] Potential race condition with page lock
Thread-Index: AQHUwgjWmEDO0ZkgjE+Y+klyARb4XQ==
Date: Mon, 11 Feb 2019 12:53:51 +0000
Message-ID: <20190211125337.16099-1-chintan.pandya@oneplus.com>
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
 1;SL2PR04MB3081;6:o4j1kJbfmEJhOTYS10ky22wByZxQ3QksZgTNsx8y0ng1NImiI8ZiTgB2vexv+r74HMEC/J0oNzEsVyiD+7D6zJZcf+Zl975nJpZZ+97GaMOyk6xurb6QU6J86UD7rX2bpYGrYmIWVyffDwjCi0PgOnyqdvYm6GXDDmV/yeGr3J0jw0qyCZ+4mXrIM2GYh9QLjqlYkQ2ZNZt+iVOq8VGaCKA0a8fjRAX2bZ4VhOVtIX6ChjHSpvgm8ABd7KBsSlgD879cuNFe9a9XAjCDWOJrJV+EnM/KzL26aBKFn+dXD3XW+5FZtOBQdx6ufbpsWc46wgreU1jezI68eAs/F0sG9wLhJoADyC7CdfTvgCELf+ZVTXhzwLjEhE2TD5jPW4CqUsR4wIn6M9iKnTcwTLplFKDvOyz6RdJ8xYGXWqjXYJwoHKgejgkG3x4yskrr+7hrIaAf56D3nQcXxHqIkKkfCA==;5:MTjo4LPtCpENHpMQk9kKZwIZo5zy2Rbts/cQIYXL4QQp1fl1LZVk8JVEQlyjoe8sngzebeKC3KMsrdla737nmclmaVMPhyBWrFmdm7ngU4LiUoz5sJf5S5CgVXaickGg2DLbq/0SOoJ8m+9FRKf6ziwQUPWRmrr6+cbcQnnwcli8cJ/7zCw+SB9GUxTDm4tPDy0ci+vwgFlya10x5gVIKA==;7:EjF7Ih5L/yCEjo8NJozS6x2+gUvhMxmrvmHqmDwJSw2/oQ5L9yzhvDMKA5njpFTlQG+f5a8k1ljaHesUwAVtlO7FvVKsnrv0xNx20dAWBXJCE+8mOAvQ9yDnHMgcgYoPvpj710/Mar967D7WzGhLAA==
x-ms-office365-filtering-correlation-id: 7c65014b-7e56-439f-13e6-08d6901ff8ea
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:SL2PR04MB3081;
x-ms-traffictypediagnostic: SL2PR04MB3081:
x-ld-processed: 0423909d-296c-463e-ab5c-e5853a518df8,ExtAddr
x-microsoft-antispam-prvs:
 <SL2PR04MB3081BF8066CDDC2AB434F6EF91640@SL2PR04MB3081.apcprd04.prod.outlook.com>
x-forefront-prvs: 0945B0CC72
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10019020)(376002)(346002)(396003)(136003)(366004)(39860400002)(189003)(199004)(7736002)(81166006)(50226002)(478600001)(8676002)(105586002)(8936002)(66066001)(81156014)(106356001)(1076003)(78486014)(305945005)(14454004)(71190400001)(71200400001)(2906002)(1511001)(36756003)(316002)(110136005)(54906003)(2501003)(2201001)(97736004)(6512007)(52116002)(6506007)(386003)(68736007)(14444005)(53936002)(44832011)(6436002)(6486002)(25786009)(2616005)(86362001)(486006)(476003)(4326008)(186003)(26005)(102836004)(6116002)(3846002)(99286004)(256004)(107886003)(55236004);DIR:OUT;SFP:1102;SCL:1;SRVR:SL2PR04MB3081;H:SL2PR04MB3323.apcprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: oneplus.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 gzrSjnqTGsVAnhqe1tdFAfesnV4ccZDXA9iJSju8P4lpVqDSjSXk0wT2MrC1BPZRBS71M+ipLB+UfGTnsFDv+mucHJ+c3TGD+ODMNcFDAyoxZwZ95Rzr4TtvTTyc7/zRP4WThFwRf6HMbqA6waCeYQW9GdCWB4FogHjADyPtle0xar62ZbTVzGnXbgs7jbvn5mwtaX5d3ygAzthUKT/VNS8G03u/eVScK6/NzAL9rJeLCOzTgO1GJYBk7UiXBi8WGxBuckNkCulH8CxSlZ5E8skK3pm3ZH4zmSzckxS9Zcp386g1p1X/cJjSuyMnSYkh8BY44MWYggQv5W9Z6RIuD8q5TfpmcCVkGQ15juVGzVR0c9pM0yKISX1sLVgOY6h5ZTHkXsfGW/3+B87lMu6j+zGoXvteSquFnnaSPKfryzI=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: oneplus.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 7c65014b-7e56-439f-13e6-08d6901ff8ea
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Feb 2019 12:53:50.0069
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

In 4.14 kernel, observed following 2 BUG_ON(!PageLocked(page)) scenarios.
Both looks to be having similar cause.

Case: 1
[127823.176076] try_to_free_buffers+0xfc/0x108 (BUG_ON(), page lock was fre=
ed
                                               somehow)
[127823.176079] jbd2_journal_try_to_free_buffers+0x15c/0x194 (page lock was
                                              available till this function)
[127823.176083] ext4_releasepage+0xe0/0x110=20
[127823.176087] try_to_release_page+0x68/0x90 (page lock was available till
                                              this function)
[127823.176090] invalidate_inode_page+0x94/0xa8
[127823.176093] invalidate_mapping_pages_without_uidlru+0xec/0x1a4 (page lo=
ck
                                              taken here)
...
...

Case: 2
[<ffffff9547a82fb0>] el1_dbg+0x18
[<ffffff9547bfb544>] __remove_mapping+0x160  (BUG_ON(), page lock is not
                                             available. Some one might have
                                             free'd that.)
[<ffffff9547bfb3c8>] remove_mapping+0x28
[<ffffff9547bf8404>] invalidate_inode_page+0xa4
[<ffffff9547bf8bcc>] invalidate_mapping_pages+0xd4  (acquired the page lock=
)
[<ffffff9547c7f934>] inode_lru_isolate+0x128
[<ffffff9547c1b500>] __list_lru_walk_one+0x10c
[<ffffff9547c1b3e0>] list_lru_walk_one+0x58
[<ffffff9547c7f7d4>] prune_icache_sb+0x50
[<ffffff9547c64fbc>] super_cache_scan+0xfc
[<ffffff9547bfb17c>] shrink_slab+0x304
[<ffffff9547bffb38>] shrink_node+0x254
[<ffffff9547bfd4fc>] do_try_to_free_pages+0x144
[<ffffff9547bfd2d8>] try_to_free_pages+0x390
[<ffffff9547bebb80>] __alloc_pages_nodemask+0x940
[<ffffff9547becedc>] __get_free_pages+0x28
[<ffffff9547cd6870>] proc_pid_readlink+0x6c
[<ffffff9547c7075c>] vfs_readlink+0x124
[<ffffff9547c66374>] SyS_readlinkat+0xc8
[<ffffff9547a83818>] __sys_trace_return+0x0

Both the scenarios say that current stack tried taking page lock but got
released in meantime by someone else. There could be 2 possiblities here.

1) Someone trying to update page flags and due to race condition, PG_locked
   bit got cleared, unwantedly.
2) Someone else took the lock without checking if it is really locked or no=
t
   as there are explicit APIs to set PG_locked.

I didn't get traces of history for having PG_locked being set non-atomicall=
y.
I believe it could be because of performance reasons. Not sure though.

Chintan Pandya (2):
  page-flags: Make page lock operation atomic
  page-flags: Catch the double setter of page flags

 fs/cifs/file.c             | 8 ++++----
 fs/pipe.c                  | 2 +-
 include/linux/page-flags.h | 4 ++--
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
 13 files changed, 23 insertions(+), 23 deletions(-)

--=20
2.17.1

