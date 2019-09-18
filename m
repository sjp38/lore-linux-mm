Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4730FC4CEC4
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 20:31:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0A0121925
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 20:31:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=cisco.com header.i=@cisco.com header.b="AijQqU0d";
	dkim=pass (1024-bit key) header.d=cisco.onmicrosoft.com header.i=@cisco.onmicrosoft.com header.b="l5fpJ8+C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0A0121925
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=cisco.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D1B06B02FF; Wed, 18 Sep 2019 16:31:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67FDE6B0300; Wed, 18 Sep 2019 16:31:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 570846B0301; Wed, 18 Sep 2019 16:31:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0163.hostedemail.com [216.40.44.163])
	by kanga.kvack.org (Postfix) with ESMTP id 32CF46B02FF
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 16:31:27 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id C4D7BAF9B
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 20:31:26 +0000 (UTC)
X-FDA: 75949186572.22.fight06_63d0cd68d252e
X-HE-Tag: fight06_63d0cd68d252e
X-Filterd-Recvd-Size: 13513
Received: from rcdn-iport-9.cisco.com (rcdn-iport-9.cisco.com [173.37.86.80])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 20:31:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=cisco.com; i=@cisco.com; l=4743; q=dns/txt; s=iport;
  t=1568838685; x=1570048285;
  h=from:to:cc:subject:date:message-id:
   content-transfer-encoding:mime-version;
  bh=LxnNVUVCz0IPdS9jM9xgtwfqdBc09223wZEccBl4BYk=;
  b=AijQqU0dPz0JUfQjQqyj9CegTx9BBuISZjrw+z6ja6t4/jjEzBhmCQVq
   3nrKgDTnN9mmgUV0XxVheblWq1zM7VqrbD4YZEVQBT5hwv+IiIQS4oaoi
   N2pCSFM1th1bDoPBR8/HQgpnSh3GSODZKvuTfab4+jTo/7/R8RAevZ4gk
   8=;
IronPort-PHdr: =?us-ascii?q?9a23=3A1BcouBBpnlQHRqpmtDjWUyQJPHJ1sqjoPgMT9p?=
 =?us-ascii?q?ssgq5PdaLm5Zn5IUjD/qs03kTRU9Dd7PRJw6rNvqbsVHZIwK7JsWtKMfkuHw?=
 =?us-ascii?q?QAld1QmgUhBMCfDkiuN/3jdS0/Fc5qX15+9Hb9Ok9QS47z?=
X-IronPort-Anti-Spam-Filtered: true
X-IronPort-Anti-Spam-Result: =?us-ascii?q?A0BIAAC1koJd/4UNJK1jAxwBAQEEAQE?=
 =?us-ascii?q?HBAEBgVMHAQELAYFEJAUnA21WIAQLKgqHXwOEUoYomk+BLoEkA1QJAQEBDAE?=
 =?us-ascii?q?BIwoCAQGBS4J0AoMDIzQJDgIDCQEBBAEBAQIBBQRthS0MhU0WLgEBNwERARZ?=
 =?us-ascii?q?qJgEEAQ0NGoMBgWoDHQECDKVYAoE4iGGCJYF7gQIBAQWBBgEBg3sYghcDBhS?=
 =?us-ascii?q?BIAGMCBiBQD+BEUaFawKBOyhFgnaCJoxziC9elwEKgiKHBY4amSGOEIgPkHs?=
 =?us-ascii?q?CBAIEBQIOAQEFgVI4gVhwFYMnUBAUgU6BJwEIgkKKHAE2c4EpjHqBMAGBIgE?=
 =?us-ascii?q?B?=
X-IronPort-AV: E=Sophos;i="5.64,522,1559520000"; 
   d="scan'208";a="545866713"
Received: from alln-core-11.cisco.com ([173.36.13.133])
  by rcdn-iport-9.cisco.com with ESMTP/TLS/DHE-RSA-SEED-SHA; 18 Sep 2019 20:31:23 +0000
Received: from XCH-RCD-007.cisco.com (xch-rcd-007.cisco.com [173.37.102.17])
	by alln-core-11.cisco.com (8.15.2/8.15.2) with ESMTPS id x8IKVNfx027780
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=FAIL);
	Wed, 18 Sep 2019 20:31:23 GMT
Received: from xhs-aln-003.cisco.com (173.37.135.120) by XCH-RCD-007.cisco.com
 (173.37.102.17) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 18 Sep
 2019 15:31:23 -0500
Received: from xhs-aln-002.cisco.com (173.37.135.119) by xhs-aln-003.cisco.com
 (173.37.135.120) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 18 Sep
 2019 15:31:21 -0500
Received: from NAM05-DM3-obe.outbound.protection.outlook.com (173.37.151.57)
 by xhs-aln-002.cisco.com (173.37.135.119) with Microsoft SMTP Server (TLS) id
 15.0.1473.3 via Frontend Transport; Wed, 18 Sep 2019 15:31:21 -0500
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=IRz7kpwuzrIbgDdJ5bhJuZPn48h2REMSImNyYRceRLWQz+65S8jpve7vqdRZa8/5KtaYmW8qDuVbN/+0FoEGyI4GdW4osCi/jG7zAjjX+FhbmvmkJYXyDMO0RHae/WumrYeOEFTkWEGiObgli8A04St2JAeqiBci/d7qzVvXdzWcE72cHo0FCdBeYza6rHJO0ND6jxmdLDgdepjMzErk78+gK7Ha6ZFSMihCSYFUZblRpdKSFDSeE0molWoBwRRMClz4GmzXgHgH5m+GZGm4A0nXm7OYy4sVUZ2qPgtAKUJ3LtQ5xnzz50I3wS46RTd3XHQZxiOYweDiYA2K5/whzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=moEkA7k1mqq/7L8BFws/Gd/FMO/o8Xo4Sf0FoV4RrFs=;
 b=eg+nwhHtEdNFQXJ3xEC7bjoWt02bFtmItJa5Eeslmk+U2+LPuAzxc2jYV0KC3TIfVtotp+3LNH1nOV12rvl9OB7thSHXfZq6ibwxZigW7i4vaVc6GErtCmU2Tg9NDqfWmukO07n6ifZtT20aH25bCmtv1CvPPiZw3vSc42OaQBDKa8PW0/sglyNrV/9QU6a45HGEnsRDjTpUYApHfe4lA629qOgw7WnIibhZGSG3kyGua3j5zIJ2eQqh1XdhB67/5lsVfmSWSyk1cJAdIM/h5uW5KApCICDR7uPIniK9ERahjtsOt4G4GoeEMuZic89Am2u361+0PAU6DonP52DiNA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=cisco.com; dmarc=pass action=none header.from=cisco.com;
 dkim=pass header.d=cisco.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=cisco.onmicrosoft.com;
 s=selector2-cisco-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=moEkA7k1mqq/7L8BFws/Gd/FMO/o8Xo4Sf0FoV4RrFs=;
 b=l5fpJ8+C5bcjkP0/rAsj0Eagi1DilDedjSKXsISyVJNOWu3juSXBP1TNxD7oW6IeVV0OtWzfXD7pskcvKAQwC9UaF7t/izJzRySmwdJktWv0hFapU7W3aAvJ4NRooZUvTFBlTeDeTlDqFo9A4oc8uXZYK0E59eapb4iGzkCPA6E=
Received: from BYAPR11MB2582.namprd11.prod.outlook.com (52.135.229.149) by
 BYAPR11MB3815.namprd11.prod.outlook.com (20.178.239.89) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2284.20; Wed, 18 Sep 2019 20:31:18 +0000
Received: from BYAPR11MB2582.namprd11.prod.outlook.com
 ([fe80::29b5:ea68:50:df31]) by BYAPR11MB2582.namprd11.prod.outlook.com
 ([fe80::29b5:ea68:50:df31%7]) with mapi id 15.20.2284.009; Wed, 18 Sep 2019
 20:31:18 +0000
From: "Saeed Karimabadi (skarimab)" <skarimab@cisco.com>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
        David
 Rientjes <rientjes@google.com>,
        Joonsoo Kim <iamjoonsoo.kim@lge.com>,
        Andrew
 Morton <akpm@linux-foundation.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>, Tejun Heo <tj@kernel.org>,
        Li Zefan
	<lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>,
        "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
        Johannes Weiner
	<hannes@cmpxchg.org>,
        Michal Hocko <mhocko@kernel.org>,
        Vladimir Davydov
	<vdavydov.dev@gmail.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>
CC: "xe-linux-external(mailer list)" <xe-linux-external@cisco.com>
Subject: CGroup unused allocated slab objects will not get released 
Thread-Topic: CGroup unused allocated slab objects will not get released 
Thread-Index: AdVuYAXsyqrfLm5yRGqVq9iRkUoA5Q==
Date: Wed, 18 Sep 2019 20:31:18 +0000
Message-ID: <BYAPR11MB2582482E28ACA901B35AF777CC8E0@BYAPR11MB2582.namprd11.prod.outlook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-Auto-Response-Suppress: DR, OOF, AutoReply
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=skarimab@cisco.com; 
x-originating-ip: [128.107.241.181]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: ea6e79d9-1b7a-4885-6ac6-08d73c772949
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600167)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR11MB3815;
x-ms-traffictypediagnostic: BYAPR11MB3815:|BYAPR11MB3815:
x-ms-exchange-purlcount: 1
x-ld-processed: 5ae1af62-9505-4097-a69a-c1553ef7840e,ExtAddr
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs: <BYAPR11MB3815426EDABDC0EDC3D65517CC8E0@BYAPR11MB3815.namprd11.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 01644DCF4A
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(4636009)(366004)(136003)(346002)(39860400002)(396003)(376002)(199004)(189003)(186003)(6506007)(102836004)(4743002)(86362001)(476003)(2501003)(33656002)(66446008)(64756008)(66556008)(66476007)(76116006)(66946007)(8936002)(81166006)(81156014)(8676002)(3846002)(52536014)(486006)(5660300002)(316002)(2906002)(99286004)(7696005)(110136005)(6116002)(7736002)(6436002)(25786009)(256004)(478600001)(14454004)(66066001)(26005)(9686003)(966005)(74316002)(107886003)(4326008)(55016002)(6306002)(71200400001)(71190400001)(7416002)(305945005)(921003)(1121003);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR11MB3815;H:BYAPR11MB2582.namprd11.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: cisco.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: l4woOXWNscUJQN7t9w183bJg8q4Y7ABeGWv1kRYMdUHTQlEAeR1uLEDixywE7SXVQ9K8G9N0gCdc8mN99fUwQbH3KKLE0LbRsl1Ll9rKCqn5FES7bpYIa+yPKAx94SPoj1jLv+t/fIYgXuUDhGG4kkYCtSBWorqxQBTEc4AKhq1r9eEzRzAhR4pP/uUBk3k9AHNBOQgNq6N/h1p+upIDwAeRELbPa/sP7Wm5vYgNx4IVGDhZHdO53QR9tWosKmnirbY85oE5yeHxr3DqwqgHJ+Q5vnTdAs1YZ2MhmnyAYnk5z2GuV4U8GKoggvQpfUu60YtoKtCZokEOYHCSI4AJBsvLiqgp5gNvQrkaxFsX51Qlzsxc9Znw4fGnlXGSlnluRSsnon+gOguLFiSoaMrU124cjw/oMb9KTgctx+4Bi70=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: ea6e79d9-1b7a-4885-6ac6-08d73c772949
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Sep 2019 20:31:18.5737
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 5ae1af62-9505-4097-a69a-c1553ef7840e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: byUh7KmPcGeJbzNLCT5BBMlTGey/A6veApT4G+/WnxUQLFVQC17xF/taW1YZ/96aFRTW96fopdV5nZASTEh1Xg==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR11MB3815
X-OriginatorOrg: cisco.com
X-Outbound-SMTP-Client: 173.37.102.17, xch-rcd-007.cisco.com
X-Outbound-Node: alln-core-11.cisco.com
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi =A0Kernel Maintainers,

We are chasing an issue where slab allocator is not releasing task_struct s=
lab objects allocated by cgroups=20
and we are wondering if this is a known issue or an expected behavior ?
If we stress test the system and spawn multiple tasks with different cgroup=
s, number of active allocated=20
task_struct objects will increase but kernel will never release those memor=
y later on, even though if system=20
goes to the idle state with lower number of the running processes.
To test this, we have prepared a bash script that would create 1000 cgroups=
 and it will spawn 100,000 bash=20
tasks. The full script and its test result is available on github :
=A0=A0=20
https://github.com/saeedsk/slab-allocator-test

Here is a quick snapshot of the test result before and after running multip=
le concurrent tasks with different cgroups:

------------- system initial statistics -------------
Slab:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 419196 kB
SReclaimable:=A0=A0=A0=A0 123788 kB
SUnreclaim:=A0=A0=A0=A0=A0=A0 295,408 kB
# name=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 <active_objs> <num_objs> <objsize> =
<objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor>=
=20
		: slabdata <active_slabs> <num_slabs> <sharedavail>
task_struct=A0=A0=A0=A0=A0=A0=A0=A0=A0 735=A0=A0=A0 990=A0=A0 5888=A0=A0=A0=
 5=A0=A0=A0 8 : tunables=A0=A0=A0 0=A0=A0=A0 0=A0=A0=A0 0 : slabdata=A0=A0=
=A0 198=A0=A0=A0 198=A0=A0=A0=A0=A0 0
Number of running processes before starting the test : 334

...... loading 100,000 time bounded tasks with 1000 mem cgroups ...........=
...=20
..... wait until are tasks are complete , normally within next 5 seconds ..=
......

------------- after tasks are loaded and completed running  -------------
Slab:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 948932 kB
SReclaimable:=A0=A0=A0=A0 125816 kB
SUnreclaim:=A0=A0=A0=A0=A0=A0 823,116 kB
# name=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 <active_objs> <num_objs> <objsize> =
<objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor>=
=20
		: slabdata <active_slabs> <num_slabs> <sharedavail>
task_struct=A0=A0=A0=A0=A0=A0=A0 11404=A0 11665=A0=A0 5888=A0=A0=A0 5=A0=A0=
=A0 8 : tunables=A0=A0=A0 0=A0=A0=A0 0=A0=A0=A0 0 : slabdata=A0=A0 2333=A0=
=A0 2333=A0=A0=A0=A0=A0 0
Number of running processes when the test is completed : 334

As it is shown above, number of active task_struct slabs has been increased=
 from 736 to 11404 objects=20
during the test. System keeps 11404 task_struct objects in the idle time wh=
ere only 334 tasks is running.=20
This huge number of active task_struct slabs it is not normal and a huge fr=
action of that memory can be -
released to system memory pool. If we write to slab's shrink systf entry, t=
hen kernel will release deactivated
objects and it will free up the related memory, but it is not happening aut=
omatically by kernel as it was=20
expected.

Following line is the command that would release those zombie objects:
# for file in /sys/kernel/slab/*; do echo 1 > $file/shrink; done

We know that some of slab caches are supposed to remain allocated until sys=
tem really need that memory.=20
So in one test we tried to consume all available system memory in a hope th=
at kernel would release the above=20
Memory but it didn't happened and "out of memory killer" started killing pr=
ocesses and no memory got released=20
by kernel slab allocator.

In recent systemd releases, CGroup memory accounting has been enabled by de=
fault and systemd will=20
create multiple cgroups to run different software daemons. Although we have=
 called this test as=20
an stress test but this situation may happen in normal system boot time whe=
re systemd is trying
to load and run multiple instances of programs daemons with different cgrou=
ps.
This issue only manifest itself when cgroup are actively in use. I've confi=
rmed that this issue is present
 in Kernel V4.19.66, Kernel V5.0.0 (Ubuntu 19.04) and latest Kernel Release=
 V5.3.0.
Any comment and or hint would be greatly appreciated.
Here is some related kernel configuration while this test were done:

$ grep SLAB  .config
# CONFIG_SLAB is not set
CONFIG_SLAB_MERGE_DEFAULT=3Dy
# CONFIG_SLAB_FREELIST_RANDOM is not set
# CONFIG_SLAB_FREELIST_HARDENED is not set

#grep SLUB  .config
CONFIG_SLUB_DEBUG=3Dy
# CONFIG_SLUB_MEMCG_SYSFS_ON is not set
CONFIG_SLUB=3Dy
CONFIG_SLUB_CPU_PARTIAL=3Dy
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set

$ grep KMEM  .config
CONFIG_MEMCG_KMEM=3Dy
# CONFIG_DEVKMEM is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=3Dy
# CONFIG_DEBUG_KMEMLEAK is not set

Thanks,
Saeed Karimabadi
Cisco Systems Inc.




