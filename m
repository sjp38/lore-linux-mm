Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4095EC282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 17:33:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02CEB218D3
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 17:33:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02CEB218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8812E8E0055; Thu,  7 Feb 2019 12:33:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80A488E0002; Thu,  7 Feb 2019 12:33:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6AC2C8E0055; Thu,  7 Feb 2019 12:33:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2606C8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 12:33:41 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id s71so385049pfi.22
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 09:33:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=KWn/Ku62sfdTtl1dDRkUntfoxUTqEP7i1GjBsfx/5cc=;
        b=XlgKadR+9g0zFQHnlSNWbQsIwZqb/MPkAaH7SPJN4r8HXjnASFpqpv6yN5+vXHDD1j
         TODG29KzzrHPl/fc5nx+tpGgX/9HgxkAsY0BJfgZVQod1aUiQr0YeFWrGFxEWQNLskpX
         pM8RS67QnKURyE6ommYcYImdoQHzsddZYxLhzYsqlv2dynAL+P+6zh6xV8dDZUVjpJ5e
         wlr0DjBllbdgJIaLrLN44zM4v1aW3MUwPqb6WKI9QWhLci7CyW0BtolNeVP/srqZbrAK
         wELrtyTR/cCLvMOj/O1JDzP5euvr8lPbcDG5jWyogErN3Uxq1wVWSGH17xeldP4KN+0C
         0Fdg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubvC9Rfe0qPKn/qWEeS3jtLW4AH6naH6czGs/wSzamthU+NT1Bl
	Klu3P9u8/C1oJqCpoywBMbWodJKI0CJDnzfCsocxxOcx+pDqd3YtA89f2rAEml+4lS0t2l8vpyx
	uYs150wj6WiDqWL9S6bbcKmm5fw3pEyNRBAHSs8/+dLUrDp1tgrM1vGE3iKJS2oMn0w==
X-Received: by 2002:aa7:8286:: with SMTP id s6mr17035372pfm.63.1549560820844;
        Thu, 07 Feb 2019 09:33:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYhdY9R2dbUvnNdONMXpeXzdOzKsWuh5N4Xu11SobtZnGAK5HRJ25Vd8N9wfT7PghOpvOsR
X-Received: by 2002:aa7:8286:: with SMTP id s6mr17035280pfm.63.1549560819853;
        Thu, 07 Feb 2019 09:33:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549560819; cv=none;
        d=google.com; s=arc-20160816;
        b=zJpN3EvPF54mwWzRSvpSeQ45X+LSpM13fK4ziVX41TaOGqKS+SUe7eypVfrD7RaqwN
         j+5TTanoIhtzOIYt8xG2ecrOWdS9g5wmXBTS9XrGsuaLivxI/Rv9GE5HDuPk3Cr7K+qC
         lmmFqt1U3mO7u+jmwZMcCT/fVaFP7PTy97v7ELmtEaARLypWumtYYDnaLvt+VfS5Yt4H
         73Ght+u32DjJeTBVnDw+3HgZLKkWmlAM8JvLKMwnuncVjOPi9AbCvOmBDx6/E8pS1D3M
         wTs2paMtldptwpCwppUknbo1WDwgoOBVumw61xFY2RRAM06lz7KgZMz4l43TKxsgvfAG
         hGlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=KWn/Ku62sfdTtl1dDRkUntfoxUTqEP7i1GjBsfx/5cc=;
        b=WkvXb2212XSBKNgzPcKmEzxtY9f/HHsX6x1stIRgGHcySpc8q2A9l6ffpAN3IKUt0A
         fI9UiZQv0IGu49g+wkMlPnvty50tcr/79m1el/G+/quVeHq3ucgaJ63O4+5vsBxpsr9p
         WWF9p5TdsVNK+PT6YElgcPhERjhlfkT2/i6EnXKg4gc0m05gutTZCM7if1BBfOcfHjpc
         kceR74N8xiE1PEjoK5nVj24yryiabG7Px27F3L0WOYb7ciYUawyP39CoY4tgDz2BkZt1
         pkkD2qi89NnlyeBhyseoAbTgDh+djGh84EiXvfae/nL2eOyNZ5MppeRYyrqog80lW1GJ
         Pk2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id e3si2148624pfd.24.2019.02.07.09.33.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 09:33:39 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Feb 2019 09:33:39 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,344,1544515200"; 
   d="scan'208";a="298013818"
Received: from orsmsx104.amr.corp.intel.com ([10.22.225.131])
  by orsmga005.jf.intel.com with ESMTP; 07 Feb 2019 09:33:38 -0800
Received: from orsmsx112.amr.corp.intel.com ([169.254.3.62]) by
 ORSMSX104.amr.corp.intel.com ([169.254.4.11]) with mapi id 14.03.0415.000;
 Thu, 7 Feb 2019 09:33:38 -0800
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
To: "rostedt@goodmis.org" <rostedt@goodmis.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"linux-integrity@vger.kernel.org" <linux-integrity@vger.kernel.org>,
	"ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>,
	"daniel@iogearbox.net" <daniel@iogearbox.net>, "jeyu@kernel.org"
	<jeyu@kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "nadav.amit@gmail.com"
	<nadav.amit@gmail.com>, "dave.hansen@linux.intel.com"
	<dave.hansen@linux.intel.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>,
	"rusty@rustcorp.com.au" <rusty@rustcorp.com.au>,
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
Thread-Index: AQHUrfxTN/9E5iQS/ECuiIskA2n60aXTmtoAgAGlzAA=
Date: Thu, 7 Feb 2019 17:33:37 +0000
Message-ID: <16a2ac45ceef5b6f310f816d696ad2ea8df3b45c.camel@intel.com>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
	 <20190117003259.23141-17-rick.p.edgecombe@intel.com>
	 <20190206112356.64cc5f0d@gandalf.local.home>
In-Reply-To: <20190206112356.64cc5f0d@gandalf.local.home>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.54.75.11]
Content-Type: text/plain; charset="utf-8"
Content-ID: <CA377F3CE86CB84DB34EDE487645D269@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gV2VkLCAyMDE5LTAyLTA2IGF0IDExOjIzIC0wNTAwLCBTdGV2ZW4gUm9zdGVkdCB3cm90ZToN
Cj4gT24gV2VkLCAxNiBKYW4gMjAxOSAxNjozMjo1OCAtMDgwMA0KPiBSaWNrIEVkZ2Vjb21iZSA8
cmljay5wLmVkZ2Vjb21iZUBpbnRlbC5jb20+IHdyb3RlOg0KPiANCj4gPiBBZGQgbmV3IGZsYWcg
Zm9yIGhhbmRsaW5nIGZyZWVpbmcgb2Ygc3BlY2lhbCBwZXJtaXNzaW9uZWQgbWVtb3J5IGluIHZt
YWxsb2MNCj4gPiBhbmQgcmVtb3ZlIHBsYWNlcyB3aGVyZSBtZW1vcnkgd2FzIHNldCBSVyBiZWZv
cmUgZnJlZWluZyB3aGljaCBpcyBubyBsb25nZXINCj4gPiBuZWVkZWQuDQo+ID4gDQo+ID4gSW4g
a3Byb2JlcywgYnBmIGFuZCBmdHJhY2UgdGhpcyBqdXN0IGFkZHMgdGhlIGZsYWcsIGFuZCByZW1v
dmVzIHRoZSBub3cNCj4gPiB1bm5lZWRlZCBzZXRfbWVtb3J5XyBjYWxscyBiZWZvcmUgY2FsbGlu
ZyB2ZnJlZS4NCj4gPiANCj4gPiBJbiBtb2R1bGVzLCB0aGUgZnJlZWluZyBvZiBpbml0IHNlY3Rp
b25zIGlzIG1vdmVkIHRvIGEgd29yayBxdWV1ZSwgc2luY2UNCj4gPiBmcmVlaW5nIG9mIFJPIG1l
bW9yeSBpcyBub3Qgc3VwcG9ydGVkIGluIGFuIGludGVycnVwdCBieSB2bWFsbG9jLg0KPiA+IElu
c3RlYWQgb2YgY2FsbF9yY3UsIGl0IG5vdyB1c2VzIHN5bmNocm9uaXplX3JjdSgpIGluIHRoZSB3
b3JrIHF1ZXVlLg0KPiA+IA0KPiA+IENjOiBSdXN0eSBSdXNzZWxsIDxydXN0eUBydXN0Y29ycC5j
b20uYXU+DQo+ID4gQ2M6IE1hc2FtaSBIaXJhbWF0c3UgPG1oaXJhbWF0QGtlcm5lbC5vcmc+DQo+
ID4gQ2M6IERhbmllbCBCb3JrbWFubiA8ZGFuaWVsQGlvZ2VhcmJveC5uZXQ+DQo+ID4gQ2M6IEFs
ZXhlaSBTdGFyb3ZvaXRvdiA8YXN0QGtlcm5lbC5vcmc+DQo+ID4gQ2M6IEplc3NpY2EgWXUgPGpl
eXVAa2VybmVsLm9yZz4NCj4gPiBDYzogU3RldmVuIFJvc3RlZHQgPHJvc3RlZHRAZ29vZG1pcy5v
cmc+DQo+ID4gQ2M6IFBhdWwgRS4gTWNLZW5uZXkgPHBhdWxtY2tAbGludXguaWJtLmNvbT4NCj4g
PiBTaWduZWQtb2ZmLWJ5OiBSaWNrIEVkZ2Vjb21iZSA8cmljay5wLmVkZ2Vjb21iZUBpbnRlbC5j
b20+DQo+ID4gLS0tDQo+ID4gIGFyY2gveDg2L2tlcm5lbC9mdHJhY2UuYyAgICAgICB8ICA2ICst
LQ0KPiANCj4gRm9yIHRoZSBmdHJhY2UgY29kZS4NCj4gDQo+IEFja2VkLWJ5OiBTdGV2ZW4gUm9z
dGVkdCAoVk13YXJlKSA8cm9zdGVkdEBnb29kbWlzLm9yZz4NCj4gDQo+IC0tIFN0ZXZlDQo+IA0K
VGhhbmtzIQ0KDQpSaWNrDQo+ID4gIGFyY2gveDg2L2tlcm5lbC9rcHJvYmVzL2NvcmUuYyB8ICA3
ICstLS0NCj4gPiAgaW5jbHVkZS9saW51eC9maWx0ZXIuaCAgICAgICAgIHwgMTYgKystLS0tLQ0K
PiA+ICBrZXJuZWwvYnBmL2NvcmUuYyAgICAgICAgICAgICAgfCAgMSAtDQo+ID4gIGtlcm5lbC9t
b2R1bGUuYyAgICAgICAgICAgICAgICB8IDc3ICsrKysrKysrKysrKysrKysrLS0tLS0tLS0tLS0t
LS0tLS0NCj4gPiAgNSBmaWxlcyBjaGFuZ2VkLCA0NSBpbnNlcnRpb25zKCspLCA2MiBkZWxldGlv
bnMoLSkNCj4gPiANCg==

