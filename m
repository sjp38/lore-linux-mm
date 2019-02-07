Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3330AC4151A
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 04:44:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D97D9218FE
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 04:44:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="LblLTJEn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D97D9218FE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 876C68E0016; Wed,  6 Feb 2019 23:44:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 825F08E0002; Wed,  6 Feb 2019 23:44:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6ED398E0016; Wed,  6 Feb 2019 23:44:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 175E38E0002
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 23:44:52 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id b47so3204803eda.10
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 20:44:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=plwAGWStOpsCdb6fNFYoOyJCQ6MR+Iqpk6RT6TyMlgc=;
        b=dAIzkjSCMi2kZ3HCrfzalQoH7OM0+WjhQ301hZZxaUpuXT/PU/ALpqE/bbEeCXgBUV
         oX4aAb/PMm6norZD6gNbpevsKLMgvFswt+rZDPwFRMGZEtLEQ/isFYLgexr0ewGOH6yE
         t6DluVYHTsh29Xu48GmkRqj7pWcUFC914coNBIbnH+5xLDfzO8uZeY5pgidviPIck+K0
         ONVgO/n8XIeToOlX12eKu5apPOgbxjUE/RGzbojfE6lgpYd+zQ6PtCyg7cfCtRozHSXm
         vEaNpxD3fVZr5ti+aN1k5qhgbp9ZfaROIStrIKNXT1tpGlEyUwxwr3NNN9A4L7EpiioH
         AIOw==
X-Gm-Message-State: AHQUAuaDAcH+ZURMjWISJUJeAEqMdTALD3PLdaA1JQ6EGkcmnpk5EZ/a
	r6GI5J6mLzRsqmzeCQ8IF3rXkWHFA2AB9pTZ6evV2vY9uM45MppEttqWSdEbvWFM+s8D+MN2/1y
	LiLHRQsObw+ySiVAOu1vbZdIkel30Ifn0oT7Tm9CtUPUrB+2oLrjRHMsxzHauzfbztA==
X-Received: by 2002:a17:906:64d:: with SMTP id t13mr9675316ejb.53.1549514691630;
        Wed, 06 Feb 2019 20:44:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaaUu9oFBv1DE70GwWyXp7OP90hxDV9pQoNN4oxjrRATlplKXunrmq7POKCneqcWPWpQGA7
X-Received: by 2002:a17:906:64d:: with SMTP id t13mr9675273ejb.53.1549514690699;
        Wed, 06 Feb 2019 20:44:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549514690; cv=none;
        d=google.com; s=arc-20160816;
        b=zd01zCiZ5ZR0ej0/OrKt0HxhZIt60kOpkhj/vl+sLVPGUz7hN1kI9152McS2JsHZgm
         xhhZKAvdrMz6PTejgwxKuhnfmJnbIZ+is2D5G2P5+0zTpB5Jmn+h5VyWGy0GKYWchtbK
         BPSoHeYZ22xrbxUl2HJxkXObp6srrbgwImA8XK7YBt8lp3CULFv6Nw1p50sg5H/8feWU
         6k6WobYt5NnIljPP8rp1Bmu+D13zY3oMP4xFqNmls+uVu4M/yojYVFRwqb46aCQfUDjo
         rrZQKko8EDu3SySLYMeIq4IPI/qwB8StktWLdEvoWS+UWh7cCyDHecyZsGskmAbKWa8D
         KlDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=plwAGWStOpsCdb6fNFYoOyJCQ6MR+Iqpk6RT6TyMlgc=;
        b=ZYT/mWj+7HgmLx7ql6L291irkXc9l60W4ME8j2I3wtNQ82MUiTxWt43rt1h5h+3/no
         Q+1mBXoVxRZMP8JwGZlmlEfwyDvKBC5NFtqPgV3+EtUSEzxIbwZJsTRL79NYMd/eXjmp
         THbPNobvqfFerIIIT9cFPHRWpMaXLnfU28lpFqUKvdcv+5d2+yJ7lxKMfyvh4x04XQLt
         2ZZaylQizsASCCGd/ZHozb1xuOEj4KaARLCI1ZMVzl4lyuV38bnOMC9nswXWvokQ2nqJ
         I7kmp9IaUDOVTXT09wzqnRNBUjRev+qJ6JBLOF7B++s5rpw5hxqcDJr6OuNlWwjF6qBF
         XdYw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=LblLTJEn;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.14.77 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-eopbgr140077.outbound.protection.outlook.com. [40.107.14.77])
        by mx.google.com with ESMTPS id q58si862527edd.101.2019.02.06.20.44.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 06 Feb 2019 20:44:50 -0800 (PST)
Received-SPF: pass (google.com: domain of peng.fan@nxp.com designates 40.107.14.77 as permitted sender) client-ip=40.107.14.77;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=LblLTJEn;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.14.77 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=plwAGWStOpsCdb6fNFYoOyJCQ6MR+Iqpk6RT6TyMlgc=;
 b=LblLTJEnn+CUF4/0aq9yxBK5pF2Dss1so3N0/aqbla8sOb3CBJWVc7JSeoibIs/afoN1A3kwwGXU5bOU5amuFNdXZ8cM8XyTIWvnASkzAa+fr/oHJDV6Znz3gNtf9l3hBmMoiA/n4B1zaBsbWpMF5LpuxHWH5Lp6yGQBNDBq81E=
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com (52.135.148.143) by
 AM0PR04MB5588.eurprd04.prod.outlook.com (20.178.117.141) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.21; Thu, 7 Feb 2019 04:44:49 +0000
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::69ce:7da3:3bcf:d903]) by AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::69ce:7da3:3bcf:d903%3]) with mapi id 15.20.1580.019; Thu, 7 Feb 2019
 04:44:49 +0000
From: Peng Fan <peng.fan@nxp.com>
To: Dennis Zhou <dennis@kernel.org>
CC: "tj@kernel.org" <tj@kernel.org>, "cl@linux.com" <cl@linux.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: RE: pcpu_create_chunk in percpu-km
Thread-Topic: pcpu_create_chunk in percpu-km
Thread-Index: AdS+Flase9I8QatNRpiWvSscyNdChgAKYZIAABfzYNA=
Date: Thu, 7 Feb 2019 04:44:49 +0000
Message-ID:
 <AM0PR04MB4481E755ACCF837C526C7F1788680@AM0PR04MB4481.eurprd04.prod.outlook.com>
References:
 <AM0PR04MB44813C69CCAE720A47164EA8886F0@AM0PR04MB4481.eurprd04.prod.outlook.com>
 <20190206171740.GA76990@dennisz-mbp.dhcp.thefacebook.com>
In-Reply-To: <20190206171740.GA76990@dennisz-mbp.dhcp.thefacebook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=peng.fan@nxp.com; 
x-originating-ip: [119.31.174.68]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;AM0PR04MB5588;6:GET+2OpA2oQtINemku0C9hhxLQWH/y8cJ+VhWkF1trGI80mpv8xXgm6ZHMTEvFqENyHFFBSjr8MB+H1KvV+p/7YmFx3iZJxE6jZaGoo7UiRPw2JQDa7+e7k2XwYccO6aHYH8Jhoqi3qGPFAujp1fvykinCMFNGJC7KvesL1FQb3zwDseaNSyLGus7eacpCRO7L6clc+eb8Wo09mkAFVxtgjQGqilZekLEasGaA6KbKhgOvgzeb28GZzGwDoRkiK/wq78fiSDIcSG2V/ez2ON1/NWaRFReq5Cw8+qKT4v+bcWUfxCSlu58dXau/jmli9NykcT1IDM9XMWdVLjNnjA2O3CX23dzl7oDJL0lESnLiGiPBT2MxXbHLNb2Ls7y9vUcfVHE616Lrm48piFxNqgNnwG2VjUgzqaraihxLmCnyagcQOD4djaqGQ33dW/BSTsyPSHKUMse6CGs+cyojJScg==;5:m/KoPwfTZDTrIbdcWL5Wsf2DtMfeiIQRb4j/1liaMCp6twvkxxieADFZthcKKWIJkKVyggofW2XO2qlbqMvUgGTBdQrfknMtjzIEzD5kwTuGX2jcIxbUhRFRjmEsHyTb3VqBlJHnfMW9w8u8M8uPEVA6gNnS2qUslLhuzbyhTCIrNQyXS9N1qUBd9lIrjJ34Yqgoks6MLg9TMCKTfaEMAA==;7:Wd7ea6MMuVD79AwxRuza5mX8/qYlqAtAereSIVB4qfQSQYsLCHpnZ4JglLVstiTCCoK9Qkd1F9+6rNlUwt5TjjFzETGTwY0FqK26zSKliqmjXCFw38HXJ51EuxVcsBuTYrCZTjSkCMM8FzFScP8c5A==
x-ms-office365-filtering-correlation-id: 017f9bc7-205e-4e05-3e70-08d68cb6fe24
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(4618075)(2017052603328)(7153060)(7193020);SRVR:AM0PR04MB5588;
x-ms-traffictypediagnostic: AM0PR04MB5588:
x-microsoft-antispam-prvs:
 <AM0PR04MB55886C673ACDD83AFD1A616788680@AM0PR04MB5588.eurprd04.prod.outlook.com>
x-forefront-prvs: 0941B96580
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(39860400002)(136003)(376002)(396003)(366004)(189003)(199004)(13464003)(51914003)(229853002)(256004)(53546011)(6246003)(55016002)(68736007)(6506007)(476003)(33656002)(4326008)(11346002)(76176011)(26005)(102836004)(6436002)(7696005)(99286004)(105586002)(106356001)(25786009)(446003)(9686003)(2906002)(44832011)(7736002)(6916009)(305945005)(478600001)(81166006)(54906003)(86362001)(8936002)(6116002)(3846002)(14454004)(53936002)(66066001)(97736004)(71200400001)(71190400001)(486006)(74316002)(186003)(8676002)(81156014)(316002);DIR:OUT;SFP:1101;SCL:1;SRVR:AM0PR04MB5588;H:AM0PR04MB4481.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 4gZeYecYgfZ4twtx+OaMfXzMwe/FPrNmAkO6yCNT+yO2R5D9HhEch1LyJw4npSTMhHjcR7TwO/UT6blrkEY5HX7w8vMAWfBbRXIa2skEBt5OYUm4fr7i+NC67HVwGrH/uyYxd4UW1a/+TFwK5pZO96KonoifHpZLEF6PZth/xylGiHur6znKXPJlF2XzpBs0xYo9oqycTSX8p0YWCJakX0hKliiAEK6Ml2KXnTRvdw4KiAGA1ixeDR9f4N5wenFI45e91o18ENXT0N/i6uHIWfaYpqelkRc3nHSdd+eP01TELsDMkwgVi6q2jx1UMs7oJSckxjY29BXy8OJuXwGUs/2CaLeGFERGnRTTCf/nPRQKPYJjwx+ymcg7tm17ifZYBEXOyd7hJHFPSQ+zwn+4DdmPzkmvfdyURdCkst1NBes=
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 017f9bc7-205e-4e05-3e70-08d68cb6fe24
X-MS-Exchange-CrossTenant-originalarrivaltime: 07 Feb 2019 04:44:49.4337
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM0PR04MB5588
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkgRGVubmlzLA0KDQo+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+IEZyb206IERlbm5p
cyBaaG91IFttYWlsdG86ZGVubmlzQGtlcm5lbC5vcmddDQo+IFNlbnQ6IDIwMTnE6jLUwjfI1SAx
OjE4DQo+IFRvOiBQZW5nIEZhbiA8cGVuZy5mYW5AbnhwLmNvbT4NCj4gQ2M6IGRlbm5pc0BrZXJu
ZWwub3JnOyB0akBrZXJuZWwub3JnOyBjbEBsaW51eC5jb207IGxpbnV4LW1tQGt2YWNrLm9yZw0K
PiBTdWJqZWN0OiBSZTogcGNwdV9jcmVhdGVfY2h1bmsgaW4gcGVyY3B1LWttDQo+IA0KPiBIaSBQ
ZW5nLA0KPiANCj4gT24gV2VkLCBGZWIgMDYsIDIwMTkgYXQgMTI6MjM6NDRQTSArMDAwMCwgUGVu
ZyBGYW4gd3JvdGU6DQo+ID4gSGksDQo+ID4NCj4gPiBJIGFtIHJlYWRpbmcgdGhlIHBlcmNwdS1r
bSBzb3VyY2UgY29kZSBhbmQgZm91bmQgdGhhdCBpbg0KPiA+IHBjcHVfY3JlYXRlX2NodW5rLCBv
bmx5IHBjcHVfZ3JvdXBfc2l6ZXNbMF0gaXMgdGFrZW4gaW50bw0KPiA+IGNvbnNpZGVyYXRpb24s
IEkgYW0gd29uZGVyaW5nIHdoeSBvdGhlciBwY3B1X2dyb3VwX3NpemVzW3hdIGFyZSBub3QNCj4g
PiB1c2VkPw0KPiA+DQo+ID4gSXMgdGhlIGZvbGxvd2luZyBwaWVjZSBjb2RlIHRoZSBjb3JyZWN0
IGxvZ2ljPw0KPiA+DQo+ID4gQEAgLTQ3LDEyICs0NywxNSBAQCBzdGF0aWMgdm9pZCBwY3B1X2Rl
cG9wdWxhdGVfY2h1bmsoc3RydWN0DQo+ID4gcGNwdV9jaHVuayAqY2h1bmssDQo+ID4NCj4gPiAg
c3RhdGljIHN0cnVjdCBwY3B1X2NodW5rICpwY3B1X2NyZWF0ZV9jaHVuayhnZnBfdCBnZnApICB7
DQo+ID4gLSAgICAgICBjb25zdCBpbnQgbnJfcGFnZXMgPSBwY3B1X2dyb3VwX3NpemVzWzBdID4+
IFBBR0VfU0hJRlQ7DQo+ID4gKyAgICAgICBpbnQgbnJfcGFnZXMgPSAwOw0KPiA+ICAgICAgICAg
c3RydWN0IHBjcHVfY2h1bmsgKmNodW5rOw0KPiA+ICAgICAgICAgc3RydWN0IHBhZ2UgKnBhZ2Vz
Ow0KPiA+ICAgICAgICAgdW5zaWduZWQgbG9uZyBmbGFnczsNCj4gPiAgICAgICAgIGludCBpOw0K
PiA+DQo+ID4gKyAgICAgICBmb3IgKGkgPSAwOyBpIDwgcGNwdV9ucl9ncm91cHM7IGkrKykNCj4g
PiArICAgICAgICAgICAgICAgbnJfcGFnZXMgKz0gcGNwdV9ncm91cF9zaXplc1tpXSA+PiBQQUdF
X1NISUZUOw0KPiA+ICsNCj4gPiAgICAgICAgIGNodW5rID0gcGNwdV9hbGxvY19jaHVuayhnZnAp
Ow0KPiA+ICAgICAgICAgaWYgKCFjaHVuaykNCj4gPiAgICAgICAgICAgICAgICAgcmV0dXJuIE5V
TEw7DQo+ID4NCj4gPiBUaGFua3MsDQo+ID4gUGVuZy4NCj4gPg0KPiANCj4gVGhlIGluY2x1ZGUg
Zm9yIHBlcmNwdS1rbS5jIHZzIHBlcmNwdS12bS5jIGlzIGJhc2VkIG9uDQo+IENPTkZJR19ORUVE
X1BFUl9DUFVfS00uIFRoaXMgaXMgc2V0IGluIG1tL0tjb25maWcgd2hpY2ggaXMgZGVwZW5kZW50
DQo+IG9uICFTTVAuIEdpdmVuIHRoYXQsIGl0IHdpbGwgb25seSBiZSBjYWxsZWQgd2l0aCB0aGUg
VVAgKHVuaXByb2Nlc3NvcikgdmVyc2lvbiBvZg0KPiBzZXR1cF9wZXJfY3B1X2FyZWFzKCkgd2hp
Y2ggaW5pdHMgYmFzZWQgb24gcGNwdV9hbGxvY19hbGxvY19pbmZvKDEsIDEpLiAgU28sDQo+IGJl
Y2F1c2Ugb2YgdGhpcywgd2Uga25vdyB0aGVyZSB3aWxsIG5vdCBiZSBvdGhlciBncm91cHMuIElu
IHRoZSBVUCBjYXNlLA0KPiBwZXJjcHUganVzdCBpZGVudGl0eSBtYXBzIHBlcmNwdSB2YXJpYWJs
ZXMuDQoNClRoYW5rcyBmb3IgdGhlIGNsYXJpZmljYXRpb24sIGl0IGlzIGNsZWFyIHRvIG1lLg0K
DQpUaGFua3MsDQpQZW5nLg0KDQo+IA0KPiBUaGFua3MsDQo+IERlbm5pcw0K

