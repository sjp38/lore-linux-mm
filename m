Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56513C072A4
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 03:54:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1529520449
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 03:54:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1529520449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B52BE6B026E; Sun, 19 May 2019 23:54:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B02646B0270; Sun, 19 May 2019 23:54:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A19EE6B0271; Sun, 19 May 2019 23:54:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 69BB46B026E
	for <linux-mm@kvack.org>; Sun, 19 May 2019 23:54:43 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 93so8308733plf.14
        for <linux-mm@kvack.org>; Sun, 19 May 2019 20:54:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:user-agent:content-id
         :content-transfer-encoding:mime-version;
        bh=U9Pmr44Fn/KYYXEc1+CZwAyKzZXIXGUjt09yTb3XYTA=;
        b=L5wV5DrvghLW12cD/zytXzvM6lIizimOoYtnay5a8ZIvbeVm0DSU1PcjTXqyfT1wnH
         2WMXlnX4PMQy8RW41BqQff/XNPdYhzqogipixWGY1CjLD+WkPj7510X+g2WwEs4ObrvT
         cwt5GUC1GQeTGONY23old0bm0P4aTTlF7jMh+14rDCjEOnXDKh3e/ebM0aFScur0BqOT
         b7L+u3OB5l2NU5jgmrTAb+Tl1XPT2x9aqfcAMDG+/sOcyAA76ray5V28CxKj2LP6Lxhi
         MXSB7a29zpPq90zQB/nhHzrrUrQeIdEtUyrcsh5PtBYTRjxA88ARzNemSghzspSmaQqd
         k4Lg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXptmAMBfgkPt/0FG05qGB+vGA2rLVas87AqERsoxgIqXdIgQzi
	dBI1hucb233WhwbohbeL9YsPXJJCrsuv91tS1eIJDVaNqcSQfuLbZemfqQw0YUYj2w/7gRXbJTo
	ZsKuuh4IiS+h/pdCya3hc5O8CwT7rUaKKto77DY5Jk8ZYAyJC31g1xObZSXZRNzJixA==
X-Received: by 2002:aa7:9203:: with SMTP id 3mr78505116pfo.123.1558324483070;
        Sun, 19 May 2019 20:54:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYGuG6rAUdWUgiuE7L/4JDK88sTYSpCfzsCqw/0IMl1pv4BymRCMhWtHbp6shn95Z6GhBi
X-Received: by 2002:aa7:9203:: with SMTP id 3mr78505055pfo.123.1558324482159;
        Sun, 19 May 2019 20:54:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558324482; cv=none;
        d=google.com; s=arc-20160816;
        b=peLtbUldc2jn2XuTPu9AkEH2QLjWrmZNOD6wvbQj/L8yWrE9ZlBrIzxD0cVrM4qgRg
         iKbTf5Bl4ekyTK6+7ZFDf7i3FvO2mwgh3Z06mbfnI5dTpveVI80v2aEHEg+Z1wncbXro
         t1ht8uruLxwWJ1KS2fCv8ZTq5yWzO95+Mj1M87xuw0UjVTFa3/2lybZbjUwLc3g7E6Qm
         n98dOiOEvR5U5P7PNMTAnmVuq2h2tCWion6Tqcz84suE9uh7IPkC1Y8wV3V58fVn0j16
         Txcesm7erPPL1IOyVRJOMrGhr+ak0tPSENGEfuPqLuQLSoYh0g0Atwb2jxeuOU374FKo
         MJOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from;
        bh=U9Pmr44Fn/KYYXEc1+CZwAyKzZXIXGUjt09yTb3XYTA=;
        b=n75wd9hm4sX1mJlp6MJ81yYMA/obkBilooJ2v5tK7XsiZAgxO7hEhVmOA3axZ1xCoL
         4WGeFYaIgJv8sNh4YktZk2x1yx+mFSYkG111Nj1y2vWDxA6iVUgh9xMJEcgTj125zpch
         BteaCWitPbaHy527GDo3Wov9xAhMBars/CGOCYAIyyI3BVP/WgE62kw7qG5t/6jQuB+j
         BYPPV5SVY+6/KYeNc3LnpX/VN/rBIjL12KAgISf5tWitAIUooaqvNFROgdxSKefgbVf7
         8+Ffj+kUCD9dkT4bh9Qf/LCAp3DUFdW47xqq/wqmrJBL33DEQrExzJnX3tQDOAxqkpFN
         gnWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id r3si15658931plb.121.2019.05.19.20.54.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 May 2019 20:54:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 19 May 2019 20:54:41 -0700
X-ExtLoop1: 1
Received: from orsmsx105.amr.corp.intel.com ([10.22.225.132])
  by FMSMGA003.fm.intel.com with ESMTP; 19 May 2019 20:54:41 -0700
Received: from orsmsx157.amr.corp.intel.com (10.22.240.23) by
 ORSMSX105.amr.corp.intel.com (10.22.225.132) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Sun, 19 May 2019 20:54:40 -0700
Received: from orsmsx112.amr.corp.intel.com ([169.254.3.79]) by
 ORSMSX157.amr.corp.intel.com ([169.254.9.37]) with mapi id 14.03.0415.000;
 Sun, 19 May 2019 20:54:40 -0700
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "peterz@infradead.org"
	<peterz@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"davem@davemloft.net" <davem@davemloft.net>, "sparclinux@vger.kernel.org"
	<sparclinux@vger.kernel.org>, "bpf@vger.kernel.org" <bpf@vger.kernel.org>
CC: "bp@alien8.de" <bp@alien8.de>, "mroos@linux.ee" <mroos@linux.ee>,
	"luto@kernel.org" <luto@kernel.org>, "namit@vmware.com" <namit@vmware.com>,
	"Hansen, Dave" <dave.hansen@intel.com>, "mingo@redhat.com" <mingo@redhat.com>
Subject: Re: [PATCH 1/1] vmalloc: Fix issues with flush flag
Thread-Topic: [PATCH 1/1] vmalloc: Fix issues with flush flag
Thread-Index: AQHVDPQ89Mk/2ntUo0SzbjfhLaw0JaZz2GuA
Date: Mon, 20 May 2019 03:54:40 +0000
Message-ID: <371f4eab57d4fa919b33cf4c3b6e5e0eb9eabc20.camel@intel.com>
References: <20190517210123.5702-1-rick.p.edgecombe@intel.com>
	 <20190517210123.5702-2-rick.p.edgecombe@intel.com>
In-Reply-To: <20190517210123.5702-2-rick.p.edgecombe@intel.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Evolution 3.30.1 (3.30.1-1.fc29) 
x-originating-ip: [10.254.94.129]
Content-Type: text/plain; charset="utf-8"
Content-ID: <91FB6DBB8B06D942BDD652676B3D5840@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGksDQoNCkFmdGVyIGludmVzdGlnYXRpbmcgdGhpcyBtb3JlLCBJIGFtIG5vdCBwb3NpdGl2ZSB3
aHkgdGhpcyBmaXhlcyB0aGUNCmlzc3VlIG9uIHNwYXJjLiBJIHdpbGwgY29udGludWUgdG8gaW52
ZXN0aWdhdGUgYXMgYmVzdCBJIGNhbiwgYnV0IHdvdWxkDQpsaWtlIHRvIHJlcXVlc3QgaGVscCBm
cm9tIHNvbWUgc3BhcmMgZXhwZXJ0cyBvbiBldmFsdWF0aW5nIG15IGxpbmUgb2YNCnRoaW5raW5n
LiBJIHRoaW5rIHRoZSBjaGFuZ2VzIGluIHRoaXMgcGF0Y2ggYXJlIHN0aWxsIHZlcnkgd29ydGh3
aGlsZQ0KZ2VuZXJhbGx5IHRob3VnaC4NCg0KDQpCZXNpZGVzIGZpeGluZyB0aGUgc3BhcmMgaXNz
dWU6DQoNCjEuIFRoZSBmaXhlcyBmb3IgdGhlIGNhbGN1bGF0aW9uIG9mIHRoZSBkaXJlY3QgbWFw
IGFkZHJlc3MgcmFuZ2UgYXJlDQppbXBvcnRhbnQgb24geDg2IGluIGNhc2UgYSBSTyBkaXJlY3Qg
bWFwIGFsaWFzIGV2ZXIgZ2V0cyBsb2FkZWQgaW50bw0KdGhlIFRMQi4gVGhpcyBzaG91bGRuJ3Qg
bm9ybWFsbHkgaGFwcGVuLCBidXQgaXQgY291bGQgY2F1c2UgdGhlDQpwZXJtaXNzaW9ucyB0byBu
b3QgZ2V0IHJlc2V0IG9uIHRoZSBkaXJlY3QgbWFwIGFsaWFzLCBhbmQgdGhlbiB0aGUgcGFnZQ0K
d291bGQgcmV0dXJuIGZyb20gdGhlIHBhZ2UgYWxsb2NhdG9yIHRvIHNvbWUgb3RoZXIgY29tcG9u
ZW50IGFzIFJPIGFuZA0KY2F1c2UgYSBjcmFzaC4gVGhpcyB3YXMgbW9zdGx5IGJyb2tlbiBpbXBs
ZW1lbnRpbmcgYSBzdHlsZSBzdWdnZXN0aW9uDQpsYXRlIGluIHRoZSBkZXZlbG9wbWVudC4gQXMg
YmVzdCBJIGNhbiB0ZWxsLCBpdCBzaG91bGRuJ3QgaGF2ZSBhbnkNCmVmZmVjdCBvbiBzcGFyYy4N
Cg0KMi4gU2ltcGx5IGZsdXNoaW5nIHRoZSBUTEIgaW5zdGVhZCBvZiB0aGUgd2hvbGUgdm1fdW5t
YXBfYWxpYXMoKQ0Kb3BlcmF0aW9uIG1ha2VzIHRoZSBmcmVlcyBmYXN0ZXIgYW5kIHB1c2hlcyB0
aGUgaGVhdnkgd29yayB0byBoYXBwZW4gb24NCmFsbG9jYXRpb24gd2hlcmUgaXQgd291bGQgYmUg
bW9yZSBleHBlY3RlZC4gdm1fdW5tYXBfYWxpYXMoKSB0YWtlcyBzb21lDQpsb2NrcyBpbmNsdWRp
bmcgYSBsb25nIGhvbGQgb2Ygdm1hcF9wdXJnZV9sb2NrLCB3aGljaCB3aWxsIG1ha2UgYWxsDQpv
dGhlciBWTV9GTFVTSF9SRVNFVF9QRVJNUyB2ZnJlZXMgd2FpdCB3aGlsZSB0aGUgcHVyZ2Ugb3Bl
cmF0aW9uDQpoYXBwZW5zLg0KDQoNClRoZSBpc3N1ZSBvYnNlcnZlZCBvbiBhbiBVbHRyYVNwYXJj
IElJSSBzeXN0ZW0gd2FzIGEgaGFuZyBvbiBib290LiBUaGUNCm9ubHkgc2lnbmlmaWNhbnQgZGlm
ZmVyZW5jZSBJIGNhbiBmaW5kIGluIGhvdyBTcGFyYyB3b3JrcyBpbiB0aGlzIGFyZWENCmlzIHRo
YXQgdGhlcmUgaXMgYWN0dWFsbHkgc3BlY2lhbCBvcHRpbWl6YXRpb24gaW4gdGhlIFRMQiBmbHVz
aCBmb3INCmhhbmRsaW5nIHZtYWxsb2MgbGF6eSBwdXJnZSBvcGVyYXRpb25zLg0KDQpTb21lIGZp
cm13YXJlIG1hcHBpbmdzIGxpdmUgYmV0d2VlbiB0aGUgbW9kdWxlcyBhbmQgdm1hbGxvYyByYW5n
ZXMsIGFuZA0KaWYgdGhlaXIgdHJhbnNsYXRpb25zIGFyZSBmbHVzaGVkIGNhbiBjYXVzZSAiaGFy
ZCBoYW5ncyBhbmQgY3Jhc2hlcw0KWzFdLiBBZGRpdGlvbmFsbHkgaW4gdGhlIG1peCwgInNwYXJj
NjQga2VybmVsIGxlYXJucyBhYm91dA0Kb3BlbmZpcm13YXJlJ3MgZHluYW1pYyBtYXBwaW5ncyBp
biB0aGlzIHJlZ2lvbiBlYXJseSBpbiB0aGUgYm9vdCwgYW5kDQp0aGVuIHNlcnZpY2VzIFRMQiBt
aXNzZXMgaW4gdGhpcyBhcmVhIi5bMV0gVGhlIGZpcm13YXJlIHByb3RlY3Rpb24NCmxvZ2ljIHNl
ZW1zIHRvIGJlIGluIHBsYWNlLCBob3dldmVyIGxhdGVyIGFub3RoZXIgY2hhbmdlIHdhcyBtYWRl
IGluDQp0aGUgbG93ZXIgYXNtIHRvIGRvIGEgImZsdXNoIGFsbCIgaWYgdGhlIHJhbmdlIHdhcyBi
aWcgZW5vdWdoIG9uIHRoaXMNCmNwdSBbMl0uIFdpdGggdGhlIGFkdmVudCBvZiB0aGUgY2hhbmdl
IHRoaXMgcGF0Y2ggYWRkcmVzc2VzLCB0aGUgcHVyZ2UNCm9wZXJhdGlvbnMgd291bGQgYmUgaGFw
cGVuaW5nIG11Y2ggZWFybGllciB0aGFuIGJlZm9yZSwgd2l0aCB0aGUgZmlyc3QNCnNwZWNpYWwg
cGVybWlzc2lvbmVkIHZmcmVlLCBpbnN0ZWFkIG9mIGFmdGVyIHRoZSBtYWNoaW5lIGhhcyBiZWVu
DQpydW5uaW5nIGZvciBzb21lIHRpbWUgYW5kIHRoZSB2bWFsbG9jIHNwYWNlcyBoYWQgYmVjb21l
IGZyYWdtZW50ZWQuDQoNClNvIG15IGJlc3QgdGhlb3J5IGlzIHRoYXQgdGhlIGhpc3Rvcnkgb2Yg
dm1hbGxvYyBsYXp5IHB1cmdlcyBjYXVzaW5nDQpoYW5ncyBvbiB0aGUgc3BhcmMgaGFzIGNvbWUg
aW50byBwbGF5IGhlcmUgc29tZWhvdywgdHJpZ2dlcmVkIGJ5IHRoYXQNCndlIHdlcmUgZG9pbmcg
dGhlIHB1cmdlcyBtdWNoIGVhcmxpZXIuIElmIGl0IHdhcyBzb21ldGhpbmcgbGlrZSB0aGlzLA0K
dGhlIGZhY3QgdGhhdCB3ZSBpbnN0ZWFkIG9ubHkgZmx1c2ggdGhlIHNtYWxsIGFsbG9jYXRpb24g
aXRzZWxmIG9uDQpzcGFyYyBhZnRlciB0aGlzIHBhdGNoIHdvdWxkIGJlIHRoZSByZWFzb24gd2h5
IGl0IGZpeGVzIGl0Lg0KDQpBZG1pdHRlZGx5LCB0aGVyZSBhcmUgc29tZSBtaXNzaW5nIHBpZWNl
cyBpbiB0aGUgdGhlb3J5LiBJZiB0aGVyZSBhcmUNCmFueSBzcGFyYyBhcmNoaXRlY3R1cmUgZXhw
ZXJ0cyB0aGF0IGNhbiBoZWxwIGVubGlnaHRlbiBtZSBpZiB0aGlzDQpzb3VuZHMgcmVhc29uYWJs
ZSBhdCBhbGwgSSB3b3VsZCByZWFsbHkgYXBwcmVjaWF0ZSBpdC4NCg0KVGhhbmtzLA0KDQpSaWNr
DQoNClsxXSBodHRwczovL3BhdGNod29yay5vemxhYnMub3JnL3BhdGNoLzM3NjUyMy8NClsyXSBo
dHRwczovL3BhdGNod29yay5vemxhYnMub3JnL3BhdGNoLzY4Nzc4MC8gDQoNCg==

