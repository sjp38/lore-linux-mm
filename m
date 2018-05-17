Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 384056B04F6
	for <linux-mm@kvack.org>; Thu, 17 May 2018 10:32:09 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 72-v6so2947148pld.19
        for <linux-mm@kvack.org>; Thu, 17 May 2018 07:32:09 -0700 (PDT)
Received: from g2t2352.austin.hpe.com (g2t2352.austin.hpe.com. [15.233.44.25])
        by mx.google.com with ESMTPS id o78-v6si5395103pfa.54.2018.05.17.07.32.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 07:32:07 -0700 (PDT)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH v3 2/3] ioremap: Update pgtable free interfaces with addr
Date: Thu, 17 May 2018 14:32:01 +0000
Message-ID: <1526567449.2693.608.camel@hpe.com>
References: <20180516233207.1580-1-toshi.kani@hpe.com>
	 <20180516233207.1580-3-toshi.kani@hpe.com>
	 <20180517064755.GP12670@dhcp22.suse.cz>
In-Reply-To: <20180517064755.GP12670@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <26F40FFEB370414CB03568B3AD5A7F9B@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "mhocko@kernel.org" <mhocko@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>

T24gVGh1LCAyMDE4LTA1LTE3IGF0IDA4OjQ3ICswMjAwLCBNaWNoYWwgSG9ja28gd3JvdGU6DQo+
IE9uIFdlZCAxNi0wNS0xOCAxNzozMjowNiwgS2FuaSBUb3NoaW1pdHN1IHdyb3RlOg0KPiA+IEZy
b206IENoaW50YW4gUGFuZHlhIDxjcGFuZHlhQGNvZGVhdXJvcmEub3JnPg0KPiA+IA0KPiA+IFRo
aXMgcGF0Y2ggKCJtbS92bWFsbG9jOiBBZGQgaW50ZXJmYWNlcyB0byBmcmVlIHVubWFwcGVkDQo+
ID4gcGFnZSB0YWJsZSIpIGFkZHMgZm9sbG93aW5nIDIgaW50ZXJmYWNlcyB0byBmcmVlIHRoZSBw
YWdlDQo+ID4gdGFibGUgaW4gY2FzZSB3ZSBpbXBsZW1lbnQgaHVnZSBtYXBwaW5nLg0KPiA+IA0K
PiA+IHB1ZF9mcmVlX3BtZF9wYWdlKCkgYW5kIHBtZF9mcmVlX3B0ZV9wYWdlKCkNCj4gPiANCj4g
PiBTb21lIGFyY2hpdGVjdHVyZXMgKGxpa2UgYXJtNjQpIG5lZWRzIHRvIGRvIHByb3BlciBUTEIN
Cj4gPiBtYWludGFuYW5jZSBhZnRlciB1cGRhdGluZyBwYWdldGFibGUgZW50cnkgZXZlbiBpbiBt
YXAuDQo+ID4gV2h5ID8gUmVhZCB0aGlzLA0KPiA+IGh0dHBzOi8vcGF0Y2h3b3JrLmtlcm5lbC5v
cmcvcGF0Y2gvMTAxMzQ1ODEvDQo+IA0KPiBQbGVhc2UgYWRkIHRoYXQgaW5mb3JtYXRpb24gdG8g
dGhlIGNoYW5nZWxvZy4NCg0KSSB3aWxsIHVwZGF0ZSB0aGUgZGVzY3JpcHRpb24gYW5kIHJlc2Vu
ZCB0aGlzIHBhdGNoLg0KDQpUaGFua3MhDQotVG9zaGkNCg==
