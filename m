Return-Path: <SRS0=dqyo=XC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CB68C43331
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 07:34:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F28D4208C3
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 07:34:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="T+LrT0pd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F28D4208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A05E66B0005; Sat,  7 Sep 2019 03:34:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 98E756B0006; Sat,  7 Sep 2019 03:34:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82EA16B0007; Sat,  7 Sep 2019 03:34:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0217.hostedemail.com [216.40.44.217])
	by kanga.kvack.org (Postfix) with ESMTP id 5C6A26B0005
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 03:34:04 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id CF7C9180AD801
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 07:34:03 +0000 (UTC)
X-FDA: 75907310766.21.ray16_5d9471d11b412
X-HE-Tag: ray16_5d9471d11b412
X-Filterd-Recvd-Size: 7728
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-eopbgr140048.outbound.protection.outlook.com [40.107.14.48])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 07:34:02 +0000 (UTC)
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=BHD3uG64S8zJ7grknWDzq5vVgR86UZpVUwkeToTKAxg65vkXxuWDLB+e45JHb2pPEPXbI8xoo2jrJ3b7SOIiGTqCW8vKDg5zWz5Ziq1ReFqhnEEIiJg+tFWUXg0lsFdbvYTAOylggAgqcaS4ES4w2RNAN48FWlmExqZyQcXCWnYhTq/oOgprBpxu3OIRsufztanPHT5+5MWzqE8gUsOSMR0TG8t2bLGtMsfGzeYhOPKwyjuOBYa6vjgUdmfpBDodIQH5rA4xxarOk35aeozZVorKF4OIxT3GLoyAuNp1DocwHxx5C35UFC8LIGtmt5c13mcQSMpALZZjG16rAQZ1Eg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=t28VnZpg/4wf8ynM/+VJ5erdvV115Bv02il+8gotWqs=;
 b=RyrftaJ+J20bSo6pZ07WVzTNvQKhQXbbE+wdLplPZru8fyexec4ySJ8bU5tbNX7QqcCvs/yR16Mlg0nbvxksEu9ri/pLoSbh/VLvojDlN1U6PqwU8v5AWWCUWD/60/oQaDmszUwfNoUjEZxBF0n6filrfwGucQWkyQHaOCN//sPVDbSRXsbqVrHUPFTzSBVd95RYgep8Vgc4EBThfgObORJ/RjC/Pd37JCtSBNzAFJZ6SC1tgCiQnzDwDI7Dba5U+FVmL2+AyyFj0BMjAvYdDcHqb9IR/LLCK5X5b1TinWsgdOqNYAJRzkX8hP7+QgSghkMBEsbzmEQ6me8oLprLdQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=mellanox.com; dmarc=pass action=none header.from=mellanox.com;
 dkim=pass header.d=mellanox.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=t28VnZpg/4wf8ynM/+VJ5erdvV115Bv02il+8gotWqs=;
 b=T+LrT0pdtjSJ3YY7PeF7tJCnR3j421q2ZFFUDPwI7SIkGko4XR0sTEnYz667u0HQkgmeFxTs1oLKWv18SoXlZivZkHHzg0Equjb2Kpce0o39Y0OOhEN/aIMud4Az5GbQv7VRepBNecaWIipgPm56vVVYZ60PN1Uud9YhSIQisUY=
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com (10.171.182.144) by
 VI1PR05MB6160.eurprd05.prod.outlook.com (20.178.123.90) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2241.15; Sat, 7 Sep 2019 07:33:58 +0000
Received: from VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::79a3:d971:d1f3:ab6f]) by VI1PR05MB4141.eurprd05.prod.outlook.com
 ([fe80::79a3:d971:d1f3:ab6f%7]) with mapi id 15.20.2220.022; Sat, 7 Sep 2019
 07:33:58 +0000
From: Jason Gunthorpe <jgg@mellanox.com>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
CC: LKML <linux-kernel@vger.kernel.org>, DRI Development
	<dri-devel@lists.freedesktop.org>,
	"syzbot+aaedc50d99a03250fe1f@syzkaller.appspotmail.com"
	<syzbot+aaedc50d99a03250fe1f@syzkaller.appspotmail.com>, Daniel Vetter
	<daniel.vetter@intel.com>, Andrew Morton <akpm@linux-foundation.org>,
	=?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, Ralph Campbell
	<rcampbell@nvidia.com>, Ira Weiny <ira.weiny@intel.com>, Michal Hocko
	<mhocko@suse.com>, Sean Christopherson <sean.j.christopherson@intel.com>,
	Jean-Philippe Brucker <jean-philippe@linaro.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>
Subject: Re: [PATCH] mm, notifier: Fix early return case for new lockdep
 annotations
Thread-Topic: [PATCH] mm, notifier: Fix early return case for new lockdep
 annotations
Thread-Index: AQHVZNssp1bwyLm3pUuFKcXxTfYpMqcf036A
Date: Sat, 7 Sep 2019 07:33:58 +0000
Message-ID: <20190907073355.GA3873@mellanox.com>
References: <20190906174730.22462-1-daniel.vetter@ffwll.ch>
In-Reply-To: <20190906174730.22462-1-daniel.vetter@ffwll.ch>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: LO2P123CA0018.GBRP123.PROD.OUTLOOK.COM
 (2603:10a6:600:a6::30) To VI1PR05MB4141.eurprd05.prod.outlook.com
 (2603:10a6:803:4d::16)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=jgg@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [81.218.143.71]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 1ff8079b-45af-404f-6b9f-08d73365be8a
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600166)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:VI1PR05MB6160;
x-ms-traffictypediagnostic: VI1PR05MB6160:
x-microsoft-antispam-prvs:
 <VI1PR05MB61608D88A6DEA6767F6F5B8BCFB50@VI1PR05MB6160.eurprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 0153A8321A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(136003)(39860400002)(346002)(376002)(366004)(396003)(189003)(199004)(66946007)(316002)(54906003)(66446008)(64756008)(33656002)(2906002)(6116002)(66476007)(3846002)(66556008)(14454004)(99286004)(86362001)(7416002)(305945005)(1076003)(8676002)(478600001)(52116002)(7736002)(14444005)(71200400001)(256004)(71190400001)(81166006)(66066001)(6436002)(26005)(2616005)(6512007)(476003)(486006)(186003)(102836004)(4326008)(446003)(11346002)(386003)(6486002)(76176011)(229853002)(6506007)(25786009)(8936002)(5660300002)(36756003)(53936002)(6246003)(6916009)(81156014);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR05MB6160;H:VI1PR05MB4141.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 3dsB2eVoC1g2cNY6O/8Rremf9AkuM2kF2SLL7nS95dMg8FK4Bdt2aNIR6UJlzuB88xl6/vkzAdoqJgqEWy/WJt/kg85g4Aw2B+m2LpO8Ypsvp2mtEcq8q29mCYMQkKpF0vrDVhWJFa/ytCR8FSiIWJn0gLrVUjbhpsmFS/0nsZDWIH1YStyYb94xcfGb1Vy4Hxe5zM6dzVrxZyN792Z37v6cFH+DVqh5R9UMuyl/5ZBUbFzCSnVS1gzAmu+OC9zSaIVcR+KPxSQoDzBLSlpmVCCbPmViDK9Z67+fNbxKERWKHkgKDFFveYrk3GJNYsd9knOI7EVUsMC1r2JbTNaWZm2IcBDBy3eproIUSzmHDiXvSvXiSlMVBuvdKhH07jnoS469Yt+/oEV1/jyhbTbI6mEsLFURLSh/vuOxYYZEDkk=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <5E3C899ACA82F04791826B13EDEB3254@eurprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 1ff8079b-45af-404f-6b9f-08d73365be8a
X-MS-Exchange-CrossTenant-originalarrivaltime: 07 Sep 2019 07:33:58.5975
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: aksp3MTsVJn3W5EHCDyn/P0JIgkYL9MnNd5UPmxm/2QraF9VQXm5WoO2GTUoAvMpqMOIhWQZthKTacSr4KrhOA==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR05MB6160
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 06, 2019 at 07:47:30PM +0200, Daniel Vetter wrote:

> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> index 5a03417e5bf7..4edd98b06834 100644
> +++ b/include/linux/mmu_notifier.h
> @@ -356,13 +356,14 @@ mmu_notifier_invalidate_range_start(struct mmu_noti=
fier_range *range)
>  static inline int
>  mmu_notifier_invalidate_range_start_nonblock(struct mmu_notifier_range *=
range)
>  {
> +	int ret =3D 0;
>  	lock_map_acquire(&__mmu_notifier_invalidate_range_start_map);
>  	if (mm_has_notifiers(range->mm)) {
>  		range->flags &=3D ~MMU_NOTIFIER_RANGE_BLOCKABLE;
> -		return __mmu_notifier_invalidate_range_start(range);
> +		ret =3D __mmu_notifier_invalidate_range_start(range);
>  	}
>  	lock_map_release(&__mmu_notifier_invalidate_range_start_map);
> -	return 0;
> +	return ret;

Gar, yes. Since nobody has grabbed hmm.git I've squashed this into the
original patch and fixed the checkpatch warning about missing line
after the ret

Everything should be in linux-next the next time it builds

Thanks,
Jason

