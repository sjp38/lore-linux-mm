Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 097E06B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 00:40:16 -0400 (EDT)
Received: from ep_ms13_bk (mailout5.samsung.com [203.254.224.35])
 by mailout1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0KMI008ZW0AANA@mailout1.samsung.com> for linux-mm@kvack.org;
 Thu, 09 Jul 2009 13:54:10 +0900 (KST)
Received: from ep_spt01 (ms13.samsung.com [203.254.225.109])
 by ms13.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0KMI00AKK0AAU2@ms13.samsung.com> for linux-mm@kvack.org; Thu,
 09 Jul 2009 13:54:10 +0900 (KST)
Content-return: prohibited
Date: Thu, 09 Jul 2009 04:54:10 +0000 (GMT)
From: NARAYANAN GOPALAKRISHNAN <narayanan.g@samsung.com>
Subject: Re: Re: Performance degradation seen after using one list for hot/cold
 pages.
Reply-to: narayanan.g@samsung.com
Message-id: <23853191.513591247115250186.JavaMail.weblogic@epml10>
MIME-version: 1.0
MIME-version: 1.0
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: base64
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
Cc: "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "stable@kernel.org" <stable@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

DQo+IEknbGwgYWRkIHRoZSByYXRoZXIgaW1wb3J0YW50IHRleHQ6DQo+IA0KPiBGaXggYSBwb3N0
LTIuNi4yNCBwZXJmb3JtYW5jZSByZWdyZXNzaW9uIGNhdXNlZCBieQ0KPiAzZGZhNTcyMWYxMmMz
ZDVhNDQxNDQ4MDg2YmVlMTU2ODg3ZGFhOTYxICgicGFnZS1hbGxvY2F0b3I6IHByZXNlcnZlIFBG
Tg0KPiBvcmRlcmluZyB3aGVuIF9fR0ZQX0NPTEQgaXMgc2V0IikuDQo+DQo+IFRoaXMgd2FzIGEg
cHJldHR5IG1ham9yIHNjcmV3dXAuDQo+DQo+IFRoaXMgaXMgd2h5IGNoYW5naW5nIGNvcmUgTU0g
aXMgc28gd29ycmlzb21lIC0gdGhlcmUncyBzbyBtdWNoIHNlY3JldCBhbmQNCj4gc3VidGxlIGhp
c3RvcnkgdG8gaXQsIGFuZCBwZXJmb3JtYW5jZSBkZXBlbmRlbmNpZXMgYXJlIHVub2J2aW91cyBh
bmQgcXVpdGUNCj4gaW5kaXJlY3QgYW5kIHRoZSBsYWcgdGltZSB0byBkaXNjb3ZlciByZWdyZXNz
aW9ucyBpcyBsb25nLg0KPiANCj4gTmFyYXlhbmFuLCBhcmUgeW91IGFibGUgdG8gcXVhbnRpZnkg
dGhlIHJlZ3Jlc3Npb24gbW9yZSBjbGVhcmx5PyAgQWxsIEkNCj4gaGF2ZSBpcyAiMiBNQnBzIGxv
d2VyIiB3aGljaCBpc24ndCB2ZXJ5IHVzZWZ1bC4gIFdoYXQgaXMgdGhpcyBhcyBhDQo+IHBlcmNl
bnRhZ2UsIGFuZCB3aXRoIHdoYXQgc29ydCBvZiBkaXNrIGNvbnRyb2xsZXI/ICBUaGFua3MuDQoN
Ckl0IGlzIGFyb3VuZCAxNSUuIFRoZXJlIGlzIG5vIGRpc2sgY29udHJvbGxlciBhcyBvdXIgc2V0
dXAgaXMgYmFzZWQgb24gU2Ftc3VuZyBPbmVOQU5EDQp1c2VkIGFzIGEgbWVtb3J5IG1hcHBlZCBk
ZXZpY2Ugb24gYSBPTUFQMjQzMCBiYXNlZCBib2FyZC4NCg0KTmFyYXlhbmFuDQo=


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
