Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2C9076B0005
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 17:16:58 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id yy13so35414429pab.3
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 14:16:58 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id ut10si15074653pab.139.2016.02.11.14.16.57
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 14:16:57 -0800 (PST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH v11 0/4] Machine check recovery when kernel accesses
 poison
Date: Thu, 11 Feb 2016 22:16:56 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F39FD8BFB@ORSMSX114.amr.corp.intel.com>
References: <cover.1455225826.git.tony.luck@intel.com>
 <20160211220222.GJ5565@pd.tnic>
In-Reply-To: <20160211220222.GJ5565@pd.tnic>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "elliott@hpe.com" <elliott@hpe.com>, Brian Gerst <brgerst@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "x86@kernel.org" <x86@kernel.org>

PiBUaGF0J3Mgc29tZSBjaGFuZ2Vsb2csIEkgdGVsbCB5YS4gV2VsbCwgaXQgdG9vayB1cyBsb25n
IGVub3VnaCBzbyBmb3IgYWxsIDQ6DQoNCkknbGwgc2VlIGlmIFBldGVyIEphY2tzb24gd2FudHMg
dG8gdHVybiBpdCBpbnRvIGEgc2VyaWVzIG9mIG1vdmllcy4NCg0KPiBSZXZpZXdlZC1ieTogQm9y
aXNsYXYgUGV0a292IDxicEBzdXNlLmRlPg0KDQpJbmdvOiBCb3JpcyBpcyBoYXBweSAuLi4geW91
ciB0dXJuIHRvIGZpbmQgdGhpbmdzIGZvciBtZSB0byBmaXggKG9yIGlzIGl0IHJlYWR5IGZvciA0
LjYgbm93Pz8pDQoNCi1Ub255DQoNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
