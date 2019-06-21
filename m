Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6006CC43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:45:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A574206B7
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:45:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="KSvIL8FZ";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="H7fUKcoB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A574206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B01A38E0003; Fri, 21 Jun 2019 09:45:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB2048E0001; Fri, 21 Jun 2019 09:45:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 979358E0003; Fri, 21 Jun 2019 09:45:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5F9FF8E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 09:45:40 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e16so4114142pga.4
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 06:45:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=uC4Bx9X6fgUoXCX3YCb/E1O6k1iheAK8w4uL3+9K5Zs=;
        b=JKzTuNuKmjKipi26W2gxzOhUtPLBFz2566v5rZrpPSUNOoD1AXZc9t15XKBU2snmLC
         t0q0R0RR5Jy5J23UrXfEMBJQSKJDvEvi07JdU2yfpTKWiCDshS9yuVvYWUxtP2+MphE9
         fjy9CQ9YrV151KwKY5ukzhrp/9nYLnA73JMBYWYCAJfqEtkxUrGpdj+3Ctx3FbjghSCL
         a7BDeZwvLJNzxXWsXflEJDFpf5IBah/YKMx6Sfeelt6fOekorrX5vfUmp78Yy1KpNJ6d
         6gHw7Rblrm6NOLDepEZOd+L0pLlulZsl/8by3ZhRgv32gD7up0fWWGuOOJi0XVwFHT55
         fCLw==
X-Gm-Message-State: APjAAAX4VEN9mLcK2k31qt9B9wCLAT3xime9TMrGvEZgd3zOYHtiBsfK
	ynrOa0f/GfZOP2/DiZflH2dqV24e6QeIbpUAG3uYwc1IUBVSYiexslhgcF41tTMc6guIR0Knruy
	g1IB7Ba6F9LVscZuVrpXwlHl8rwmpmM7ICn9RfFNn3dd3DVYUGjd1a9tVVR5Ew+WH1w==
X-Received: by 2002:a17:90a:db42:: with SMTP id u2mr6886822pjx.48.1561124740018;
        Fri, 21 Jun 2019 06:45:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwNslrQ9K9JeMIDKzg0k1nPYkOOVpC6SDOOEc0M3ZLbmBDRKtn9ccY1P/bSryWo4u7M8FKZ
X-Received: by 2002:a17:90a:db42:: with SMTP id u2mr6886768pjx.48.1561124739427;
        Fri, 21 Jun 2019 06:45:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561124739; cv=none;
        d=google.com; s=arc-20160816;
        b=jRllBUd082A6UyTrBtdJzyxiAkLg/QtWOMtGi1BoKLnVznn40dV5sWGcvs8PxBIICG
         mYWnbYO/LGzIiK4YXZo86Jfrphn7A+ri50enZbN6qQHazCsw2Nneu7i2NB4COv/YTxRh
         IpeLTIqgWwTre+oNWmcZvGcnVkHEW5XY/vVv8cD3PAIixSaYcOq+jwp/lmoI4NfMGEnf
         qujuoJsNV8KRTD5BL5QCu/83XtaVoFeylDX/mcPE669srae+QZrhZJi3ebSTq1sm3+TQ
         6VLGKv08zduzkMGqWhUk7ZqvZRt/sXMvR1K8KdQ8NzvWqnf3bm27JrSf0Aa8iW/A8OYE
         O14w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=uC4Bx9X6fgUoXCX3YCb/E1O6k1iheAK8w4uL3+9K5Zs=;
        b=o0fMJXhh0svfMA6qHN5BoPaU8N+Gef9h8ezo55IaFCXGX+QyzIqNHRKAFPgJt9RW4B
         dCWP0G3PZmauyw9Oz2emie+QpIENQg7Ivs5FGz3q9FMxvvhfm9BmueJa/awdteHAemoO
         I55WkvzAt5jwTkV2IacJbYHob9Ffzsia8hsFYq66lsZg+3mZhKjeNnBsYP5342DXtm+m
         7QyVzLNwZSJMEFOVtIU6DbVEFW8BLfq47mOVELuzuXj+5kDQ3A7IcyJZ2YSgXXKJOoIT
         KDgVR9tNI64rSW/7c2ng/A+25mvCUgTm3ipBB/hZzCyfCSrnKmZkOvdh5YEVf0Jp7ZxN
         W4bg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=KSvIL8FZ;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=H7fUKcoB;
       spf=pass (google.com: domain of prvs=10751dd214=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10751dd214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id ay6si2704232plb.203.2019.06.21.06.45.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 06:45:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10751dd214=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=KSvIL8FZ;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=H7fUKcoB;
       spf=pass (google.com: domain of prvs=10751dd214=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=10751dd214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5LDjBw9025928;
	Fri, 21 Jun 2019 06:45:11 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=uC4Bx9X6fgUoXCX3YCb/E1O6k1iheAK8w4uL3+9K5Zs=;
 b=KSvIL8FZV0rWLKFOvYNSz4D+qi8b3uwybMeZm3vgwFRDvkNVChtVWUS/tVA8W0zVAjCw
 Lbavuf6hfx1F0iAA9Eohr/gGDdpNQgCfEwjkmSLV6RQxQaD/KhI9ByuD6DGmTfO8EUFR
 qZHMuhEkgL4FriwKbmi7k0yTQeMe2R7hDcM= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t8qjp1p83-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Fri, 21 Jun 2019 06:45:10 -0700
Received: from ash-exhub103.TheFacebook.com (2620:10d:c0a8:82::c) by
 ash-exhub202.TheFacebook.com (2620:10d:c0a8:83::6) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Fri, 21 Jun 2019 06:45:04 -0700
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.174) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Fri, 21 Jun 2019 06:45:04 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=uC4Bx9X6fgUoXCX3YCb/E1O6k1iheAK8w4uL3+9K5Zs=;
 b=H7fUKcoBl1sDK6JS6WfQxVydhTCUD/49WPnkbafq9paSu3BD6jzwEXVgLynKb7LgbIp6GdXgKmCg0rz8ZziFBAR1apUazqg90/XkkbSaEFBCbYtB5IsoZB2I0lvVR5qIcb8xUkKEUNPAgNA2T0eo7ihpQFcI0nE9KyByUpVY86U=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1119.namprd15.prod.outlook.com (10.175.8.20) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Fri, 21 Jun 2019 13:45:03 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.2008.014; Fri, 21 Jun 2019
 13:45:03 +0000
From: Song Liu <songliubraving@fb.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
CC: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        "oleg@redhat.com" <oleg@redhat.com>,
        "rostedt@goodmis.org"
	<rostedt@goodmis.org>,
        "mhiramat@kernel.org" <mhiramat@kernel.org>,
        "matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
        "Kernel
 Team" <Kernel-team@fb.com>
Subject: Re: [PATCH v4 5/5] uprobe: collapse THP pmd after removing all
 uprobes
Thread-Topic: [PATCH v4 5/5] uprobe: collapse THP pmd after removing all
 uprobes
Thread-Index: AQHVIhGkBNxZAI1nUkK1d2OfbYvmTqamGxWAgAAIBYCAAAVYgIAAAncA
Date: Fri, 21 Jun 2019 13:45:03 +0000
Message-ID: <4B58B3B3-10CB-4593-8BEC-1CEF41F856A1@fb.com>
References: <20190613175747.1964753-1-songliubraving@fb.com>
 <20190613175747.1964753-6-songliubraving@fb.com>
 <20190621124823.ziyyx3aagnkobs2n@box>
 <B72B62C9-78EE-4440-86CA-590D3977BDB1@fb.com>
 <20190621133613.xnzpdlicqvjklrze@box>
In-Reply-To: <20190621133613.xnzpdlicqvjklrze@box>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::1:ed23]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 37eca679-553c-47c9-817d-08d6f64ea98a
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1119;
x-ms-traffictypediagnostic: MWHPR15MB1119:
x-microsoft-antispam-prvs: <MWHPR15MB111952A5EA62772B1DBCAA5FB3E70@MWHPR15MB1119.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0075CB064E
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(376002)(366004)(136003)(39860400002)(396003)(189003)(199004)(66946007)(6506007)(53546011)(2906002)(102836004)(6116002)(6512007)(81166006)(81156014)(8676002)(86362001)(76176011)(68736007)(33656002)(186003)(76116006)(305945005)(66476007)(66446008)(66556008)(64756008)(7736002)(73956011)(256004)(99286004)(5660300002)(53936002)(36756003)(25786009)(316002)(71190400001)(71200400001)(6916009)(478600001)(6486002)(46003)(6246003)(14454004)(229853002)(486006)(50226002)(57306001)(446003)(11346002)(476003)(6436002)(2616005)(54906003)(8936002)(4326008);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1119;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: XWLQkvGs+wUS8MbEqjKrJ2KKkEiGh3RPcMQhzVV/gaBmh6aCxMsKe4ZA+68ysmTuu01CIeukfj2DycjWQnVgE2sj2bJJ0ln02kWI2n+8yVJVXTI2Z9X5GUBL5Kd2hbXSm1z1rZP2fI2XHBRdM9yUj2MejFvigkF5DHjd0U+jerKNHmhwQw7ZJGTKjJPu+Dziv4ju9V8f6Dc24R0OR4ZJcahA1ilv6yOMWJ5h5XPny7oavuzzWg3lNPfxhjC0hMFSBwKOB1QSLOldWcryOjA+jRD8pxuxgcNNz7LJBv3hO/HIYWsb+q0oEJa+uftFhzWo2zqnTMimKCLsW3yvgfobxjlVuf+Dbjm8fUtrlw9WCg/j0YGfGR+NSVeYi4g8wVKWl+h3AJabgPdqnYFzLEXnhfceE6ju6xo39fX10D7jYEA=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <B9866EA11D85E042B406BAB3B1F95438@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 37eca679-553c-47c9-817d-08d6f64ea98a
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Jun 2019 13:45:03.0471
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1119
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-21_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=741 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906210115
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 21, 2019, at 6:36 AM, Kirill A. Shutemov <kirill@shutemov.name> wr=
ote:
>=20
> On Fri, Jun 21, 2019 at 01:17:05PM +0000, Song Liu wrote:
>>=20
>>=20
>>> On Jun 21, 2019, at 5:48 AM, Kirill A. Shutemov <kirill@shutemov.name> =
wrote:
>>>=20
>>> On Thu, Jun 13, 2019 at 10:57:47AM -0700, Song Liu wrote:
>>>> After all uprobes are removed from the huge page (with PTE pgtable), i=
t
>>>> is possible to collapse the pmd and benefit from THP again. This patch
>>>> does the collapse.
>>>>=20
>>>> An issue on earlier version was discovered by kbuild test robot.
>>>>=20
>>>> Reported-by: kbuild test robot <lkp@intel.com>
>>>> Signed-off-by: Song Liu <songliubraving@fb.com>
>>>> ---
>>>> include/linux/huge_mm.h |  7 +++++
>>>> kernel/events/uprobes.c |  5 ++-
>>>> mm/huge_memory.c        | 69 +++++++++++++++++++++++++++++++++++++++++
>>>=20
>>> I still sync it's duplication of khugepaged functinallity. We need to f=
ix
>>> khugepaged to handle SCAN_PAGE_COMPOUND and probably refactor the code =
to
>>> be able to call for collapse of particular range if we have all locks
>>> taken (as we do in uprobe case).
>>>=20
>>=20
>> I see the point now. I misunderstood it for a while.=20
>>=20
>> If we add this to khugepaged, it will have some conflicts with my other=
=20
>> patchset. How about we move the functionality to khugepaged after these
>> two sets get in?=20
>=20
> Is the last patch of the patchset essential? I think this part can be don=
e
> a bit later in a proper way, no?

Technically, we need this patch to regroup pmd mapped page, and thus get=20
the performance benefit after the uprobe is detached.=20

On the other hand, if we get the first 4 patches of the this set and the=20
other set in soonish. I will work on improving this patch right after that.=
.

Thanks,
Song=

