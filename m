Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C63DC00319
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 00:17:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E94CC2083E
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 00:17:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="cZjYeicI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E94CC2083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 505FD8E00D9; Thu, 21 Feb 2019 19:17:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DBFC8E00D4; Thu, 21 Feb 2019 19:17:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CA8E8E00D9; Thu, 21 Feb 2019 19:17:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 127838E00D4
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 19:17:29 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id e25so251658otp.0
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 16:17:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=xr2PVGnchdEXX3rSpUVBd9tUKC1r1MM2z4aoy96Xjng=;
        b=jE5htCYAsQgMkgMWQlWsj2LHs917aIwcxFfoSGEtvqrFcSANfObiFKdQHxDQcNIBwV
         veW0GcfK6jhnbIOEdYfgrx+Vm9c3m5N0lYsRz//J+xY/QWIUKeaLwnEduuL82Qenko1P
         uhVhFdh7Jmodja4F08/hpFhXjS+y4BxfAQEMTl08L0PzF4D7rSSYtZ/WWmnOkZW5JLoQ
         m6FXjH1mAQSKfY5K10dfRI8isfFzVAurAnmpcpCMCDNm1Ypz7Y/Xy4Pan7f1BaBaV8vw
         gK+5H71SJjeBS7ZHsuwKMpUlZtsrVNgdsD2U6fQz+TVzv+PEQ0Gp4N6cuAcE/r2nPWUX
         zEAw==
X-Gm-Message-State: AHQUAuYNwW+aryvsiXoInWB0InPjGMlAgmYx14HkEkpSSf2TAgjFervi
	C+OR2Ik3I7TJ2fn1HkUOkE3/NsB8PHTmzhvXVvWZGP0wXxkh/4UM8+satLsjqMVyxp0m8txfDnN
	FCSPyPf5TszyJsSSJmKcquwDwWQ3hqaII1Ku/7b4jA7FjXyGvWyRx7Q6PQDUKIj/KvQ==
X-Received: by 2002:aca:c4cf:: with SMTP id u198mr769840oif.151.1550794648744;
        Thu, 21 Feb 2019 16:17:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3IazzeMRxvD5KAoLioh+M5zkxMRGKrntO07oYdc/T7SlFCFzvxo8cphiKTk3GWbpPj2YpiRJ
X-Received: by 2002:aca:c4cf:: with SMTP id u198mr769819oif.151.1550794648035;
        Thu, 21 Feb 2019 16:17:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550794648; cv=none;
        d=google.com; s=arc-20160816;
        b=itcQu4qTQ/nQ676NZrYODsI6c6xfhV/6HB8NJmZ5RqmE2AGZRr0WLicxu/ZcBP0MHY
         y9/bLaxzn3qXwZLL4CPH6+wV6sy981RIjJIFOxkhQa4Y10WNUvNSdccjAb7IFaTshB9A
         rBwKRbuwd88VOhXIfc8RTEyluEyZA07R6snl/7gVqFG26uxoIoXyVwq4c7k2lMdBM1R0
         uRNezxqlj82A0oSugZUd6xYXPAvB+KMqeXoEZFPOqNwvv+yx/nmeuP9GULewZzLeGFi/
         0IXkJ4J7Zdsd0EZYDNsPARG+oqjUwF4+1l4W0kc05ZWOKDuh2+y/Y5y1I4Gv2rrz+5Dw
         6glA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=xr2PVGnchdEXX3rSpUVBd9tUKC1r1MM2z4aoy96Xjng=;
        b=e6TS4gzFa3gNsl9DDBaa836giQW3M1wQrlaZS9DAN5wiYu0QANgoE4M1lmVo/XBFYe
         tM0n7lM1EGRBCpXDZZdHT2FWFPYgVBs3l3j3PXJ3J9dkT0NvDALInveIyrnwVYEG5Dby
         aCcnMxe+whfjfNEHFQAU6rsDEsbBgFJ74UD/l1nytbJCsKAC8TLfGazdkt+KCMiI01k8
         dsb2zxOuyNqvvVE8Wh1zRuYq5VzDeGYTk2fKs7guMAGqSmRQNaIUBha0ZPR7hb9lAHuP
         x/ckF3+qlD2ASrzZbH5sS4MvH55FSosQ4VFEterV0nNIDXk7vQGHmnLxqAIdI/FBQY6i
         vWoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=cZjYeicI;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.78.55 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-eopbgr780055.outbound.protection.outlook.com. [40.107.78.55])
        by mx.google.com with ESMTPS id e189si129413oif.123.2019.02.21.16.17.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 21 Feb 2019 16:17:28 -0800 (PST)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.78.55 as permitted sender) client-ip=40.107.78.55;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=cZjYeicI;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.78.55 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=xr2PVGnchdEXX3rSpUVBd9tUKC1r1MM2z4aoy96Xjng=;
 b=cZjYeicILS90TldOk4WQsSNktO7QznvmKQ5//jo0/afUjfblxhgi1ICqa0mLWtP6sO8Jtm0pAYQxC14nT74ubWiVrSnRIiEPHRirq0TfVE5FIi8Qb5neARPV5E2sCIypasY5QXsVxlAZNE+0XD1q6JQ5lx3FmObqg5EegFOiK9c=
Received: from BL0PR05MB4772.namprd05.prod.outlook.com (20.177.145.81) by
 BL0PR05MB4867.namprd05.prod.outlook.com (52.132.15.77) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.11; Fri, 22 Feb 2019 00:17:25 +0000
Received: from BL0PR05MB4772.namprd05.prod.outlook.com
 ([fe80::14dc:3a42:ace7:1fbd]) by BL0PR05MB4772.namprd05.prod.outlook.com
 ([fe80::14dc:3a42:ace7:1fbd%4]) with mapi id 15.20.1665.006; Fri, 22 Feb 2019
 00:17:25 +0000
From: Nadav Amit <namit@vmware.com>
To: Sean Christopherson <sean.j.christopherson@intel.com>
CC: Rick Edgecombe <rick.p.edgecombe@intel.com>, Andy Lutomirski
	<luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, LKML
	<linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin"
	<hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov
	<bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra
	<peterz@infradead.org>, Damian Tometzki <linux_dti@icloud.com>,
	linux-integrity <linux-integrity@vger.kernel.org>, LSM List
	<linux-security-module@vger.kernel.org>, Andrew Morton
	<akpm@linux-foundation.org>, Kernel Hardening
	<kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, Will
 Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Kristen Carlson Accardi <kristen@linux.intel.com>, "deneen.t.dock@intel.com"
	<deneen.t.dock@intel.com>
Subject: Re: [PATCH v3 03/20] x86/mm: Save DRs when loading a temporary mm
Thread-Topic: [PATCH v3 03/20] x86/mm: Save DRs when loading a temporary mm
Thread-Index: AQHUykBLv/ry53ApEkWdFOpKIcxWtaXq8LSAgAACwwA=
Date: Fri, 22 Feb 2019 00:17:24 +0000
Message-ID: <A8727670-F848-4BAD-BEFE-9C94329EA774@vmware.com>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
 <20190221234451.17632-4-rick.p.edgecombe@intel.com>
 <20190222000731.GE7224@linux.intel.com>
In-Reply-To: <20190222000731.GE7224@linux.intel.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [208.91.2.1]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 7215046b-f341-4d3f-08d1-08d6985b1f2d
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600110)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:BL0PR05MB4867;
x-ms-traffictypediagnostic: BL0PR05MB4867:
x-microsoft-exchange-diagnostics:
 1;BL0PR05MB4867;20:kCefyEeLr/frwa1JE68c7LEkoJ5PAn+3H7G4bxqGfqHBFZJq6o3gubHgcNI+A7zdhuYLucvKVn/NiQ99v7ytY4cE+0KQaNeGX/gMScCg1AQGi4V2H2sFub+5EHQ05F8zV3fWTeQKoIi6PARlGOG4hBW3kaoQDD2R8680F/j27sU=
x-microsoft-antispam-prvs:
 <BL0PR05MB4867F850F87297E2989B5511D07F0@BL0PR05MB4867.namprd05.prod.outlook.com>
x-forefront-prvs: 09565527D6
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(346002)(39860400002)(376002)(396003)(366004)(199004)(189003)(4326008)(305945005)(86362001)(53936002)(7736002)(105586002)(36756003)(2906002)(14454004)(33656002)(6246003)(106356001)(256004)(14444005)(478600001)(102836004)(6346003)(8676002)(81166006)(68736007)(81156014)(8936002)(71200400001)(5660300002)(486006)(26005)(54906003)(186003)(6116002)(25786009)(97736004)(76176011)(476003)(6512007)(53546011)(3846002)(7416002)(71190400001)(66066001)(6916009)(316002)(6506007)(82746002)(229853002)(6436002)(99286004)(446003)(83716004)(6486002)(11346002)(2616005);DIR:OUT;SFP:1101;SCL:1;SRVR:BL0PR05MB4867;H:BL0PR05MB4772.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 sFnHvFNsYpYPBHlO6+6SeLpWqVuIeNkP4I6BGRlidEoPoRtFdRrn3znVxMjq+M8iCyFHXPh8fofZa31MT1oLrVi5siao2Nu3FI4Ay2vCg90E7/jcGltDsVqXeH1rUPHFxglbnocxvzkAjNjVd4poTGiPsBj/QIXMtsNRojC3kwirR6Hp4ZEnVc1AhJagvrgwspx4lhZYwzm98MnZ4EyP3uJ/YdPOXyqAywpf/N9J2VSgaqlFhDqXpM+T7sY2FtTEXHITJ0nq5VnJ9okG/yqWmvDKm4sDTcvyG/ORgxjJ48k1E2t0TPY/Hiu0HBWY1ZJ5fb1X81Wb1S0IwCZwYPMLBaN9ottmZd4jlgbBipZNKKU6B2APheuF/jxJNq0v1q5RgKGJ67jFh01RbJVuot28ODdkMjTq+ut+gBTlf+9Vmjg=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <D769DF7E6D82BE459723C84B195B28F4@namprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 7215046b-f341-4d3f-08d1-08d6985b1f2d
X-MS-Exchange-CrossTenant-originalarrivaltime: 22 Feb 2019 00:17:24.9382
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BL0PR05MB4867
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Feb 21, 2019, at 4:07 PM, Sean Christopherson <sean.j.christopherson@i=
ntel.com> wrote:
>=20
> On Thu, Feb 21, 2019 at 03:44:34PM -0800, Rick Edgecombe wrote:
>> From: Nadav Amit <namit@vmware.com>
>>=20
>> Prevent user watchpoints from mistakenly firing while the temporary mm
>> is being used. As the addresses that of the temporary mm might overlap
>> those of the user-process, this is necessary to prevent wrong signals
>> or worse things from happening.
>>=20
>> Cc: Andy Lutomirski <luto@kernel.org>
>> Signed-off-by: Nadav Amit <namit@vmware.com>
>> ---
>> arch/x86/include/asm/mmu_context.h | 25 +++++++++++++++++++++++++
>> 1 file changed, 25 insertions(+)
>>=20
>> diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/m=
mu_context.h
>> index d684b954f3c0..0d6c72ece750 100644
>> --- a/arch/x86/include/asm/mmu_context.h
>> +++ b/arch/x86/include/asm/mmu_context.h
>> @@ -13,6 +13,7 @@
>> #include <asm/tlbflush.h>
>> #include <asm/paravirt.h>
>> #include <asm/mpx.h>
>> +#include <asm/debugreg.h>
>>=20
>> extern atomic64_t last_mm_ctx_id;
>>=20
>> @@ -358,6 +359,7 @@ static inline unsigned long __get_current_cr3_fast(v=
oid)
>>=20
>> typedef struct {
>> 	struct mm_struct *prev;
>> +	unsigned short bp_enabled : 1;
>> } temp_mm_state_t;
>>=20
>> /*
>> @@ -380,6 +382,22 @@ static inline temp_mm_state_t use_temporary_mm(stru=
ct mm_struct *mm)
>> 	lockdep_assert_irqs_disabled();
>> 	state.prev =3D this_cpu_read(cpu_tlbstate.loaded_mm);
>> 	switch_mm_irqs_off(NULL, mm, current);
>> +
>> +	/*
>> +	 * If breakpoints are enabled, disable them while the temporary mm is
>> +	 * used. Userspace might set up watchpoints on addresses that are used
>> +	 * in the temporary mm, which would lead to wrong signals being sent o=
r
>> +	 * crashes.
>> +	 *
>> +	 * Note that breakpoints are not disabled selectively, which also caus=
es
>> +	 * kernel breakpoints (e.g., perf's) to be disabled. This might be
>> +	 * undesirable, but still seems reasonable as the code that runs in th=
e
>> +	 * temporary mm should be short.
>> +	 */
>> +	state.bp_enabled =3D hw_breakpoint_active();
>=20
> Pretty sure caching hw_breakpoint_active() is unnecessary.  It queries a
> per-cpu value, not hardware's DR7 register, and that same value is
> consumed by hw_breakpoint_restore().  No idea if breakpoints can be
> disabled while using a temp mm, but even if that can happen, there's no
> need to restore breakpoints if they've all been disabled, i.e. if
> hw_breakpoint_active() returns false in unuse_temporary_mm().

Good point. I will fix it for next version.

Thanks,
Nadav

