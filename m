Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 032C1C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 11:14:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A09252173C
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 11:14:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=armh.onmicrosoft.com header.i=@armh.onmicrosoft.com header.b="SN/xW1TU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A09252173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 357CC8E0003; Mon, 18 Feb 2019 06:14:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 307FE8E0002; Mon, 18 Feb 2019 06:14:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D2888E0003; Mon, 18 Feb 2019 06:14:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B977B8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 06:14:28 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d9so7030327edh.4
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 03:14:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:user-agent:content-id:content-transfer-encoding
         :mime-version;
        bh=v+kg+3SUn8YALUSgNr6Ir2VTidISkCWDI/Gzi//ZmY4=;
        b=og0q3jdkPB8uaY7bFJUEIdYC/uaASBL0KtX+G4e5CvP7dupQpNqFG8gQrPjWJSJeqz
         jmo4+DsmXIDRsnJJ2+Sl2DsPb2WZxxeNVr5P8dW1l5fEqYE65p7r9pMar71ih0AY24w/
         24ACSd4Hyv7gS+3x5BUl+7M8xz4kBt4uUWWKIVwjln7mJYAucguNq7CnZrOknEvlSl1Q
         OABQ+Us1PIVvnEX/lE19LtaxbITbKetMCdkwso91TOtkNA/+1kwgYbJjgPDN6pgVq0bT
         Ze6SC53Vm1fKJhbHIfcuLH95nZClwp5lQow+0wn73CrYXoeIUMUw40Dc5xdv1z0meltG
         s4Tw==
X-Gm-Message-State: AHQUAuY0p9Q0oaZG2/KThT60c+LRkINakzvzjEgKH4+ST4Xl3QXVhMxS
	2ryPzBdCKOmwgbaWjObIQlsNLgNdC+V5FS0F7QSSszkgqRZ4LoI1T4sYXw5myH08OFQppNcN3XZ
	OVTqCWFtI7bYY648f+Vnr1AUxFKJrsRFYkvQBLN2heerq6HTtDfoy17J6uvrvmX5kKw==
X-Received: by 2002:a17:906:9398:: with SMTP id l24mr1514701ejx.128.1550488468201;
        Mon, 18 Feb 2019 03:14:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZkQgJfXbfex8BJEnPM0cTUZOnPKUJVDxfFpWxPpit3SaTVYX9I6R4PgaCWWfwqWM1cr5Zt
X-Received: by 2002:a17:906:9398:: with SMTP id l24mr1514620ejx.128.1550488466596;
        Mon, 18 Feb 2019 03:14:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550488466; cv=none;
        d=google.com; s=arc-20160816;
        b=N5yskdh7lyUxhALWA2RhgmFmChKcsJOAd9A2SZB79Yhg2eWSbJZqnwJ/8rVbAj0tc5
         dszqZA6NfwB4FPVLAVFIXUYuew06WPT/27G321UYCiSul54efzk67GX4SvNERI687XCt
         qOKg8ojLbbhXyMn4EiU7QR/CBmdLEMZHrggG8mPloCha70XaLEfnBgMH2f7PcoLj4Zwr
         pjSwIULtzGd0+3hy+tkNI5RUeWW6qr6DO833h8DdjNxU8LswmrW3z/YfZRE9sW8tRvGm
         uwmu/fJKoqFBVGvQIqJHVXR3Dj7eWOTAL+ER9XTMEvBsq95RDSCxuZ/zbf5lgeF/6Wf5
         rIoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from:dkim-signature;
        bh=v+kg+3SUn8YALUSgNr6Ir2VTidISkCWDI/Gzi//ZmY4=;
        b=Jkt69H5DjVooqMIu11ebQYFaiSjYLsefPvDSPsI3kF/UkxCfwrWSktNk/zY8hWwF5P
         BVQ7yEli1Tyr3GaYp0bPH+oxc26XMxdgTTCwVI9PiMWoHwPuKsr9fHwKfjMLte6kO26H
         kHB7xaTznZ4gsdvdQyb0pB3N9A47OfZZwWz88RAFbIif6Wuxq22+m9P6H7j7/clEKKXr
         TLK6biK+nhlyghDk6aePtbkeqf4ofVsYaLhbIGsxhfdwzImzQKiyfLrO95V7f6CCXKXk
         bLIrqyfAXtBnM62g3jaRPMASL0n5/kknkeFKiNABAf4FKxrrFWiI1YOs4GSzzO1K3G+C
         G/lA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@armh.onmicrosoft.com header.s=selector1-arm-com header.b="SN/xW1TU";
       spf=pass (google.com: domain of mark.rutland@arm.com designates 40.107.7.82 as permitted sender) smtp.mailfrom=Mark.Rutland@arm.com
Received: from EUR04-HE1-obe.outbound.protection.outlook.com (mail-eopbgr70082.outbound.protection.outlook.com. [40.107.7.82])
        by mx.google.com with ESMTPS id kb11si681078ejb.163.2019.02.18.03.14.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Feb 2019 03:14:26 -0800 (PST)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 40.107.7.82 as permitted sender) client-ip=40.107.7.82;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@armh.onmicrosoft.com header.s=selector1-arm-com header.b="SN/xW1TU";
       spf=pass (google.com: domain of mark.rutland@arm.com designates 40.107.7.82 as permitted sender) smtp.mailfrom=Mark.Rutland@arm.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=armh.onmicrosoft.com;
 s=selector1-arm-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=v+kg+3SUn8YALUSgNr6Ir2VTidISkCWDI/Gzi//ZmY4=;
 b=SN/xW1TUIgRvUHT4QCEAi3CoxJtju28dlN8M3Hw3TvAvXRuDhqkaCc/9G6l3cnnmbQ5IudTMqJFV+OiGOpH4UwqGrMm7JGteNIBYw11kRUAquwsDcBx0NzfkxZuTe3u2Au8Lhr692ebSbmAI08FnLosDacpjBzfjn/b5ffCVpjI=
Received: from VI1PR08MB3742.eurprd08.prod.outlook.com (20.178.15.26) by
 VI1PR08MB4592.eurprd08.prod.outlook.com (20.178.13.90) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1622.18; Mon, 18 Feb 2019 11:14:24 +0000
Received: from VI1PR08MB3742.eurprd08.prod.outlook.com
 ([fe80::2508:8790:80cb:2f91]) by VI1PR08MB3742.eurprd08.prod.outlook.com
 ([fe80::2508:8790:80cb:2f91%6]) with mapi id 15.20.1622.018; Mon, 18 Feb 2019
 11:14:24 +0000
From: Mark Rutland <Mark.Rutland@arm.com>
To: Steven Price <Steven.Price@arm.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org"
	<x86@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel
	<ard.biesheuvel@linaro.org>, Peter Zijlstra <peterz@infradead.org>, Catalin
 Marinas <Catalin.Marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>,
	Will Deacon <Will.Deacon@arm.com>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, =?iso-8859-1?Q?J=E9r=F4me_Glisse?=
	<jglisse@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov
	<bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin"
	<hpa@zytor.com>, James Morse <James.Morse@arm.com>, Thomas Gleixner
	<tglx@linutronix.de>, "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
Subject: Re: [PATCH 03/13] mm: Add generic p?d_large() macros
Thread-Topic: [PATCH 03/13] mm: Add generic p?d_large() macros
Thread-Index: AQHUxVB13qXbZZSGCkaNmBP9ni6xCaXla5CA
Date: Mon, 18 Feb 2019 11:14:23 +0000
Message-ID: <20190218111421.GC8036@lakrids.cambridge.arm.com>
References: <20190215170235.23360-1-steven.price@arm.com>
 <20190215170235.23360-4-steven.price@arm.com>
In-Reply-To: <20190215170235.23360-4-steven.price@arm.com>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
x-originating-ip: [217.140.106.52]
x-clientproxiedby: LO2P265CA0014.GBRP265.PROD.OUTLOOK.COM
 (2603:10a6:600:62::26) To VI1PR08MB3742.eurprd08.prod.outlook.com
 (2603:10a6:803:bc::26)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Mark.Rutland@arm.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c9d66bc4-5040-437a-c302-08d695923cba
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:VI1PR08MB4592;
x-ms-traffictypediagnostic: VI1PR08MB4592:
x-ms-exchange-purlcount: 1
x-microsoft-exchange-diagnostics:
 1;VI1PR08MB4592;20:+LaEaSls8RFdyZp8JCBePq6fsER350oifRElVu9PkeUYOE/7f3GTgIqhWjdnfX43V29xc4fvgR4rxCrZOEmEGVda7y/DHstmUdlbctibbDGiuKiNgGE0S+NXJyhqmQeOEj+wKN3NZZjarYEY7OlurQ93avcj6ZcqoI2bn7t0gSA=
x-microsoft-antispam-prvs:
 <VI1PR08MB45924F5EC4EE6FB3B2955EBB84630@VI1PR08MB4592.eurprd08.prod.outlook.com>
x-forefront-prvs: 09525C61DB
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(396003)(136003)(346002)(376002)(39860400002)(40434004)(199004)(189003)(6436002)(81166006)(8676002)(478600001)(4326008)(71200400001)(446003)(6512007)(11346002)(102836004)(6246003)(6862004)(5024004)(14444005)(256004)(6306002)(76176011)(99286004)(68736007)(476003)(6506007)(386003)(71190400001)(316002)(81156014)(58126008)(7736002)(54906003)(966005)(8936002)(2906002)(14454004)(72206003)(86362001)(5660300002)(305945005)(1076003)(186003)(97736004)(106356001)(7416002)(52116002)(26005)(105586002)(3846002)(6116002)(6636002)(486006)(33656002)(44832011)(53936002)(6486002)(66066001)(25786009)(229853002)(18370500001)(41533002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR08MB4592;H:VI1PR08MB3742.eurprd08.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: arm.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 AW0NrUKeAakbjy85/NBtXV21wpnIrAjcnMTJU2xeRwfixyvWPMmDLEsQ+HU6JUpWjf1tuLdBuvMHR8TwqKjwoxasfgSsJLCnWaIoAGesRuYuwOpvnTqA5SMecKsV1+gJjs+2AVmyk4pOcra2JDONbm5Z/ZcRk+e8ngxULwYR5YfjWCvndTtm5L4i5TPrdvqSE7oe9nl7Op7I3THsq9zNEKu8agrWySFq2YJ1Chb0ee1JtfOV+R/VFAyChasBrDpouX46iQ9yWzy4IHHNb2Lh9GRViy5YA5AjbIkjwoHa26EXPUtEjMThux4KGLRsV+aREjcPe5ddvpRJCb0gAGif4dm1C0cYXy6Sy8htmfGn/RwXs5pZYhMNCTwmMFrJJpFk4wZWVWPv2lKk4RI75wGa5Eh9OzWYmGY1v8Uuc2hQGnU=
Content-Type: text/plain; charset="iso-8859-1"
Content-ID: <1EAE3F73B7FC5443939FAD57784A5865@eurprd08.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: arm.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c9d66bc4-5040-437a-c302-08d695923cba
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Feb 2019 11:14:23.0296
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: f34e5979-57d9-4aaa-ad4d-b122a662184d
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR08MB4592
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 05:02:24PM +0000, Steven Price wrote:
> From: James Morse <james.morse@arm.com>
>
> Exposing the pud/pgd levels of the page tables to walk_page_range() means
> we may come across the exotic large mappings that come with large areas
> of contiguous memory (such as the kernel's linear map).
>
> For architectures that don't provide p?d_large() macros, provided a
> does nothing default.
>
> Signed-off-by: James Morse <james.morse@arm.com>
> Signed-off-by: Steven Price <steven.price@arm.com>
> ---
>  include/asm-generic/pgtable.h | 10 ++++++++++
>  1 file changed, 10 insertions(+)
>
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.=
h
> index 05e61e6c843f..7630d663cd51 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -1186,4 +1186,14 @@ static inline bool arch_has_pfn_modify_check(void)
>  #define mm_pmd_folded(mm)__is_defined(__PAGETABLE_PMD_FOLDED)
>  #endif
>
> +#ifndef pgd_large
> +#define pgd_large(x)0
> +#endif
> +#ifndef pud_large
> +#define pud_large(x)0
> +#endif
> +#ifndef pmd_large
> +#define pmd_large(x)0
> +#endif

It might be worth a comment defining the semantics of these, e.g. how
they differ from p?d_huge() and p?d_trans_huge().

Thanks,
Mark.

> +
>  #endif /* _ASM_GENERIC_PGTABLE_H */
> --
> 2.20.1
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
IMPORTANT NOTICE: The contents of this email and any attachments are confid=
ential and may also be privileged. If you are not the intended recipient, p=
lease notify the sender immediately and do not disclose the contents to any=
 other person, use it for any purpose, or store or copy the information in =
any medium. Thank you.

