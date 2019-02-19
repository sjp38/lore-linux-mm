Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C3ADC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 07:13:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 772CF206BA
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 07:13:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="rIluS3pB";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="CsHp1jPz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 772CF206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA0F38E0003; Tue, 19 Feb 2019 02:13:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4F0B8E0002; Tue, 19 Feb 2019 02:13:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEF7C8E0003; Tue, 19 Feb 2019 02:13:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id A383A8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 02:13:54 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id o34so18788000qtf.19
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 23:13:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=ZPpCqQtFwqciHf/SkNd587ZGZa/yYn3cppiHex2bE04=;
        b=hkXGxr99TBF3vojz+d3599UElg3Vh0YpfjEY5btg9+D62GK6wIEwqbr3Ls6DMNwmDY
         mVjTMrWLDi1Udr3Ptqgaw/49c3iAKatsyTkLA4F3hgayo7Fk0qS3aYYp4R35zc7SdZDe
         pLnKXaUhw7HpGutTdXjDdmCl2k6UVlib1YvTa85XdBrQBycV+AxpeVgC9Z560nH3h1BL
         YbBdyHcpCp29tn00icu0eYNy2HlBPw+4179uSX8CZYd5k2RvX7JvG37AmUJZRS83Jk2k
         u0fnh83QAeIokyQaLaAksuUTFpLzoI1n+oUitnEZcoc+f6qTg8G8CBziXprpAhzOFVWl
         IIcg==
X-Gm-Message-State: AHQUAubbNxqfywq70NMgPDFDJHGP8GqyPndMXlFpRutpOrBraj6SB1p1
	ax3h4lDfXX3VJYqbpCA0I0iRFFEa7f75PUGijdcNepML7wosSDCO9z2u1oy9x0FKv/h8vZ4lWPm
	mHYDBBi9AlXYxBN6ofJefe/GXkk+7L7JcxQbMZQJ4+SrjevUoGvzjbjf5Ju4jIzqt8Q==
X-Received: by 2002:aed:221c:: with SMTP id n28mr4559937qtc.21.1550560434295;
        Mon, 18 Feb 2019 23:13:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ0Xu8dphI+/c1K34l4hviDzoaXItuEyR0KrGfrqMrDXrrWu9WF+11n33EPZtO1KIZfKno7
X-Received: by 2002:aed:221c:: with SMTP id n28mr4559916qtc.21.1550560433590;
        Mon, 18 Feb 2019 23:13:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550560433; cv=none;
        d=google.com; s=arc-20160816;
        b=CnKPp1Hl5QozWx0Aj9iyHssAXTuwq1XHeoWo1bg+tdU1A9ViY7lxIeIvQp7oX5Tjow
         R2wNMI9H1fkxL1Pz3y7jJtdgplKf3efZQ8wFHHFi8F7gdQkjC+wu1g/6Apf+954nIOMk
         elElUj74adV3jKCEwSyEI0fnfYQ3lI1zJnsHw5rplekcycU+KiRNT6LEC6C0VTybX0TK
         3uLEQ+hQ5IhobWgPYBXJo1PWGodBJGuyxtkzhlpM2BGe8aa0mACthMFzOqClZy2Xa1c1
         4/AIR/dXdBCjNSIUcC9CDw0qhaVjTCVUQnxngfOwFay7KEoRDwwlpq8npjxatnMHkBXl
         RAzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from:dkim-signature:dkim-signature;
        bh=ZPpCqQtFwqciHf/SkNd587ZGZa/yYn3cppiHex2bE04=;
        b=HR4uHUMPkgaZcUskVbGjwR+hOi0++edRVWQIFA/pZ7u1PW9JTyJm5XCtm+FHCqVIxB
         RDgXnO7xZVNyfqHGhaLlK8W3FtyhPDfGqhcMzCxrMsl1fl8p2eQNZ4RaqfwPj7UTARSf
         J/Ut4MU0ltOjY2CsUyjqRhalGnFtbqpDZXwanuGv2XK/QYdoh6b1NRQEcjceqpdflqnP
         iQBzec5hXVgZsTiCOjh6gdSFZttTc/TxM8zM7ot257DrV58mFN/fFvxphJqp+Hy2z6Xy
         TBqV9mPOMPTAOqCM0aAm+bcT+4eNAmR0U0Ne0nMjx7L1wa3o8lo1YbeXcQN94ix9TlZW
         f8dA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=rIluS3pB;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=CsHp1jPz;
       spf=pass (google.com: domain of prvs=79538942c9=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=79538942c9=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id i185si2072674qkf.56.2019.02.18.23.13.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 23:13:53 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=79538942c9=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=rIluS3pB;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=CsHp1jPz;
       spf=pass (google.com: domain of prvs=79538942c9=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=79538942c9=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1J7DQXD014220;
	Mon, 18 Feb 2019 23:13:52 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : content-type : content-id :
 content-transfer-encoding : mime-version; s=facebook;
 bh=ZPpCqQtFwqciHf/SkNd587ZGZa/yYn3cppiHex2bE04=;
 b=rIluS3pBCUVF5hKeCA7vI6ppuC92uQFFG+nppgIG9vqpy+X0IbLEzsZ3FfusZxTSYl+1
 hinYCrl9HiS3SLt7oixqVbpNe10kqx4O6IiYai6FmBmg/oKUpIKt8iEiZ2KpgDO2DwzQ
 oGbxDFfqi8Avt/4K5laPUKduMRIzqcuvo58= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qrct481ur-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 18 Feb 2019 23:13:51 -0800
Received: from frc-mbx01.TheFacebook.com (2620:10d:c0a1:f82::25) by
 frc-hub05.TheFacebook.com (2620:10d:c021:18::175) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Mon, 18 Feb 2019 23:13:51 -0800
Received: from frc-hub04.TheFacebook.com (2620:10d:c021:18::174) by
 frc-mbx01.TheFacebook.com (2620:10d:c0a1:f82::25) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Mon, 18 Feb 2019 23:13:50 -0800
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.74) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Mon, 18 Feb 2019 23:13:50 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ZPpCqQtFwqciHf/SkNd587ZGZa/yYn3cppiHex2bE04=;
 b=CsHp1jPzknxBCvMAuWW6cF12gUT60uFB1BrIRGXUrL+az31kMF8gvZXBSwv7b70jBfIyL0rfqcTsPnXK+sc7oJ/0KFleyPMk7sObOx+JSx/v11WOaJDV89tRGDOEICPOS7vLPGtO0z8thG3jOv18sDE7UAlwPbT1ckFVdJvzAQU=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYASPR01MB0012.namprd15.prod.outlook.com (52.135.241.97) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1622.16; Tue, 19 Feb 2019 07:13:33 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92%3]) with mapi id 15.20.1601.016; Tue, 19 Feb 2019
 07:13:33 +0000
From: Roman Gushchin <guro@fb.com>
To: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>
CC: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "riel@surriel.com"
	<riel@surriel.com>,
        "dchinner@redhat.com" <dchinner@redhat.com>,
        "guroan@gmail.com" <guroan@gmail.com>,
        Kernel Team <Kernel-team@fb.com>,
        "hannes@cmpxchg.org" <hannes@cmpxchg.org>
Subject: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
Thread-Topic: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
Thread-Index: AQHUyCKfeT5lZyV8PESiIPUMxsb/VQ==
Date: Tue, 19 Feb 2019 07:13:33 +0000
Message-ID: <20190219071329.GA7827@castle.DHCP.thefacebook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BYAPR08CA0064.namprd08.prod.outlook.com
 (2603:10b6:a03:117::41) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::1:753b]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 72a1185d-9415-4e27-7c68-08d69639c1fe
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYASPR01MB0012;
x-ms-traffictypediagnostic: BYASPR01MB0012:
x-ms-exchange-purlcount: 4
x-microsoft-exchange-diagnostics: 1;BYASPR01MB0012;20:Yu5iKlZpalGPZ8L2Wfw3VpYg4kYT/hZyZ/0tTuDyIBY8pwfPzkIkNHks0aClkoUJCp5nXuSj8vJ987G6E3J3EjfxtN0X99ZlZQx1gVqgfyCkcj6N6dxuyB5lY5VC1j1WngP5GtP813V6RT/hQqj9NPeHEBfLMtNOIWR1n7PwGvI=
x-microsoft-antispam-prvs: <BYASPR01MB0012127E36085186001A66F0BE7C0@BYASPR01MB0012.namprd15.prod.outlook.com>
x-forefront-prvs: 09538D3531
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(136003)(366004)(396003)(346002)(376002)(199004)(189003)(256004)(81166006)(486006)(6486002)(33896004)(966005)(5660300002)(97736004)(5640700003)(6436002)(71190400001)(8676002)(71200400001)(2351001)(476003)(478600001)(7736002)(14454004)(33656002)(25786009)(105586002)(6116002)(46003)(106356001)(4326008)(6506007)(386003)(2501003)(305945005)(102836004)(316002)(186003)(99286004)(53936002)(14444005)(1076003)(54906003)(8936002)(52116002)(86362001)(81156014)(68736007)(6916009)(6306002)(6512007)(9686003)(2906002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYASPR01MB0012;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: uIU+CNNbUdwhKtBS8tZjFlEk8yKH3GiMuGviIYegZ8kV4wkBM1aXNtcyY9JM/jTEC49LVuszv4WjM0+1pOQAg5RvMlxGhak5eG9FOFFOZHTsGf99vf9OWfX9QJzihDQd1iBPK/WE49pe7htNuH3aOwDR4j7qjPpLmEJ00BGobDTXey8vJYXfI/Z/2nM+XJfad2rGln1La9o+e52sz7KIiysHIj4beZig7V7gDtRdrR+O3kbRupD2PDd9YDDTYTE92JZaCjm74OUJfEZnc2uEqrBzhyH5KKD5aSL3iy963C/CVvnYYKPtiNDOoSTm9rfYFE484hko2QkFw+g3tSLoyVXFK+AW9GRwXCnTkpwD+vddRk5LD0CCghgSm6fO9Kd/GKBjI0VqsxXZpEITC0gc9RN+RAjQb6FA/ZMnTqTiT3k=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <CE84E415D6706A4A9AF4B0CD01403B7C@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 72a1185d-9415-4e27-7c68-08d69639c1fe
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Feb 2019 07:13:32.5392
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYASPR01MB0012
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-19_05:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Sorry, once more, now with fsdevel@ in cc, asked by Dave.
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
due to memcg leak bug. Dave and Michal's position is to focus on dying memo=
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

