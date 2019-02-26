Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15912C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 23:50:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9179218CD
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 23:50:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="LZn4oHCc";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="GwUYiNxH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9179218CD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E8278E0003; Tue, 26 Feb 2019 18:50:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 498678E0001; Tue, 26 Feb 2019 18:50:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 339898E0003; Tue, 26 Feb 2019 18:50:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 079F98E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 18:50:14 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id z64so4964233ywd.12
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 15:50:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=UxNseYtvy3qCAyi0iYKcxOmE4pf/t1SNeHCMaX7CDzo=;
        b=Hrbto6gFUh47GmCRUJmQYsfk3lRiadq0oYxdENX0v/t+Ba3fM1ALDS8fmCYyXpiQPK
         wzwmH6sKEcQ+XL10H8EWv/uZgqicfXKqa7QRfEqIL29kVQCZqYMJlh6HFDqOn3iIbRgc
         oDE3YQhoS9dolp+jYhTAv73hOG/qjvXg1zS+C3Otmm7VGTYu0y4UGvUw+qydFBFdPLW0
         GjASwJWLGty5a6Ic5uuDVQkM3LaWh64LppTuu5PDESbY7GRU2ckt3qKh3Oa13/ldcvBC
         mBjX5BnW2cs49YSfQqG7S3bXDNS3FwkR/6XqtHByUGBaifRiDFKMNFUa3Vg4e3ggaVnQ
         +feA==
X-Gm-Message-State: AHQUAuaJUK/WrnTFy1oQdOKY/TnaxeX2oc//rPU10q9dL5Zg+cJPGWb2
	v/nvCS3IvGXPJNBVR/5qAq5o9WC5tcQ2Ir6Yh9JaunsKQi756Gw5AT61PIrxPtx5Lbj7c//FFLf
	6IuMm9U5zxjbwb84RFnl+u0gFXjvoFuzjOznROj1cKYATgSzaD0cJv/6gohRU910ynw==
X-Received: by 2002:a25:6b41:: with SMTP id o1mr17710073ybm.135.1551225013687;
        Tue, 26 Feb 2019 15:50:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZMnlaNe/ipTHfMl2cxDNTq9eynCnx9ywaBVFh7jf9J7r6B+wkM7wT/Zs4HYnl2baRxZXrc
X-Received: by 2002:a25:6b41:: with SMTP id o1mr17710046ybm.135.1551225013106;
        Tue, 26 Feb 2019 15:50:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551225013; cv=none;
        d=google.com; s=arc-20160816;
        b=A6Nzs3s20FBlH+sPEP9gZ1PBAIhv+XMlsbIIvmJJCtaut7T6cFWdMEdAx/DLoY38xX
         M06Vka9j40WxBG4QBAl/0OWVupRRIyVNYmDmG9+MCtxN+Gl9xR8MEPXlXbD6+K7VGWO+
         nyPF+Ntz9fDafmcNa6GfDYkLrLRgHZAAYvnAYHNiXDLsOOz7U+48smz0tuT6zj8JzrDm
         ZlxvAHW2fKin/giLjnPGdW2Qp3QilQV5JIuf57I41iTfklGGEyXVnST9Qs1AC2wYlmp/
         YtFH/2ZXnVwfPx7i7/7VAfGl2yhrvS5Cc6cSkj5VWNEON55ffhGZ377/Bj+/WRJucu/+
         DQsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=UxNseYtvy3qCAyi0iYKcxOmE4pf/t1SNeHCMaX7CDzo=;
        b=UpM7MMGrB+qluegIN7PyAdVF+7lHS31dGjl69Y6TPwXRoNsO7Soh7Y3LlqqOLUW/MP
         fmnb+VxvEev0mMiAC3zITsolXuK9M3fNR8F86UWTne73YGREzrzQ+hRRVzZs6aAXgar+
         VVMUHjPl/NsKZQvmFMM1hwBlm4eNcsJ8HHKEmFCWwNlDtCJ0MB5qgAISUq7HfF8MTHL0
         a79lKLqjpBh6L4fOUrI/dC55Y12xoTSyjkox4tXkFAs9So3TZRinG7K4TuzezTQZwxLK
         tE7lOZbFP55EzGSkCQPj/yyS7Fq25ys6iBH4XKDur7KniA4KwQcvRZiBPMynH6DrPC80
         a/PA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=LZn4oHCc;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=GwUYiNxH;
       spf=pass (google.com: domain of prvs=79607285cb=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=79607285cb=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id x5si7650316ywb.289.2019.02.26.15.50.12
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 15:50:13 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=79607285cb=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=LZn4oHCc;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=GwUYiNxH;
       spf=pass (google.com: domain of prvs=79607285cb=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=79607285cb=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1QNo4xI014586;
	Tue, 26 Feb 2019 15:50:10 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=UxNseYtvy3qCAyi0iYKcxOmE4pf/t1SNeHCMaX7CDzo=;
 b=LZn4oHCcbVQ6T0AHcSNrwF7lR8R+d1WrsOJbKg3Z+QW5tf7iZP4O7sY4sb3Sn0xq8eWE
 Rs7GwKqTT6gQ5nx1r5ANYKVl54YlgRPhtG6J/4nhg84JYG6l7IPldJ0C3wlA9W6QodU3
 v97fMUZ6tYoLiy+GYyeT7trPWnkzs8DXRnE= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qwefkg6nc-6
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Tue, 26 Feb 2019 15:50:10 -0800
Received: from frc-hub02.TheFacebook.com (2620:10d:c021:18::172) by
 frc-hub04.TheFacebook.com (2620:10d:c021:18::174) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Tue, 26 Feb 2019 15:50:00 -0800
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.72) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Tue, 26 Feb 2019 15:50:00 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=UxNseYtvy3qCAyi0iYKcxOmE4pf/t1SNeHCMaX7CDzo=;
 b=GwUYiNxHv7ORUf8Wi0Jym1hIBi3GjjLVMVUjxQVao0v2DCb8p7k6/3wtQFz1BNqcw1mmVEVpe4fNNZooVaZIEw0bV/H0ADjNOZqcMcuGv+2j9Jflx6w3NsJw6wYja5t2jEHFMo4BAlYQk5Mxm8Yrh8/7WZ/HzLENsOcb+Yc3sA8=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2375.namprd15.prod.outlook.com (52.135.198.25) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.15; Tue, 26 Feb 2019 23:49:57 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92%3]) with mapi id 15.20.1643.019; Tue, 26 Feb 2019
 23:49:57 +0000
From: Roman Gushchin <guro@fb.com>
To: "up@kvack.org" <up@kvack.org>, "the@kvack.org" <the@kvack.org>,
        "LRU@kvack.org" <LRU@kvack.org>, "counts@kvack.org" <counts@kvack.org>,
        "tracking@kvack.org" <tracking@kvack.org>
CC: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "cgroups@vger.kernel.org"
	<cgroups@vger.kernel.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Kernel Team <Kernel-team@fb.com>
Subject: Re: your mail
Thread-Topic: your mail
Thread-Index: AQHUzUcWDtH4mHJ4O0uyGF7XBp7tPqXywWGA
Date: Tue, 26 Feb 2019 23:49:57 +0000
Message-ID: <20190226234950.GA19099@tower.DHCP.thefacebook.com>
References: <20190225201635.4648-1-hannes@cmpxchg.org>
In-Reply-To: <20190225201635.4648-1-hannes@cmpxchg.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: CO2PR05CA0091.namprd05.prod.outlook.com
 (2603:10b6:104:1::17) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:a769]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: cd5201c6-67da-48ed-16a7-08d69c451cf3
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB2375;
x-ms-traffictypediagnostic: BYAPR15MB2375:
x-microsoft-exchange-diagnostics: 1;BYAPR15MB2375;20:jOxA6uZUj6yEwHDlMXA4c2ziLhjW0XLXl3GjrSR/ooJt156nOBBvJxGpbBxbVgT6Z2h6zVnQosFLsPsCrBMoMOlBD07S2ZhorIK9Cplk/PEd69AjI2w4gdm0TgtFhvk7uUqjMY/8KJ/pVplLsCuaNQG0RREIKFZS1oU4APm8s2s=
x-microsoft-antispam-prvs: <BYAPR15MB23752279E0323F92E113896BBE7B0@BYAPR15MB2375.namprd15.prod.outlook.com>
x-forefront-prvs: 096029FF66
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(346002)(376002)(396003)(366004)(39860400002)(52314003)(189003)(199004)(8676002)(81156014)(81166006)(186003)(46003)(8936002)(2501003)(486006)(305945005)(7736002)(33656002)(52116002)(53936002)(102836004)(76176011)(446003)(478600001)(11346002)(476003)(14454004)(68736007)(97736004)(105586002)(6506007)(386003)(106356001)(7416002)(25786009)(9686003)(6512007)(86362001)(6246003)(256004)(6116002)(6486002)(99286004)(229853002)(2201001)(5660300002)(4326008)(1076003)(316002)(2906002)(7116003)(221733001)(6436002)(71190400001)(71200400001)(54906003)(110136005)(3480700005)(111123002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2375;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 8en2ZygQCyFMTgMIWqn0+8YSfGz91T0Ce3PcLbWIu4NqebuclEYHehT2gr3UPGtgShGcWqgwPt4zI8554/5w2hySpN/BGEA50/dZpQqjo6pK8w5t5rN/WSw06TNeyDVPYdBf62vpvCmQbj1P4KNiH6AjJuwKV6mvey5k89BFulfEF3iB9lSHNk+tNruwLIGfJpI5Woq0XeGTY6DrJDIvGkD1l6je/hip7gc3WvwUyTm2bpaQjn1mWCHvydelxATHU8wqcoULjD3NuoR3ajBivatGcy3PbaAWJwcBZN6WV3EUMvPvMg0mqJvVK4+WJDQupLnnkcV0Gb9i2/ByMt1O2GnmF68HW8L7d7ZPvZqd46Gj3No0fSkpCGYoYdRci0WmNb2mbvM9IQ5GYHmw244wIKpyQb3uviObsGjq9Y8Wj14=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <09E3E0D2F7346B45B659EA0BC27E7BB7@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: cd5201c6-67da-48ed-16a7-08d69c451cf3
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 Feb 2019 23:49:56.5128
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2375
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-26_13:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2019 at 03:16:29PM -0500, Johannes Weiner wrote:
> [resending, rebased on top of latest mmots]
>=20
> The memcg LRU stats usage is currently a bit messy. Memcg has private
> per-zone counters because reclaim needs zone granularity sometimes,
> but we also have plenty of users that need to awkwardly sum them up to
> node or memcg granularity. Meanwhile the canonical per-memcg vmstats
> do not track the LRU counts (NR_INACTIVE_ANON etc.) as you'd expect.
>=20
> This series enables LRU count tracking in the per-memcg vmstats array
> such that lruvec_page_state() and memcg_page_state() work on the enum
> node_stat_item items for the LRU counters. Then it converts all the
> callers that don't specifically need per-zone numbers over to that.

The updated version looks very good* to me!
Please, feel free to use:
Reviewed-by: Roman Gushchin <guro@fb.com>

Looking through the patchset, I have a feeling that we're sometimes
gathering too much data. Perhaps we don't need the whole set
of counters to be per-cpu on both memcg- and memcg-per-node levels.
Merging them can save quite a lot of space. Anyway, it's a separate
topic.

* except "to" and "subject" of the cover letter

Thanks!

