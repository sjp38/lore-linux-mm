Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3794D6B04E4
	for <linux-mm@kvack.org>; Thu,  4 Jan 2018 08:13:25 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id 31so1105938plk.20
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 05:13:25 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id w5si2052960pgo.75.2018.01.04.05.13.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 05:13:24 -0800 (PST)
From: "Lu, Aaron" <aaron.lu@intel.com>
Subject: Re: [aaron:for_lkp_skl_2sp2_test 151/225]
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c:1188:34: error:
 '__GFP_COLD' undeclared; did you mean '__GFP_COMP'?
Date: Thu, 4 Jan 2018 13:13:19 +0000
Message-ID: <1515071598.1908.2.camel@intel.com>
References: <201801041745.WvR1n84H%fengguang.wu@intel.com>
	 <20180104095607.57f64ngwbfwm2jx2@suse.de>
In-Reply-To: <20180104095607.57f64ngwbfwm2jx2@suse.de>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <F786EDE3F53727488479F3C55C6888A3@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wu, Fengguang" <fengguang.wu@intel.com>, "mgorman@suse.de" <mgorman@suse.de>
Cc: "kbuild-all@01.org" <kbuild-all@01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

T24gVGh1LCAyMDE4LTAxLTA0IGF0IDA5OjU2ICswMDAwLCBNZWwgR29ybWFuIHdyb3RlOg0KPiBP
biBUaHUsIEphbiAwNCwgMjAxOCBhdCAwNToyNTo0N1BNICswODAwLCBrYnVpbGQgdGVzdCByb2Jv
dCB3cm90ZToNCj4gPiB0cmVlOiAgIGFhcm9uL2Zvcl9sa3Bfc2tsXzJzcDJfdGVzdA0KPiA+IGhl
YWQ6ICAgNmM5MzgxYjY1ODkyMjIyY2JlMjIxNGZiMjJhZjkwNDNmOWNlMTA2NQ0KPiA+IGNvbW1p
dDogY2ViZDM5NTFhYWE2OTM2YTJkZDcwZTkyNWE1ZDU2NjdiODk2ZGEyMyBbMTUxLzIyNV0gbW06
DQo+ID4gcmVtb3ZlIF9fR0ZQX0NPTEQNCj4gPiBjb25maWc6IHg4Nl82NC1yYW5kY29uZmlnLXgw
MDktMjAxODAwIChhdHRhY2hlZCBhcyAuY29uZmlnKQ0KPiA+IGNvbXBpbGVyOiBnY2MtNyAoRGVi
aWFuIDcuMi4wLTEyKSA3LjIuMSAyMDE3MTAyNQ0KPiA+IHJlcHJvZHVjZToNCj4gPiAgICAgICAg
IGdpdCBjaGVja291dCBjZWJkMzk1MWFhYTY5MzZhMmRkNzBlOTI1YTVkNTY2N2I4OTZkYTIzDQo+
ID4gICAgICAgICAjIHNhdmUgdGhlIGF0dGFjaGVkIC5jb25maWcgdG8gbGludXggYnVpbGQgdHJl
ZQ0KPiA+ICAgICAgICAgbWFrZSBBUkNIPXg4Nl82NCANCj4gPiANCj4gDQo+IFRoaXMgbG9va3Mg
bGlrZSBhIGJhY2twb3J0IG9mIHNvbWUgZGVzY3JpcHRpb24uIF9fR0ZQX0NPTEQgaXMgcmVtb3Zl
ZA0KPiBpbg0KPiBhbGwgY2FzZXMgaW4gbWFpbmxpbmUgc28gSSdtIGd1ZXNzaW5nIHRoaXMgaXMg
c3BlY2lmaWMgdG8gQWFyb24ncw0KPiB0cmVlLg0KPiBUaGUgZml4IGlzIHRvIGVsaW1pbmF0ZSBf
X0dGUF9DT0xEIGFuZCBqdXN0IHVzZSBHRlBfS0VSTkVMLg0KDQpTb3JyeSBmb3IgdGhlIG5vaXNl
Lg0KDQpJJ20gcmViYXNpbmcgc29tZSBwYXRjaGVzIHRvIGZpbmQgYSByZWdyZXNzaW9uIG9uIGFu
IG9sZCBicmFuY2gsIEkNCmRpZG4ndCByZWFsaXplIHRoaXMgd291bGQgdHJpZ2dlciB0aGUgcm9i
b3QuDQoNClBsZWFzZSBpZ25vcmUgYWxsIG1lc3NhZ2VzIGZyb20gbXkgdHJlZSwgc29ycnkgYWdh
aW4u

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
