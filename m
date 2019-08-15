Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5EE3C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 16:27:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8061920578
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 16:27:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Uay/BsDc";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="HzWUxenw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8061920578
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1459D6B02BC; Thu, 15 Aug 2019 12:27:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F67E6B02BE; Thu, 15 Aug 2019 12:27:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EDA086B02BF; Thu, 15 Aug 2019 12:27:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0080.hostedemail.com [216.40.44.80])
	by kanga.kvack.org (Postfix) with ESMTP id CF0E46B02BC
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 12:27:33 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 6A44568B3
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:27:33 +0000 (UTC)
X-FDA: 75825192786.14.lunch30_41b90e8213f45
X-HE-Tag: lunch30_41b90e8213f45
X-Filterd-Recvd-Size: 9470
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com [67.231.153.30])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:27:31 +0000 (UTC)
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x7FGE7MD003505;
	Thu, 15 Aug 2019 09:27:22 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=imCysVDJD/5CfqoVmE3yxThlJlL+sTCqaOveqBkRwHo=;
 b=Uay/BsDc0ojYHc8D3IdPs70T/24xdoYYLsd0I0pTqn6ApTnwJs3ot9Xa8aFa3+2OUXBc
 ca0I4TwIVvxI5jzXoPg+/GxKo2S6tZu8yJr+S5198eCyRhYZjlS14C1QR1ZappYH9jre
 V27W+9j2iP2RwWxSRnNfM858vbrp72Negns= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0089730.ppops.net with ESMTP id 2udaem83uk-16
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Thu, 15 Aug 2019 09:27:22 -0700
Received: from ash-exopmbx101.TheFacebook.com (2620:10d:c0a8:82::b) by
 ash-exhub203.TheFacebook.com (2620:10d:c0a8:83::5) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 15 Aug 2019 09:27:14 -0700
Received: from ash-exhub104.TheFacebook.com (2620:10d:c0a8:82::d) by
 ash-exopmbx101.TheFacebook.com (2620:10d:c0a8:82::b) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 15 Aug 2019 09:27:14 -0700
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.175) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Thu, 15 Aug 2019 09:27:14 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=HCX1dfPrZ+4EI0qHixItlW5gQf9P8Z2X0E5pZLj1gnNaaF+nh5nbdWUc2izN9rF39G1ECPn27898yxHXn8hLzJ4FuVNIDeSYxchR8aFf5H5akOmnZ6gTRRPkGY2FW4UI31x2B7k5bzvLmV3WgS3nD4SoDSy604mAWDfbfJrYipB1POJpPx+N0N81UWnOi9MFK8G9qHV1M1Tw318zm5HhwdAQrnVlZXiDMGTDOfYKuLkNUjrYWhoyIf0URva/YGCzF7tEQ4DXV38Klq6+rpkH9nH7qNOuLC8Hh0Kvv/119qs6cAVFOs8PqmQ3O+cqziTesanD+lHeEyemn73BEvnjOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=imCysVDJD/5CfqoVmE3yxThlJlL+sTCqaOveqBkRwHo=;
 b=J500ETMl6ssq6/CkT3MblMu89NRWfgrYNHPcLt+Jt02d9b2+i5V3f0QFjMzaYBlcIEwVWU2U6msB0f+pTw7KisJE8+F4s2OUdMLX/yjN1R6piTCJovCAtZRpRVu6NXitnFJQaQpK83rsCPC8aQMrxvuHCSOGuMazsZ0yaHhBVj+ElC8llNAhOhvEJz51E2AGLKvH9aiCoqGR8O4peKrjjNHt+SsjDfziumXf9RgFMcHn+8FMOyXvXwFhrYqUDLKGRzpFiKZ25imy+xqlsyNWlkd6w+6GLB4b0NqqIEn2ehpO4adjJyz9cC4ZW2DFr8xqVYFAt/F8nUFzqD4RNGvfqw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=imCysVDJD/5CfqoVmE3yxThlJlL+sTCqaOveqBkRwHo=;
 b=HzWUxenw53eWSEyXxLso+8pOHnHPEyrZu3SFxumUKAx6HlGjsh6iUbRH2z/PlL47A6ysGZq6qhGQq8xhQaORkn6tkyhrSBG//gkP1XHXP7/nU7X9TL7UnT8L58pNJXTzPnHpCk3cY0vjWUVzZOck3JKibM3G7h6u9CyYHcEGNeQ=
Received: from DM5PR15MB1163.namprd15.prod.outlook.com (10.173.215.141) by
 DM5PR15MB1916.namprd15.prod.outlook.com (10.174.247.144) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2178.16; Thu, 15 Aug 2019 16:27:13 +0000
Received: from DM5PR15MB1163.namprd15.prod.outlook.com
 ([fe80::21cc:b41:96bc:f2ca]) by DM5PR15MB1163.namprd15.prod.outlook.com
 ([fe80::21cc:b41:96bc:f2ca%9]) with mapi id 15.20.2157.022; Thu, 15 Aug 2019
 16:27:13 +0000
From: Song Liu <songliubraving@fb.com>
To: Oleg Nesterov <oleg@redhat.com>
CC: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux MM
	<linux-mm@kvack.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        "Matthew
 Wilcox" <matthew.wilcox@oracle.com>,
        "Kirill A. Shutemov"
	<kirill.shutemov@linux.intel.com>,
        Kernel Team <Kernel-team@fb.com>,
        "William
 Kucharski" <william.kucharski@oracle.com>,
        "srikar@linux.vnet.ibm.com"
	<srikar@linux.vnet.ibm.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        "Kirill A.
 Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v12 5/6] khugepaged: enable collapse pmd for pte-mapped
 THP
Thread-Topic: [PATCH v12 5/6] khugepaged: enable collapse pmd for pte-mapped
 THP
Thread-Index: AQHVTXlDuUiBx4u3AUqTmiQ0C68ad6bxcvOAgAAJMACAAXXfAIAAEp4AgAAZUACABFVTAIAAE+cAgAAVvICAAGtUAIABKBiAgALZxQCAAGeLAA==
Date: Thu, 15 Aug 2019 16:27:13 +0000
Message-ID: <5EF80861-B72C-4B5C-AB2F-FB822367BD0C@fb.com>
References: <20190808163303.GB7934@redhat.com>
 <770B3C29-CE8F-4228-8992-3C6E2B5487B6@fb.com>
 <20190809152404.GA21489@redhat.com>
 <3B09235E-5CF7-4982-B8E6-114C52196BE5@fb.com>
 <4D8B8397-5107-456B-91FC-4911F255AE11@fb.com>
 <20190812121144.f46abvpg6lvxwwzs@box> <20190812132257.GB31560@redhat.com>
 <20190812144045.tkvipsyit3nccvuk@box>
 <2D11C742-BB7E-4296-9E97-5114FA58474B@fb.com>
 <857DA509-D891-4F4C-A55C-EE58BC2CC452@fb.com>
 <20190815101635.GD32051@redhat.com>
In-Reply-To: <20190815101635.GD32051@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::1:3f20]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b6c7283d-5979-499c-256d-08d7219d6e08
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:DM5PR15MB1916;
x-ms-traffictypediagnostic: DM5PR15MB1916:
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs: <DM5PR15MB19168A9179A3D979EF72D8B3B3AC0@DM5PR15MB1916.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 01304918F3
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(136003)(396003)(376002)(366004)(346002)(189003)(199004)(36756003)(53546011)(4744005)(102836004)(81156014)(6506007)(186003)(229853002)(81166006)(14454004)(86362001)(99286004)(33656002)(6486002)(76176011)(4326008)(6916009)(5660300002)(6246003)(8676002)(478600001)(6512007)(316002)(6436002)(54906003)(8936002)(6116002)(71200400001)(71190400001)(2906002)(476003)(256004)(486006)(446003)(11346002)(53936002)(7416002)(2616005)(76116006)(66476007)(66556008)(66446008)(57306001)(64756008)(305945005)(7736002)(46003)(25786009)(66946007)(91956017)(50226002);DIR:OUT;SFP:1102;SCL:1;SRVR:DM5PR15MB1916;H:DM5PR15MB1163.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: lAJ8q6frNwkdED2kDcMUsIKcqsUi+79zPBLIpV0z9HJ7ERvtsJN5F5CaDlugU5alN8/IlayUBnkObQGpL8MRV1pl3w4WWj5ddsP2AkXdgKyk6M9KkjRYDMlixUWmx+15gCTFLcREtpVT63Gn8sfWZs5DN1WQk9d2rvrQZUh31Zf6MoWV2fmFic8WvZPmCf5m6HHZoEZ/7138sWhawRlWryB053vMqSOfc+p5ZgakPu4FM1CSAxlR5N9C4sVvQ6eUy5v45/23tMQE0yCYc/OvUgv6bGcYC7gtG8eJ1Zvq1HpwkpMJhTZZna+91oHEY2HPO2Wpxx/tpRbM6uU//dEdcKNh0KPxbmIEqz1wfymknowo46EP21eBOaBwrNHeCE0TekOqwcnhyKV/0yZ0g+LlZ0B90/N+/IWafmnvreHDn0I=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <8DA236B55E549741B62C1855F61E2952@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: b6c7283d-5979-499c-256d-08d7219d6e08
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Aug 2019 16:27:13.4384
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: istBfoHTbgp9i3dzKb/Gu4Wxen7nV3Jtt1K8/SAmrJ9asCnLRl+edMLB3VTAHb3T7xoxSfNe+EOGtOKF/S1ZMw==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM5PR15MB1916
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-15_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=849 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908150159
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Aug 15, 2019, at 3:16 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>=20
> Hi Song,
>=20
> sorry, I forgot to reply to this email,
>=20
> On 08/13, Song Liu wrote:
>>=20
>> Do you have further comments for the version below? If not, could you
>> please reply with your Acked-by or Reviewed-by?
>=20
> I see nothing wrong in the last series, no objections from me.
>=20
> I don't think I can't ack the changes in this area, but feel free to
> add my Reviewed-by.
>=20
> Oleg.
>=20

Thanks Oleg!

Will resend latest version shortly.=20

Song


