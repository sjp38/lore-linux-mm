Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D94AC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 18:32:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57E97206B6
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 18:32:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57E97206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E53538E012B; Fri, 22 Feb 2019 13:32:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDA9B8E0123; Fri, 22 Feb 2019 13:32:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C576E8E012B; Fri, 22 Feb 2019 13:32:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0248E0123
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 13:32:26 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id a5so2431343pfn.2
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 10:32:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=+kp26HJxE9BUMgrXUICUhq3fE0bJad6rfE/JOWKAD2o=;
        b=Me7T3B0UI77kOFHsSgJBiV5amq+FQtkqI+U/YkPSLMkQpwkpKwmoNJUXqhUogeDLeE
         EKewwefIGzWAEOjLOjrBjBvczQ1eYPZL9w8mQ1zljWlU44AOk29pSgArsejUh+12qgg9
         OdKxE1MbVUL49cJsNWrL6h1LJqj3m+0Y03c2eG3eCY5aGlyv89rTREuDGKfLZqvAejQQ
         ARWENdSGXmGoIe+MOKVzI4FjyOsc6NfcKZzlE5YIT+eXlfl2ptfockt6ib/kNKc0Bft7
         QA55lD3RHTi4J8JOU5CYfkKSpxAt9VNHNRnz6bJu5zJ7b7xdHXzWvuLUass+xWcwB+A6
         fkRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAub51NmQ6vbFtSvQhXFabTqWtaf+2ft6aCqcZIF4MbQww+0YP3Hq
	vTFCvDTS7LSBSpjdFWSX+KIVauGaNOhJl8hAeprpAGgdYkJMiF+3M96gUgMxY470OIrxlI6CcgX
	qxai4yB6qSLkvjhEBKAifkx5DhVc33fQPxAkWfepfwLFQjD5FDNn/dscJdmGIJBMJMA==
X-Received: by 2002:a63:6244:: with SMTP id w65mr5152506pgb.300.1550860346181;
        Fri, 22 Feb 2019 10:32:26 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia0kmZVYctwJSXKFRb7F1UwkpW3wPA7Qp396IIrUyebRy8UavenMDyEye46fRSTn5FEuo1i
X-Received: by 2002:a63:6244:: with SMTP id w65mr5152436pgb.300.1550860345224;
        Fri, 22 Feb 2019 10:32:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550860345; cv=none;
        d=google.com; s=arc-20160816;
        b=saEuu3qSiFH6OXR9FY5XSygQgGQHcGFgiKLGMcEW6dLt2+k2FaFRK5DMc+hd7j24Oe
         cD7bb0stCsp6wKbViNP5YY3JXOpaKxU/dKMLGwjPDflq8I2FwrrhUzbaCNpDYa1jhrGv
         LhGnjbaGOJl6ERopvvjfd8CdHVQNq5pTOOpub+gfJ4N8ZN209UoiRaTuMygB3od/p4La
         +XT/tvg4q01Wdl871PiY+Db2P6pI7OrHNVaHjoTCR0tYRhWR+UgHGct2LBtHDxk3wf06
         rZ5JXXavVI9AksaXlhvXu0J2PCVUrsQGXzbt7P+BKDibcVUafkeYorgVZzNwyidXjzAJ
         Y6mA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=+kp26HJxE9BUMgrXUICUhq3fE0bJad6rfE/JOWKAD2o=;
        b=E2krr7giJsjMEAP/xlDkNcuJB1P99JmMr1m4R2QGpbVPnSgQtpv3mL3ryLzSJLPq0w
         +cX7+CHbcO+jC+QGmnvKSFehWJPA7HsJQwZR3jmOjeI33vpXsH7UNs2Zqrz7/3Yq+boA
         eKur/5EJJDiCsaJyZklZDAMgtFixlB5cwclSMbCN+iBJxcimwekGvTv9eICXNv0+qKQT
         l76SdNe/on9J//otNhdYK1f+zDfCK1oSz7ifY/bM6wfDuJYst6qy0kgzOyPm9+kiKea4
         rb+4MOU2hVAso5G2YT6PXbputjdHjgaV0eRo+PLCxPMiW6561MrNMT/vkh2zMJjQoLin
         nM5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id j70si1978907pge.271.2019.02.22.10.32.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 10:32:25 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Feb 2019 10:32:24 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,400,1544515200"; 
   d="scan'208";a="117054389"
Received: from orsmsx107.amr.corp.intel.com ([10.22.240.5])
  by orsmga007.jf.intel.com with ESMTP; 22 Feb 2019 10:32:24 -0800
Received: from orsmsx153.amr.corp.intel.com (10.22.226.247) by
 ORSMSX107.amr.corp.intel.com (10.22.240.5) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Fri, 22 Feb 2019 10:32:23 -0800
Received: from orsmsx112.amr.corp.intel.com ([169.254.3.70]) by
 ORSMSX153.amr.corp.intel.com ([169.254.12.140]) with mapi id 14.03.0415.000;
 Fri, 22 Feb 2019 10:32:23 -0800
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
To: "bp@alien8.de" <bp@alien8.de>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"linux-integrity@vger.kernel.org" <linux-integrity@vger.kernel.org>,
	"ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "tglx@linutronix.de"
	<tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>,
	"nadav.amit@gmail.com" <nadav.amit@gmail.com>, "Dock, Deneen T"
	<deneen.t.dock@intel.com>, "linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com"
	<hpa@zytor.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>,
	"mingo@redhat.com" <mingo@redhat.com>, "linux_dti@icloud.com"
	<linux_dti@icloud.com>, "luto@kernel.org" <luto@kernel.org>,
	"will.deacon@arm.com" <will.deacon@arm.com>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>
Subject: Re: [PATCH v3 00/20] Merge text_poke fixes and executable lockdowns
Thread-Topic: [PATCH v3 00/20] Merge text_poke fixes and executable lockdowns
Thread-Index: AQHUykBH6Cl4tgVNiUeaovpifCvY+6XshO+AgAAmmIA=
Date: Fri, 22 Feb 2019 18:32:22 +0000
Message-ID: <33968a3c7cc750f3d1cabf062f5fb25fd176e816.camel@intel.com>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
	 <20190222161419.GB30766@zn.tnic>
In-Reply-To: <20190222161419.GB30766@zn.tnic>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.54.75.11]
Content-Type: text/plain; charset="utf-8"
Content-ID: <6AFE1C37A3162E43A5884A3972E03B3D@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gRnJpLCAyMDE5LTAyLTIyIGF0IDE3OjE0ICswMTAwLCBCb3Jpc2xhdiBQZXRrb3Ygd3JvdGU6
DQo+IE9uIFRodSwgRmViIDIxLCAyMDE5IGF0IDAzOjQ0OjMxUE0gLTA4MDAsIFJpY2sgRWRnZWNv
bWJlIHdyb3RlOg0KPiA+IENoYW5nZXMgdjIgdG8gdjM6DQo+ID4gIC0gRml4IGNvbW1pdCBtZXNz
YWdlcyBhbmQgY29tbWVudHMgW0JvcmlzXQ0KPiA+ICAtIFJlbmFtZSBWTV9IQVNfU1BFQ0lBTF9Q
RVJNUyBbQm9yaXNdDQo+ID4gIC0gUmVtb3ZlIHVubmVjZXNzYXJ5IGxvY2FsIHZhcmlhYmxlcyBb
Qm9yaXNdDQo+ID4gIC0gUmVuYW1lIHNldF9hbGlhc18qKCkgZnVuY3Rpb25zIFtCb3JpcywgQW5k
eV0NCj4gPiAgLSBTYXZlL3Jlc3RvcmUgRFIgcmVnaXN0ZXJzIHdoZW4gdXNpbmcgdGVtcG9yYXJ5
IG1tDQo+ID4gIC0gTW92ZSBsaW5lIGRlbGV0aW9uIGZyb20gcGF0Y2ggMTAgdG8gcGF0Y2ggMTcN
Cj4gDQo+IEluIHlvdXIgcHJldmlvdXMgc3VibWlzc2lvbiB0aGVyZSB3YXMgYSBwYXRjaCBjYWxs
ZWQNCj4gDQo+IFN1YmplY3Q6IFtQQVRDSCB2MiAwMS8yMF0gRml4ICJ4ODYvYWx0ZXJuYXRpdmVz
OiBMb2NrZGVwLWVuZm9yY2UgdGV4dF9tdXRleCBpbg0KPiB0ZXh0X3Bva2UqKCkiDQo+IA0KPiBX
aGF0IGhhcHBlbmVkIHRvIGl0Pw0KPiANCj4gSXQgZGlkIGludHJvZHVjZSBhIGZ1bmN0aW9uIHRl
eHRfcG9rZV9rZ2RiKCksIGEuby4sIGFuZCBJIHNlZSB0aGlzDQo+IGZ1bmN0aW9uIGluIHRoZSBk
aWZmIGNvbnRleHRzIGluIHNvbWUgb2YgdGhlIHBhdGNoZXMgaW4gdGhpcyBzdWJtaXNzaW9uDQo+
IHNvIGl0IGxvb2tzIHRvIG1lIGxpa2UgeW91IG1pc3NlZCB0aGF0IGZpcnN0IHBhdGNoIHdoZW4g
c3VibWl0dGluZyB2Mz8NCj4gDQo+IE9yIGFtICpJKiBtaXNzaW5nIHNvbWV0aGluZz8NCj4gDQo+
IFRoeC4NCj4gDQpPaCwgeW91IGFyZSByaWdodCEgU29ycnkgYWJvdXQgdGhhdC4gSSdsbCBqdXN0
IHNlbmQgYSBuZXcgdmVyc2lvbiB3aXRoIGZpeGVzIGZvcg0Kb3RoZXIgY29tbWVudHMgaW5zdGVh
ZCBvZiBhIHJlc2VuZCBvZiB0aGlzIG9uZS4NCg0KVGhhbmtzLA0KDQpSaWNrDQo=

