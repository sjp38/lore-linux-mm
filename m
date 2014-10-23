Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0AD6A6B0069
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 13:19:19 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so1433901pad.5
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 10:19:19 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ng16si2054602pdb.186.2014.10.23.10.19.18
        for <linux-mm@kvack.org>;
        Thu, 23 Oct 2014 10:19:18 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH] x86, MCE: support memory error recovery for both UCNA
 and Deferred error in machine_check_poll
Date: Thu, 23 Oct 2014 17:18:29 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F3290F9B0@ORSMSX114.amr.corp.intel.com>
References: <1412921020.3631.7.camel@debian> <20141023104717.GB4619@pd.tnic>
In-Reply-To: <20141023104717.GB4619@pd.tnic>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Chen Yucong <slaoub@gmail.com>
Cc: Andi Kleen <ak@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-edac@vger.kernel.org" <linux-edac@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Aravind Gopalakrishnan <aravind.gopalakrishnan@amd.com>

PiBUaGUgZ2VuZXJhbCBpZGVhIG9mIHByZWVtcHRpdmVseSBwb2lzb25pbmcgcGFnZXMgd2hpY2gg
Y29udGFpbiBkZWZlcnJlZA0KPiBlcnJvcnMgaXMgZmluZSB0aG91Z2guDQoNCkFncmVlZC4gSSB1
c2VkIHRvIHRoaW5rIHRoYXQgaXQgd2Fzbid0IGxpa2VseSB0byBiZSB2ZXJ5IHVzZWZ1bCBiZWNh
dXNlIGluIG1hbnkNCmNhc2VzIHRoZSBVQ05BIGVycm9ycyBhcmUganVzdCBhIHRyYWlsIG9mIGJy
ZWFkY3J1bWJzIHNldCBieSBkaWZmZXJlbnQgdW5pdHMNCm9uIHRoZSBjaGlwIGFzIHRoZSBwb2lz
b24gcGFzc2VkIHRocm91Z2ggb24gdGhlIHdheSB0byBjb25zdW1wdGlvbiAtIHdoZXJlDQp0aGVy
ZSB3b3VsZCBiZSBhIGZhdGFsIChvciByZWNvdmVyYWJsZSkgZXJyb3IuDQoNCkJ1dCByZWNlbnRs
eSBJIGZvdW5kIHRoYXQgYSBwYXJ0aWFsIHdyaXRlIHRvIGEgcG9pc29uZWQgY2FjaGUgbGluZSBv
bmx5IHNldHMgdGhlDQp0cmFpbCBvZiBVQ05BIGVycm9ycyAtIHRoZXJlIGlzIG5vIGNvbnN1bXB0
aW9uLCBzbyBubyBtYWNoaW5lIGNoZWNrLiAgU28gaW4NCnRoaXMgY2FzZSBpdCB3b3VsZCBkZWZp
bml0ZWx5IGJlIHdvcnRod2hpbGUgdG8gdHJpZ2dlciB0aGUgc2FtZSBhY3Rpb24gdGhhdCB3ZQ0K
ZG8gZm9yIFNSQU8gdG8gdW5tYXAgdGhlIHBhZ2UgYmVmb3JlIHNvbWVvbmUgZG9lcyBkbyBhIHJl
YWQuDQoNCi1Ub255DQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
