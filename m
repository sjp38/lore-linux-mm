Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1AD7AC433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:57:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FE502086D
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 06:57:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amdcloud.onmicrosoft.com header.i=@amdcloud.onmicrosoft.com header.b="v39ceR85"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FE502086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amd.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E2D36B000C; Wed,  7 Aug 2019 02:57:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36C4F6B000E; Wed,  7 Aug 2019 02:57:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20DB46B0010; Wed,  7 Aug 2019 02:57:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id C59616B000C
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 02:57:28 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id t9so43421145wrx.9
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 23:57:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=oHO211pT3iSsIc5GQu9tV3fhX1wvXmg0iWBJcU790YU=;
        b=jnkhyXJa63X+HNTKfk8P54UgptmU+TA2sjDIXkX+4U8jcR7bZVwgV7Vmdwf29gtuB0
         vAQ7ZOzvLBC3rzGo2t0JMeMCicBiNqgmqHDIGxuUseL/fgBOHKze+60UK3Uby2VImf0P
         GuraKq+UogId5NDZ622MaBq3mR5pZLG3lpdopfHhakU6RYXV8TJwLr+UeFEazmzfrv5a
         lLKnnlFQXvcebyZlhIHX8zYtWdo1EvRNPSdRXAcqaRVAtLN6uA8hp2AtAOnUyJ3ld3oK
         f62JrFYxXGxaaW0lbFPMicC6Yf/Kbb5+jl6ivFamphhRdCynLn+VUVFInj2xwcxKHf5p
         qNBQ==
X-Gm-Message-State: APjAAAUfcWelUjyYSBoJ3ggNtvJ6Fp1mwn5t/CXZeCjmf3sFtp/r/q/E
	rOTQ+iIO27bX6buUhCt9jJlKsRtgx4pPJ83PVO8NWSDFSt1FcBeEIgLm6weIhvaECE2HykjzWIr
	72130baIAkyQbQCFR3KNQjx4YKGGFyF8LrhmnBaDC2n1Im1GXPbJORWjJVqFB6jY=
X-Received: by 2002:a05:6000:1085:: with SMTP id y5mr981800wrw.285.1565161048381;
        Tue, 06 Aug 2019 23:57:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjj0NjI7X9WozUqGSHw7s6o2vI4+SjICZEt4HX+tndlmNr93UKgy2KnKOELaRv+MKxobqe
X-Received: by 2002:a05:6000:1085:: with SMTP id y5mr981734wrw.285.1565161047601;
        Tue, 06 Aug 2019 23:57:27 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1565161047; cv=pass;
        d=google.com; s=arc-20160816;
        b=lca0sZeZx0uzGpwetO0x7hMAjU/wmBJp76HCRtmxuJtgNXscpm3LCbErXH1H6xD/Zm
         xQF9B3ispHha0I3W8uvRt55KF87NhRxriMLcwfzdU416W7zdiWw3+QjfGBcqg4DSyVZI
         6rHlz+Eyy7vP8lWv7mHkLUQuY0pDiIkLfsWXuJeMps9JNXXUxu07Ouz5fxuwTBJT+OJr
         en/dk/ZMSca24I4MYfZ+JXapE1M4bemx3gtZry6jemhG5lHEP+p4z4KYumCuHOdY6q5U
         07OoCt4sXW4x9J9Nky1kivPbAtUDd1NLO48I4MF7l3YkgzYnav13AQJT1ul709OHG/IU
         pCbg==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=oHO211pT3iSsIc5GQu9tV3fhX1wvXmg0iWBJcU790YU=;
        b=0nAG2oHnGTQbs8lvm0al45JxUfSVoZnEbpxR9q8tNM+gP8kcnjuQVcKRkdmuDiBmlV
         1TKvsNykzaX58DdFfkFyqNW801kYNEWHT/sdYRe15rNz+LAn8LMtZVE+sOy+JHR2SkH8
         kn6OA4nyU2dK6UQK3j+tUHBvs9S+gyeVl4EwJjkM4hHJlqLSbB/Lhmay5MgY8mRzmd5Q
         k59f5esAE2XQKfP1Lf+fcikp2+QsAlC99Cdt5IbGh6yy/xR6U0dB4n3NmEUJkotMaKDI
         rPhj4P3BNmhEuFXSQcbvtmWngMjf3Tfk0kiNerfGth6R4Q777IPBw0bvfUW+wzXU5aLS
         UisQ==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=v39ceR85;
       arc=pass (i=1 spf=pass spfdomain=amd.com dkim=pass dkdomain=amd.com dmarc=pass fromdomain=amd.com);
       spf=neutral (google.com: 40.107.78.84 is neither permitted nor denied by best guess record for domain of christian.koenig@amd.com) smtp.mailfrom=Christian.Koenig@amd.com
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-eopbgr780084.outbound.protection.outlook.com. [40.107.78.84])
        by mx.google.com with ESMTPS id o19si65342738wmf.126.2019.08.06.23.57.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 23:57:27 -0700 (PDT)
Received-SPF: neutral (google.com: 40.107.78.84 is neither permitted nor denied by best guess record for domain of christian.koenig@amd.com) client-ip=40.107.78.84;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amdcloud.onmicrosoft.com header.s=selector1-amdcloud-onmicrosoft-com header.b=v39ceR85;
       arc=pass (i=1 spf=pass spfdomain=amd.com dkim=pass dkdomain=amd.com dmarc=pass fromdomain=amd.com);
       spf=neutral (google.com: 40.107.78.84 is neither permitted nor denied by best guess record for domain of christian.koenig@amd.com) smtp.mailfrom=Christian.Koenig@amd.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=hNP8H8yaNF9Yz2mkDaKAymI7B6H1roaYjQZ2YFl7gjAt8j2iuDGCyy5khC2QSY/mWgzGGv3xnXKqeqHc4oqrCNxWZAWZCdZKZdkia3dXxcNzs3y93Ndo9LqwPgNn7xXnDgkSjUQPWNvlos/++tse6atCvCdjvvalr2/SXGUhlmFcm2QaXp3ZQMT3MqtBYhfA3SNrXf7dUFBOc4jnA0+CgbzHXwXP0yRNG1Y7nK+XMdEaJzGMDZ/+wauXGJxj4Cs8dLD7sEXZN81roQcBVxLprSXjAZIX+1C0Jia6d2n7MXGPvXF79siqLHgFbwGCy03mUjdBpHXWlVnoPiz48S2D6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=oHO211pT3iSsIc5GQu9tV3fhX1wvXmg0iWBJcU790YU=;
 b=a4rpY3YZCaOiXC9XB8qqW1gsmNiHAMrty7lqdq3HR4OhxSe/Ld2mjp7wLXuhPXbhtSKwkxYywNDberNqOPrOPnCf90EDQZmPBqD+cvUGa5cEOnhP2I6uuQJoIdRKpMJAWqSsaIB63xuoURu9UIVsPyHPHCmJ2jRxj4N49CibT4hovCZdtvXJPLO6ZSnes5BJNvuVI8LLB3nVxfB4J+UvoglbTvjZ0uC7g33ocARHkEPSTl7pJ99T2NSTcbXWK/9KJEqfExBGPaxFmiAOxwb1cFSkGFOviPhRIC6Uy9EnW22MfBYhkCJbpWrwjuG94EiEt8XJf6OJD0jA9GCKrW8tlA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=amd.com;dmarc=pass action=none header.from=amd.com;dkim=pass
 header.d=amd.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amdcloud.onmicrosoft.com; s=selector1-amdcloud-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=oHO211pT3iSsIc5GQu9tV3fhX1wvXmg0iWBJcU790YU=;
 b=v39ceR85O4dBSQlEdyWZzbiYIqg/+yLFXgUMlWGpxk03Hx58gmgZ0tkDTvrqztJw1+VAXzHuBUsmxUQA3RrLIf4m0UwbEOUiElhQOaSQHj9zeJaCbgsNmMwkUgwOK5984mkQx5XwWef2kmP4Q9zcuH07psJaTKquhprnSyPlrf4=
Received: from DM5PR12MB1546.namprd12.prod.outlook.com (10.172.36.23) by
 DM5PR12MB1516.namprd12.prod.outlook.com (10.172.34.140) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2136.17; Wed, 7 Aug 2019 06:57:24 +0000
Received: from DM5PR12MB1546.namprd12.prod.outlook.com
 ([fe80::fc5f:ce01:e8c8:db89]) by DM5PR12MB1546.namprd12.prod.outlook.com
 ([fe80::fc5f:ce01:e8c8:db89%12]) with mapi id 15.20.2136.018; Wed, 7 Aug 2019
 06:57:24 +0000
From: "Koenig, Christian" <Christian.Koenig@amd.com>
To: Jason Gunthorpe <jgg@ziepe.ca>, Alex Deucher <alexdeucher@gmail.com>
CC: "Kuehling, Felix" <Felix.Kuehling@amd.com>, Christoph Hellwig
	<hch@lst.de>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, Ralph
 Campbell <rcampbell@nvidia.com>, "amd-gfx@lists.freedesktop.org"
	<amd-gfx@lists.freedesktop.org>, "nouveau@lists.freedesktop.org"
	<nouveau@lists.freedesktop.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org"
	<dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	=?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Ben Skeggs
	<bskeggs@redhat.com>
Subject: Re: [PATCH 15/15] amdgpu: remove CONFIG_DRM_AMDGPU_USERPTR
Thread-Topic: [PATCH 15/15] amdgpu: remove CONFIG_DRM_AMDGPU_USERPTR
Thread-Index: AQHVTHDu3MOrnAsG0k6xIfWlHrhaOqbuZFmAgAAB+ACAABLOAIAAEiYAgAC2igA=
Date: Wed, 7 Aug 2019 06:57:24 +0000
Message-ID: <4a040a3f-8981-3e94-2436-8295a0caa534@amd.com>
References: <20190806160554.14046-1-hch@lst.de>
 <20190806160554.14046-16-hch@lst.de> <20190806174437.GK11627@ziepe.ca>
 <587b1c3c-83c4-7de9-242f-6516528049f4@amd.com>
 <CADnq5_Puv-N=FVpNXhv7gOWZ8=tgBD2VjrKpVzEE0imWqJdD1A@mail.gmail.com>
 <20190806200356.GU11627@ziepe.ca>
In-Reply-To: <20190806200356.GU11627@ziepe.ca>
Accept-Language: de-DE, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
x-originating-ip: [2a02:908:1252:fb60:be8a:bd56:1f94:86e7]
x-clientproxiedby: PR1PR01CA0026.eurprd01.prod.exchangelabs.com
 (2603:10a6:102::39) To DM5PR12MB1546.namprd12.prod.outlook.com
 (2603:10b6:4:8::23)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Christian.Koenig@amd.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a77d8ec9-efa7-4813-db10-08d71b048069
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(4618075)(2017052603328)(7193020);SRVR:DM5PR12MB1516;
x-ms-traffictypediagnostic: DM5PR12MB1516:
x-microsoft-antispam-prvs:
 <DM5PR12MB1516E201064E60EB3F8CDEE983D40@DM5PR12MB1516.namprd12.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 01221E3973
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(346002)(396003)(366004)(39860400002)(376002)(136003)(51444003)(76114002)(199004)(189003)(5660300002)(2906002)(53936002)(6436002)(6486002)(53546011)(229853002)(386003)(46003)(110136005)(86362001)(256004)(7416002)(68736007)(6506007)(99286004)(4326008)(54906003)(64126003)(31696002)(58126008)(81156014)(102836004)(316002)(81166006)(66946007)(71190400001)(66556008)(66476007)(64756008)(66446008)(8676002)(6246003)(65826007)(31686004)(71200400001)(486006)(8936002)(186003)(476003)(6116002)(305945005)(52116002)(7736002)(76176011)(6512007)(2616005)(11346002)(14454004)(25786009)(65956001)(478600001)(65806001)(36756003)(446003);DIR:OUT;SFP:1101;SCL:1;SRVR:DM5PR12MB1516;H:DM5PR12MB1546.namprd12.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: amd.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 8YGFqtGY7eIxOCfGaSZf53fsvPEb8t+YTjCvzhJOLdzYtc9BhXbN0gh1WnEi3qgzU7652PP9Ecke/dzqrHk1XkBSYzjmkx50qCKhiFJCDt2CLCfp14d73W1YuxfS3lDucSmloG9gkSnExOIRIZDrIPAfGLLB/QT/vTmGOmhPoKtxCmHVBGqtpPmMJ0dHBKDlBAvCFA3ys8IUjPdfwceG7wWqkyexTcVXXw2g+/huhVInqnuljI/VcJ5YVHBtvK7oKhBcF34EDtUUQf0MlOWk88+JOIwA76/QeEryrKTl4a9YqrOmhccwWxNNP4uouaYBd/oiMnBKjc6zonseSeZMPhIJq2qJ/FmB+fiq3WUOqp39WzJKK/FNzdcUm62C/ipDS3X+IYEk/YV/TSsEpsf01uDzm5djR8v4XD+oI4eHVCE=
Content-Type: text/plain; charset="utf-8"
Content-ID: <43772BFAF78A0B4E87A7805839F5F2C5@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: amd.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a77d8ec9-efa7-4813-db10-08d71b048069
X-MS-Exchange-CrossTenant-originalarrivaltime: 07 Aug 2019 06:57:24.7103
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 3dd8961f-e488-4e60-8e11-a82d994e183d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: ckoenig@amd.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM5PR12MB1516
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

QW0gMDYuMDguMTkgdW0gMjI6MDMgc2NocmllYiBKYXNvbiBHdW50aG9ycGU6DQo+IE9uIFR1ZSwg
QXVnIDA2LCAyMDE5IGF0IDAyOjU4OjU4UE0gLTA0MDAsIEFsZXggRGV1Y2hlciB3cm90ZToNCj4+
IE9uIFR1ZSwgQXVnIDYsIDIwMTkgYXQgMTo1MSBQTSBLdWVobGluZywgRmVsaXggPEZlbGl4Lkt1
ZWhsaW5nQGFtZC5jb20+IHdyb3RlOg0KPj4+IE9uIDIwMTktMDgtMDYgMTM6NDQsIEphc29uIEd1
bnRob3JwZSB3cm90ZToNCj4+Pj4gT24gVHVlLCBBdWcgMDYsIDIwMTkgYXQgMDc6MDU6NTNQTSAr
MDMwMCwgQ2hyaXN0b3BoIEhlbGx3aWcgd3JvdGU6DQo+Pj4+PiBUaGUgb3B0aW9uIGlzIGp1c3Qg
dXNlZCB0byBzZWxlY3QgSE1NIG1pcnJvciBzdXBwb3J0IGFuZCBoYXMgYSB2ZXJ5DQo+Pj4+PiBj
b25mdXNpbmcgaGVscCB0ZXh0LiAgSnVzdCBwdWxsIGluIHRoZSBITU0gbWlycm9yIGNvZGUgYnkg
ZGVmYXVsdA0KPj4+Pj4gaW5zdGVhZC4NCj4+Pj4+DQo+Pj4+PiBTaWduZWQtb2ZmLWJ5OiBDaHJp
c3RvcGggSGVsbHdpZyA8aGNoQGxzdC5kZT4NCj4+Pj4+ICAgIGRyaXZlcnMvZ3B1L2RybS9LY29u
ZmlnICAgICAgICAgICAgICAgICB8ICAyICsrDQo+Pj4+PiAgICBkcml2ZXJzL2dwdS9kcm0vYW1k
L2FtZGdwdS9LY29uZmlnICAgICAgfCAxMCAtLS0tLS0tLS0tDQo+Pj4+PiAgICBkcml2ZXJzL2dw
dS9kcm0vYW1kL2FtZGdwdS9hbWRncHVfdHRtLmMgfCAgNiAtLS0tLS0NCj4+Pj4+ICAgIGRyaXZl
cnMvZ3B1L2RybS9hbWQvYW1kZ3B1L2FtZGdwdV90dG0uaCB8IDEyIC0tLS0tLS0tLS0tLQ0KPj4+
Pj4gICAgNCBmaWxlcyBjaGFuZ2VkLCAyIGluc2VydGlvbnMoKyksIDI4IGRlbGV0aW9ucygtKQ0K
Pj4+PiBGZWxpeCwgd2FzIHRoaXMgYW4gZWZmb3J0IHRvIGF2b2lkIHRoZSBhcmNoIHJlc3RyaWN0
aW9uIG9uIGhtbSBvcg0KPj4+PiBzb21ldGhpbmc/IEFsc28gY2FuJ3Qgc2VlIHdoeSB0aGlzIHdh
cyBsaWtlIHRoaXMuDQo+Pj4gVGhpcyBvcHRpb24gcHJlZGF0ZXMgS0ZEJ3Mgc3VwcG9ydCBvZiB1
c2VycHRycywgd2hpY2ggaW4gdHVybiBwcmVkYXRlcw0KPj4+IEhNTS4gUmFkZW9uIGhhcyB0aGUg
c2FtZSBraW5kIG9mIG9wdGlvbiwgdGhvdWdoIGl0IGRvZXNuJ3QgYWZmZWN0IEhNTSBpbg0KPj4+
IHRoYXQgY2FzZS4NCj4+Pg0KPj4+IEFsZXgsIENocmlzdGlhbiwgY2FuIHlvdSB0aGluayBvZiBh
IGdvb2QgcmVhc29uIHRvIG1haW50YWluIHVzZXJwdHINCj4+PiBzdXBwb3J0IGFzIGFuIG9wdGlv
biBpbiBhbWRncHU/IEkgc3VzcGVjdCBpdCB3YXMgb3JpZ2luYWxseSBtZWFudCBhcyBhDQo+Pj4g
d2F5IHRvIGFsbG93IGtlcm5lbHMgd2l0aCBhbWRncHUgd2l0aG91dCBNTVUgbm90aWZpZXJzLiBO
b3cgaXQgd291bGQNCj4+PiBhbGxvdyBhIGtlcm5lbCB3aXRoIGFtZGdwdSB3aXRob3V0IEhNTSBv
ciBNTVUgbm90aWZpZXJzLiBJIGRvbid0IGtub3cgaWYNCj4+PiB0aGlzIGlzIGEgdXNlZnVsIHRo
aW5nIHRvIGhhdmUuDQo+PiBSaWdodC4gIFRoZXJlIHdlcmUgcGVvcGxlIHRoYXQgZGlkbid0IGhh
dmUgTU1VIG5vdGlmaWVycyB0aGF0IHdhbnRlZA0KPj4gc3VwcG9ydCBmb3IgdGhlIEdQVS4NCj4g
Pz8gSXMgdGhhdCBldmVuIGEgcmVhbCB0aGluZz8gbW11X25vdGlmaWVyIGRvZXMgbm90IGhhdmUg
bXVjaCBrY29uZmlnDQo+IGRlcGVuZGVuY3kuDQoNClllcywgdGhhdCB1c2VkIHRvIGJlIGEgdmVy
eSByZWFsIHRoaW5nLg0KDQpJbml0aWFsbHkgYSBsb3Qgb2YgdXNlcnMgZGlkbid0IHdhbnRlZCBt
bXUgbm90aWZpZXJzIHRvIGJlIGVuYWJsZWQgDQpiZWNhdXNlIG9mIHRoZSBwZXJmb3JtYW5jZSBv
dmVyaGVhZCB0aGV5IGNvc3RzLg0KDQpUaGVuIHdlIGhhZCB0aGUgcHJvYmxlbSB0aGF0IEhNTSBt
aXJyb3Igd2Fzbid0IGF2YWlsYWJsZSBvbiBhIGxvdCBvZiANCmFyY2hpdGVjdHVyZXMuDQoNCk5v
dCBzdXJlIGlmIHdlIHN0aWxsIG5lZWQgaXQgc2VwYXJhdGVseSwgYnV0IEkgdGhpbmsgdGhhdCBp
dCBzaG91bGRuJ3QgDQpiZSByZW1vdmVkIHdpdGhvdXQgYXNraW5nIGFyb3VuZCBpZiBzb21lYm9k
eSBzdGlsbCBuZWVkcyB0aGF0Lg0KDQpDaHJpc3RpYW4uDQoNCj4NCj4gSmFzb24NCg0K

