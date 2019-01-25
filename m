Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id D80D98E00DF
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 13:21:00 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id u17so6816201pgn.17
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 10:21:00 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id z22si25054625plo.202.2019.01.25.10.20.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 10:20:59 -0800 (PST)
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
Subject: Re: [PATCH 5/5] dax: "Hotplug" persistent memory for use like
 normal RAM
Date: Fri, 25 Jan 2019 18:20:56 +0000
Message-ID: <b7d45d83a314955e7dff25401dfc0d4f4247cfcd.camel@intel.com>
References: <20190124231441.37A4A305@viggo.jf.intel.com>
	 <20190124231448.E102D18E@viggo.jf.intel.com>
	 <0852310e-41dc-dc96-2da5-11350f5adce6@oracle.com>
	 <CAPcyv4hjJhUQpMy1CVJZur0Ssr7Cr2fkcD50L5gzx6v_KY14vg@mail.gmail.com>
	 <5A90DA2E42F8AE43BC4A093BF067884825733A5B@SHSMSX104.ccr.corp.intel.com>
	 <CAPcyv4ikXD8rJAmV6tGNiq56m_ZXPZNrYkTwOSUJ7D1O_M5s=w@mail.gmail.com>
In-Reply-To: <CAPcyv4ikXD8rJAmV6tGNiq56m_ZXPZNrYkTwOSUJ7D1O_M5s=w@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <54E31B413D1FF149BE238966A26CD136@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>, "Du, Fan" <fan.du@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "bp@suse.de" <bp@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "tiwai@suse.de" <tiwai@suse.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "jglisse@redhat.com" <jglisse@redhat.com>, "zwisler@kernel.org" <zwisler@kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "baiyaowei@cmss.chinamobile.com" <baiyaowei@cmss.chinamobile.com>, "thomas.lendacky@amd.com" <thomas.lendacky@amd.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, "Huang,
 Ying" <ying.huang@intel.com>, "jane.chu@oracle.com" <jane.chu@oracle.com>, "bhelgaas@google.com" <bhelgaas@google.com>

DQpPbiBGcmksIDIwMTktMDEtMjUgYXQgMDk6MTggLTA4MDAsIERhbiBXaWxsaWFtcyB3cm90ZToN
Cj4gT24gRnJpLCBKYW4gMjUsIDIwMTkgYXQgMTI6MjAgQU0gRHUsIEZhbiA8ZmFuLmR1QGludGVs
LmNvbT4gd3JvdGU6DQo+ID4gRGFuDQo+ID4gDQo+ID4gVGhhbmtzIGZvciB0aGUgaW5zaWdodHMh
DQo+ID4gDQo+ID4gQ2FuIEkgc2F5LCB0aGUgVUNFIGlzIGRlbGl2ZXJlZCBmcm9tIGgvdyB0byBP
UyBpbiBhIHNpbmdsZSB3YXkgaW4NCj4gPiBjYXNlIG9mIG1hY2hpbmUNCj4gPiBjaGVjaywgb25s
eSBQTUVNL0RBWCBzdHVmZiBmaWx0ZXIgb3V0IFVDIGFkZHJlc3MgYW5kIG1hbmFnZWQgaW4gaXRz
DQo+ID4gb3duIHdheSBieQ0KPiA+IGJhZGJsb2NrcywgaWYgUE1FTS9EQVggZG9lc24ndCBkbyBz
bywgdGhlbiBjb21tb24gUkFTIHdvcmtmbG93IHdpbGwNCj4gPiBraWNrIGluLA0KPiA+IHJpZ2h0
Pw0KPiANCj4gVGhlIGNvbW1vbiBSQVMgd29ya2Zsb3cgYWx3YXlzIGtpY2tzIGluLCBpdCdzIGp1
c3QgdGhlIHBhZ2Ugc3RhdGUNCj4gcHJlc2VudGVkIGJ5IGEgREFYIG1hcHBpbmcgbmVlZHMgZGlz
dGluY3QgaGFuZGxpbmcuIE9uY2UgaXQgaXMNCj4gaG90LXBsdWdnZWQgaXQgbm8gbG9uZ2VyIG5l
ZWRzIHRvIGJlIHRyZWF0ZWQgZGlmZmVyZW50bHkgdGhhbiAiU3lzdGVtDQo+IFJBTSIuDQo+IA0K
PiA+IEFuZCBob3cgYWJvdXQgd2hlbiBBUlMgaXMgaW52b2x2ZWQgYnV0IG5vIG1hY2hpbmUgY2hl
Y2sgZmlyZWQgZm9yDQo+ID4gdGhlIGZ1bmN0aW9uDQo+ID4gb2YgdGhpcyBwYXRjaHNldD8NCj4g
DQo+IFRoZSBob3RwbHVnIGVmZmVjdGl2ZWx5IGRpc2Nvbm5lY3RzIHRoaXMgYWRkcmVzcyByYW5n
ZSBmcm9tIHRoZSBBUlMNCj4gcmVzdWx0cy4gVGhleSB3aWxsIHN0aWxsIGJlIHJlcG9ydGVkIGlu
IHRoZSBsaWJudmRpbW0gInJlZ2lvbiIgbGV2ZWwNCj4gYmFkYmxvY2tzIGluc3RhbmNlLCBidXQg
dGhlcmUncyBubyBzYWZlIC8gY29vcmRpbmF0ZWQgd2F5IHRvIGdvIGNsZWFyDQo+IHRob3NlIGVy
cm9ycyB3aXRob3V0IGFkZGl0aW9uYWwga2VybmVsIGVuYWJsaW5nLiBUaGVyZSBpcyBubyAiY2xl
YXINCj4gZXJyb3IiIHNlbWFudGljIGZvciAiU3lzdGVtIFJBTSIuDQo+IA0KUGVyaGFwcyBhcyBm
dXR1cmUgZW5hYmxpbmcsIHRoZSBrZXJuZWwgY2FuIGdvIHBlcmZvcm0gImNsZWFyIGVycm9yIiBm
b3INCm9mZmxpbmVkIHBhZ2VzLCBhbmQgbWFrZSB0aGVtIHVzYWJsZSBhZ2Fpbi4gQnV0IEknbSBu
b3Qgc3VyZSBob3cNCnByZXBhcmVkIG1tIGlzIHRvIHJlLWFjY2VwdCBwYWdlcyBwcmV2aW91c2x5
IG9mZmxpbmVkLg0K
