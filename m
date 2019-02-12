Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C548FC282D7
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 00:01:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83921214DA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 00:01:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83921214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C8388E0189; Mon, 11 Feb 2019 19:01:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 177E98E0186; Mon, 11 Feb 2019 19:01:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 019348E0189; Mon, 11 Feb 2019 19:01:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B19368E0186
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 19:01:41 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id p20so588850plr.22
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 16:01:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=ysNhV9YyAyjVC386cqq7H+45h9HYg7bmIQ4ZSRDoqcY=;
        b=BcVTH4bh8sMOdNi1ghkXVsO9lMB3WL9GujWeHhI2eiEksmL8Vb7C0syaaAW/jWci5X
         +vA342OntsZTkBlu5gbKCCZIt9tQy1UzYOEQmHki/D7xUgqDZ+4xpGVNsrOMcTxuW3cB
         LGG0+IWl8YVWNsEeFV1iOfKEPGYHILBoJfc9iHmhJoEkJDhtjkjUsptwVeGbysKIUNrt
         ivnAP3o6VjLNjVaPqhjaNkBFYiOHaZ84Mdu6FiU8+6kqPGEtIWOaJp1Hn7dyz/rZky5Q
         HdWkY9rD3TAElzs+qsL9OvtzDqgVOONHcoP3V1K4Uinq8AExk+tHNOnENOgpK2oM6VRs
         bbcA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubmHliZeez7GpDiyixJ96hnBide8qHPcIQRjf7dYdcJppFDBi6R
	Uqh05mmVFHEOE6SZwL8uQFXsYqWUg9VXlVsAPSY2rUe8oqelvHc15hVTZcvsRvW65nVgTiuzZtB
	ksO7+Jao5muBxPQEOWYF4UpH+vOvatFS/bidtvnxvovxl6DL5/9aUp7XH196wQQ+fXw==
X-Received: by 2002:a62:5486:: with SMTP id i128mr888855pfb.215.1549929701322;
        Mon, 11 Feb 2019 16:01:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZuUlYQw1kbblK8i7bTrgpRwaRqlpOjCTv42oBKNCvBLcSTOKCd5GxNxudhvr2Mo3usBwRk
X-Received: by 2002:a62:5486:: with SMTP id i128mr888784pfb.215.1549929700477;
        Mon, 11 Feb 2019 16:01:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549929700; cv=none;
        d=google.com; s=arc-20160816;
        b=Z6bCijzfiAwczrePtTMyXbnxvV+IAJdwTmgBTRcze+wOId/gg9m4ojajeqeKWjNPow
         aDz4cCqxoTI7Fvtx0LNtbq2U5Ak7T5g7GIgNgARPfGBP8CLafqHl4x+EPCI64YcnGjFE
         rFyS/y3u20hm374++xAI8OYP+5EP0v+6EFwFSh0dNKUNbPBNNCagEylrnSlEFT5XOlma
         I0vzy+eB3cAVVX/1j+yrnS2fsJ9YST6lWTeLo/jfskQsGA7voEgYoUY974YQEi1DSZ31
         nqsWW72kb2XJbgJI+LPR3CmvjI5WMOtUhpgRjgOZSwSjZYaomQNTzfns1cclBGMmfGul
         u1LA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=ysNhV9YyAyjVC386cqq7H+45h9HYg7bmIQ4ZSRDoqcY=;
        b=SfGEpat9T8Q5OAA37TUPDnPdKnJo9y+Fo4f2FHOjlJqVWe/o8xAdI/klVX3HDUNdox
         2QU2FtaT/F84iw5WbVeY3GkuU/EC4kRpioChJ2qL6DcH8XmDFBO6KYpsEmV0QG9WNgFA
         s8kNJdCLHLC0lmiKSsONMqUBPbtrCZKWsLejiSdWK033apin0EgRBJXLBmc1AjFUoYp+
         7VgEvnLcDTim5s1FU+5v510Eb301uHqCOfPeGodPnq9RonE9Coh2U/Eg/hi6rJOVFje4
         WNAGBa04V+xyxLPnsnFv8HW5WoqDuHU9C+IwDDEMkN7LgSMOjMfRbGUv3ihY8GcSvU/g
         YwMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id e9si10783795pgk.173.2019.02.11.16.01.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 16:01:40 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 16:01:39 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,360,1544515200"; 
   d="scan'208";a="123722978"
Received: from orsmsx101.amr.corp.intel.com ([10.22.225.128])
  by fmsmga008.fm.intel.com with ESMTP; 11 Feb 2019 16:01:38 -0800
Received: from orsmsx112.amr.corp.intel.com ([169.254.3.70]) by
 ORSMSX101.amr.corp.intel.com ([169.254.8.11]) with mapi id 14.03.0415.000;
 Mon, 11 Feb 2019 16:01:38 -0800
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
To: "luto@kernel.org" <luto@kernel.org>, "bp@alien8.de" <bp@alien8.de>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"linux-integrity@vger.kernel.org" <linux-integrity@vger.kernel.org>,
	"ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "tglx@linutronix.de"
	<tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nadav.amit@gmail.com" <nadav.amit@gmail.com>, "dave.hansen@linux.intel.com"
	<dave.hansen@linux.intel.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>,
	"linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com"
	<hpa@zytor.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>,
	"mingo@redhat.com" <mingo@redhat.com>, "linux_dti@icloud.com"
	<linux_dti@icloud.com>, "will.deacon@arm.com" <will.deacon@arm.com>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>
Subject: Re: [PATCH v2 13/20] Add set_alias_ function and x86 implementation
Thread-Topic: [PATCH v2 13/20] Add set_alias_ function and x86 implementation
Thread-Index: AQHUt2sVkrG1Bgg4x0e07u2CUOZGlKXbkeGAgABAZoCAABFAgA==
Date: Tue, 12 Feb 2019 00:01:37 +0000
Message-ID: <3c34b566afb814ae40665916a0834cdd52d548a2.camel@intel.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
	 <20190129003422.9328-14-rick.p.edgecombe@intel.com>
	 <20190211190925.GQ19618@zn.tnic>
	 <CALCETrX2AOTTZOQafZgOFxiQsFgdYHVaLonXTqTa3RUs5MPVUQ@mail.gmail.com>
In-Reply-To: <CALCETrX2AOTTZOQafZgOFxiQsFgdYHVaLonXTqTa3RUs5MPVUQ@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.54.75.11]
Content-Type: text/plain; charset="utf-8"
Content-ID: <787C9EEF34D39049AB332793C711E15A@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gTW9uLCAyMDE5LTAyLTExIGF0IDE0OjU5IC0wODAwLCBBbmR5IEx1dG9taXJza2kgd3JvdGU6
DQo+IE9uIE1vbiwgRmViIDExLCAyMDE5IGF0IDExOjA5IEFNIEJvcmlzbGF2IFBldGtvdiA8YnBA
YWxpZW44LmRlPiB3cm90ZToNCj4gPiANCj4gPiBPbiBNb24sIEphbiAyOCwgMjAxOSBhdCAwNDoz
NDoxNVBNIC0wODAwLCBSaWNrIEVkZ2Vjb21iZSB3cm90ZToNCj4gPiA+IFRoaXMgYWRkcyB0d28g
bmV3IGZ1bmN0aW9ucyBzZXRfYWxpYXNfZGVmYXVsdF9ub2ZsdXNoIGFuZA0KPiA+IA0KPiA+IHMv
VGhpcyBhZGRzL0FkZC8NCj4gPiANCj4gPiA+IHNldF9hbGlhc19udl9ub2ZsdXNoIGZvciBzZXR0
aW5nIHRoZSBhbGlhcyBtYXBwaW5nIGZvciB0aGUgcGFnZSB0byBpdHMNCj4gPiANCj4gPiBQbGVh
c2UgZW5kIGZ1bmN0aW9uIG5hbWVzIHdpdGggcGFyZW50aGVzZXMsIGJlbG93IHRvby4NCj4gPiAN
Cj4gPiA+IGRlZmF1bHQgdmFsaWQgcGVybWlzc2lvbnMgYW5kIHRvIGFuIGludmFsaWQgc3RhdGUg
dGhhdCBjYW5ub3QgYmUgY2FjaGVkIGluDQo+ID4gPiBhIFRMQiwgcmVzcGVjdGl2ZWx5LiBUaGVz
ZSBmdW5jdGlvbnMgdG8gbm90IGZsdXNoIHRoZSBUTEIuDQo+ID4gDQo+ID4gcy90by9kby8NCj4g
PiANCj4gPiBBbHNvLCBwbHMgcHV0IHRoYXQgZGVzY3JpcHRpb24gYXMgY29tbWVudHMgb3ZlciB0
aGUgZnVuY3Rpb25zIGluIHRoZQ0KPiA+IGNvZGUuIE90aGVyd2lzZSB0aGF0ICJudiIgYXMgcGFy
dCBvZiB0aGUgbmFtZSBkb2Vzbid0IHJlYWxseSBleHBsYWluDQo+ID4gd2hhdCBpdCBkb2VzLg0K
PiA+IA0KPiA+IEFjdHVhbGx5LCB5b3UgY291bGQganVzdCBhcyB3ZWxsIGNhbGwgdGhlIGZ1bmN0
aW9uDQo+ID4gDQo+ID4gc2V0X2FsaWFzX2ludmFsaWRfbm9mbHVzaCgpDQo+ID4gDQo+ID4gQWxs
IHRoZSBvdGhlciB3b3JkcyBhcmUgd3JpdHRlbiBpbiBmdWxsLCBubyBuZWVkIHRvIGhhdmUgIm52
IiB0aGVyZS4NCj4gDQo+IFdoeSBhcmUgeW91IGNhbGxpbmcgdGhpcyBhbiAiYWxpYXMiPyAgWW91
J3JlIG1vZGlmeWluZyB0aGUgZGlyZWN0IG1hcC4NCj4gWW91ciBwYXRjaGVzIGFyZSB0aGlua2lu
ZyBvZiB0aGUgZGlyZWN0IG1hcCBhcyBhbiBhbGlhcyBvZiB0aGUgdm1hcA0KPiBtYXBwaW5nLCBi
dXQgdGhhdCBkb2VzIHNlZW0gYSBiaXQgYmFja3dhcmRzLiAgSG93IGFib3V0DQo+IHNldF9kaXJl
Y3RfbWFwX2ludmFsaWRfbm9mbHVzaCgpLCBldGM/DQo+IA0KSSBwaWNrZWQgaXQgdXAgZnJvbSBz
b21lIG9mIHRoZSBuYW1lcyBpbiBhcmNoL3g4Ni9tbS9wYWdlYXR0ci5jOg0KQ1BBX05PX0NIRUNL
X0FMSUFTLCBzZXRfbWVtb3J5X25wX25vYWxpYXMoKSwgZXRjLiBJbiB0aGF0IGZpbGUgdGhlIGRp
cmVjdG1hcA0KYWRkcmVzcyBzZWVtcyB0byBiZSB0aGUgImFsaWFzIi4gRm9yIDMyIGJpdCB3aXRo
IGhpZ2htZW0gdGhvdWdoLCB0aGlzIHdvdWxkIGFsc28NCnNldCBwZXJtaXNzaW9ucyBmb3IgYSBr
bWFwIG1hcHBpbmcgYXMgd2VsbCAoaWYgb25lIGV4aXN0ZWQpLCBzaW5jZSB0aGF0IGFkZHJlc3MN
CndpbGwgYmUgcmV0dXJuZWQgZnJvbSBwYWdlX2FkZHJlc3MoKS4NCg0KWWVhLCBpbiB2bWFsbG9j
LCB2bV91bm1hcF9hbGlhc2VzIHRhbGtzIGFib3V0IHRoZSB2bWFwIGFkZHJlc3MgImFsaWFzIi4g
U28gSQ0KZ3Vlc3MgY2FsbGluZyBpdCAiYWxpYXMiIGlzIGFtYmlndW91cy4gQnV0IGRvZXMgc2V0
X2RpcmVjdF9tYXBfaW52YWxpZF9ub2ZsdXNoDQptYWtlIHNlbnNlIGluIHRoZSBoaWdobWVtIGNh
c2U/DQoNCkkgY291bGRuJ3QgdGhpbmsgb2YgYW55IG5hbWVzIHRoYXQgSSBsb3ZlZCwgd2hpY2gg
aXMgd2h5IEkgcmFuIHRoZQ0Kc2V0X2FsaWFzXypfbm9mbHVzaCBuYW1lcyBieSBwZW9wbGUgaW4g
YW4gZWFybGllciB2ZXJzaW9uLCBhbHRob3VnaCBsb29raW5nIGJhY2sNCm9ubHkgQXJkIGNoaW1l
ZCBpbiBvbiB0aGF0LiAic2V0X2RpcmVjdF9tYXBfaW52YWxpZF9ub2ZsdXNoIiBpcyBmaW5lIHdp
dGggbWUgaWYNCm5vYm9keSBvYmplY3RzLg0KDQpUaGFua3MsDQoNClJpY2sNCg==

