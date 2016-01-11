Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1BAB9680F7F
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 18:48:24 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ho8so68131755pac.2
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 15:48:24 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id r79si25913755pfb.75.2016.01.11.15.48.23
        for <linux-mm@kvack.org>;
        Mon, 11 Jan 2016 15:48:23 -0800 (PST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH v8 1/3] x86: Expand exception table to allow new
 handling options
Date: Mon, 11 Jan 2016 23:48:12 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F39FAA697@ORSMSX114.amr.corp.intel.com>
References: <cover.1452297867.git.tony.luck@intel.com>
	<3a259f1cce4a3c309c2f81df715f8c2c9bb80015.1452297867.git.tony.luck@intel.com>
	<CALCETrURssJHn42dXsEJbJbr=VGPnV1U_-UkYEZ48SPUSbUDww@mail.gmail.com>
	<CAMzpN2j=ZRrL=rXLOTOoUeodtu_AqkQPm1-K0uQmVwLAC6MQGA@mail.gmail.com>
	<CAMzpN2jAvhM74ZGNecnqU3ozLUXb185Cb2iZN6LB0bToFo4Xhw@mail.gmail.com>
	<CALCETrVR=_CYHt4R4yurKpnfi76P8GTwHycPLmqPshK2bCv+Fg@mail.gmail.com>
 <CAMzpN2gamZbY+k=oADhAxEiNPEzeezaRDDOvF2ZU1rWG2CDNSA@mail.gmail.com>
In-Reply-To: <CAMzpN2gamZbY+k=oADhAxEiNPEzeezaRDDOvF2ZU1rWG2CDNSA@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Gerst <brgerst@gmail.com>, Andy Lutomirski <luto@amacapital.net>
Cc: "Williams, Dan J" <dan.j.williams@intel.com>, Borislav Petkov <bp@alien8.de>, X86 ML <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Robert <elliott@hpe.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>

PiBJIGFncmVlIHRoYXQgZm9yIGF0IGxlYXN0IHB1dF91c2VyKCkgdXNpbmcgYXNtIGdvdG8gd291
bGQgYmUgYW4gZXZlbg0KPiBiZXR0ZXIgb3B0aW9uLiAgZ2V0X3VzZXIoKSBvbiB0aGUgb3RoZXIg
aGFuZCwgd2lsbCBiZSBtdWNoIG1lc3NpZXIgdG8NCj4gZGVhbCB3aXRoLCBzaW5jZSBhc20gZ290
byBzdGF0ZW1lbnRzIGNhbid0IGhhdmUgb3V0cHV0cywgcGx1cyBpdA0KPiB6ZXJvZXMgdGhlIG91
dHB1dCByZWdpc3RlciBvbiBmYXVsdC4NCg0KZ2V0X3VzZXIoKSBpcyB0aGUgbXVjaCBtb3JlIGlu
dGVyZXN0aW5nIG9uZSBmb3IgbWUuIEEgcmVhZCBmcm9tDQphIHBvaXNvbmVkIHVzZXIgYWRkcmVz
cyB0aGF0IGdlbmVyYXRlcyBhIG1hY2hpbmUgY2hlY2sgaXMgc29tZXRoaW5nDQp0aGF0IGNhbiBi
ZSByZWNvdmVyZWQgKGtpbGwgdGhlIHByb2Nlc3MpLiAgQSB3cml0ZSB0byB1c2VyIHNwYWNlIGRv
ZXNuJ3QNCmV2ZW4gZ2VuZXJhdGUgYSBtYWNoaW5lIGNoZWNrLg0KDQotVG9ueQ0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
