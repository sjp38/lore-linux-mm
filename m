Return-Path: <SRS0=K2Kt=QQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BE8CC282C4
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 03:42:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9007C20869
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 03:42:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="QXADtuH/";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="GD5OvFaS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9007C20869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA20A8E00AE; Fri,  8 Feb 2019 22:42:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D51188E00AD; Fri,  8 Feb 2019 22:42:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C40E68E00AE; Fri,  8 Feb 2019 22:42:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9B56C8E00AD
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 22:42:45 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id n95so5832588qte.16
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 19:42:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=f9oA2LbLNWpkczbTyDOtl3kXpJBnp+RAj1oKWYbirls=;
        b=YWp5w37pIMCL/qbUhEbhe1T09RmniD4OH8HqMhj6QuvKVjc7urv0dPoUAPiymHelUI
         KtdNtZgndh/SyqY9O9q5e2AF+WxlwDYrr4L57AnLVF6SS7PBralBfymfAtzj2L0cnpxN
         jn56ANTRRT9kLKh/9NEajqdZ+L+f+TKuiQjmciqmeNkmb4B0up386CW9SWKbP9hrWBpN
         IWu3ZFj8gOLpJdF2LJWgvCwNUnLv4qm46S/S7avz6UDmFUdqKdVYDO6SyL8O+p24DYz8
         B3qJ1f6taVwNM7b4YGZp88UWbd3s+W50CaOjImp85gAWc34OeTvQXYZO7Re4IiYPr68R
         UyAg==
X-Gm-Message-State: AHQUAuYpsoeLiloZrmUrueyZz1UsoZBDcPi6Iv8zsGlkwbQHzxeTkQ5h
	vGZig/o/lATmNtCA3igZILm9Z0fhKY42mDXITsHHiTqpBaFogqTe1D0+/YjN5mr1EYO1SdG3iSi
	zpPvVoWnVJ2YGife7vSH3UuzxYQiNKwPWc04YF3wMHfx+MeS3+VLT2m5y5SCFNg1igw==
X-Received: by 2002:a37:d106:: with SMTP id s6mr18156047qki.105.1549683763818;
        Fri, 08 Feb 2019 19:42:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZa9tSFjPqw/J6X/W3FIyyjUFWWgdCwPrHelmqqqxKdRvYk5EHgwd8kl3MuxFP9LYhN1UTU
X-Received: by 2002:a37:d106:: with SMTP id s6mr18155968qki.105.1549683761281;
        Fri, 08 Feb 2019 19:42:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549683761; cv=none;
        d=google.com; s=arc-20160816;
        b=EON937MSy9NbzyxdcFm/wSe87s4SO+q+gzaeHgZJZ+WePXa/YDsAcU5BIB/c66ngCN
         7KEFYYIFNfQBueGVh6Jod14T/o98xRGNCYHQ00bAE51JSAVaDhwODtL66/7X6fPFpxoX
         aQRYXw8Ypx0uRV8JQfdAp222RRfyocNbQHzgDyrtUny8ZmIU68bt2uH7Aumj6Rqpq8m7
         7FDDiiNFQxhS+oFVthp5Onr0vu11E53K0u5zF1q7ZZ7bD0j9KnlBlyj4J/JV1luX/YVZ
         YaC9yejXhUdl9w1tYYa+BaSHeHWkR3rXCaoepTxJVhtl+u1imYbGA+p/cU2AZKdlDZwi
         Cn7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=f9oA2LbLNWpkczbTyDOtl3kXpJBnp+RAj1oKWYbirls=;
        b=kfZ80As8iVHg3557UXUjvfkivqL/uJ+YUsgEYVIf9EgEqkzQq04gVd/U6rHglAN+zt
         lS+TGjqyMY5FJw1f+Cj0kgOZ1JeeA9oDelhH7dIa4axejfhIN5gyCj5uZaixG7Axh8SZ
         2rG1qBoTGBTakew7AGc73re6ZlBC90gS6O0RfTcNMnWPdjltVDWgWpI/qgVObsoF6HjL
         4xhihXRbK/irg4VzhbM1I+EDnoaxzcAPLVCheHBlKDVILJwekQ6wPAvj4EUfgm4DYKtK
         MBQKmm9BBS/K52/veKTDM4RKUa2hiXrAjtzPFUv1B2lHIKeOqZLueg5yTGw3cw7gyPQh
         P7RQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="QXADtuH/";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=GD5OvFaS;
       spf=pass (google.com: domain of prvs=79438cf530=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=79438cf530=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id a2si2917082qtg.254.2019.02.08.19.42.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 19:42:41 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=79438cf530=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="QXADtuH/";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=GD5OvFaS;
       spf=pass (google.com: domain of prvs=79438cf530=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=79438cf530=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x193cOTl030111;
	Fri, 8 Feb 2019 19:42:34 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=f9oA2LbLNWpkczbTyDOtl3kXpJBnp+RAj1oKWYbirls=;
 b=QXADtuH/VSOWAF+5DDbiQJwgiMxQSOGhr+6D1Nfr0YZCQGV7T8qnRrKKl9FTAVPapZIG
 tG4QWREl28xewjiRHqTIYJRt4jaoEpkUFFyocxiHIQpryQ1+UHgJ+yAHXQPx3Cqja9gW
 yZ07GOB+kV686CIKENPVd8wSf5DMAiZraRk= 
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qhnea066c-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Fri, 08 Feb 2019 19:42:34 -0800
Received: from prn-mbx07.TheFacebook.com (2620:10d:c081:6::21) by
 prn-hub05.TheFacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Fri, 8 Feb 2019 19:42:33 -0800
Received: from prn-hub01.TheFacebook.com (2620:10d:c081:35::125) by
 prn-mbx07.TheFacebook.com (2620:10d:c081:6::21) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Fri, 8 Feb 2019 19:42:33 -0800
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.25) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Fri, 8 Feb 2019 19:42:33 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=f9oA2LbLNWpkczbTyDOtl3kXpJBnp+RAj1oKWYbirls=;
 b=GD5OvFaSpEYJU5C0sOb70fKAZ+5A9qwqGysYKZ7Wf8yoPndfT3ZuBK8M7TYt2ViBcwqmnyHHgg1hLuFRRwHIUjdB3VcGMpPfCAGh+KCmFFVfK3NdjCM4u9qyHLl/BSvi254zbzeDrYRKaqAMCkikcmkfcD9yM8WfjiYEW8gKUFo=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3112.namprd15.prod.outlook.com (20.178.239.139) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.17; Sat, 9 Feb 2019 03:42:31 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92%3]) with mapi id 15.20.1601.016; Sat, 9 Feb 2019
 03:42:31 +0000
From: Roman Gushchin <guro@fb.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>,
        Michal Hocko
	<mhocko@kernel.org>, Chris Mason <clm@fb.com>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>,
        "linux-xfs@vger.kernel.org"
	<linux-xfs@vger.kernel.org>,
        "vdavydov.dev@gmail.com"
	<vdavydov.dev@gmail.com>
Subject: Re: [PATCH 1/2] Revert "mm: don't reclaim inodes with many attached
 pages"
Thread-Topic: [PATCH 1/2] Revert "mm: don't reclaim inodes with many attached
 pages"
Thread-Index: AQHUuFKyWLaITMbS90mKhttYYyCJLqXHu+eAgADdi4CAAH9ygIAAHdwAgAC+jQCACjmaAIABQTOAgABH/oCAADEXgIAAp1YAgABRyYA=
Date: Sat, 9 Feb 2019 03:42:30 +0000
Message-ID: <20190209034223.GA2591@castle.DHCP.thefacebook.com>
References: <25EAF93D-BC63-4409-AF21-F45B2DDF5D66@fb.com>
 <20190131013403.GI4205@dastard> <20190131091011.GP18811@dhcp22.suse.cz>
 <20190131185704.GA8755@castle.DHCP.thefacebook.com>
 <20190131221904.GL4205@dastard> <20190207102750.GA4570@quack2.suse.cz>
 <20190207213727.a791db810341cec2c013ba93@linux-foundation.org>
 <20190208095507.GB6353@quack2.suse.cz>
 <20190208125049.GA11587@quack2.suse.cz>
 <20190208144944.082a771e84f02a77bad3e292@linux-foundation.org>
In-Reply-To: <20190208144944.082a771e84f02a77bad3e292@linux-foundation.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BYAPR07CA0092.namprd07.prod.outlook.com
 (2603:10b6:a03:12b::33) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::1:db87]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;BYAPR15MB3112;20:856hCyX4fJdMdWcIzpwY+PDNB1XYpsu70rELFTwp/wBEU2Ks+XNSQySv+jcKC57i4BA3Hq654Z/vkn+h3gjaxTlk7eOOevC1eJa9LClIVhofqBeezzyJ14mTwBBII+h2gNZSoS54xlGy/rkW2yDRxqcPg7KLnOavuBZLaoATEIo=
x-ms-office365-filtering-correlation-id: 7b6751be-f96e-4da0-915a-08d68e409e57
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB3112;
x-ms-traffictypediagnostic: BYAPR15MB3112:
x-microsoft-antispam-prvs: <BYAPR15MB311218F81DB0959FAF368AD8BE6A0@BYAPR15MB3112.namprd15.prod.outlook.com>
x-forefront-prvs: 09435FCA72
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(136003)(376002)(39860400002)(346002)(366004)(199004)(189003)(97736004)(8676002)(106356001)(229853002)(6436002)(6116002)(446003)(4326008)(81166006)(11346002)(81156014)(8936002)(186003)(6916009)(6512007)(9686003)(256004)(478600001)(5024004)(14444005)(6486002)(68736007)(105586002)(33656002)(14454004)(386003)(46003)(33896004)(53936002)(99286004)(25786009)(6506007)(76176011)(71200400001)(52116002)(102836004)(71190400001)(93886005)(486006)(2906002)(6246003)(86362001)(476003)(305945005)(7736002)(316002)(54906003)(1076003);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3112;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: vjLKh+N40P1WdqiNyE8of39w7Fj7AloVFPIWXny4F4Bxt3tBLR2Xpt5ToNi7IX9iSmjLGFV9+nrrzTqABJ3aEoxUTvC0/Ik0YusttJ1zcX0k4+nO+7nmMHJG/mVgLqMxNBvxoHBYPDa+549BGULswJFH+2QcxqgFgJrhKoOzy6YkCrWVN5xCIHoLjrxHda1bvOeoePtCeOpw6pP4NT0YJFDqHoxhsFR2CBHnbYidd2XAzVPm307n9vHSWTVh2ZpPKqOabRMxCD4xkDNqIgCzYzV2MW/5JfFf7jA6Or1C/bFTOP3odhJyaysVm3y/WVkzhl9oYwss5vzzUl4TMNpBVEMKd2AwDSzBvpCGvbrVbFZ++TJrwfqakQYAEbfp4rDBc9SgdFi5/vRlLZ+cliKv7peogm+v0KUXA59WeL66VIM=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <732A74A8901BE749BECB4649E223D905@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 7b6751be-f96e-4da0-915a-08d68e409e57
X-MS-Exchange-CrossTenant-originalarrivaltime: 09 Feb 2019 03:42:29.8119
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3112
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-09_03:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 08, 2019 at 02:49:44PM -0800, Andrew Morton wrote:
> On Fri, 8 Feb 2019 13:50:49 +0100 Jan Kara <jack@suse.cz> wrote:
>=20
> > > > Has anyone done significant testing with Rik's maybe-fix?
> > >=20
> > > I will give it a spin with bonnie++ today. We'll see what comes out.
> >=20
> > OK, I did a bonnie++ run with Rik's patch (on top of 4.20 to rule out o=
ther
> > differences). This machine does not show so big differences in bonnie++
> > numbers but the difference is still clearly visible. The results are
> > (averages of 5 runs):
> >=20
> > 		 Revert			Base			Rik
> > SeqCreate del    78.04 (   0.00%)	98.18 ( -25.81%)	90.90 ( -16.48%)
> > RandCreate del   87.68 (   0.00%)	95.01 (  -8.36%)	87.66 (   0.03%)
> >=20
> > 'Revert' is 4.20 with "mm: don't reclaim inodes with many attached page=
s"
> > and "mm: slowly shrink slabs with a relatively small number of objects"
> > reverted. 'Base' is the kernel without any reverts. 'Rik' is a 4.20 wit=
h
> > Rik's patch applied.
> >=20
> > The numbers are time to do a batch of deletes so lower is better. You c=
an see
> > that the patch did help somewhat but it was not enough to close the gap
> > when files are deleted in 'readdir' order.
>=20
> OK, thanks.
>=20
> I guess we need a rethink on Roman's fixes.   I'll queued the reverts.

Agree.

I still believe that we should cause the machine-wide memory pressure
to clean up any remains of dead cgroups, and Rik's patch is a step into
the right direction. But we need to make some experiments and probably
some code changes here to guarantee that we don't regress on performance.

>=20
>=20
> BTW, one thing I don't think has been discussed (or noticed) is the
> effect of "mm: don't reclaim inodes with many attached pages" on 32-bit
> highmem machines.  Look why someone added that code in the first place:
>=20
> : commit f9a316fa9099053a299851762aedbf12881cff42
> : Author: Andrew Morton <akpm@digeo.com>
> : Date:   Thu Oct 31 04:09:37 2002 -0800
> :=20
> :     [PATCH] strip pagecache from to-be-reaped inodes
> :    =20
> :     With large highmem machines and many small cached files it is possi=
ble
> :     to encounter ZONE_NORMAL allocation failures.  This can be demonstr=
ated
> :     with a large number of one-byte files on a 7G machine.
> :    =20
> :     All lowmem is filled with icache and all those inodes have a small
> :     amount of highmem pagecache which makes them unfreeable.
> :    =20
> :     The patch strips the pagecache from inodes as they come off the tai=
l of
> :     the inode_unused list.
> :    =20
> :     I play tricks in there peeking at the head of the inode_unused list=
 to
> :     pick up the inode again after running iput().  The alternatives see=
med
> :     to involve more widespread changes.
> :    =20
> :     Or running invalidate_inode_pages() under inode_lock which would be=
 a
> :     bad thing from a scheduling latency and lock contention point of vi=
ew.
>=20
> I guess I shold have added a comment.  Doh.
>=20

It's a very useful link.

Thanks!

