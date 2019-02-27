Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE1D3C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 13:33:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DF2B2133D
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 13:33:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=nxp.com header.i=@nxp.com header.b="xcjoHXEr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DF2B2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nxp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E64D8E0003; Wed, 27 Feb 2019 08:33:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8970A8E0001; Wed, 27 Feb 2019 08:33:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75F5A8E0003; Wed, 27 Feb 2019 08:33:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 266C68E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 08:33:22 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id o7so13201047pfi.23
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 05:33:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=pP2p8GEwTeqB12i0ZJ0WiEERkhBCKcXaq41pWUmSvyE=;
        b=sG5He0gQG+d66ScRdFGKAa8AK7+HhDLe631rqxZwx9rshqU3ja2eRMaZKGYseTBtIX
         tD+0bTQr5yAh86v0t5DYPiN5w3iByIwaAz3dp6F1P+YCNB0QJnFdHByaHuz0HKSwHfEh
         aWpfHvEk8ajoDdQVzaC9SiTBNvpCNI6BsD5VZBS6gCgHCgP76DwB8C0UEHBv7mVyfCvK
         z/457059GxPD0ErBqiREBwhaAVw7OCQJTRTOLNWWm4w18HenKjG2a/wwP6fyVWCAih3M
         elhipfgTkfeREkl40DP3Q7p9RymkwmhqB3exeHDO4DsYpoIY5a8FHRnDpEuFgE8QjDiH
         /f9g==
X-Gm-Message-State: AHQUAuYnfAgOXdqUvi5TZUnNJPzgVr7kd6qniic9M2PYAGLkB4VeReZN
	5M3+8ehmR7Jgs2MrmSbSODI0fwhT0pjzBSB0yx1Fnlkj4UEmM1ZIb/IDWIl96e9jH3IMU90nmur
	ehEKXmaFmIW3l7mfs8WhozFeGMhPBnsaQSys4SOKml03WgMKKq90Da2y2t9AVfGBufw==
X-Received: by 2002:a17:902:8304:: with SMTP id bd4mr2085405plb.329.1551274401721;
        Wed, 27 Feb 2019 05:33:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibahrcm815UT3RaRqie+M1YGv88X4hVI/WNQJs54fmuzES325MR9SRrq25EhAnK8cYHFJV4
X-Received: by 2002:a17:902:8304:: with SMTP id bd4mr2085308plb.329.1551274400422;
        Wed, 27 Feb 2019 05:33:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551274400; cv=none;
        d=google.com; s=arc-20160816;
        b=1IIfjKfZ2xyHve1MmmLT8kWyFo6Y/A0qfLbos+Z/ckB4xDHssvSweWL5pUlo7MNxuv
         09rMGEvpm9TrPu5+DGRcxfW2Zu2DlIC9cRZwvGBRWFAyVs55qGOM5/MIcUyYae8OYVFz
         2lRNwsjUuJoCzZbEgSYdRPZOnRZounSSrSPUG9UBkCGasQQNi6/NXYk7sus1dXgS1diM
         6yAxYz5PlyDZH+X/nr4V56hRapP527xilWPih+48orI+NnXPImry7HZo3M0Oy76bTowC
         rYFUEYnaICvByLKq4XFFVbjQ5WsepxN2eU8TQHGHKFke4nzkTZgSJxIWxbOv0h/QmcvZ
         pQng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=pP2p8GEwTeqB12i0ZJ0WiEERkhBCKcXaq41pWUmSvyE=;
        b=BPt7edN42NeiFwiNmBOF449ED07bVr22JM4SmxdKgSvTMWYGbmBRnoxHiR+D4a7enV
         OMAcb+9xhiyIsCNGZR5hvbEFe4m/pFrs25yfznNXMjzWLvmgBX5FXxBvZ3IxX3JYXJbl
         mfvn+vquRaseJptArr+Mh8/JJ3WUMFXLrUhCKBYTt5uvBA482tn3tfgmqwR6RrWJOW7H
         iEnpKh2hej+tFkVUsmRwHhrFciNJ6ba0PkF+rsXkfBuZyxNKX5Gzw8a2kxwTxpDDIXbM
         zJE7e2u/pj3iIKkY9Cv1PzxT+A9jlipvWMy79hkJGhG+ut2lcAzIpOaSAo7YzWYyBvTu
         XtRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=xcjoHXEr;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.15.52 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150052.outbound.protection.outlook.com. [40.107.15.52])
        by mx.google.com with ESMTPS id r18si3467146pgv.485.2019.02.27.05.33.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 05:33:20 -0800 (PST)
Received-SPF: pass (google.com: domain of peng.fan@nxp.com designates 40.107.15.52 as permitted sender) client-ip=40.107.15.52;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nxp.com header.s=selector1 header.b=xcjoHXEr;
       spf=pass (google.com: domain of peng.fan@nxp.com designates 40.107.15.52 as permitted sender) smtp.mailfrom=peng.fan@nxp.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nxp.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nxp.com; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=pP2p8GEwTeqB12i0ZJ0WiEERkhBCKcXaq41pWUmSvyE=;
 b=xcjoHXEr1IG35NaSemQ4p/edTyuB4Sp21ElwkDomP+UJO0LxiSweXMdCflpScIXDWcgOBzZNCmHhWNDWcAlYR/KfE7YTVXVSagpalRnsoLL03lvr7dHkUQY/j49n9TtSbe7NB0c3DAKXrh8ZVf979A6MEU8TC246wBIhvK1lR2Q=
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com (52.135.147.15) by
 AM0PR04MB3956.eurprd04.prod.outlook.com (52.134.93.159) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.16; Wed, 27 Feb 2019 13:33:15 +0000
Received: from AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185]) by AM0PR04MB4481.eurprd04.prod.outlook.com
 ([fe80::a51f:134d:b530:f185%5]) with mapi id 15.20.1643.019; Wed, 27 Feb 2019
 13:33:15 +0000
From: Peng Fan <peng.fan@nxp.com>
To: Dennis Zhou <dennis@kernel.org>
CC: "tj@kernel.org" <tj@kernel.org>, "cl@linux.com" <cl@linux.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "van.freenix@gmail.com"
	<van.freenix@gmail.com>
Subject: RE: [RFC] percpu: decrease pcpu_nr_slots by 1
Thread-Topic: [RFC] percpu: decrease pcpu_nr_slots by 1
Thread-Index: AQHUzCG3EUVkDmE6x0qXBqXQe9HUi6Xwo+MAgACRjOCAASTWAIABRxxQ
Date: Wed, 27 Feb 2019 13:33:15 +0000
Message-ID:
 <AM0PR04MB44814BC1B03CC8D3963D969988740@AM0PR04MB4481.eurprd04.prod.outlook.com>
References: <20190224092838.3417-1-peng.fan@nxp.com>
 <20190225152336.GC49611@dennisz-mbp.dhcp.thefacebook.com>
 <AM0PR04MB448161D9ED7D152AD58B53E9887B0@AM0PR04MB4481.eurprd04.prod.outlook.com>
 <20190226173238.GA51080@dennisz-mbp.dhcp.thefacebook.com>
In-Reply-To: <20190226173238.GA51080@dennisz-mbp.dhcp.thefacebook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=peng.fan@nxp.com; 
x-originating-ip: [119.31.174.68]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 84eccfdb-b0fe-4c1e-f5a9-08d69cb820af
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:AM0PR04MB3956;
x-ms-traffictypediagnostic: AM0PR04MB3956:
x-microsoft-exchange-diagnostics:
 =?utf-8?B?MTtBTTBQUjA0TUIzOTU2OzIzOllnOEJycWRYRFlRRmxWSWJCWDBwUW9YaHRy?=
 =?utf-8?B?UjFrOUVMcWVzeDFlQzBZZy83U2pINGsydThIeTBhbEZRUDA0Qk1FVmNHVGV6?=
 =?utf-8?B?QStTR1pjcUQrak4xdlBVbjVSOUFHSG14UUczQlNWTmpLU2FYRzVSbGFlSFdw?=
 =?utf-8?B?NTVEUTIrd2VYem15ejMrSGV6VzdGWm9NQ0NZZkwrQ0FSdEFDT0ZBKzNHOGZj?=
 =?utf-8?B?a0V5dktMTHZqNG9ZbFRIOVZXb2JWSzNvb2xpTDgzMlpQaUx5SnVyR2dPQjNB?=
 =?utf-8?B?akc3enFWNzFUZjM1K3RzYjkybXlUUkU2MGY4Z1JDNjJPRGxhSjE4aVF1N0NV?=
 =?utf-8?B?TUxPcUU5eXVjdktLOCtyaEpqSWMvbUU4ZmRZT3h6NVhuSjJvMzFETDNSbEJD?=
 =?utf-8?B?U01HNE1ZRkt5aVlPN1Ftb2NIVjdROU9kN1hSeDdCS1REMHUwZ0JnRlZWYjBQ?=
 =?utf-8?B?cXhiL0dXbEc3czFRT0NiTkUrRmxrcEZ6VGt3aTZkcCsrZTQ1VmlrWlAycW5I?=
 =?utf-8?B?VVhaTlRNRG9LeU5aQmllMDdUUFpTVU5JcXJEazV4a3IwTFFTZ0FkVW14K1Rw?=
 =?utf-8?B?SDBVN0RsSDZYV1gwS0JybE1GTFZBOGhiOEp5Y3k2dDNKWFNweGxyUzJMM0h1?=
 =?utf-8?B?N1Q5WEFCYzFXYzU3Qk5pSStXUW5PMEFrZGxjSE4wbktQTEduY29SK251c3hD?=
 =?utf-8?B?N0FBVHVWVkRzSGRSRUdIMXZZSWV3SWx2TzY4NkFzZWpSZUFBUngrbjRPWWxo?=
 =?utf-8?B?TitYb0grcE5kUURXNWZWeklXN0RVd3RucXJEUEZYUVNGbVcrR0VFK3ppVlgr?=
 =?utf-8?B?TEZTZmhBWHpRcXJYeE1iV0lydW5EVW5FeGtYbVpxYlBkcWY0K0N4K2VIYUpo?=
 =?utf-8?B?bWdBNGRhQWd0RmxoWlhMYVNOMlovNHFwUUthODFZOTFyQlV6QjFqZUJ1VzBG?=
 =?utf-8?B?WUR1Rm52aGUvcjlROTNqcThJK29oVGVRQUVjTGhuME1oV3JDa085aFhuOEdO?=
 =?utf-8?B?dldXNERWbDdjU1hMbGgrRUR2TGowais5cjM4U3FRNC9mN3BoU0lGbmdEWXJ0?=
 =?utf-8?B?REZlMmFzMUpJUGswY1ljb1VwVzJBSmhSSG5hMDFUeXdISzFyY0xUelF2a2ln?=
 =?utf-8?B?SkhTcm5wRzZteFhrNmlJZWtvSmtsU1NtSnU2SkFOQ3l1TUJpU21GRnNyMDBt?=
 =?utf-8?B?VVhNMllaTVhMZGphNDlxMUcxVVVRYTlyeVV2L242L2VwZDZKY0hzUzM4KzZV?=
 =?utf-8?B?Z01SNUY5RmNhNzVleENTTFdsMjlJTzMxTDhCc1JmN3NiSWg4Mm1GUVNUc01p?=
 =?utf-8?B?UHpZNU85Y1RJUi9lYjNHcWRCckxqb241aTByalhQOFk0SWdGLysxMkVnMUtO?=
 =?utf-8?B?bnkwOGw1TDMvai9YR0dXWlNwaGw0ZEs1Ry9zV0taTHFLUWhEdGtSNHFRelpQ?=
 =?utf-8?B?NnVJOVFyWURDVUZuZnZZK2JsK3F6TkN4Q2RYK2k0R2tJaTRtZzBLbmZXOW9m?=
 =?utf-8?B?MFd0bUZHNTIwMk1RSzBNaXQ5UTZJV0I2Q0JhRktadjY4b3ZkMEhOeTVDSGlY?=
 =?utf-8?B?Ykw3b3Vpb3VWTTIwa0VjVFVjaUZtVWVwRDRjRC9LQzVoRmRjWFdpS3VnVHZs?=
 =?utf-8?B?TkRGblR2KytJN0Qrd3I3UGtLaVZIVjdRb1p1aEpvZUEvTzBnTzR1enR6bkNy?=
 =?utf-8?B?RjVLTFdTVDd5NzA0R08rWktCZUkvZTh2RFlSN3c0K2ZDUHpVTTZFTndqOG8z?=
 =?utf-8?Q?viuBXv+nqtf3aS9LI+3hp6jwNcmR+pn/cFRbE=3D?=
x-microsoft-antispam-prvs:
 <AM0PR04MB395667EE26FA9B54EC27860C88740@AM0PR04MB3956.eurprd04.prod.outlook.com>
x-forefront-prvs: 0961DF5286
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(396003)(376002)(366004)(39860400002)(136003)(13464003)(189003)(199004)(446003)(6916009)(55016002)(71200400001)(9686003)(6436002)(186003)(486006)(14444005)(3846002)(25786009)(71190400001)(53546011)(6506007)(5660300002)(7696005)(305945005)(2906002)(4326008)(8936002)(93886005)(54906003)(6246003)(7736002)(97736004)(478600001)(8676002)(14454004)(99286004)(33656002)(53936002)(81166006)(81156014)(52536013)(105586002)(316002)(229853002)(86362001)(66066001)(6116002)(74316002)(102836004)(106356001)(68736007)(256004)(476003)(26005)(76176011)(44832011)(11346002);DIR:OUT;SFP:1101;SCL:1;SRVR:AM0PR04MB3956;H:AM0PR04MB4481.eurprd04.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: nxp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 zl+TyUU5OFyFJ21ski1rUdJ05mi3hxUpYEBFd2WWdvgHcdY1WBuPMSv0FSKobHq+/BgIr3JAj8bGzlf9uzPiTVx4O9p4lxQ+/kB16O7UKP8WynAlFVwMZI+8PakzKwQ6t4J81J7Apj8c66Kpt47tAyHbX82gbpVXvTiHSY1mWU7Mz3hC9T5Ns7iWj1DjR3xBXVtxBqEXhFGyTgB+sQoEehrH9nYfrBowWBc6OWtH7qJjeCojddOoBon5XeGweL6KaVuHcHTd+JIuIW5suRlcqrQvzpQTZeJ/UB3cywt9bKJn/AiPMiI+7iPSVnLbF5v3CSkez6AgKgpdvcfUERI7TKZxWazDc4tgNIq1JWkqE8HdbL/dQFf5HqaMQ61qJTh5RqCXXSA2to0kLbBCF60xT+QW/rb55SDS4EFg+FAtgy0=
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: nxp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 84eccfdb-b0fe-4c1e-f5a9-08d69cb820af
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Feb 2019 13:33:15.4340
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 686ea1d3-bc2b-4c6f-a92c-d99c5c301635
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AM0PR04MB3956
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkgRGVubmlzLA0KDQo+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+IEZyb206IERlbm5p
cyBaaG91IFttYWlsdG86ZGVubmlzQGtlcm5lbC5vcmddDQo+IFNlbnQ6IDIwMTnlubQy5pyIMjfm
l6UgMTozMw0KPiBUbzogUGVuZyBGYW4gPHBlbmcuZmFuQG54cC5jb20+DQo+IENjOiBkZW5uaXNA
a2VybmVsLm9yZzsgdGpAa2VybmVsLm9yZzsgY2xAbGludXguY29tOyBsaW51eC1tbUBrdmFjay5v
cmc7DQo+IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc7IHZhbi5mcmVlbml4QGdtYWlsLmNv
bQ0KPiBTdWJqZWN0OiBSZTogW1JGQ10gcGVyY3B1OiBkZWNyZWFzZSBwY3B1X25yX3Nsb3RzIGJ5
IDENCj4gDQo+IE9uIFR1ZSwgRmViIDI2LCAyMDE5IGF0IDEyOjA5OjI4QU0gKzAwMDAsIFBlbmcg
RmFuIHdyb3RlOg0KPiA+IEhpIERlbm5pcywNCj4gPg0KPiA+ID4gLS0tLS1PcmlnaW5hbCBNZXNz
YWdlLS0tLS0NCj4gPiA+IEZyb206IGRlbm5pc0BrZXJuZWwub3JnIFttYWlsdG86ZGVubmlzQGtl
cm5lbC5vcmddDQo+ID4gPiBTZW50OiAyMDE55bm0MuaciDI15pelIDIzOjI0DQo+ID4gPiBUbzog
UGVuZyBGYW4gPHBlbmcuZmFuQG54cC5jb20+DQo+ID4gPiBDYzogdGpAa2VybmVsLm9yZzsgY2xA
bGludXguY29tOyBsaW51eC1tbUBrdmFjay5vcmc7DQo+ID4gPiBsaW51eC1rZXJuZWxAdmdlci5r
ZXJuZWwub3JnOyB2YW4uZnJlZW5peEBnbWFpbC5jb20NCj4gPiA+IFN1YmplY3Q6IFJlOiBbUkZD
XSBwZXJjcHU6IGRlY3JlYXNlIHBjcHVfbnJfc2xvdHMgYnkgMQ0KPiA+ID4NCj4gPiA+IE9uIFN1
biwgRmViIDI0LCAyMDE5IGF0IDA5OjE3OjA4QU0gKzAwMDAsIFBlbmcgRmFuIHdyb3RlOg0KPiA+
ID4gPiBFbnRyeSBwY3B1X3Nsb3RbcGNwdV9ucl9zbG90cyAtIDJdIGlzIHdhc3RlZCB3aXRoIGN1
cnJlbnQgY29kZSBsb2dpYy4NCj4gPiA+ID4gcGNwdV9ucl9zbG90cyBpcyBjYWxjdWxhdGVkIHdp
dGggYF9fcGNwdV9zaXplX3RvX3Nsb3Qoc2l6ZSkgKyAyYC4NCj4gPiA+ID4gVGFrZSBwY3B1X3Vu
aXRfc2l6ZSBhcyAxMDI0IGZvciBleGFtcGxlLCBfX3BjcHVfc2l6ZV90b19zbG90IHdpbGwNCj4g
PiA+ID4gcmV0dXJuIG1heCgxMSAtIFBDUFVfU0xPVF9CQVNFX1NISUZUICsgMiwgMSksIGl0IGlz
IDgsIHNvIHRoZQ0KPiA+ID4gPiBwY3B1X25yX3Nsb3RzIHdpbGwgYmUgMTAuDQo+ID4gPiA+DQo+
ID4gPiA+IFRoZSBjaHVuayB3aXRoIGZyZWVfYnl0ZXMgMTAyNCB3aWxsIGJlIGxpbmtlZCBpbnRv
IHBjcHVfc2xvdFs5XS4NCj4gPiA+ID4gSG93ZXZlciBmcmVlX2J5dGVzIGluIHJhbmdlIFs1MTIs
MTAyNCkgd2lsbCBiZSBsaW5rZWQgaW50bw0KPiA+ID4gPiBwY3B1X3Nsb3RbN10sIGJlY2F1c2Ug
YGZscyg1MTIpIC0gUENQVV9TTE9UX0JBU0VfU0hJRlQgKyAyYCBpcyA3Lg0KPiA+ID4gPiBTbyBw
Y3B1X3Nsb3RbOF0gaXMgaGFzIG5vIGNoYW5jZSB0byBiZSB1c2VkLg0KPiA+ID4gPg0KPiA+ID4g
PiBBY2NvcmRpbmcgY29tbWVudHMgb2YgUENQVV9TTE9UX0JBU0VfU0hJRlQsIDF+MzEgYnl0ZXMg
c2hhcmUgdGhlDQo+ID4gPiBzYW1lDQo+ID4gPiA+IHNsb3QgYW5kIFBDUFVfU0xPVF9CQVNFX1NI
SUZUIGlzIGRlZmluZWQgYXMgNS4gQnV0IGFjdHVhbGx5IDF+MTUNCj4gPiA+ID4gc2hhcmUgdGhl
IHNhbWUgc2xvdCAxIGlmIHdlIG5vdCB0YWtlIFBDUFVfTUlOX0FMTE9DX1NJWkUgaW50bw0KPiA+
ID4gPiBjb25zaWRlcmF0aW9uLA0KPiA+ID4gPiAxNn4zMSBzaGFyZSBzbG90IDIuIENhbGN1bGF0
aW9uIGFzIGJlbG93Og0KPiA+ID4gPiBoaWdoYml0ID0gZmxzKDE2KSAtPiBoaWdoYml0ID0gNQ0K
PiA+ID4gPiBtYXgoNSAtIFBDUFVfU0xPVF9CQVNFX1NISUZUICsgMiwgMSkgZXF1YWxzIDIsIG5v
dCAxLg0KPiA+ID4gPg0KPiA+ID4gPiBUaGlzIHBhdGNoIGJ5IGRlY3JlYXNpbmcgcGNwdV9ucl9z
bG90cyB0byBhdm9pZCB3YXN0ZSBvbmUgc2xvdCBhbmQNCj4gPiA+ID4gbGV0IFtQQ1BVX01JTl9B
TExPQ19TSVpFLCAzMSkgcmVhbGx5IHNoYXJlIHRoZSBzYW1lIHNsb3QuDQo+ID4gPiA+DQo+ID4g
PiA+IFNpZ25lZC1vZmYtYnk6IFBlbmcgRmFuIDxwZW5nLmZhbkBueHAuY29tPg0KPiA+ID4gPiAt
LS0NCj4gPiA+ID4NCj4gPiA+ID4gVjE6DQo+ID4gPiA+ICBOb3QgdmVyeSBzdXJlIGFib3V0IHdo
ZXRoZXIgaXQgaXMgaW50ZW5kZWQgdG8gbGVhdmUgdGhlIHNsb3QgdGhlcmUuDQo+ID4gPiA+DQo+
ID4gPiA+ICBtbS9wZXJjcHUuYyB8IDQgKystLQ0KPiA+ID4gPiAgMSBmaWxlIGNoYW5nZWQsIDIg
aW5zZXJ0aW9ucygrKSwgMiBkZWxldGlvbnMoLSkNCj4gPiA+ID4NCj4gPiA+ID4gZGlmZiAtLWdp
dCBhL21tL3BlcmNwdS5jIGIvbW0vcGVyY3B1LmMgaW5kZXgNCj4gPiA+ID4gOGQ5OTMzZGI2MTYy
Li4xMmE5YmEzOGYwYjUgMTAwNjQ0DQo+ID4gPiA+IC0tLSBhL21tL3BlcmNwdS5jDQo+ID4gPiA+
ICsrKyBiL21tL3BlcmNwdS5jDQo+ID4gPiA+IEBAIC0yMTksNyArMjE5LDcgQEAgc3RhdGljIGJv
b2wgcGNwdV9hZGRyX2luX2NodW5rKHN0cnVjdA0KPiA+ID4gPiBwY3B1X2NodW5rICpjaHVuaywg
dm9pZCAqYWRkcikgIHN0YXRpYyBpbnQgX19wY3B1X3NpemVfdG9fc2xvdChpbnQgc2l6ZSkNCj4g
ew0KPiA+ID4gPiAgCWludCBoaWdoYml0ID0gZmxzKHNpemUpOwkvKiBzaXplIGlzIGluIGJ5dGVz
ICovDQo+ID4gPiA+IC0JcmV0dXJuIG1heChoaWdoYml0IC0gUENQVV9TTE9UX0JBU0VfU0hJRlQg
KyAyLCAxKTsNCj4gPiA+ID4gKwlyZXR1cm4gbWF4KGhpZ2hiaXQgLSBQQ1BVX1NMT1RfQkFTRV9T
SElGVCArIDEsIDEpOw0KPiA+ID4gPiAgfQ0KPiA+ID4NCj4gPiA+IEhvbmVzdGx5LCBpdCBtYXkg
YmUgYmV0dGVyIHRvIGp1c3QgaGF2ZSBbMS0xNikgWzE2LTMxKSBiZSBzZXBhcmF0ZS4NCg0KTWlz
c2VkIHRvIHJlcGx5IHRoaXMgaW4gcHJldmlvdXMgdGhyZWFkLCB0aGUgZm9sbG93aW5nIGNvbW1l
bnRzIGxldA0KbWUgdGhpbmsgdGhlIGNodW5rIHNsb3QgY2FsY3VsYXRpb24gbWlnaHQgYmUgd3Jv
bmcsIHNvIHRoaXMgY29tbWVudA0KbmVlZHMgdG8gYmUgdXBkYXRlZCwgc2F5aW5nICJbUENQVV9N
SU5fQUxMT0NfU0laRSAtIDE1KSBieXRlcyBzaGFyZQ0KdGhlIHNhbWUgc2xvdCIsIGlmIFsxLTE2
KVsxNi0zMSkgaXMgZXhwZWN0ZWQuDQoiDQovKiB0aGUgc2xvdHMgYXJlIHNvcnRlZCBieSBmcmVl
IGJ5dGVzIGxlZnQsIDEtMzEgYnl0ZXMgc2hhcmUgdGhlIHNhbWUgc2xvdCAqLw0KI2RlZmluZSBQ
Q1BVX1NMT1RfQkFTRV9TSElGVCAgICAgICAgICAgIDUNCiINCg0KPiA+ID4gSSdtIHdvcmtpbmcg
b24gYSBjaGFuZ2UgdG8gdGhpcyBhcmVhLCBzbyBJIG1heSBjaGFuZ2Ugd2hhdCdzIGdvaW5nIG9u
DQo+IGhlcmUuDQo+ID4gPg0KPiA+ID4gPg0KPiA+ID4gPiAgc3RhdGljIGludCBwY3B1X3NpemVf
dG9fc2xvdChpbnQgc2l6ZSkgQEAgLTIxNDUsNyArMjE0NSw3IEBAIGludA0KPiA+ID4gPiBfX2lu
aXQgcGNwdV9zZXR1cF9maXJzdF9jaHVuayhjb25zdCBzdHJ1Y3QgcGNwdV9hbGxvY19pbmZvICph
aSwNCj4gPiA+ID4gIAkgKiBBbGxvY2F0ZSBjaHVuayBzbG90cy4gIFRoZSBhZGRpdGlvbmFsIGxh
c3Qgc2xvdCBpcyBmb3INCj4gPiA+ID4gIAkgKiBlbXB0eSBjaHVua3MuDQo+ID4gPiA+ICAJICov
DQo+ID4gPiA+IC0JcGNwdV9ucl9zbG90cyA9IF9fcGNwdV9zaXplX3RvX3Nsb3QocGNwdV91bml0
X3NpemUpICsgMjsNCj4gPiA+ID4gKwlwY3B1X25yX3Nsb3RzID0gX19wY3B1X3NpemVfdG9fc2xv
dChwY3B1X3VuaXRfc2l6ZSkgKyAxOw0KPiA+ID4gPiAgCXBjcHVfc2xvdCA9IG1lbWJsb2NrX2Fs
bG9jKHBjcHVfbnJfc2xvdHMgKiBzaXplb2YocGNwdV9zbG90WzBdKSwNCj4gPiA+ID4gIAkJCQkg
ICBTTVBfQ0FDSEVfQllURVMpOw0KPiA+ID4gPiAgCWZvciAoaSA9IDA7IGkgPCBwY3B1X25yX3Ns
b3RzOyBpKyspDQo+ID4gPiA+IC0tDQo+ID4gPiA+IDIuMTYuNA0KPiA+ID4gPg0KPiA+ID4NCj4g
PiA+IFRoaXMgaXMgYSB0cmlja3kgY2hhbmdlLiBUaGUgbmljZSB0aGluZyBhYm91dCBrZWVwaW5n
IHRoZSBhZGRpdGlvbmFsDQo+ID4gPiBzbG90IGFyb3VuZCBpcyB0aGF0IGl0IGVuc3VyZXMgYSBk
aXN0aW5jdGlvbiBiZXR3ZWVuIGEgY29tcGxldGVseQ0KPiA+ID4gZW1wdHkgY2h1bmsgYW5kIGEg
bmVhcmx5IGVtcHR5IGNodW5rLg0KPiA+DQo+ID4gQXJlIHRoZXJlIGFueSBpc3N1ZXMgbWV0IGJl
Zm9yZSBpZiBub3Qga2VlcGluZyB0aGUgdW51c2VkIHNsb3Q/DQo+ID4gRnJvbSByZWFkaW5nIHRo
ZSBjb2RlIGFuZCBnaXQgaGlzdG9yeSBJIGNvdWxkIG5vdCBmaW5kIGluZm9ybWF0aW9uLg0KPiA+
IEkgdHJpZWQgdGhpcyBjb2RlIG9uIGFhcmNoNjQgcWVtdSBhbmQgZGlkIG5vdCBtZWV0IGlzc3Vl
cy4NCj4gPg0KPiANCj4gVGhpcyBjaGFuZ2Ugd291bGQgcmVxdWlyZSB2ZXJpZmljYXRpb24gdGhh
dCBhbGwgcGF0aHMgbGVhZCB0byBwb3dlciBvZiAyIGNodW5rDQo+IHNpemVzIGFuZCBtb3N0IGxp
a2VseSBhIEJVR19PTiBpZiB0aGF0J3Mgbm90IHRoZSBjYXNlLg0KDQpJIHRyeSB0byB1bmRlcnN0
YW5kLCAicG93ZXIgb2YgMiBjaHVuayBzaXplcyIsIHlvdSBtZWFuIHRoZSBydW50aW1lIGZyZWVf
Ynl0ZXMNCm9mIGEgY2h1bms/DQoNCj4gDQo+IFNvIHdoaWxlIHRoaXMgd291bGQgd29yaywgd2Un
cmUgaG9sZGluZyBvbnRvIGFuIGFkZGl0aW9uYWwgc2xvdCBhbHNvIHRvIGJlIHVzZWQNCj4gZm9y
IGNodW5rIHJlY2xhbWF0aW9uIHZpYSBwY3B1X2JhbGFuY2Vfd29ya2ZuKCkuIElmIGEgY2h1bmsg
d2FzIG5vdCBhIHBvd2VyDQo+IG9mIDIgcmVzdWx0aW5nIGluIHRoZSBsYXN0IHNsb3QgYmVpbmcg
ZW50aXJlbHkgZW1wdHkgY2h1bmtzIHdlIGNvdWxkIGZyZWUgc3R1ZmYgYQ0KPiBjaHVuayB3aXRo
IGFkZHJlc3NlcyBzdGlsbCBpbiB1c2UuDQoNCllvdSBtZWFuIHRoZSBmb2xsb3dpbmcgY29kZSBt
aWdodCBmcmVlIHN0dWZmIHdoZW4gYSBwZXJjcHUgdmFyaWFibGUgaXMgc3RpbGwgYmVpbmcgdXNl
ZA0KaWYgdGhlIGNodW5rIHJ1bnRpbWUgZnJlZV9ieXRlcyBpcyBub3QgYSBwb3dlciBvZiAyPw0K
Ig0KMTYyMyAgICAgICAgIGxpc3RfZm9yX2VhY2hfZW50cnlfc2FmZShjaHVuaywgbmV4dCwgJnRv
X2ZyZWUsIGxpc3QpIHsNCjE2MjQgICAgICAgICAgICAgICAgIGludCBycywgcmU7DQoxNjI1DQox
NjI2ICAgICAgICAgICAgICAgICBwY3B1X2Zvcl9lYWNoX3BvcF9yZWdpb24oY2h1bmstPnBvcHVs
YXRlZCwgcnMsIHJlLCAwLA0KMTYyNyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgIGNodW5rLT5ucl9wYWdlcykgew0KMTYyOCAgICAgICAgICAgICAgICAgICAgICAgICBw
Y3B1X2RlcG9wdWxhdGVfY2h1bmsoY2h1bmssIHJzLCByZSk7DQoxNjI5ICAgICAgICAgICAgICAg
ICAgICAgICAgIHNwaW5fbG9ja19pcnEoJnBjcHVfbG9jayk7DQoxNjMwICAgICAgICAgICAgICAg
ICAgICAgICAgIHBjcHVfY2h1bmtfZGVwb3B1bGF0ZWQoY2h1bmssIHJzLCByZSk7DQoxNjMxICAg
ICAgICAgICAgICAgICAgICAgICAgIHNwaW5fdW5sb2NrX2lycSgmcGNwdV9sb2NrKTsNCjE2MzIg
ICAgICAgICAgICAgICAgIH0NCjE2MzMgICAgICAgICAgICAgICAgIHBjcHVfZGVzdHJveV9jaHVu
ayhjaHVuayk7DQoxNjM0ICAgICAgICAgICAgICAgICBjb25kX3Jlc2NoZWQoKTsNCjE2MzUgICAg
ICAgICB9DQoiDQoNCj4gDQo+ID4gPiBJdCBoYXBwZW5zIHRvIGJlIHRoYXQgdGhlIGxvZ2ljIGNy
ZWF0ZXMgcG93ZXIgb2YgMiBjaHVua3Mgd2hpY2ggZW5kcw0KPiA+ID4gdXAgYmVpbmcgYW4gYWRk
aXRpb25hbCBzbG90IGFueXdheS4NCj4gPg0KPiA+DQo+ID4gU28sDQo+ID4gPiBnaXZlbiB0aGF0
IHRoaXMgbG9naWMgaXMgdHJpY2t5IGFuZCBhcmNoaXRlY3R1cmUgZGVwZW5kZW50LA0KPiA+DQo+
ID4gQ291bGQgeW91IHNoYXJlIG1vcmUgaW5mb3JtYXRpb24gYWJvdXQgYXJjaGl0ZWN0dXJlIGRl
cGVuZGVudD8NCj4gPg0KPiANCj4gVGhlIGNydXggb2YgdGhlIGxvZ2ljIGlzIGluIHBjcHVfYnVp
bGRfYWxsb2NfaW5mbygpLiBJdCdzIGJlZW4gc29tZSB0aW1lIHNpbmNlDQo+IEkndmUgdGhvdWdo
dCBkZWVwbHkgYWJvdXQgaXQsIGJ1dCBJIGRvbid0IGJlbGlldmUgdGhlcmUgaXMgYSBndWFyYW50
ZWUgdGhhdCBpdCB3aWxsDQo+IGJlIGEgcG93ZXIgb2YgMiBjaHVuay4NCg0KSSBhbSBhIGJpdCBs
b3N0IGFib3V0IGEgcG93ZXIgb2YgMiwgbmVlZCB0byByZWFkIG1vcmUgYWJvdXQgdGhlIGNvZGUu
DQoNClRoYW5rcywNClBlbmcuDQoNCj4gDQo+IFRoYW5rcywNCj4gRGVubmlzDQo=

