Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 462ABC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 00:31:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDDC3208E4
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 00:31:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="kA0il8um";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="AlIfDrPR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDDC3208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E7178E0003; Mon, 18 Feb 2019 19:31:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36E7F8E0002; Mon, 18 Feb 2019 19:31:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EA598E0003; Mon, 18 Feb 2019 19:31:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id CAE368E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 19:31:53 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id h26so14944607pfn.20
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 16:31:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=Wj5Wfr1M0wYFx6kGprl398oeDQlmCicF61se2iu+CqY=;
        b=DMxzts0PWnGbvfPMz0XPW++1uY3FOaWq6VkKzujkXAmAX30XiQ0tE6CJjIKst7boQa
         vBnAT0AER/lkN+p92ygkatQrafUjlAZuOhm70eVm3UZI9LQJmBf/BFl5hqHpDCC1lr9n
         F3UETyo2XyDROmxQUbJ5LsZnRJUHz80PkFTSR/ePIalZ9XuHSnLLMEcbecI6PVNPicub
         XGbWMi8yZrFOQouDoRjaktJseQ7i70o5qg0oYq39aK8hVuSqG/c5jBYJhYFF0w+HpYfa
         LA1a59qexwtYIXWo/8tRJ/8fcft9pOmlRlxRp2jzqRNLmsyUpC2VVtJfVUoiF1m1VtNP
         aAcA==
X-Gm-Message-State: AHQUAubbIqyQdHemqjMOuhyd4t27H7Cgx7R+OVxGLHWOzftSsLrW9jeT
	27nq84dgz6YAnOo9Y1e9pGYeYTrzSFW5ZMnZfdm9+0HFAfkRaRiKEd4Pq3lYNF1NDjbIlj4b4G+
	6iPGXNYKa/lCA7hGM9pjk+pgvtPsbBqO6NtDc0wcLT4NC9DS2/MZdPOJkVFnY2+u1IA==
X-Received: by 2002:a62:e704:: with SMTP id s4mr26682226pfh.94.1550536313363;
        Mon, 18 Feb 2019 16:31:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZwNLHIqjW1cUc+feYhWqbjzK7G0vMiweLbt2tX/icTeCZGz9TemMuYJ5KZrTq156ZUix3Y
X-Received: by 2002:a62:e704:: with SMTP id s4mr26682154pfh.94.1550536312377;
        Mon, 18 Feb 2019 16:31:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550536312; cv=none;
        d=google.com; s=arc-20160816;
        b=RPDiibtZz8LcZrgSsBI/eZ5ImCA0PWpCLJp89dlkxMjGlN8dYPxkoIbhtMzaySHjc3
         axdwdYMdMnFaxIgtFM/qqlpTIQvNoYEbzKXG7v0GFHcapqIxscXUYRGO+fLmQGnkiclx
         oza/btcEDIPqtzq/rUwhr75lobt0LKRXYFPN45EyXdC1AyGnZbQLa4ARuGD6N2UA9KCt
         Vh9vuINXX9tTCEK71vrRlFYzakbsAkv3wCnEuSPRlSR+/jFosHozFq0s7oPzlwZev66m
         nuxsFlCQuVKWlEK+9WMtbihbEolQPTgY2ZU2F/Y/Z+cGlE+6SOcs6EbwWB3ZPnSBrrNA
         9jQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from:dkim-signature:dkim-signature;
        bh=Wj5Wfr1M0wYFx6kGprl398oeDQlmCicF61se2iu+CqY=;
        b=hL1TZFCvNTs9Xd//RMEDYfs4MX5FibTJUMN5JJ1l5b7LtNylCb5TaylI/8FNXl2+Nq
         dk76MxuUWVltoDIWrKDFQApDNiSkkBS/Dwluj/xsHtRZaAdrEqcfxvGyZq9RMAXVRDPg
         xInTPv3SIodCuRkwN/a9P0RC8nKrwKJiPO5x4Xrunyix3iBU5W/KAF08a0wq1BW5LLIj
         KdMmEXoW/WNKJLqE6SxscfSfU8uTorhJVrtW3ld9JmhA/lplQL4jIzX6vEvbOgnGk8pC
         Zjmqy5oW22uyRnj7tVo5TZYA4uCGGPD7Yxc6X/qzcM2Re7aQx8Om8WEuhp7bNh6N8ZO2
         umsA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=kA0il8um;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=AlIfDrPR;
       spf=pass (google.com: domain of prvs=79538942c9=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=79538942c9=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id r16si7183798pgm.483.2019.02.18.16.31.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 16:31:52 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=79538942c9=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=kA0il8um;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=AlIfDrPR;
       spf=pass (google.com: domain of prvs=79538942c9=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=79538942c9=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1J0SVCk000336;
	Mon, 18 Feb 2019 16:31:49 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : content-type : content-id :
 content-transfer-encoding : mime-version; s=facebook;
 bh=Wj5Wfr1M0wYFx6kGprl398oeDQlmCicF61se2iu+CqY=;
 b=kA0il8um97VR8vakgy3ev6i4zSGX+1XVHcRUfBeKvvI+yQeXOw00bQPz1WcJRiTIsM8v
 P5ad/2ie60L2xKd/G7+/fw0s3zq8qx/GUC07FkAPdmvX6ptUHSNcsQPAphUU1vZnl2+a
 9+yGOa38g77Tik/YhfxSPQqO7nHiX1kkVsM= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qr0ck9453-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 18 Feb 2019 16:31:49 -0800
Received: from frc-mbx01.TheFacebook.com (2620:10d:c0a1:f82::25) by
 frc-hub04.TheFacebook.com (2620:10d:c021:18::174) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Mon, 18 Feb 2019 16:31:47 -0800
Received: from frc-hub06.TheFacebook.com (2620:10d:c021:18::176) by
 frc-mbx01.TheFacebook.com (2620:10d:c0a1:f82::25) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Mon, 18 Feb 2019 16:31:47 -0800
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.76) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Mon, 18 Feb 2019 16:31:47 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Wj5Wfr1M0wYFx6kGprl398oeDQlmCicF61se2iu+CqY=;
 b=AlIfDrPReSwDkH6qzNZ2CF0OfXJ1Z5tJrGvQ2TqCwImR4kXFmSKVTM3yQj5NwEF91uuU4Htt3Coe4cKb8Nsk077kUmvys0n4PSiIExeZbjXLcBwAuLaQCE0aiE6KzMcrvOMTeV9Em8isX6G6wx0GM5/Nw30qLGxLDvdqV7REuR8=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2805.namprd15.prod.outlook.com (20.179.158.146) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1622.16; Tue, 19 Feb 2019 00:31:45 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92%3]) with mapi id 15.20.1601.016; Tue, 19 Feb 2019
 00:31:45 +0000
From: Roman Gushchin <guro@fb.com>
To: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "mhocko@kernel.org"
	<mhocko@kernel.org>,
        "riel@surriel.com" <riel@surriel.com>,
        "dchinner@redhat.com" <dchinner@redhat.com>,
        "guroan@gmail.com"
	<guroan@gmail.com>,
        Kernel Team <Kernel-team@fb.com>,
        "hannes@cmpxchg.org"
	<hannes@cmpxchg.org>
Subject: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
Thread-Topic: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
Thread-Index: AQHUx+p+ZryDtWtqFESgmWXECjtRHA==
Date: Tue, 19 Feb 2019 00:31:45 +0000
Message-ID: <20190219003140.GA5660@castle.DHCP.thefacebook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR04CA0031.namprd04.prod.outlook.com
 (2603:10b6:300:ee::17) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::1:7986]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 7c9a8b57-a3a1-43c3-374f-08d69601a080
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB2805;
x-ms-traffictypediagnostic: BYAPR15MB2805:
x-ms-exchange-purlcount: 4
x-microsoft-exchange-diagnostics: 1;BYAPR15MB2805;20:9rfbxI0OlDA/wv93IsQ8RaOaDhwc2o8MnTIdB+pAfgpmkRpmOz/sPo4qz6gG+Adz3y7HrZukt8kh4kvJLHqUnobrn4GnJ3mi573QQHS4jIJ6ZL165atUse6zZ6lhmXcY1W3cJoH2ggNiXmRmO/duVsiL2DTvDvZXc5va48OfUBs=
x-microsoft-antispam-prvs: <BYAPR15MB28051850AE8F4698D74A4768BE7C0@BYAPR15MB2805.namprd15.prod.outlook.com>
x-forefront-prvs: 09538D3531
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(376002)(346002)(396003)(39860400002)(136003)(199004)(189003)(305945005)(97736004)(81156014)(186003)(476003)(102836004)(8936002)(6306002)(6506007)(9686003)(81166006)(6486002)(7736002)(386003)(33656002)(46003)(14444005)(8676002)(5640700003)(2351001)(256004)(6512007)(106356001)(486006)(105586002)(6436002)(6116002)(68736007)(25786009)(2501003)(54906003)(99286004)(316002)(5660300002)(478600001)(52116002)(71190400001)(71200400001)(2906002)(1076003)(53936002)(14454004)(86362001)(4326008)(6916009)(966005)(33896004);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2805;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: sc4SRifHoIGh3ZAxtQ8BLhI54qmQGcjzXMKEJYi6Veg2Pkv2EqeNTLtIbEOCFk4hsVPkmJpadQHJ46ezMk1pSwFsxBDszwG4OxgM2BOkF7N7Pdl2amx1HckD48I1RFlOS2yWy2Tzu/FiOuaEFcPmQeJqMTZDbNUtgd7HZtTB1+9+EBb5cY4o6X0wTta9+he1D3nS2a5GccJKEPFeOh5SR0CvMdguEU3aB/jLUIle+hSQdtdEvXuZ7hS2o8Tez0zktaBRGo9zeffTtcOnzcs99T3FutuSRW9j8O/1kWpor5369NL3HVxxBkY6nVvQ9PbtSaLvobZAIiww7Gtni5b9WpV/JhaUOo0J3yzoXOqstBERggSuHBRecoKwsXzjodFLidhit1FqrjJVy9caMV+zUgPu3300i4mHAlhi4vTKa8s=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <BD5415FE16B11B49899F36422FFDCD7D@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 7c9a8b57-a3a1-43c3-374f-08d69601a080
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Feb 2019 00:31:44.4169
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2805
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-18_18:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Sorry, resending with the fixed to/cc list. Please, ignore the first letter=
.
--

Recent reverts of memcg leak fixes [1, 2] reintroduced the problem
with accumulating of dying memory cgroups. This is a serious problem:
on most of our machines we've seen thousands on dying cgroups, and
the corresponding memory footprint was measured in hundreds of megabytes.
The problem was also independently discovered by other companies.

The fixes were reverted due to xfs regression investigated by Dave Chinner.
Simultaneously we've seen a very small (0.18%) cpu regression on some hosts=
,
which caused Rik van Riel to propose a patch [3], which aimed to fix the
regression. The idea is to accumulate small memory pressure and apply it
periodically, so that we don't overscan small shrinker lists. According
to Jan Kara's data [4], Rik's patch partially fixed the regression,
but not entirely.

The path forward isn't entirely clear now, and the status quo isn't accepta=
ble
sue to memcg leak bug. Dave and Michal's position is to focus on dying memo=
ry
cgroup case and apply some artificial memory pressure on corresponding slab=
s
(probably, during cgroup deletion process). This approach can theoretically
be less harmful for the subtle scanning balance, and not cause any regressi=
ons.

In my opinion, it's not necessarily true. Slab objects can be shared betwee=
n
cgroups, and often can't be reclaimed on cgroup removal without an impact o=
n the
rest of the system. Applying constant artificial memory pressure precisely =
only
on objects accounted to dying cgroups is challenging and will likely
cause a quite significant overhead. Also, by "forgetting" of some slab obje=
cts
under light or even moderate memory pressure, we're wasting memory, which c=
an be
used for something useful. Dying cgroups are just making this problem more
obvious because of their size.

So, using "natural" memory pressure in a way, that all slabs objects are sc=
anned
periodically, seems to me as the best solution. The devil is in details, an=
d how
to do it without causing any regressions, is an open question now.

Also, completely re-parenting slabs to parent cgroup (not only shrinker lis=
ts)
is a potential option to consider.

It will be nice to discuss the problem on LSF/MM, agree on general path and
make a potential list of benchmarks, which can be used to prove the solutio=
n.

[1] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/comm=
it/?id=3Da9a238e83fbb0df31c3b9b67003f8f9d1d1b6c96
[2] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/comm=
it/?id=3D69056ee6a8a3d576ed31e38b3b14c70d6c74edcc
[3] https://lkml.org/lkml/2019/1/28/1865
[4] https://lkml.org/lkml/2019/2/8/336

