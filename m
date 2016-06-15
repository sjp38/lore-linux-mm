Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6207C6B0260
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 09:13:30 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id a64so35758165oii.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 06:13:30 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id xo8si935591pac.60.2016.06.15.06.13.29
        for <linux-mm@kvack.org>;
        Wed, 15 Jun 2016 06:13:29 -0700 (PDT)
From: "Anaczkowski, Lukasz" <lukasz.anaczkowski@intel.com>
Subject: RE: [PATCH v2] Linux VM workaround for Knights Landing A/D leak
Date: Wed, 15 Jun 2016 13:12:13 +0000
Message-ID: <C1C2579D7BE026428F81F41198ADB17237A866F9@irsmsx110.ger.corp.intel.com>
References: <7FB15233-B347-4A87-9506-A9E10D331292@gmail.com>
 <1465923672-14232-1-git-send-email-lukasz.anaczkowski@intel.com>
 <20160614181002.GA30049@pd.tnic>
In-Reply-To: <20160614181002.GA30049@pd.tnic>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "Srinivasappa, Harish" <harish.srinivasappa@intel.com>, "Odzioba, Lukasz" <lukasz.odzioba@intel.com>, "Andrejczuk, Grzegorz" <grzegorz.andrejczuk@intel.com>, "Daniluk, Lukasz" <lukasz.daniluk@intel.com>

RnJvbTogQm9yaXNsYXYgUGV0a292IFttYWlsdG86YnBAYWxpZW44LmRlXSANClNlbnQ6IFR1ZXNk
YXksIEp1bmUgMTQsIDIwMTYgODoxMCBQTQ0KDQo+PiArCWlmIChib290X2NwdV9oYXNfYnVnKFg4
Nl9CVUdfUFRFX0xFQUspKQ0KPg0KPiBzdGF0aWNfY3B1X2hhc19idWcoKQ0KDQo+PiArCWlmIChj
LT54ODZfbW9kZWwgPT0gODcpIHsNCj4NCj4gVGhhdCBzaG91bGQgYmUgSU5URUxfRkFNNl9YRU9O
X1BISV9LTkwsIEFGQUlDVC4NCg0KPj4gKwkJc3RhdGljIGJvb2wgcHJpbnRlZDsNCj4+ICsNCj4+
ICsJCWlmICghcHJpbnRlZCkgew0KPj4gKwkJCXByX2luZm8oIkVuYWJsaW5nIFBURSBsZWFraW5n
IHdvcmthcm91bmRcbiIpOw0KPj4gKwkJCXByaW50ZWQgPSB0cnVlOw0KPj4gKwkJfQ0KPg0KPiBw
cl9pbmZvX29uY2UNCg0KVGhhbmtzLCBCb3JpcyEgVGhpcyBpcyB2ZXJ5IHZhbHVhYmxlLiBJJ2xs
IGFkZHJlc3MgIHRob3NlIGNvbW1lbnRzIGluIG5leHQgdmVyc2lvbiBvZiB0aGUgcGF0Y2guDQoN
CkNoZWVycywNCkx1a2Fzeg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
