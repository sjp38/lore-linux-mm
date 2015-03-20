Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id DC05F6B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 13:24:23 -0400 (EDT)
Received: by iedm5 with SMTP id m5so33924729ied.3
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 10:24:23 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ac10si10368696pac.147.2015.03.20.10.24.23
        for <linux-mm@kvack.org>;
        Fri, 20 Mar 2015 10:24:23 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH] tracing: add trace event for memory-failure
Date: Fri, 20 Mar 2015 17:24:21 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32A258C2@ORSMSX114.amr.corp.intel.com>
References: <1426734270-8146-1-git-send-email-xiexiuqi@huawei.com>
 <20150319103939.GD11544@pd.tnic> <550B9EF2.7000604@huawei.com>
In-Reply-To: <550B9EF2.7000604@huawei.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie XiuQi <xiexiuqi@huawei.com>, Borislav Petkov <bp@suse.de>
Cc: "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "bhelgaas@google.com" <bhelgaas@google.com>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jingle.chen@huawei.com" <jingle.chen@huawei.com>

PiBSQVMgdXNlciBzcGFjZSB0b29scyBsaWtlIHJhc2RhZW1vbiB3aGljaCBiYXNlIG9uIHRyYWNl
IGV2ZW50LCBjb3VsZA0KPiByZWNlaXZlIG1jZSBlcnJvciBldmVudCwgYnV0IG5vIG1lbW9yeSBy
ZWNvdmVyeSByZXN1bHQgZXZlbnQuIFNvLCBJDQo+IHdhbnQgdG8gYWRkIHRoaXMgZXZlbnQgdG8g
bWFrZSB0aGlzIHNjZW5hcmlvIGNvbXBsZXRlLg0KDQpFeGNlbGxlbnQgYW5zd2VyLiAgQXJlIHlv
dSBnb2luZyB0byB3cml0ZSB0aGF0IHBhdGNoIGZvciByYXNkYWVtb24/DQoNCi1Ub255DQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
