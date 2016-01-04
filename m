Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2B8866B0003
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 12:00:07 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id 65so159836355pff.3
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 09:00:07 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id s63si60106893pfi.31.2016.01.04.09.00.06
        for <linux-mm@kvack.org>;
        Mon, 04 Jan 2016 09:00:06 -0800 (PST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH v6 2/4] x86: Cleanup and add a new exception class
Date: Mon, 4 Jan 2016 17:00:04 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F39F9FF79@ORSMSX114.amr.corp.intel.com>
References: <cover.1451869360.git.tony.luck@intel.com>
 <18380d9d19d5165822d12532127de2fb7a8b8cc7.1451869360.git.tony.luck@intel.com>
 <20160104142213.GI22941@pd.tnic>
In-Reply-To: <20160104142213.GI22941@pd.tnic>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "elliott@hpe.com" <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "x86@kernel.org" <x86@kernel.org>

PiBTbyB5b3UncmUgdG91Y2hpbmcgdGhvc2UgYWdhaW4gaW4gcGF0Y2ggMi4gV2h5IG5vdCBhZGQg
dGhvc2UgZGVmaW5lcyB0bw0KPiBwYXRjaCAxIGRpcmVjdGx5IGFuZCBkaW1pbmlzaCB0aGUgY2h1
cm4/DQoNClRvIHByZXNlcnZlIGF1dGhvcnNoaXAuIEFuZHkgZGlkIHBhdGNoIDEgKHRoZSBjbGV2
ZXIgcGFydCkuIFBhdGNoIDIgaXMganVzdCBzeW50YWN0aWMNCnN1Z2FyIG9uIHRvcCBvZiBpdC4N
Cg0KLVRvbnkNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
