Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 114E5C4151A
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 18:20:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9FE32086C
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 18:20:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9FE32086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 662B18E005A; Thu,  7 Feb 2019 13:20:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 612DE8E0002; Thu,  7 Feb 2019 13:20:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5026D8E005A; Thu,  7 Feb 2019 13:20:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 106DC8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 13:20:52 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id m16so488320pgd.0
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 10:20:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=eu6XjxkXbhwpTILA5yewfHz1XgcU2AEUeuWXjdae8SI=;
        b=auKBiyF8COwKpZWcx7GQWeRXjaMQO18NzE6p//K5s33aeswkNfhb8MXa4lktAZQCpa
         DQwsBCBOnblurYaj6tJWPlIs0C2hA2erhDQwxLPVOVEDbs+TGEBvEQkvkaAL3H4km4Vg
         /RUAqxV7WYZcBrLnX8d0rtnAI/B/z4NCr+EQjSvgPw6omL/4QraVuUqXjb3yXBTBxjLE
         HY9qRoH2ZAfKAFe5GiKkMKtfB28TDhAFeds6a03wAxxj8EuMFE7mcLWCi3zSyrzMgDHo
         AsNyNx8sDR3M5B+r9OAWaTuzaB6oUUD3qRB5itubH+dsOHiCB5IgTQh8hrUDh6S0QbGy
         w0NA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuY/TJlqWLosUqlnzOYMZN1xqdJ7qcx+xX/OVAaj12A4l3AKGHJo
	9p7FDT0X5Sd1XoEIMRQJzDmPbsMi9Mv97LxGFsKcG5vV0xerlo/kwIqLeZmMhkEYbq5rY7sFqpi
	zTjzR46Tc0s9I6pdVqMUxkcKWKDzP2ZnUSc3yyvFECy/IqcOdVh3xCz6PcZF+0xIr4Q==
X-Received: by 2002:a62:8d4f:: with SMTP id z76mr17970770pfd.2.1549563651735;
        Thu, 07 Feb 2019 10:20:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZG8zzZdfuW0AiWP8tfdBNiYMxnY24u3zLMf9TJwv3P7m0XYVLal9tYfJ18a9u5uprXQ2+s
X-Received: by 2002:a62:8d4f:: with SMTP id z76mr17970715pfd.2.1549563650954;
        Thu, 07 Feb 2019 10:20:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549563650; cv=none;
        d=google.com; s=arc-20160816;
        b=ynv0Em6ClJDJwcBgAtpA72i8KEE3A8q6sBsgwrvXYWS6HZLZcxyKBPxNZwmPmtNCyk
         eP+FMMXGLGXWGsJ/pbiSA1Gcqn8eb+X7i6RE40SauAnFoYgMR5YixLV9B8BNGFayukRx
         ticn2I8HaBWbXYmcr8Yc/qOAmTtF+XvzDVSZVWeWt0Kgho0vLBkJ+cD+3YmkxWR32xJT
         iEnj8klP7PXKNTL02cbC31J8h005/tU7Ctx4ok/5U/F242rjR8KeUzys4wcigvqAi7mJ
         TjB49iUXHTFNv5jDcgU+5o2lJcI+HN0h1l8fxNlL5Zf49NzX6O77+lVmNGOqDbyNU3l3
         b8DQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=eu6XjxkXbhwpTILA5yewfHz1XgcU2AEUeuWXjdae8SI=;
        b=WCFOv/2zkMNtubeSUEmDG2GTljfiW7cQnpeG5r/EiudSRGpgP06FgfesVgUUdYsySb
         mrcVvCSDTdBQnduKSU1HK/iBT7J/wnMF4aGKCZWGTwCbUcCTiMnj9VpkKXGBg8Iakf43
         P8sInvHufkvGiGufPeQKaZi8T9dMqyTZ/GZUBKvUc1MC7WAER2mv62geKmQYcaJ2MLz2
         49PvV6GWd3v0003WPuCO68n4c8I+W5zvj76nveFZvJreU/vCJ/6y2UPlkLVDuO18fk+m
         ngmmRdkjJnJESx4Mtiky3hlElcztyotyBFZ/sP4OXGND7qPiYCsyizwa0SJN+LQsqfdj
         iqaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d14si9873087pll.30.2019.02.07.10.20.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 10:20:50 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Feb 2019 10:20:50 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,345,1544515200"; 
   d="scan'208";a="120751908"
Received: from orsmsx106.amr.corp.intel.com ([10.22.225.133])
  by fmsmga007.fm.intel.com with ESMTP; 07 Feb 2019 10:20:49 -0800
Received: from orsmsx156.amr.corp.intel.com (10.22.240.22) by
 ORSMSX106.amr.corp.intel.com (10.22.225.133) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 7 Feb 2019 10:20:47 -0800
Received: from orsmsx112.amr.corp.intel.com ([169.254.3.62]) by
 ORSMSX156.amr.corp.intel.com ([169.254.8.107]) with mapi id 14.03.0415.000;
 Thu, 7 Feb 2019 10:20:46 -0800
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
To: "rostedt@goodmis.org" <rostedt@goodmis.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"daniel@iogearbox.net" <daniel@iogearbox.net>, "peterz@infradead.org"
	<peterz@infradead.org>, "ard.biesheuvel@linaro.org"
	<ard.biesheuvel@linaro.org>, "linux-integrity@vger.kernel.org"
	<linux-integrity@vger.kernel.org>, "jeyu@kernel.org" <jeyu@kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "tglx@linutronix.de"
	<tglx@linutronix.de>, "nadav.amit@gmail.com" <nadav.amit@gmail.com>,
	"dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "Dock, Deneen T"
	<deneen.t.dock@intel.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>,
	"linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com"
	<hpa@zytor.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>,
	"mingo@redhat.com" <mingo@redhat.com>, "linux_dti@icloud.com"
	<linux_dti@icloud.com>, "luto@kernel.org" <luto@kernel.org>,
	"will.deacon@arm.com" <will.deacon@arm.com>, "bp@alien8.de" <bp@alien8.de>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>,
	"mhiramat@kernel.org" <mhiramat@kernel.org>, "ast@kernel.org"
	<ast@kernel.org>, "paulmck@linux.ibm.com" <paulmck@linux.ibm.com>
Subject: Re: [PATCH 16/17] Plug in new special vfree flag
Thread-Topic: [PATCH 16/17] Plug in new special vfree flag
Thread-Index: AQHUrfxTN/9E5iQS/ECuiIskA2n60aXTmtoAgAGlzACAAASHgIAACKWA
Date: Thu, 7 Feb 2019 18:20:45 +0000
Message-ID: <e71683c86dbe1b32fcec5cc708e8773e72242519.camel@intel.com>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
	 <20190117003259.23141-17-rick.p.edgecombe@intel.com>
	 <20190206112356.64cc5f0d@gandalf.local.home>
	 <16a2ac45ceef5b6f310f816d696ad2ea8df3b45c.camel@intel.com>
	 <20190207124949.0ea219a7@gandalf.local.home>
In-Reply-To: <20190207124949.0ea219a7@gandalf.local.home>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.54.75.11]
Content-Type: text/plain; charset="utf-8"
Content-ID: <04CF8A361999FE4C8001D62D362CA687@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVGh1LCAyMDE5LTAyLTA3IGF0IDEyOjQ5IC0wNTAwLCBTdGV2ZW4gUm9zdGVkdCB3cm90ZToN
Cj4gT24gVGh1LCA3IEZlYiAyMDE5IDE3OjMzOjM3ICswMDAwDQo+ICJFZGdlY29tYmUsIFJpY2sg
UCIgPHJpY2sucC5lZGdlY29tYmVAaW50ZWwuY29tPiB3cm90ZToNCj4gDQo+IA0KPiA+ID4gPiAt
LS0NCj4gPiA+ID4gIGFyY2gveDg2L2tlcm5lbC9mdHJhY2UuYyAgICAgICB8ICA2ICstLSAgDQo+
ID4gPiANCj4gPiA+IEZvciB0aGUgZnRyYWNlIGNvZGUuDQo+ID4gPiANCj4gPiA+IEFja2VkLWJ5
OiBTdGV2ZW4gUm9zdGVkdCAoVk13YXJlKSA8cm9zdGVkdEBnb29kbWlzLm9yZz4NCj4gPiA+IA0K
PiA+ID4gLS0gU3RldmUNCj4gPiA+ICAgDQo+ID4gDQo+ID4gVGhhbmtzIQ0KPiANCj4gSSBqdXN0
IG5vdGljZWQgdGhhdCB0aGUgc3ViamVjdCBpcyBpbmNvcnJlY3Q7IEl0IGlzIG1pc3NpbmcgdGhl
DQo+ICJzdWJzeXN0ZW06IiBwYXJ0LiBTZWUgRG9jdW1lbnRhdGlvbi9wcm9jZXNzL3N1Ym1pdHRp
bmctcGF0Y2hlcy5yc3QNCj4gDQo+IC0tIFN0ZXZlDQpTb3JyeSBhYm91dCB0aGF0LiBUaGVyZSBp
cyBhY3R1YWxseSB2MiBvZiB0aGlzIHBhdGNoc2V0IG91dCB0aGVyZSwgd2hlcmUgdGhlcmUNCmFy
ZSBubyBjb2RlIGNoYW5nZXMgZm9yIHRoaXMgcGF0Y2gsIGJ1dCBpdCBpcyBzcGxpdCBpbnRvIHNl
cGFyYXRlIHBhdGNoZXMgZm9yDQplYWNoIHN1YnN5c3RlbS4gSXQgaGFzICJ4ODYvZnRyYWNlOiAi
IGZvciB0aGUgZnRyYWNlIHBhdGNoLg0KDQpSaWNrDQo=

