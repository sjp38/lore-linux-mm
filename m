Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 496EBC282D7
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 17:55:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F09F2217D6
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 17:55:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="OpAGewTa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F09F2217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F18F8E0096; Tue,  5 Feb 2019 12:55:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A1568E0093; Tue,  5 Feb 2019 12:55:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 78F268E0096; Tue,  5 Feb 2019 12:55:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 465F98E0093
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 12:55:03 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id a19so3690938otq.1
        for <linux-mm@kvack.org>; Tue, 05 Feb 2019 09:55:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=DvX0SvjzS9cg6KCABhOsPWSCOuOybvRlHZr0Cemjf4M=;
        b=m9o8Zm0ktcAzBWqapHbPbIwYZZBPUp+fyJerV1I1H1r8mk6SVE5QtTsBqkkNTru9Y5
         otR9z5XvPCedIbiAw1JWwCIJVfLVFH1k6HcWWIjPQWzE7KmkBxBXt8kqT81WQlWSyHDx
         ICIHiBcQFloL7dpqmuaBUJBwA6BALMCwR35rnOzMAmynGM35pxgJ6E/OFVoBR7fLF3p7
         PPO7bxwz944uD+yvgDiHOuR1lszl1HjdQDPcH6FPECYwsCJ+KLRlNXnYrWlobP20oa+Z
         D2IoeEElUbo7IPw+A6YRkW4RY2OKO3hvQea0psCN4WjE4z8rTPkQ3pRR0QsO+TZC/qUl
         JppA==
X-Gm-Message-State: AHQUAuYaa5wm3c3/gvRx993G1Z7wrKLaOCfzIeMckL/myXJDkgQ7s+ot
	S5uMdBnu0k8qzTZFecDa0zQRnUc/InxYIUcpXdVLutRYUZ0uTitnc2wxIoMzYC/xOUUn7bvX162
	BKrJJEOwEPWtNTIfVVoIiQJzxiyUCWtWt6KOvx+GLx8XGoeSWqTDACtWTdyelqiFXDg==
X-Received: by 2002:a05:6830:14ca:: with SMTP id t10mr3500481otq.112.1549389302790;
        Tue, 05 Feb 2019 09:55:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibcya0U0iLvjkfzZmMI0yFgZJ/kgTURAEnG/xe8hYmfdBs266KJvxv3pV4JMsFomIkVzYZ6
X-Received: by 2002:a05:6830:14ca:: with SMTP id t10mr3500449otq.112.1549389302213;
        Tue, 05 Feb 2019 09:55:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549389302; cv=none;
        d=google.com; s=arc-20160816;
        b=X9OToAY/f0F/E6i+NhE/nmRA46tfAw5NaQ9FG1hY6rZ/L80yxuHtKVYZhns/n4HVte
         WBzH2w1sSBgUn8YRExePhQWQ4oFthokNOUzY9Sw/rzdVfIIF/1lbaqREwHyg/Xu/DlQX
         VrsqIahhuOav4bnsBsr8IVgnRXuexEKDxhbsn7YowPIpJkhaETJD+UDuwlplRsTyNo1W
         mPoTk7tYMa0Gg55vWlm3mWzTMBAhvraMKX7K7WEskbK5Zip/w4aJ4Iaf6poSo6Su6sL3
         +GSor+RdhQ05fVQR3Cjv69o8Lgj7vXSMKVCJbmHBk8kd/M2YLnaFl+8kSLSWKWyEVf0V
         p5SA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=DvX0SvjzS9cg6KCABhOsPWSCOuOybvRlHZr0Cemjf4M=;
        b=GhTApHFeNNO+PmRTjVQNIMsaPWAqMjDMoOmUhUfUGf/KBxT38oHxRV81jFb5r1bqWL
         pqEol0RIgSsPjczhVCNf6sZqUFQ5BGo+A/VhMtrCDeoeX5s+PsLxX5P6lv2RXe036Oo4
         GqY/eoviSr4FPZrN/9S3OYzZVCxvRaEuGK2eqZmhS9Lp9LicbJ7W4vEyv4Jis8oDcrIc
         YqI3L3J/lfwXXPwgCf2zmjx0hGIH9TRBw/kKqYC5WfYOgCuY42dOTiMFMNimLyzgv85/
         i2j9kD2vWaY4uQf47cbOTCU3CHCGwSmkcrlkiYX3pXrGXTznJ1VXS69sWgwC3fWv4+qt
         uS8A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=OpAGewTa;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.78.58 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-eopbgr780058.outbound.protection.outlook.com. [40.107.78.58])
        by mx.google.com with ESMTPS id 48si8508521otg.161.2019.02.05.09.55.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Feb 2019 09:55:02 -0800 (PST)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.78.58 as permitted sender) client-ip=40.107.78.58;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=OpAGewTa;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.78.58 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=DvX0SvjzS9cg6KCABhOsPWSCOuOybvRlHZr0Cemjf4M=;
 b=OpAGewTadxIiu2tMElin5owl7CWsCVVrijVMnRG6Pthy8Zdi1OfGb8jRXisJK8MdhqZFGho3dHnHLTlJBmPRrn8ZxrZhf3Ol53iQFg0sFuknEJUGQRj+E27JmJYsrepyunMK+Dkti5KARvgxwX65eZuQYgRlzJpxYwnGf5wNiR8=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB6296.namprd05.prod.outlook.com (20.178.51.81) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.15; Tue, 5 Feb 2019 17:54:57 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::99ab:18fb:f393:df31]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::99ab:18fb:f393:df31%3]) with mapi id 15.20.1601.016; Tue, 5 Feb 2019
 17:54:57 +0000
From: Nadav Amit <namit@vmware.com>
To: Borislav Petkov <bp@alien8.de>
CC: Peter Zijlstra <peterz@infradead.org>, Rick Edgecombe
	<rick.p.edgecombe@intel.com>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar
	<mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, X86 ML
	<x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner
	<tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>, Damian
 Tometzki <linux_dti@icloud.com>, linux-integrity
	<linux-integrity@vger.kernel.org>, LSM List
	<linux-security-module@vger.kernel.org>, Andrew Morton
	<akpm@linux-foundation.org>, Kernel Hardening
	<kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, Will
 Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Kristen Carlson Accardi <kristen@linux.intel.com>, "Dock, Deneen T"
	<deneen.t.dock@intel.com>, Kees Cook <keescook@chromium.org>, Dave Hansen
	<dave.hansen@intel.com>, Masami Hiramatsu <mhiramat@kernel.org>
Subject: Re: [PATCH v2 06/20] x86/alternative: use temporary mm for text
 poking
Thread-Topic: [PATCH v2 06/20] x86/alternative: use temporary mm for text
 poking
Thread-Index: AQHUt2sRlZaCHhQDiEGNmzE5nFIfqqXRA/aAgAAZ9ACAABHSgIAAWTuA
Date: Tue, 5 Feb 2019 17:54:56 +0000
Message-ID: <6D321F51-6B19-46F6-91AC-74248A542BA0@vmware.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-7-rick.p.edgecombe@intel.com>
 <20190205095853.GJ21801@zn.tnic>
 <20190205113146.GP17528@hirez.programming.kicks-ass.net>
 <20190205123533.GN21801@zn.tnic>
In-Reply-To: <20190205123533.GN21801@zn.tnic>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.1]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics:
 1;BYAPR05MB6296;20:QxqDJfbj9XKfepbpbqVmkv5766jXl1JorpcDc6xl1KJTVSUXIhn8Yppt06+640zAjKe19ZUYjxzlT4M0m9fIzrT19NXajABrJO1ZdDj+E2tBtRdgF4MdWJDksNZuGxoMluWmebwHQGTI/5LvMPDyWX2bkhPN5tJcnu8luW5HTyM=
x-ms-office365-filtering-correlation-id: 233f17a2-c471-4c41-7414-08d68b930a6a
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:BYAPR05MB6296;
x-ms-traffictypediagnostic: BYAPR05MB6296:
x-microsoft-antispam-prvs:
 <BYAPR05MB629637D5EFD114B23FBDE163D06E0@BYAPR05MB6296.namprd05.prod.outlook.com>
x-forefront-prvs: 0939529DE2
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(376002)(366004)(346002)(396003)(39860400002)(189003)(199004)(81156014)(105586002)(81166006)(93886005)(8936002)(106356001)(2906002)(83716004)(7736002)(86362001)(305945005)(66066001)(14454004)(76176011)(33656002)(71190400001)(97736004)(7416002)(8676002)(316002)(186003)(4744005)(54906003)(26005)(71200400001)(6436002)(36756003)(102836004)(446003)(478600001)(6916009)(99286004)(82746002)(476003)(256004)(68736007)(4326008)(6512007)(2616005)(11346002)(6506007)(53546011)(229853002)(6116002)(3846002)(6486002)(53936002)(6246003)(486006)(25786009);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB6296;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 Ul9qel0S4EZTHba0GgO2eznZQaY624VlPUugjgCH3NFi1b4exP8NOmkXrIxJZBzWQ/9PO790babvf+zx0YTNmHw23UGyw+mITeq8dcEnV5+WT1i9k92R332oCrqA6Z8JAnwzltUXeqkJcatAvWsRexKqhuZHdeCsagmB0PBY7TzMef7OAIl8fLzvwsHHguiU5yeqHfAa2iELj+whTRRM1Q8CXeQbWt8QFB9a2cHOmgTFxjVn3xkqKtGVfQMrXAMNpVAtDbObNsQZnoK2nHGtGARUrWZoGqMzAKQbFIxf5JIb1ZR7/HV7NgpPJ9EEmbA7y7Zd4I/poK/y8+sK/8alNNmUlobAlWEwuYz4Sx5l8KKbdDUXjG84E1cep7hBpaKFiBrw/Bwevt7zMPU34CU4iPzUYAUAlTWAJLxE753GYJY=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <F6D00271B554CB47B00297C100C54604@namprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 233f17a2-c471-4c41-7414-08d68b930a6a
X-MS-Exchange-CrossTenant-originalarrivaltime: 05 Feb 2019 17:54:56.8334
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB6296
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Feb 5, 2019, at 4:35 AM, Borislav Petkov <bp@alien8.de> wrote:
>=20
> On Tue, Feb 05, 2019 at 12:31:46PM +0100, Peter Zijlstra wrote:
>> ...
>>=20
>> So while in general I agree with BUG_ON() being undesirable, I think
>> liberal sprinking in text_poke() is fine; you really _REALLY_ want this
>> to work or fail loudly. Text corruption is just painful.
>=20
> Ok. It would be good to have the gist of this sentiment in a comment
> above it so that it is absolutely clear why we're doing it.

I added a short comment for v3 above each BUG_ON().

> And since text_poke() can't fail, then it doesn't need a retval too.
> AFAICT, nothing is actually using it.

As Peter said, this is addressed in a separate patch (one patch per logical
change).

