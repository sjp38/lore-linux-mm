Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CECC9C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 14:41:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90A1125B3C
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 14:41:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nutanix.com header.i=@nutanix.com header.b="SYhtREIR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90A1125B3C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nutanix.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27AC46B026E; Thu, 30 May 2019 10:41:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22B946B026F; Thu, 30 May 2019 10:41:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F4766B0270; Thu, 30 May 2019 10:41:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id CB4D56B026E
	for <linux-mm@kvack.org>; Thu, 30 May 2019 10:41:54 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id z2so4734214pfb.12
        for <linux-mm@kvack.org>; Thu, 30 May 2019 07:41:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:thread-topic
         :thread-index:date:message-id:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=O8i9IqaaD1CRb6cjs0t1uFf86N1aw0xAHzhZKdyNk5c=;
        b=aVVuuH20Mt4BgPTkLa9vEbiwAiZQs7oPyEWMwNR0P6Y/JdNu/hxHOV7s1bIx12vvNg
         kP9Ad4DbTINBsWZhh2Lm9rKs5Avvb4J223pseimMp2mbxExll15od16PbFUYFP7ogHqr
         0+95KfejmzACPvN8nGhs1scw4f1QMC5BFDzuiiTAXNQf2PM0pYedJXZq58SO36rPtYDt
         Mtpdav0+2g49M64xfaJhd3zurKt9b9n6O/u4BZ/RPIs6Q4deMjG0Od8mySjaVapibLIE
         /C54MMYiGQvnQILXOOlNNebDpzJ7ECQQzF7zviSx/Oy8OkjUBS7jH95gqigPrhOoPLEP
         qxTw==
X-Gm-Message-State: APjAAAXVh+IpRBF7MgNVZueh8efoS+2ljKrw3+uLH9DKl3htmnWnbKWi
	vd+OfmayfHBre2BAhRJSgwfqsYOO8/5ns4UEe1MTM+hPhLThNXLU9P7sFQn2R8JcB5LwfQitWvk
	4oxDfhxJHN1gKyDpo2bMBEJWeN4edZh1StzG4N0OAhs2fByFOEF/JQOJkQ1Iu04MW8A==
X-Received: by 2002:a17:902:9698:: with SMTP id n24mr3980117plp.118.1559227314287;
        Thu, 30 May 2019 07:41:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyaqOhDEa20bcsxgxznoBfn+qu4CB+MpC6LnXm17kL0/yg/j6eBPcnLSBQFuUuWgZvpaKgz
X-Received: by 2002:a17:902:9698:: with SMTP id n24mr3980050plp.118.1559227313163;
        Thu, 30 May 2019 07:41:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559227313; cv=none;
        d=google.com; s=arc-20160816;
        b=QtwuB3DgNlJEq+GIQV07Xlcp6ORpBIW7l9WI4sLq6IkcGEfehndyFoII/sDuzqhGDq
         Hh3m/eFDxXXNvraVAmqR4a4qoAlgvoFIiRfddnY35UCtyE1g+bXrpfElDtu0t+zKr2+g
         XAxTggOdr2qf6StiwlRuLH/OMrzxyNstfJr9u/8d+SrJKgDm/zKcC+uwha7UX2fqxGUC
         ZifT5kxwTbUuAtaerI2NLK11NVun5lxxfQQWJqG3UNjLwcNRtdnMFrlxyEwq7cG5H8cI
         MAKm29fYc1aa6VOqtamIzlvRO1Jc8Cy4RGx+ImUZnp2krOzp5QELJB0pRLxnzi0i4b/J
         LAVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :to:from:dkim-signature;
        bh=O8i9IqaaD1CRb6cjs0t1uFf86N1aw0xAHzhZKdyNk5c=;
        b=cTEZK49MyY6hF9ZGnu5M8+pyBizis2LfW+fZd/sl+SQQqo6kXhTjhhJoPEZbX3V3ZJ
         kGBORamR+7XZSKJad29j8ZqezKE+m4Wf9MhEqkAz0PpsOIc59aLxb5ZR+zGqAMVVrvub
         ABVg55VooZwrxpukOLgU3VFZ2i6cuc/0v6Us5iulvu3S6/TJdovY2vwW4WwjR0eKqmxj
         UwYp/PHUJwU9akRP9JNLVIRgEcKGFU27EfBxAji8zJBCAIvVmpcLJHrTgDCouYDEuLKc
         QeAxcYXL2+EoRz4AHkBxfCTqMvDLA+O0Ri1Q76y7wReGt6YvQPhcqHlxlpSqvbrsKC11
         txfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nutanix.com header.s=proofpoint20171006 header.b=SYhtREIR;
       spf=pass (google.com: domain of thanos.makatos@nutanix.com designates 148.163.151.68 as permitted sender) smtp.mailfrom=thanos.makatos@nutanix.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nutanix.com
Received: from mx0a-002c1b01.pphosted.com (mx0a-002c1b01.pphosted.com. [148.163.151.68])
        by mx.google.com with ESMTPS id h20si3192417pgj.113.2019.05.30.07.41.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 07:41:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of thanos.makatos@nutanix.com designates 148.163.151.68 as permitted sender) client-ip=148.163.151.68;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nutanix.com header.s=proofpoint20171006 header.b=SYhtREIR;
       spf=pass (google.com: domain of thanos.makatos@nutanix.com designates 148.163.151.68 as permitted sender) smtp.mailfrom=thanos.makatos@nutanix.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nutanix.com
Received: from pps.filterd (m0127837.ppops.net [127.0.0.1])
	by mx0a-002c1b01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4UEaN5i006321
	for <linux-mm@kvack.org>; Thu, 30 May 2019 07:41:52 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nutanix.com; h=from : to : subject
 : date : message-id : content-type : content-transfer-encoding :
 mime-version; s=proofpoint20171006;
 bh=O8i9IqaaD1CRb6cjs0t1uFf86N1aw0xAHzhZKdyNk5c=;
 b=SYhtREIRnoKwFsq+Ig46okDt2FmQfif/+zuryhc/GCZBZU0hkBtTBtF/KSiSaAnnJhWO
 dQ68sJH+k7mWsjqia9vi0hdd3yNTTw04iHKXr/B9xS8NoPbKegSO5CBwANxsheeIBEkC
 tsXy29p/rTAgdcjpEeagXYqqtbCh4pH1xeewXGRUqUGzLNQcZdLHeGWbex365BFnzv+O
 CXd09KGS9zSJQ/I3x59Pywsy72YyFZWS8gqhiDfZHSar3Px09CAy+5W4IwqD5QYyggxc
 1dAqjUP/1tbJwpp3/iEFhrYm986vhWS+b6zfHnmK/dKI7+1owIquRAeEdw897ez+vfHX oQ== 
Received: from nam03-dm3-obe.outbound.protection.outlook.com (mail-dm3nam03lp2058.outbound.protection.outlook.com [104.47.41.58])
	by mx0a-002c1b01.pphosted.com with ESMTP id 2st3ee1898-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 30 May 2019 07:41:52 -0700
Received: from MN2PR02MB6205.namprd02.prod.outlook.com (52.132.174.26) by
 MN2PR02MB6144.namprd02.prod.outlook.com (52.132.173.85) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1922.21; Thu, 30 May 2019 14:41:50 +0000
Received: from MN2PR02MB6205.namprd02.prod.outlook.com
 ([fe80::25d5:60b3:a680:7ebd]) by MN2PR02MB6205.namprd02.prod.outlook.com
 ([fe80::25d5:60b3:a680:7ebd%3]) with mapi id 15.20.1922.021; Thu, 30 May 2019
 14:41:50 +0000
From: Thanos Makatos <thanos.makatos@nutanix.com>
To: linux-mm <linux-mm@kvack.org>
Subject: giving access of one process's memory to another via kernel module
Thread-Topic: giving access of one process's memory to another via kernel
 module
Thread-Index: AdUW9c2kWvTgUKxpQJGDn2H9Qw9pvQ==
Date: Thu, 30 May 2019 14:41:50 +0000
Message-ID: 
 <MN2PR02MB62059A7369140242963542088B180@MN2PR02MB6205.namprd02.prod.outlook.com>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [62.254.189.133]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 3cbe51d9-6804-4a6b-8529-08d6e50cf383
x-microsoft-antispam: 
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:MN2PR02MB6144;
x-ms-traffictypediagnostic: MN2PR02MB6144:
x-proofpoint-crosstenant: true
x-microsoft-antispam-prvs: 
 <MN2PR02MB6144BD2E1B458F55C95929568B180@MN2PR02MB6144.namprd02.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 00531FAC2C
x-forefront-antispam-report: 
 SFV:NSPM;SFS:(10019020)(136003)(366004)(39860400002)(376002)(396003)(346002)(199004)(189003)(26005)(81166006)(81156014)(102836004)(8676002)(99286004)(486006)(25786009)(6506007)(2906002)(186003)(66476007)(66556008)(68736007)(8936002)(33656002)(44832011)(6916009)(478600001)(66946007)(66446008)(86362001)(64756008)(14454004)(7696005)(305945005)(7736002)(76116006)(14444005)(71190400001)(66066001)(9686003)(55016002)(52536014)(3846002)(476003)(71200400001)(6436002)(256004)(5660300002)(4744005)(53936002)(73956011)(6116002)(74316002)(316002)(64030200001);DIR:OUT;SFP:1102;SCL:1;SRVR:MN2PR02MB6144;H:MN2PR02MB6205.namprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: nutanix.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 
 6ZPeEStUObz8e/f62TJLW6qpDax6Qetka7jzFIYx87PF05GJnePYmCAO3SyN/ZteejkAWHhJ3inFkI8hsvNUkepuir6tn1A+0+HDns95w2bNrX/eWvQxUJL+noYUDQGOdpR95sQ9oKShbqVzP6T2Y3cyg3o+RfT8Lirru5RUDT9WBQ5+JR0WJ9+uXmbxx9RRjczWdLqsO/+3Ky5jIwCzUCa0vs3/Pp7cdkx1GX8Yx8ugDd/LZyXB103TIaVFQWkFUg1N8MMdFFyylfjQqSV8vovXIiMXHPrB2lk5w8NJ0Melrg+IHCyZtlgqllR3EOgpFpBISvaBS8CxrUvtjeHkE72UBij/rNFJgRkRT53wv5luw2qg5q4OYnODKvOG1L+mFcFRFOBBUes3A3OMjTx1fl9HjU6jUS3TxBS6FTryXVg=
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: nutanix.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 3cbe51d9-6804-4a6b-8529-08d6e50cf383
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 May 2019 14:41:50.5815
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: bb047546-786f-4de1-bd75-24e5b6f79043
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: thanos.makatos@nutanix.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR02MB6144
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-30_08:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I'm prototyping a device driver that is backed by a userspace process (serv=
er) instead of a physical device. When a user process (client) submits an I=
/O, I want the server to have access to that memory.
=20
I've tried pinning the client pages (get_user_pages_fast) and inserting the=
m in the server's VM (with vm_insert_page while serving an mmap call from t=
his context).
=20
This works if the client allocated memory with MAP_SHARED. If not, vm_inser=
t_page fails with EINVAL (probably because the client's page has PageAnon=
=3D1 set).
=20
A real device would have access to this memory. Is there a way to make a vi=
rtual device (my server, implemented in a separate userspace context) have =
access to it?
=20
PS. I haven't managed to register to the list so please CC me to your repli=
es

