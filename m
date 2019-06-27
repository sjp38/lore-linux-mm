Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A875C4321A
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 21:24:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1559620828
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 21:24:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="YPadNksS";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="cONWwgOq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1559620828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 983856B0003; Thu, 27 Jun 2019 17:24:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 934B08E0003; Thu, 27 Jun 2019 17:24:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D7A28E0002; Thu, 27 Jun 2019 17:24:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5CFE66B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 17:24:37 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id f11so4993865ywc.4
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 14:24:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=sNOu3HJF9ywLPRfufTO5OfZzrVkrGyiQosuhKaX+PKU=;
        b=bEBdr70Wb3a+QMg9gtiAql+6eS5l7aD27bTDmw2dd/JRNthU2sEVl9J5i9b72bm2dR
         N+D1NE8ASYPaBLDZil6BEINEab2xT5LwkbD8yLOli/dkCHTd+ShLgxC28V20CxprY8f/
         bI9uZxWmX3UkUXoqEd8EIJcUlF14PzCNfQ/W2uNkqn22V4E9sYeAMyKTKbNhcp7+MqG/
         NH1vTu1nOgfkK3GW63GFElfhSTmWezreBYL+IUbilLfHR27dDCb9uQBdQXht19KGeF9M
         sz9hiSEZ1EoTq4BauJ00uCFhtHWguhZAocNc3deD0ZShKFGONZFIlXstewYrfhaBan7M
         MHzA==
X-Gm-Message-State: APjAAAWPH8Mc2nJU8KISDcAyxyCtqvV+n9JTeHORVFXxkiCelhaDcQ3h
	Z/vZSj3u73/B9D+U1JBQtyT/364TOo01H8QBKKdKL6V6QYePeeIQ+s0bLOCGtpfPcEWWvxBSKXm
	u1X3PWyI6HF5F0sNP+xjDxoUxit0fp8Z6+UzOvKyb5XT5QDoMPlUNoO4XI6ALygo/lQ==
X-Received: by 2002:a0d:eb4f:: with SMTP id u76mr3281699ywe.285.1561670676961;
        Thu, 27 Jun 2019 14:24:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEcpKpb1kUZNblt7QD25QhQ8CzLhRFIZRoOXde28+CoSQN/i5s34ziidwI1lT/MiX+ZNqq
X-Received: by 2002:a0d:eb4f:: with SMTP id u76mr3281677ywe.285.1561670676356;
        Thu, 27 Jun 2019 14:24:36 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id p71si109191yba.319.2019.06.27.14.24.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 14:24:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1081203066=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=YPadNksS;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=cONWwgOq;
       arc=fail (signature failed);
       spf=pass (google.com: domain of prvs=1081203066=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1081203066=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x5RLJSFP005746;
	Thu, 27 Jun 2019 14:24:29 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=sNOu3HJF9ywLPRfufTO5OfZzrVkrGyiQosuhKaX+PKU=;
 b=YPadNksSiOYGqw+BAyyZpfaWwww3OIwZFi6ng0BIayOywkVkfgsAdBfmb9YVPMxK74It
 Q0uaE6NWTpZtpHPvoM9tcirgjyokdmfxVBQT/AmILxIwLyHYd0///NDHfpeoaXlwW0aW
 daP1EJnhvurny0ESMh7mg/6yf0Nr/PAJRBc= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0001303.ppops.net with ESMTP id 2tcc49wc1s-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Thu, 27 Jun 2019 14:24:28 -0700
Received: from ash-exhub202.TheFacebook.com (2620:10d:c0a8:83::6) by
 ash-exhub103.TheFacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 27 Jun 2019 14:24:26 -0700
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.103) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Thu, 27 Jun 2019 14:24:26 -0700
ARC-Seal: i=1; a=rsa-sha256; s=testarcselector01; d=microsoft.com; cv=none;
 b=ybgO0aecehDfhCD9kKZmqGgtcrKd6UbTnI6mKmzghb9Mnr96LFZ2p/FQR9M1j+XzaSlUCT0/483puHxPA9WYqRzT/Bk3m0m0LLKYZp4da4MP1n1tfjcdzFtsGfckU7Ry01E2p2vABvyiUeNqZH0fihYqc/PXoQJZjEOvZ6EX67E=
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=testarcselector01;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=sNOu3HJF9ywLPRfufTO5OfZzrVkrGyiQosuhKaX+PKU=;
 b=u/nonQjW2/rPfIadF188kpIEeO7AH1eB2ra2JkUOTkMLM3Lb3/16hJSlyaskfwYhac/YdMlNObfwVjjD01bd9kavSBqY3Xks/utFWTuR1RQm+BvCHaFCnevRUmRtW9TWhUlDSCRccKit0vXXHX7rO3dePfsaXBXnylIxaSylqxY=
ARC-Authentication-Results: i=1; test.office365.com
 1;spf=none;dmarc=none;dkim=none;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=sNOu3HJF9ywLPRfufTO5OfZzrVkrGyiQosuhKaX+PKU=;
 b=cONWwgOqiZvAyWfGsIE5JImH/EeoYWyEdx0i35coVnU44YH+rI70/oJFtukfMwsDwEUb1Fbmerf+wkYujPyNwU38S7yFmSRfU7aiGGIz2cDUfguMXYwVzxVxCILeR2rmsemJktFjhYGBkfnq9cBlL7jamXSiLJ4sUkhH7D9bR6w=
Received: from BN8PR15MB2626.namprd15.prod.outlook.com (20.179.137.220) by
 BN8PR15MB2979.namprd15.prod.outlook.com (20.178.220.83) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Thu, 27 Jun 2019 21:24:25 +0000
Received: from BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::e594:155f:a43:92ad]) by BN8PR15MB2626.namprd15.prod.outlook.com
 ([fe80::e594:155f:a43:92ad%6]) with mapi id 15.20.2008.018; Thu, 27 Jun 2019
 21:24:25 +0000
From: Roman Gushchin <guro@fb.com>
To: Waiman Long <longman@redhat.com>
CC: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
        "David Rientjes" <rientjes@google.com>,
        Joonsoo Kim <iamjoonsoo.kim@lge.com>,
        "Andrew Morton" <akpm@linux-foundation.org>,
        Alexander Viro
	<viro@zeniv.linux.org.uk>,
        Jonathan Corbet <corbet@lwn.net>,
        Luis Chamberlain
	<mcgrof@kernel.org>,
        "Kees Cook" <keescook@chromium.org>,
        Johannes Weiner
	<hannes@cmpxchg.org>,
        "Michal Hocko" <mhocko@kernel.org>,
        Vladimir Davydov
	<vdavydov.dev@gmail.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Shakeel Butt
	<shakeelb@google.com>,
        "Andrea Arcangeli" <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm, slab: Extend vm/drop_caches to shrink kmem slabs
Thread-Topic: [PATCH 2/2] mm, slab: Extend vm/drop_caches to shrink kmem slabs
Thread-Index: AQHVKrRnjGLXeWaE8kq5EhXDbrxOt6auY3OAgAGdGgCAAAdmgA==
Date: Thu, 27 Jun 2019 21:24:25 +0000
Message-ID: <20190627212419.GA25233@tower.DHCP.thefacebook.com>
References: <20190624174219.25513-1-longman@redhat.com>
 <20190624174219.25513-3-longman@redhat.com>
 <20190626201900.GC24698@tower.DHCP.thefacebook.com>
 <063752b2-4f1a-d198-36e7-3e642d4fcf19@redhat.com>
In-Reply-To: <063752b2-4f1a-d198-36e7-3e642d4fcf19@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR10CA0016.namprd10.prod.outlook.com (2603:10b6:301::26)
 To BN8PR15MB2626.namprd15.prod.outlook.com (2603:10b6:408:c7::28)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::d870]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 85e7d3af-a785-47e9-895c-08d6fb45d42b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BN8PR15MB2979;
x-ms-traffictypediagnostic: BN8PR15MB2979:
x-microsoft-antispam-prvs: <BN8PR15MB29796CB922220D28EDB2B5B4BEFD0@BN8PR15MB2979.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6430;
x-forefront-prvs: 008184426E
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(136003)(39860400002)(396003)(346002)(366004)(199004)(189003)(81156014)(8676002)(6486002)(8936002)(6436002)(81166006)(229853002)(76176011)(66556008)(64756008)(52116002)(66946007)(73956011)(66476007)(2906002)(66446008)(99286004)(446003)(11346002)(486006)(476003)(46003)(53936002)(14444005)(102836004)(7736002)(305945005)(186003)(256004)(9686003)(53546011)(386003)(6512007)(6506007)(316002)(5660300002)(68736007)(25786009)(1076003)(71200400001)(54906003)(6116002)(478600001)(14454004)(7416002)(6246003)(33656002)(6916009)(4326008)(86362001)(71190400001);DIR:OUT;SFP:1102;SCL:1;SRVR:BN8PR15MB2979;H:BN8PR15MB2626.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: LijSsYHZvhuTlMC7mP6/vlfb8V4T4r78OTs4AjMiy9BYneidFCZfxZNlhOiRJ7Rfqt82SvEJD+qZnZFA64DIIOorpos5N8GA7dPgwW+VK3PUWJwfN2v9iX9VRuGYgcrie2AuNHvEYPtdcRLvKSdlJed3kyxZEldRV+GCNcVIiVPIbkIDQx85p7wBipqZjRgS5nK87PfJQQ6T9oHwsTMNZ7MFQABdMAOWQnjdWX3DYiS20oS4lGIp/+IZ1jXXLZYh6OaGX23jdZtfE5b8OQJP7wwyhnzsK42JHggVCqCq3ftoXN3+KFbA30WNkxY3CCM+NOa/GcGPfD99GNFIb7ERi3ikyUMt6xYirNR+pnJuZLAHLu29i76kct7xr2qAkdezbTYihtKzAl/15KE43+A0fOLKlw9SKjJ3FISZR6twn04=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <7E5727AEB2313B4682CD26ADDCB22D2A@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 85e7d3af-a785-47e9-895c-08d6fb45d42b
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Jun 2019 21:24:25.4110
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN8PR15MB2979
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-27_14:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906270244
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 27, 2019 at 04:57:50PM -0400, Waiman Long wrote:
> On 6/26/19 4:19 PM, Roman Gushchin wrote:
> >> =20
> >> +#ifdef CONFIG_MEMCG_KMEM
> >> +static void kmem_cache_shrink_memcg(struct mem_cgroup *memcg,
> >> +				    void __maybe_unused *arg)
> >> +{
> >> +	struct kmem_cache *s;
> >> +
> >> +	if (memcg =3D=3D root_mem_cgroup)
> >> +		return;
> >> +	mutex_lock(&slab_mutex);
> >> +	list_for_each_entry(s, &memcg->kmem_caches,
> >> +			    memcg_params.kmem_caches_node) {
> >> +		kmem_cache_shrink(s);
> >> +	}
> >> +	mutex_unlock(&slab_mutex);
> >> +	cond_resched();
> >> +}
> > A couple of questions:
> > 1) how about skipping already offlined kmem_caches? They are already sh=
runk,
> >    so you probably won't get much out of them. Or isn't it true?
>=20
> I have been thinking about that. This patch is based on the linux tree
> and so don't have an easy to find out if the kmem caches have been
> shrinked. Rebasing this on top of linux-next, I can use the
> SLAB_DEACTIVATED flag as a marker for skipping the shrink.
>=20
> With all the latest patches, I am still seeing 121 out of a total of 726
> memcg kmem caches (1/6) that are deactivated caches after system bootup
> one of the test systems. My system is still using cgroup v1 and so the
> number may be different in a v2 setup. The next step is probably to
> figure out why those deactivated caches are still there.

It's not a secret: these kmem_caches are holding objects, which are in use.
It's a drawback of the current slab accounting implementation: every
object holds a whole page and the corresponding kmem_cache. It's optimized
for a large number of objects, which are created and destroyed within
the life of the cgroup (e.g. task_structs), and it works worse for long-liv=
ing
objects like vfs cache.

Long-term I think we need a different implementation for long-living object=
s,
so that objects belonging to different memory cgroups can share the same pa=
ge
and kmem_caches.

It's a fairly big change though.

>=20
> > 2) what's your long-term vision here? do you think that we need to shri=
nk
> >    kmem_caches periodically, depending on memory pressure? how a user
> >    will use this new sysctl?
> Shrinking the kmem caches under extreme memory pressure can be one way
> to free up extra pages, but the effect will probably be temporary.
> > What's the problem you're trying to solve in general?
>=20
> At least for the slub allocator, shrinking the caches allow the number
> of active objects reported in slabinfo to be more accurate. In addition,
> this allow to know the real slab memory consumption. I have been working
> on a BZ about continuous memory leaks with a container based workloads.
> The ability to shrink caches allow us to get a more accurate memory
> consumption picture. Another alternative is to turn on slub_debug which
> will then disables all the per-cpu slabs.

I see... I agree with Michal here, that extending drop_caches sysctl isn't
the best idea. Isn't it possible to achieve the same effect using slub sysf=
s?

Thanks!

