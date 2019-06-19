Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96E36C31E5B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 00:54:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAF8020863
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 00:53:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="VJFE7xDU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAF8020863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5ABAD6B0003; Tue, 18 Jun 2019 20:53:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55C158E0002; Tue, 18 Jun 2019 20:53:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 424518E0001; Tue, 18 Jun 2019 20:53:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 232C86B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 20:53:59 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id z6so14154693qtj.7
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 17:53:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=OdvVMWVc4CxJp888G8h5ta2Gb+IW1NMgVjFOLbLHn/o=;
        b=gYlo1bRuoPg5OEZQ12N1Nyh2OEBBEKa1fTdHYadEfdZjbJpgKp3DZ/X+VzRBG+sB7U
         YWWb9A214yd5NJ+hJ7O8MM5jhmicWHzr+8by8vfw84PRlIC68xx13vLeczpzhrQtjfMW
         tpV7TF9cVBuEmLr882bHJIbp7GzeHieQIjpSTNxQ6QpwKbdIxmDcW7YUXvqCXouXKDAD
         019p9SJMOc0zZ4nUTeSamhtEyU3BT678+k6oXuSeHNUYcOe5h/DSXAbf4af6akrjOM2v
         +cgdgTjQ4JDfk4/3RZKYPDLRG2Fo9pxKnDxIKv40tV3a18iAiKqN2dJGI5aBkqdpo97i
         LByg==
X-Gm-Message-State: APjAAAUplhUNvCoxUPsd6OY4I0BXML045Kb4meZmatOd+2Hwb0sMogdb
	l8SOyp5PpXGXdvP67WG0lY4wFuhqQwBUdtaPUqDFYEyQ0MAU5AjfNlkpep10pS2c+mUW5g8e4zg
	SJvBqLvjODMa6FKrZ44XaBBev9/IIVxAGCM3ZQlsayG29aSjxwzzy/oqSy8D3Gtk=
X-Received: by 2002:ac8:39a3:: with SMTP id v32mr72413670qte.262.1560905638845;
        Tue, 18 Jun 2019 17:53:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzigZGWTAW8Fyh6asec3bGqnhp+1h4+b4snKMhLfxiWXgpu481Y6p+lDVgVQMM5fcpHd1zU
X-Received: by 2002:ac8:39a3:: with SMTP id v32mr72413634qte.262.1560905638201;
        Tue, 18 Jun 2019 17:53:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560905638; cv=none;
        d=google.com; s=arc-20160816;
        b=aI4bgW58iuJRdVxL01P77ZoW0f6RgPQksiJhphQg/zndp+7x7kKNVhdCgOx5aJytns
         G34MyHDHj2sUO9JgMmXwai7WoMSElfDi0HWU6YDLyk+x5vBQAYBc3aYfCFKP7b7eXALv
         7R6u+czsTuqsErL3mbYLsMybA+1qQ975ofehcl93uLRUmes+K8Dt/CX96RR9h/k1Ev/U
         79vWU5nEd4uO7OPTkmQPstpmLOeYXxiyKPHCGrAUUjTJJlQ2Ebe0N4Ycc8zxykBtiJbi
         sCcoqfXbjqT/LEVXdzDW0ZI6LkF7RkscErqsOFqX3LRiHE5iumfmPUnFB6CfW+O36zhG
         u4KA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=OdvVMWVc4CxJp888G8h5ta2Gb+IW1NMgVjFOLbLHn/o=;
        b=KFYmGxExzk9D2lNcwLRvsrFttB+QshMIoL74wjrchlyflTIwavBcS7m8Aq6s3s8mhp
         3wT/jEA50nX/biE/hIFegiquPRqzGrIRIF8wuj6m6xH5QsOKo4B21peXMQljsGgPNak9
         X8NuT+Tn40uNSm2KRCYVV/A/rTG3aT2JrJ2iR4uXIUWnFJAh/7hL4lmgzTciBFrAGRvu
         j98US2z1Nzo8jvcp1HYjdcCzGaqnoeRPD2WG6PUWdnKM0BZhtd9iUvIoy1AklIITs5BS
         6mcNIQG1K3rteoAN0TmoUd+0Acoq6gaZHSB1pKjLTD8+dvJxpCsi2oMJkXwUexZMuF/i
         5l1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=VJFE7xDU;
       spf=neutral (google.com: 40.107.71.61 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (mail-eopbgr710061.outbound.protection.outlook.com. [40.107.71.61])
        by mx.google.com with ESMTPS id x9si1629881qta.147.2019.06.18.17.53.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 17:53:58 -0700 (PDT)
Received-SPF: neutral (google.com: 40.107.71.61 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) client-ip=40.107.71.61;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=VJFE7xDU;
       spf=neutral (google.com: 40.107.71.61 is neither permitted nor denied by best guess record for domain of felix.kuehling@amd.com) smtp.mailfrom=Felix.Kuehling@amd.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amdcloud-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=OdvVMWVc4CxJp888G8h5ta2Gb+IW1NMgVjFOLbLHn/o=;
 b=VJFE7xDUaRVP/mLJxtgnAhwu+rG5uEISn/JPAB560feOteDvfnQS4ffajwijnWrBp3l/2Aq2dF0xVxa/RDhyH0FPmvOAabO1hTDG2bGPj8hvRa9hvZvdv9BNJublXrbCMKTxiaUMyzqZG4lL8PaZbHF+jXLvTbndHBRFhIrfJMs=
Received: from DM6PR12MB3947.namprd12.prod.outlook.com (10.255.174.156) by
 DM6PR12MB3449.namprd12.prod.outlook.com (20.178.198.216) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.12; Wed, 19 Jun 2019 00:53:55 +0000
Received: from DM6PR12MB3947.namprd12.prod.outlook.com
 ([fe80::5964:8c3c:1b5b:c480]) by DM6PR12MB3947.namprd12.prod.outlook.com
 ([fe80::5964:8c3c:1b5b:c480%2]) with mapi id 15.20.1987.014; Wed, 19 Jun 2019
 00:53:55 +0000
From: "Kuehling, Felix" <Felix.Kuehling@amd.com>
To: Christoph Hellwig <hch@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>
CC: Jerome Glisse <jglisse@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	Andrea Arcangeli <aarcange@redhat.com>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>, Ben Skeggs <bskeggs@redhat.com>, "Yang,
 Philip" <Philip.Yang@amd.com>
Subject: Re: [PATCH v3 hmm 11/12] mm/hmm: Remove confusing comment and logic
 from hmm_release
Thread-Topic: [PATCH v3 hmm 11/12] mm/hmm: Remove confusing comment and logic
 from hmm_release
Thread-Index: AQHVIk0QeCItTUOe+UqO7ZSHV3sMaKacxokAgAPTBYCAAFGygIABQxSA
Date: Wed, 19 Jun 2019 00:53:55 +0000
Message-ID: <be4f8573-6284-04a6-7862-23bb357bfe3c@amd.com>
References: <20190614004450.20252-1-jgg@ziepe.ca>
 <20190614004450.20252-12-jgg@ziepe.ca> <20190615142106.GK17724@infradead.org>
 <20190618004509.GE30762@ziepe.ca> <20190618053733.GA25048@infradead.org>
In-Reply-To: <20190618053733.GA25048@infradead.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [165.204.54.211]
user-agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
x-clientproxiedby: YTXPR0101CA0070.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:b00:1::47) To DM6PR12MB3947.namprd12.prod.outlook.com
 (2603:10b6:5:1cb::28)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Felix.Kuehling@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a80b948e-d657-4f2f-8718-08d6f4509ac3
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4618075)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:DM6PR12MB3449;
x-ms-traffictypediagnostic: DM6PR12MB3449:
x-microsoft-antispam-prvs:
 <DM6PR12MB34492FFD87A8C64FFE095F9892E50@DM6PR12MB3449.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 0073BFEF03
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(376002)(366004)(346002)(39860400002)(396003)(136003)(189003)(199004)(256004)(229853002)(73956011)(2906002)(71190400001)(102836004)(36756003)(7736002)(68736007)(65826007)(66556008)(305945005)(66946007)(71200400001)(316002)(25786009)(66446008)(64756008)(8936002)(6246003)(6436002)(66476007)(6486002)(4326008)(86362001)(486006)(76176011)(64126003)(26005)(186003)(476003)(14444005)(58126008)(8676002)(110136005)(54906003)(7416002)(53936002)(66066001)(5660300002)(65956001)(65806001)(478600001)(53546011)(6506007)(31686004)(3846002)(52116002)(386003)(99286004)(14454004)(6512007)(72206003)(81166006)(31696002)(6116002)(11346002)(446003)(81156014)(2616005);DIR:OUT;SFP:1101;SCL:1;SRVR:DM6PR12MB3449;H:DM6PR12MB3947.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 7mbPSu11w5H5HDPC8boobnD4i4zVCPxr5tSqYE/HnTIKDM5LD0I4pMmL6UNAej57LNEKD9u/jR1Fb+hQDa3NTTIy0gT4w+d+0Ua1pdXvA+RQH26w3gU+CPdOWLwOfdTT4Bz5JvUqBXcfFhqPwytRGbmP2jhKfWP/DPW4dJgYDaxn6AzTk4Av6HCP2L226B5xWsUGg/DYfSmu5k1CGW3zbphMZgrp1bbhV77OzPBnvx+27joWMd8hj2KnfFcKdiiTDhBcCRys2QM/9UROLoKIunBGx+p9hy6Lsmjv3Pg8/9uTPs1B8tGcTP3TBjnSoTYZYn+c+ody14uJ0SPo4k8Lb88+p6gbJxMrNCSRCp3YxoIfTHvIAY2A5oQaZ0qpQDMGfBqkDx5rbwacQ3EBIsYXvDrdt1XnfDesrhAlbUxXSSQ=
Content-Type: text/plain; charset="utf-8"
Content-ID: <BDC9BD32EDDEB14C9515C4D0AC9287F7@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a80b948e-d657-4f2f-8718-08d6f4509ac3
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Jun 2019 00:53:55.4418
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: fkuehlin@amd.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM6PR12MB3449
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gMjAxOS0wNi0xOCAxOjM3LCBDaHJpc3RvcGggSGVsbHdpZyB3cm90ZToNCj4gT24gTW9uLCBK
dW4gMTcsIDIwMTkgYXQgMDk6NDU6MDlQTSAtMDMwMCwgSmFzb24gR3VudGhvcnBlIHdyb3RlOg0K
Pj4gQW0gSSBsb29raW5nIGF0IHRoZSB3cm9uZyB0aGluZz8gTG9va3MgbGlrZSBpdCBjYWxscyBp
dCB0aHJvdWdoIGEgd29yaw0KPj4gcXVldWUgc2hvdWxkIHNob3VsZCBiZSBPSy4uDQo+IFllcywg
aXQgY2FsbHMgaXQgdGhyb3VnaCBhIHdvcmsgcXVldWUuICBJIGd1ZXNzIHRoYXQgaXMgZmluZSBi
ZWNhdXNlDQo+IGl0IG5lZWRzIHRvIHRha2UgdGhlIGxvY2sgYWdhaW4uDQo+DQo+PiBUaG91Z2gg
dmVyeSBzdHJhbmdlIHRoYXQgYW1kZ3B1IG9ubHkgZGVzdHJveXMgdGhlIG1pcnJvciB2aWEgcmVs
ZWFzZSwNCj4+IHRoYXQgY2Fubm90IGJlIHJpZ2h0Lg0KPiBBcyBzYWlkIHRoZSB3aG9sZSB0aGlu
Z3MgbG9va3MgcmF0aGVyIG9kZCB0byBtZS4NCg0KVGhpcyBjb2RlIGlzIGRlcml2ZWQgZnJvbSBv
dXIgb2xkIE1NVSBub3RpZmllciBjb2RlLiBCZWZvcmUgSE1NIHdlIHVzZWQgDQp0byByZWdpc3Rl
ciBhIHNpbmdsZSBNTVUgbm90aWZpZXIgcGVyIG1tX3N0cnVjdCBhbmQgbG9vayB1cCB2aXJ0dWFs
IA0KYWRkcmVzcyByYW5nZXMgdGhhdCBoYWQgYmVlbiByZWdpc3RlcmVkIGZvciBtaXJyb3Jpbmcg
dmlhIGRyaXZlciBBUEkgDQpjYWxscy4gVGhlIGlkZWEgd2FzIHRvIHJldXNlIGEgc2luZ2xlIE1N
VSBub3RpZmllciBmb3IgdGhlIGxpZmUgdGltZSBvZiANCnRoZSBwcm9jZXNzLiBJdCB3b3VsZCBy
ZW1haW4gcmVnaXN0ZXJlZCB1bnRpbCB3ZSBnb3QgYSBub3RpZmllcl9yZWxlYXNlLg0KDQpobW1f
bWlycm9yIHRvb2sgdGhlIHBsYWNlIG9mIHRoYXQgd2hlbiB3ZSBjb252ZXJ0ZWQgdGhlIGNvZGUg
dG8gSE1NLg0KDQpJIHN1cHBvc2Ugd2UgY291bGQgZGVzdHJveSB0aGUgbWlycm9yIGVhcmxpZXIs
IHdoZW4gd2UgaGF2ZSBubyBtb3JlIA0KcmVnaXN0ZXJlZCB2aXJ0dWFsIGFkZHJlc3MgcmFuZ2Vz
LCBhbmQgY3JlYXRlIGEgbmV3IG9uZSBpZiBuZWVkZWQgbGF0ZXIuDQoNClJlZ2FyZHMsDQogwqAg
RmVsaXgNCg0KDQo=

