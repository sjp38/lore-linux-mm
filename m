Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A235C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 16:38:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17F7E21925
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 16:38:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="SjJb+ti8";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="JdpF17kN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17F7E21925
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9D9E8E0003; Fri, 15 Feb 2019 11:38:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4D608E0001; Fri, 15 Feb 2019 11:38:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93B778E0003; Fri, 15 Feb 2019 11:38:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5477D8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 11:38:11 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id y1so7176950pgo.0
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 08:38:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=oILiAclxTDisBTUNOB4lM3TfY0Ee+VDWLB/xhSdB5Qw=;
        b=W4X340vJb+4A+Hq5Fd2xhRIze1Ugpn23FFHsmEDoiwTTWeaDS4u2G3KY14jEQy4qRH
         xXZUAKt3ARwguYhoCdjo68HC/GHFW1QBDlTfaKQYeGXc27bY/keoGVZ0n4xHma69Ppvl
         tQrJRmRuZf2IHgmSYFBqVQQjmUtBQnmaWM4Wqs8/hTGWlX35C6e9iHa9nlOaYGUdRl3W
         SPJz8yHFc7KkqmBzbrJ/2quqrHCOEMYX00yQct9E6lc2OlTjX0jwJCiNcKkhuelnc6kq
         bVvFimW8HFmzPCkaHXkqqv6qsW/YxQCgfx5ijh+T+N+j5w3iRu+T3ftZn8pdESWpOBUb
         +cQg==
X-Gm-Message-State: AHQUAuZXQ602IYSddx1lQUisnW5z0/Sn/Hgx0t5uvz5SChkvqrLrkDPd
	bMnhs1Q8NnRds46MPl2Qowfd+oGtytuXY4vv3UGpAme99kxdWN6rlQySvZtApjAL6bt1Lo+JFrF
	4Ok0U18Pq8NOhQ7450JLnrVoab/EP6Fv8moSS1YucLYvpAPQL3tLQNNbaUEQMBEXDEA==
X-Received: by 2002:a62:61c3:: with SMTP id v186mr10775657pfb.55.1550248690891;
        Fri, 15 Feb 2019 08:38:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib9eaIX20T3mdxq4U20SscG2BEINLD1ucb32jpzXUW16txs5MZ0C5wE/XvDVRtLPSBEgec6
X-Received: by 2002:a62:61c3:: with SMTP id v186mr10775612pfb.55.1550248690181;
        Fri, 15 Feb 2019 08:38:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550248690; cv=none;
        d=google.com; s=arc-20160816;
        b=VxdcGLnCA2k7R/6oRJ+pCBgiFsRnWgFYA+XtOPGXwiS7S9ujbyb+VYjUy7TRUrCdFa
         qr687tpbHAoXSLNk2F8wNtNZBHfB+eu91crVjd1YONkc3QXVzbuhEtTZDXCu6FPGB5y2
         WPg6vAB1MxcW511eaHMoXrTwLZnVx+Kut2jd8jv4LlgkBIB8TPX5xQPiopLFIfPz1r6/
         0FyysnDqqrZI35FhGleTj31XU0OgixKavnHS59jhxHHnDeYPSEkL9eBHL20K5na3gRZ8
         yw0Sx0d9cCJo60fp90mYTd1O2Pj7RODzLLLzqN+sERL5t1LIJ+waTFdl49oVK5tYIyvL
         N3RA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=oILiAclxTDisBTUNOB4lM3TfY0Ee+VDWLB/xhSdB5Qw=;
        b=tY0C3VWzsvmI1rFqDJA6TuVClp5N4Wy3eRs7zrcGbCb6C1ca+45929R6f6U4qpVAYN
         CufYzq1tjSZ20lrb0UD1d6M27g/bSz2gaed8tav/2lIQ/uTHj5q7Z3PDNx16xkLueUmJ
         19GzoZimfaJLRcn7c+ZnzWPeMoEwKKypO8qWO16C829nEiPXBrEt3LCX1tAwXwcaFyJk
         tZbBVehfjL12HGLMgFgE1F5R0KZnnjrK2iV585xZO0hmJbJVYMKWTm7Y4u6cF7rxOgV2
         8ljnkP2kselPNTOmF5VO3eUqpAxs/uwzCEApnKVQZG8DxAv+Lt8pA+hXxcJ/1Jl/Jn+j
         sxfg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=SjJb+ti8;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=JdpF17kN;
       spf=pass (google.com: domain of prvs=7949112413=davejwatson@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=7949112413=davejwatson@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id t22si5644732pga.463.2019.02.15.08.38.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 08:38:10 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=7949112413=davejwatson@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=SjJb+ti8;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=JdpF17kN;
       spf=pass (google.com: domain of prvs=7949112413=davejwatson@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=7949112413=davejwatson@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1FGWt8b005408;
	Fri, 15 Feb 2019 08:38:09 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : content-type : content-id :
 content-transfer-encoding : mime-version; s=facebook;
 bh=oILiAclxTDisBTUNOB4lM3TfY0Ee+VDWLB/xhSdB5Qw=;
 b=SjJb+ti8zYy2bWjOfA6Gh8RyDC6hpHkolz7QHm+t+eqpA/RDu+zb1kbc9eksYHg0UBFF
 r/iExueO54nY5+U9753FkyxMC8kh42BcWUKEGzPfcKjOpT0g2B1ETHubVMcA7Uioo+85
 b332gycafljq62QHfp5zxtq7WOyUYqphaRk= 
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qp0txg22w-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Fri, 15 Feb 2019 08:38:09 -0800
Received: from prn-hub02.TheFacebook.com (2620:10d:c081:35::126) by
 prn-hub01.TheFacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Fri, 15 Feb 2019 08:38:07 -0800
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.26) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Fri, 15 Feb 2019 08:38:07 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=oILiAclxTDisBTUNOB4lM3TfY0Ee+VDWLB/xhSdB5Qw=;
 b=JdpF17kNHk4UY7QcNGLRNC/6behcDcuUUwcKf/zgr2naseV7AisFdh/1mrZbXL/L7g7Ti29bvaTyihZhNV+QypMD9WgGXor0oUecSae62l9lV5M3P1QLrqxGZSlbuCeFuYOLwBTHz5c1/CkciqEoON7mWQA2nqhdSBFZDWjvo9w=
Received: from MWHPR15MB1134.namprd15.prod.outlook.com (10.175.2.12) by
 MWHPR15MB1693.namprd15.prod.outlook.com (10.175.141.151) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1622.19; Fri, 15 Feb 2019 16:38:05 +0000
Received: from MWHPR15MB1134.namprd15.prod.outlook.com
 ([fe80::93f:b6fe:a6e9:80dc]) by MWHPR15MB1134.namprd15.prod.outlook.com
 ([fe80::93f:b6fe:a6e9:80dc%8]) with mapi id 15.20.1601.023; Fri, 15 Feb 2019
 16:38:05 +0000
From: Dave Watson <davejwatson@fb.com>
To: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>
CC: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Maged Michael
	<magedmichael@fb.com>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: [LSF/MM TOPIC] Improve performance of fget/fput
Thread-Topic: [LSF/MM TOPIC] Improve performance of fget/fput
Thread-Index: AQHUxUzTqmvWMcBbakqADGu841l6Tg==
Date: Fri, 15 Feb 2019 16:38:05 +0000
Message-ID: <20190215163852.6ls6bchssazma6bm@davejwatson-mba.local>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: NeoMutt/20180716
x-clientproxiedby: BYAPR08CA0045.namprd08.prod.outlook.com
 (2603:10b6:a03:117::22) To MWHPR15MB1134.namprd15.prod.outlook.com
 (2603:10b6:320:22::12)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::1:5b6b]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 937aeb10-44f2-4279-d6b0-08d69363f492
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:MWHPR15MB1693;
x-ms-traffictypediagnostic: MWHPR15MB1693:
x-microsoft-exchange-diagnostics: 1;MWHPR15MB1693;20:004eTB3wBN9EasGDlcpi5/JlQcufGjjWApEx0bb1cniwMhQgyAb4zfD+yYF9OygsLR3pZoHlbablub7+K4bz2v0mtGJac9lnpAs771mn15M/6Gr1QEAubTVQwLaKAVz18tjHUrr6A00JJhYYlVGj/hzRJx4b378YOCou7ozciHM=
x-microsoft-antispam-prvs: <MWHPR15MB16937596A9754DB8DEE58DAFDD600@MWHPR15MB1693.namprd15.prod.outlook.com>
x-forefront-prvs: 09497C15EB
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(376002)(346002)(136003)(396003)(366004)(199004)(189003)(7736002)(386003)(8936002)(99286004)(102836004)(6506007)(52116002)(81166006)(33896004)(14454004)(2906002)(98436002)(2501003)(25786009)(561944003)(81156014)(53936002)(8676002)(105586002)(106356001)(2351001)(5640700003)(6916009)(6486002)(71200400001)(71190400001)(6436002)(4326008)(256004)(97736004)(6116002)(478600001)(305945005)(9686003)(6512007)(476003)(316002)(486006)(1076003)(68736007)(54906003)(86362001)(58126008)(46003)(186003);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1693;H:MWHPR15MB1134.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: f7Uo61VHvsEGrirHwGzqpDGuZB+6Ltw5ofoiBeSK8EP8pagxzMOT1OQa5YjO+hG+LyDOY+6ffxEm8fKAdOwysMpzmIxCl42Oew7ZkF/EB5yiyvaaY87VEVWzJWTQgXvSRBlnFx5QgQpan5UiMjjm14a8JPHoU83qNd7HHqsPOCC7pIMd5ErbfDKEcFoJ2Jf+ys+vJoHg62jdhB8Et+NJ9N0p66Hb12wYTLdqbE38wtdDqkAuz9x9bAcb1hH96yDJAb39yl4wGzC3IMGXDpZhHUFaeqrYCZaZ2HQ0vqk8KnkknPJxO1GsgHYOlrPiojRuRZPqe+VrQIbdPxBZ9gy24PvhTD8BbiPxx63TdwIJs4C5J5sHRmayVFHdXTLp6fqNo/0W1k6Mp0bpUMEdkUqwHuP28WyNBrF0yOjYK5D8e/A=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <3D753BDD5C51904C81AE759469E1EF38@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 937aeb10-44f2-4279-d6b0-08d69363f492
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Feb 2019 16:38:02.3744
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1693
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-15_12:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In some of our hottest network services, fget_light + fput overhead
can represent 1-2% of the processes' total CPU usage.  I'd like to
discuss ways to reduce this overhead.

One proposal we have been testing is removing the refcount increment
and decrement, and using some sort of safe memory reclamation
instead. The hottest callers include recvmsg, sendmsg, epoll_wait, etc
- mostly networking calls, often used on non-blocking sockets.  Often
we are only incrementing and decrementing the refcount for a very
short period of time, ideally we wouldn't adjust the refcount unless
we know we are going to block.

We could use RCU, but we would have to be particularly careful that
none of these calls ever block, or ensure that we increment the
refcount at the blocking locations.  As an alternative to RCU, hazard
pointers have similar overhead to SRCU, and could work equally well on
blocking or nonblocking syscalls without additional changes.

(There were also recent related discussions on SCM_RIGHTS refcount
cycle issues, which is the other half of a file* gc)

There might also be ways to rearrange the file* struct or fd table so
that we're not taking so many cache misses for sockfd_lookup_light,
since for sockets we don't use most of the file* struct at all.

