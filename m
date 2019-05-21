Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 454F9C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 14:49:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EEA3E2173E
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 14:49:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EEA3E2173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=hpe.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99A216B000C; Tue, 21 May 2019 10:49:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94A256B000D; Tue, 21 May 2019 10:49:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8132C6B000E; Tue, 21 May 2019 10:49:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 481AF6B000C
	for <linux-mm@kvack.org>; Tue, 21 May 2019 10:49:53 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 14so12301737pgo.14
        for <linux-mm@kvack.org>; Tue, 21 May 2019 07:49:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=pji8TOs7U/TrDCChBg6Op4M1YvYB63rqtpn3wsAM/7I=;
        b=K6WPE3rejvlhdz+hvkOeq83XOwsswmuVdI9C+xn3u8/wq6n8qwERpGQuW5QdzA39cq
         nZ3Lsj75jW++B+iIzo89lIdH1Pa1x/Gvd4k7yUC5g3YfB6obYvU45xxXR6F94Ok3txAm
         Sf9dDTnKo2L/+WkPsav4Sr0hfkTXE3TtbxwMxAS4v5GQkIeSQ6dGcOpksRqLA9/6aTUB
         rhoxaHGXZIJYFO/okOIKSkaRHuVaovSsHAPvlpC6lEJrdQio2PxOBYqj33IBMhSyPYDu
         Yb7mTKLKNcRv5VzQ9j/jQa7/0ksKCbQsVeT8PzkMKmuvniRYWjCdGUJzULDsHIFBhowx
         CDGA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of elliott@hpe.com designates 148.163.147.86 as permitted sender) smtp.mailfrom=elliott@hpe.com
X-Gm-Message-State: APjAAAXU7GTB/ktabhPjC28punqm1JhCrpU3oplyy7txnwNDMKJrDjLF
	Y8nAboF1Ka0Dhaz8PAvI+8y6+9mggQXehB7b83ZmhwBorM/umc1QvI9tv03YcYWSPhzYpYlcoDo
	jfh3eF6fYtokTcgvC0NkafvY70TPvGcmtu36uLpYVe696erUV51ayKG8V5WfEQEchBg==
X-Received: by 2002:a62:4d04:: with SMTP id a4mr15981239pfb.177.1558450192889;
        Tue, 21 May 2019 07:49:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKh4JKciqQ7bp1XmGzoI8HnnbNgB0P4iM8v4LEdSWphQ//Tb6uIzWfQs8N19clCD432jZ7
X-Received: by 2002:a62:4d04:: with SMTP id a4mr15981147pfb.177.1558450192182;
        Tue, 21 May 2019 07:49:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558450192; cv=none;
        d=google.com; s=arc-20160816;
        b=wdCONCITMOlmhKa+ge9poYikHYo/GE2KqioCgGKaDmktYBNvxIjxiFKxSHtHpUu66U
         5yC3vZ4ynTu9xDj4/2q+5xz/ne+TovlnUr2rSh9hB+NNT3u1KbI4pNWBnF1TvS9jPBr/
         JFfsZVERba/spvHEVqFxQMGO7IzZ2TCalSF0dxl4piyc+tBbRsn0TplGjr+S8/tv6JUM
         a1hwPFvQxW/yRytw7A0D2gMxdBvqb1tnDogwJ7tNMzmUCx9mTovvc+jcQtwBs4IZBmvY
         Te6EBNN5+qopDZmnNjQt27/5qF6RaENqW/jNbrXkjsupUwAWG/KFMLLWe6sKKqu+/C2R
         Qz1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=pji8TOs7U/TrDCChBg6Op4M1YvYB63rqtpn3wsAM/7I=;
        b=NRm1aoIZ66DgXG5bX7DGQ8it13vmIYFsEE21K2ZnacFied/lnd+GEwr4IuCIc34cxt
         QtZurjq+FHk+slg7KKgMP4lH+v5SlJqLGXjro0MeE9c4kvd+a9t9twyu5qbMY5/Ylmzn
         jEjmIGq86+SMwQNVqZWE/JebSmUNbNMN0oTqzDX12vD9+hLd9EetgL9+TWzMlnfxrBaz
         64gmz+2AlJ97daMGF/i+sY7L5qLAkGys2pUnYqoF87bBl8ByvbW+Nm8/9r/MBNWEoQI6
         ggwrP05CEQkEdo5bi83Wkb57nCmNSvQOUUf74WhJNtDS129J9IFRGU5YJRabkDA3lg0s
         R+Dg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of elliott@hpe.com designates 148.163.147.86 as permitted sender) smtp.mailfrom=elliott@hpe.com
Received: from mx0a-002e3701.pphosted.com (mx0a-002e3701.pphosted.com. [148.163.147.86])
        by mx.google.com with ESMTPS id x73si21266497pgx.167.2019.05.21.07.49.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 07:49:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of elliott@hpe.com designates 148.163.147.86 as permitted sender) client-ip=148.163.147.86;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of elliott@hpe.com designates 148.163.147.86 as permitted sender) smtp.mailfrom=elliott@hpe.com
Received: from pps.filterd (m0134422.ppops.net [127.0.0.1])
	by mx0b-002e3701.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4LEehgS008034;
	Tue, 21 May 2019 14:49:51 GMT
Received: from g2t2352.austin.hpe.com (g2t2352.austin.hpe.com [15.233.44.25])
	by mx0b-002e3701.pphosted.com with ESMTP id 2smjsyge3y-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Tue, 21 May 2019 14:49:51 +0000
Received: from G2W6311.americas.hpqcorp.net (g2w6311.austin.hp.com [16.197.64.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
	(No client certificate requested)
	by g2t2352.austin.hpe.com (Postfix) with ESMTPS id 444C5CA;
	Tue, 21 May 2019 14:49:50 +0000 (UTC)
Received: from G9W8672.americas.hpqcorp.net (16.220.49.31) by
 G2W6311.americas.hpqcorp.net (16.197.64.53) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3; Tue, 21 May 2019 14:49:49 +0000
Received: from G9W9210.americas.hpqcorp.net (2002:10dc:429b::10dc:429b) by
 G9W8672.americas.hpqcorp.net (2002:10dc:311f::10dc:311f) with Microsoft SMTP
 Server (TLS) id 15.0.1367.3; Tue, 21 May 2019 14:49:49 +0000
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (15.241.52.12) by
 G9W9210.americas.hpqcorp.net (16.220.66.155) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3 via Frontend Transport; Tue, 21 May 2019 14:49:49 +0000
Received: from AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM (10.169.7.147) by
 AT5PR8401MB0692.NAMPRD84.PROD.OUTLOOK.COM (10.169.7.144) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1922.15; Tue, 21 May 2019 14:49:47 +0000
Received: from AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM
 ([fe80::2884:44eb:25bf:b376]) by AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM
 ([fe80::2884:44eb:25bf:b376%12]) with mapi id 15.20.1922.016; Tue, 21 May
 2019 14:49:47 +0000
From: "Elliott, Robert (Servers)" <elliott@hpe.com>
To: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>,
        Dan Williams
	<dan.j.williams@intel.com>
CC: Linux MM <linux-mm@kvack.org>,
        linuxppc-dev
	<linuxppc-dev@lists.ozlabs.org>,
        linux-nvdimm <linux-nvdimm@lists.01.org>
Subject: RE: [PATCH] mm/nvdimm: Use correct #defines instead of opencoding
Thread-Topic: [PATCH] mm/nvdimm: Use correct #defines instead of opencoding
Thread-Index: AQHVCgChFb7/EbTm2EmzJ0DwQTd3laZp/p0AgAAB4ICAAAH7AIAACYkAgAsy44CAACJ3AIAAUp6Q
Date: Tue, 21 May 2019 14:49:47 +0000
Message-ID: <AT5PR8401MB1169DEEAA95D4E4EA9C61285AB070@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
References: <20190514025604.9997-1-aneesh.kumar@linux.ibm.com>
 <CAPcyv4iNgFbSq0Hqb+CStRhGWMHfXx7tL3vrDaQ95DcBBY8QCQ@mail.gmail.com>
 <f99c4f11-a43d-c2d3-ab4f-b7072d090351@linux.ibm.com>
 <CAPcyv4gOr8SFbdtBbWhMOU-wdYuMCQ4Jn2SznGRsv6Vku97Xnw@mail.gmail.com>
 <02d1d14d-650b-da38-0828-1af330f594d5@linux.ibm.com>
 <CAPcyv4jcSgg0wxY9FAM4ke9JzVc9Pu3qe6dviS3seNgHfG2oNw@mail.gmail.com>
 <87mujgcf0h.fsf@linux.ibm.com>
In-Reply-To: <87mujgcf0h.fsf@linux.ibm.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [2601:2c3:877f:e23c:fdc1:1746:34b1:a6c]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 8bde30a5-0cc3-4142-e927-08d6ddfb920f
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(4618075)(2017052603328)(7193020);SRVR:AT5PR8401MB0692;
x-ms-traffictypediagnostic: AT5PR8401MB0692:
x-microsoft-antispam-prvs: <AT5PR8401MB06927E80F27B0859F1AB8DD6AB070@AT5PR8401MB0692.NAMPRD84.PROD.OUTLOOK.COM>
x-ms-oob-tlc-oobclassifiers: OLM:1148;
x-forefront-prvs: 0044C17179
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(136003)(346002)(376002)(366004)(39860400002)(199004)(13464003)(189003)(7736002)(6246003)(9686003)(6116002)(54906003)(2906002)(8676002)(110136005)(53936002)(99286004)(316002)(33656002)(476003)(305945005)(4326008)(7696005)(71200400001)(81166006)(76176011)(71190400001)(81156014)(68736007)(8936002)(6506007)(25786009)(102836004)(6436002)(53546011)(229853002)(55016002)(256004)(74316002)(66556008)(64756008)(52536014)(66446008)(5660300002)(66476007)(4744005)(186003)(46003)(486006)(76116006)(73956011)(66946007)(478600001)(86362001)(14454004)(446003)(11346002);DIR:OUT;SFP:1102;SCL:1;SRVR:AT5PR8401MB0692;H:AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hpe.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: I6AvVHDPGKk7QMDyM6WBco+hI7j4gcsJhjY/RP65hwAnce/6EqoPnFr7NycudNWW9ykAfbvGBsXqofG9GOEdKXuVxkoghOugxPy3ZmPs5XmWsFNH7/nwWq/0P2CHf8xZIF6O1hM3qoOND1KbBukFQS0Jzsnga2R2c9sH0HvnWvjhsGh05GHPHbbWAety5ebD9Xi8jEgDd92n9XwaCsfvZ0OLzkVrA0qnk5HC5Vuq7M3iGWs8aU+8SIks3fqvKF5q+1jhyh3xExrwC1bYJK0HBcMkTqxOvXjfb020DqdHivYUcH/4t+FPx3qZME+wQa8ldQL3PLfJ2sjTToks2adNkqS2Zh+H6BNFmssdOAtDAY9TiTW5L++2MZo2liV1FRVPqLhFrT3BeLpjTFOGyJdqn5mjKy32ZsYQ9ijVLw74JM0=
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 8bde30a5-0cc3-4142-e927-08d6ddfb920f
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 May 2019 14:49:47.4838
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 105b2061-b669-4b31-92ac-24d304d195dc
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: elliott@hpe.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AT5PR8401MB0692
X-OriginatorOrg: hpe.com
X-HPE-SCL: -1
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-21_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=855 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905210092
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> -----Original Message-----
> From: Linux-nvdimm <linux-nvdimm-bounces@lists.01.org> On Behalf Of
> Aneesh Kumar K.V
> Sent: Tuesday, May 21, 2019 4:51 AM
> Subject: Re: [PATCH] mm/nvdimm: Use correct #defines instead of
> opencoding
>=20
...
> @@ -36,6 +36,9 @@ struct nd_pfn_sb {
>  	__le32 end_trunc;
>  	/* minor-version-2 record the base alignment of the mapping */
>  	__le32 align;
> +	/* minor-version-3 record the page size and struct page size
> */
> +	__le32 page_size;
> +	__le32 page_struct_size;
>  	u8 padding[4000];
>  	__le64 checksum;
>  };

You might need to reduce the padding size to offset the extra added
fields.


