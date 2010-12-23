Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A0DEE6B0088
	for <linux-mm@kvack.org>; Thu, 23 Dec 2010 12:46:24 -0500 (EST)
From: Seiji Aguchi <seiji.aguchi@hds.com>
Date: Thu, 23 Dec 2010 12:31:24 -0500
Subject: RE: [RFC][PATCH] Add a sysctl option controlling kexec when MCE
 occurred
Message-ID: <5C4C569E8A4B9B42A84A977CF070A35B2C132F6BB0@USINDEVS01.corp.hds.com>
References: <5C4C569E8A4B9B42A84A977CF070A35B2C132F68FC@USINDEVS01.corp.hds.com>
 <aab9953c699dace1ed94efd6505c7844.squirrel@www.firstfloor.org>
 <20101223091851.GC30055@liondog.tnic>
In-Reply-To: <20101223091851.GC30055@liondog.tnic>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Borislav Petkov <bp@alien8.de>, Andi Kleen <andi@firstfloor.org>
Cc: "rdunlap@xenotime.net" <rdunlap@xenotime.net>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "ebiederm@xmission.com" <ebiederm@xmission.com>, "akpm@linuxfoundation.org" <akpm@linuxfoundation.org>, "eugeneteo@kernel.org" <eugeneteo@kernel.org>, "kees.cook@canonical.com" <kees.cook@canonical.com>, "drosenberg@vsecurity.com" <drosenberg@vsecurity.com>, "ying.huang@intel.com" <ying.huang@intel.com>, "len.brown@intel.com" <len.brown@intel.com>, "seto.hidetoshi@jp.fujitsu.com" <seto.hidetoshi@jp.fujitsu.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "gregkh@suse.de" <gregkh@suse.de>, "davem@davemloft.net" <davem@davemloft.net>, "hadi@cyberus.ca" <hadi@cyberus.ca>, "hawk@comx.dk" <hawk@comx.dk>, "opurdila@ixiacom.com" <opurdila@ixiacom.com>, "hidave.darkstar@gmail.com" <hidave.darkstar@gmail.com>, "dzickus@redhat.com" <dzickus@redhat.com>, "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>, "ext-andriy.shevchenko@nokia.com" <ext-andriy.shevchenko@nokia.com>, "tj@kernel.org" <tj@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kexec@lists.infradead.org" <kexec@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Satoru Moriya <satoru.moriya@hds.com>
List-ID: <linux-mm.kvack.org>

SGksDQoNCkkgYWdyZWUgd2l0aCBCb3Jpc2xhdiB0aGF0IGtleGVjIHNob3VsZG4ndCBzdGFydCBh
dCBhbGwgYmVjYXVzZSB3ZSBjYW4ndCBndWFyYW50ZWUgDQphIHN0YWJsZSBzeXN0ZW0gYW55bW9y
ZSB3aGVuIE1DRSBpcyByZXBvcnRlZC4NCg0KT24gdGhlIG90aGVyIGhhbmQsIEkgdW5kZXJzdGFu
ZCB0aGVyZSBhcmUgcGVvcGxlIGxpa2UgQW5kaSB3aG8gd2FudCB0byBzdGFydCBrZXhlYyANCmV2
ZW4gaWYgTUNFIG9jY3VycmVkLg0KDQpUaGF0IGlzIHdoeSBJIHByb3Bvc2UgYWRkaW5nIGEgbmV3
IG9wdGlvbiBjb250cm9sbGluZyBrZXhlYyBiZWhhdmlvdXIgd2hlbiBNQ0Ugb2NjdXJyZWQuDQoN
CkkgZG9uJ3Qgc3RpY2sgdG8gInN5c2N0bCIuDQpJIHN1Z2dlc3QgdG8gYWRkIGEgbmV3IGJvb3Qg
cGFyYW1ldGVyIGluc3RlYWQgb2Ygc3lzY3RsIGJlY2F1c2UgdXNlcnMgY2FuJ3QgY2hhbmdlIA0K
dGhlaXIgY29uZmlndXJhdGlvbiBvbmNlIHRoZSBib290IHBhcmFtZXRlciBpcyBzZXQuDQoNCkkg
d2lsbCByZXNlbmQgdGhlIHBhdGNoIGlmIGl0IGlzIGFjY2VwdGFibGUuDQoNClJlZ2FyZHMsDQoN
ClNlaWppDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
