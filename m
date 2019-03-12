Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1FE9C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 17:25:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 880DD206DF
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 17:25:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="VVeI6ph6";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="FJuvMWsE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 880DD206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22FBF8E0004; Tue, 12 Mar 2019 13:25:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DEDD8E0002; Tue, 12 Mar 2019 13:25:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A8CB8E0004; Tue, 12 Mar 2019 13:25:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BDB838E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 13:25:02 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id b15so3754517pfo.12
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 10:25:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=7bmjjq0v8++DzO5z2jPLMHrsWacQIAWH5Yc2evpo46w=;
        b=F3InsCy6xEZOmBEuD2Dk9PJZrReQk39QwqhtghtrDtGN56ybv8xQr9e4UfUSLE4U/E
         +MJTI+pntMF/SM6J+eTj3iSOTyPyqTrndD9JO/J92LWb755l9TKCXn2NG8j77NRs5NTG
         MAWtw/hKDofBd8RCxbDtu6hMaGW+mCwggyTI+Z+RynhFubhFvlSPQpkkb3SyqiW4BzjR
         c7KYlKNWJbXyPGClGx8ZFalKPo50CjXJKYud7jwPAi0V6QdUxKyO3LUTHJSgBCzIJqQl
         a3r7dFysyg1adg7HKxXN+AdL811s8eHJUKL0foOk0zVwh1gq6TN5IUxbJkCz0qojrgWM
         2X9w==
X-Gm-Message-State: APjAAAVVgYvcN4iyHl+7AgjJfyZlJCqdqT5nzBKcC2yOfAaHrHD8ZpQF
	npVeyAPD0Vw9aBLMH0mQZkSJgbwgXNqOWUsPYc8JQ4cQq3+7dIhH4kd8qOLod7/L8vWOW49zNVx
	iA0u0bRpm7dzZTNqmvHI/6UFNDnsLP6M1JpQQlpIN7knqoKhFiGk/janKRza14P9oQA==
X-Received: by 2002:a17:902:2a47:: with SMTP id i65mr41567369plb.237.1552411502476;
        Tue, 12 Mar 2019 10:25:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWGwDB0uTzgD0LcXMIEjcH5Fge2SFbkN74HMtD+YHGGU2oixZla8DwlGldEXklu0otllnw
X-Received: by 2002:a17:902:2a47:: with SMTP id i65mr41567312plb.237.1552411501693;
        Tue, 12 Mar 2019 10:25:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552411501; cv=none;
        d=google.com; s=arc-20160816;
        b=irM7MTq+Yi6cujIb3GedYDsaPMwF4pHxQeyOj3t9nA6mINnqYK48r06oBwdI/goyZK
         5N4ZnIgYp7R0XcGFpmIET3vP4YsPxVFg3oba7Dog1mlT4o4rgUpMDUtLHF0WiWWomp6z
         SWyudioaWkqjsCRV3YhvSLpu/Tg8McCaX4CH4XnXcOaP2LjU2hLjUa7Uz33ZDBN6/6/0
         q961Q2JEwk//tpsf6Asq0lFxDai0kY0WC/cp0Ohi76T0MBg+mJ8PiPcmEWzhseD4H2ZH
         fZEKvlgCnxc9u8tikl+O7U9WiHcHsFeFSX2LoKgFVWeEP4Y1clBCeKRUR+Vfn1tzLRFI
         KMrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=7bmjjq0v8++DzO5z2jPLMHrsWacQIAWH5Yc2evpo46w=;
        b=MLsFNm/zpQYy6ZMfFyMEgIOUbYLbOLsn0nFqPx58GpqeCRf/EiNw6WvyQGcL4ZZ0Wy
         7w7z366pilQ2QoI5xfW7b557GR62TifnzVf4s4BzFfIfzamTPfBMuoqBEHzO5SW9uVY6
         A51xtw01zpmE/hnz+6vhTBjGcfYNFAP0b/5aJcl6JYD6zzrJrtLl/AL7U0Z6uKtOPce8
         zay7x0KS4hj8ZR/GDtK+fEs2E2h9MW3e+r/D2gS5Ft6XIV5WNTrDZQRxj0kDT5KsIMLi
         pc7H/gc0wEjMILQF8XXKBSoFBifEIv4BroKsr4k1mVo2ycBxdXXbhg4evLkasnhFhxEJ
         mjkA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=VVeI6ph6;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=FJuvMWsE;
       spf=pass (google.com: domain of prvs=89745e2bfb=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=89745e2bfb=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id q5si5029881pgj.382.2019.03.12.10.25.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 10:25:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=89745e2bfb=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=VVeI6ph6;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=FJuvMWsE;
       spf=pass (google.com: domain of prvs=89745e2bfb=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=89745e2bfb=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2CHL0d6016284;
	Tue, 12 Mar 2019 10:24:53 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=7bmjjq0v8++DzO5z2jPLMHrsWacQIAWH5Yc2evpo46w=;
 b=VVeI6ph6+9NMGVl3dfe4SowENo8XL+0ojreiZwy4OPlRofsvHomd0rj3sDb7pYhhG00I
 y4QOixooii588ZCMj0f0X3/KJu4XUPIxNlihshI7Oku1d6FJzBCt+eEj7l8OxdGAD2jv
 3g7bMvBt9XB/jC5RYmW9xHbWY99B6ynYS00= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2r6f6j8p2q-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Tue, 12 Mar 2019 10:24:53 -0700
Received: from frc-hub02.TheFacebook.com (2620:10d:c021:18::172) by
 frc-hub02.TheFacebook.com (2620:10d:c021:18::172) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 12 Mar 2019 10:22:05 -0700
Received: from NAM05-CO1-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.72) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Tue, 12 Mar 2019 10:22:05 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=7bmjjq0v8++DzO5z2jPLMHrsWacQIAWH5Yc2evpo46w=;
 b=FJuvMWsEMM+WbqzhNG5DccfsPMLk7YHV9Bb6Hzr9EubPEO//gm1PFeiS/IAfOrE5Sz4LDwRAQs0vaeWltCYUJdmc2VVv/lFi4HKR1TSwi6CjeDEVyXvcWshoWBg5ie4OHZN2DDGCpOdlrA9XSgGmTLs5ekbA7kG0qsYflgrd+bk=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3175.namprd15.prod.outlook.com (20.179.56.29) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.13; Tue, 12 Mar 2019 17:22:02 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::790e:7294:b086:9ded%2]) with mapi id 15.20.1686.021; Tue, 12 Mar 2019
 17:22:02 +0000
From: Roman Gushchin <guro@fb.com>
To: Matthew Wilcox <willy@infradead.org>
CC: "Tobin C. Harding" <me@tobin.cc>, "Tobin C. Harding" <tobin@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
        David Rientjes <rientjes@google.com>,
        Joonsoo Kim <iamjoonsoo.kim@lge.com>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 0/4] mm: Use slab_list list_head instead of lru
Thread-Topic: [PATCH 0/4] mm: Use slab_list list_head instead of lru
Thread-Index: AQHU16bt6o0Uju0YQ0mKx1ZofK0W1KYGcySAgACefICAAB6OAIAAGdwAgAD22QA=
Date: Tue, 12 Mar 2019 17:22:02 +0000
Message-ID: <20190312172157.GC32504@tower.DHCP.thefacebook.com>
References: <20190311010744.5862-1-tobin@kernel.org>
 <20190311204919.GA20002@tower.DHCP.thefacebook.com>
 <20190311231633.GF19508@bombadil.infradead.org>
 <20190312010554.GA9362@eros.localdomain>
 <20190312023828.GH19508@bombadil.infradead.org>
In-Reply-To: <20190312023828.GH19508@bombadil.infradead.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: CO2PR04CA0121.namprd04.prod.outlook.com
 (2603:10b6:104:7::23) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::2:d3a0]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 38156624-f19e-4885-c261-08d6a70f3dbc
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB3175;
x-ms-traffictypediagnostic: BYAPR15MB3175:
x-microsoft-antispam-prvs: <BYAPR15MB31758ED1D5016AF0DBABF86DBE490@BYAPR15MB3175.namprd15.prod.outlook.com>
x-forefront-prvs: 09749A275C
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(346002)(376002)(136003)(39860400002)(366004)(189003)(199004)(7736002)(316002)(386003)(86362001)(105586002)(6506007)(46003)(106356001)(102836004)(81166006)(81156014)(8676002)(186003)(54906003)(5660300002)(93886005)(6116002)(68736007)(4744005)(33656002)(2906002)(97736004)(99286004)(6916009)(76176011)(52116002)(1076003)(7416002)(6486002)(71190400001)(25786009)(6436002)(14454004)(229853002)(8936002)(478600001)(71200400001)(256004)(14444005)(476003)(9686003)(6512007)(6246003)(4326008)(486006)(53936002)(11346002)(305945005)(446003);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3175;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: dW4ccKz8pwgu7uFv4MDYkzacYQ10l0AatXZvykEqExqjJtf+NMSaUUc2HNg+ijhg1dJFw1HpaJ33+NzkoOVvkjbgGDsd7QmNQbpzc6REWF+/Gx7pucElr7SAlmRP9X95F/dUOLRBjI7+Yk6sDnwhRS6coF8s/93+HnoK6ZYlu5KPPzCyyFeuhOkTpevGjyKmBVn7I9RHSZkitUzXAr0bYQ9MVeltRY8dHGmVFHV9rK8L0jJyYrhK7lyC3jrWLvn6fqivdPtcWC6xsu81n6YBBeihnlI0AUwRKzeh6ui94wBMOXpbTHksAI4RejndM8YAoFuxwjvCr1+rX/HM9v45PJ5GXB6WWxMoUasF2fMss5JUEi8V4s3QfxYZfAvJqnW68JcpoF9y16vEdOF1LuQdL8/bXN+v9QTCmOhRaqhT/WE=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <1F5178F547901B46ADA5BB1AE7AC6125@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 38156624-f19e-4885-c261-08d6a70f3dbc
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Mar 2019 17:22:02.4214
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3175
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-12_10:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 07:38:28PM -0700, Matthew Wilcox wrote:
> On Tue, Mar 12, 2019 at 12:05:54PM +1100, Tobin C. Harding wrote:
> > > slab_list and lru are in the same bits.  Once this patch set is in,
> > > we can remove the enigmatic 'uses lru' comment that I added.
> >=20
> > Funny you should say this, I came to me today while daydreaming that I
> > should have removed that comment :)
> >=20
> > I'll remove it in v2.
>=20
> That's great.  BTW, something else you could do to verify this patch
> set is check that the object file is unchanged before/after the patch.
> I tend to use 'objdump -dr' to before.s and after.s and use 'diff'
> to compare the two.

Btw, is it guaranteed that the object file will not change?
I was about to recommend the same, but was not sure, if such change
can cause gcc to generate a *slightly* different obj code.

Thanks!

