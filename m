Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6710A6B0255
	for <linux-mm@kvack.org>; Mon, 26 Oct 2015 12:46:39 -0400 (EDT)
Received: by iofz202 with SMTP id z202so192068158iof.2
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 09:46:39 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id 81si25641725ioz.98.2015.10.26.09.46.38
        for <linux-mm@kvack.org>;
        Mon, 26 Oct 2015 09:46:38 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH v2 UPDATE 3/3] ACPI/APEI/EINJ: Allow memory error
 injection to NVDIMM
Date: Mon, 26 Oct 2015 16:46:28 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32B5F6D2@ORSMSX114.amr.corp.intel.com>
References: <1445871783-18365-1-git-send-email-toshi.kani@hpe.com>
	 <3908561D78D1C84285E8C5FCA982C28F32B5F5AF@ORSMSX114.amr.corp.intel.com>
 <1445877115.20657.88.camel@hpe.com>
In-Reply-To: <1445877115.20657.88.camel@hpe.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>, "bp@alien8.de" <bp@alien8.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "rjw@rjwysocki.net" <rjw@rjwysocki.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

PiArICAgICAgICAgICAoKHBhcmFtMiAmIFBBR0VfTUFTSykgIT0gUEFHRV9NQVNLKSkNCj4gICAg
ICAgICAgICAgICAgcmV0dXJuIC1FSU5WQUw7DQo+DQo+IFRoZSAzcmQgY29uZGl0aW9uIGNoZWNr
IG1ha2VzIHN1cmUgdGhhdCB0aGUgcGFyYW0yIG1hc2sgaXMgdGhlIHBhZ2Ugc2l6ZSBvciBsZXNz
LiAgU28sIEkNCj4gdGhpbmsgd2UgYXJlIE9LIG9uIHRoaXMuDQoNCk9vcHMuIFRoZSBvcmlnaW5h
bCB3YXMgZXZlbiBvbiB0aGUgc2NyZWVuIGFzIHBhcnQgb2YgdGhlIGRpZmYgKHdoaWNoIEkgc2ln
bmVkIG9mZiBvbiBqdXN0IHR3byB5ZWFycyBhZ28pLg0KDQpJJ2QgYmUgaGFwcGllciBpZiB5b3Ug
bWFkZSBpdCB0aGUgMXN0IGNvbmRpdGlvbiB0aG91Z2gsIHNvIHdlIHNraXAgY2FsbGluZyByZWdp
b25faW50ZXJzZWN0c18qKCkgd2l0aA0KYSBub25zZW5zZSAic2l6ZSIgYXJndW1lbnQuDQoNCi1U
b255DQoNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
