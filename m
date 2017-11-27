Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 64B4B6B0253
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 01:44:08 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id s18so28211277pge.19
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 22:44:08 -0800 (PST)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id q13si21808925pgt.668.2017.11.26.22.44.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Nov 2017 22:44:06 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: hugetlb page migration vs. overcommit
Date: Mon, 27 Nov 2017 06:27:36 +0000
Message-ID: <4c97aaf2-19ed-b45c-e61a-fa9510cd9ddf@ah.jp.nec.com>
References: <20171122152832.iayefrlxbugphorp@dhcp22.suse.cz>
 <91969714-5256-e96f-a48b-43af756a2686@oracle.com>
In-Reply-To: <91969714-5256-e96f-a48b-43af756a2686@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="utf-8"
Content-ID: <0430D7B812B862409056DAEAE92916D4@gisp.nec.co.jp>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Michal Hocko <mhocko@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

T24gMTEvMjMvMjAxNyAwNDoxMSBBTSwgTWlrZSBLcmF2ZXR6IHdyb3RlOg0KPiBPbiAxMS8yMi8y
MDE3IDA3OjI4IEFNLCBNaWNoYWwgSG9ja28gd3JvdGU6DQo+PiBIaSwNCj4+IGlzIHRoZXJlIGFu
eSByZWFzb24gd2h5IHdlIGVuZm9yY2UgdGhlIG92ZXJjb21taXQgbGltaXQgZHVyaW5nIGh1Z2V0
bGINCj4+IHBhZ2VzIG1pZ3JhdGlvbj8gSXQncyBpbiBhbGxvY19odWdlX3BhZ2Vfbm9kZS0+X19h
bGxvY19idWRkeV9odWdlX3BhZ2UNCj4+IHBhdGguIEkgYW0gd29uZGVyaW5nIHdoZXRoZXIgdGhp
cyBpcyByZWFsbHkgYW4gaW50ZW50aW9uYWwgYmVoYXZpb3IuDQo+IA0KPiBJIGRvIG5vdCB0aGlu
ayBpdCB3YXMgaW50ZW50aW9uYWwuICBCdXQsIEkgd2FzIG5vdCBhcm91bmQgd2hlbiB0aGF0DQo+
IGNvZGUgd2FzIGFkZGVkLg0KPiANCj4+IFRoZSBwYWdlIG1pZ3JhdGlvbiBhbGxvY2F0ZXMgYSBw
YWdlIGp1c3QgdGVtcG9yYXJpbHkgc28gd2Ugc2hvdWxkIGJlDQo+PiBhYmxlIHRvIGdvIG92ZXIg
dGhlIG92ZXJjb21taXQgbGltaXQgZm9yIHRoZSBtaWdyYXRpb24gZHVyYXRpb24uIFRoZQ0KPj4g
cmVhc29uIEkgYW0gYXNraW5nIGlzIHRoYXQgaHVnZXRsYiBwYWdlcyB0ZW5kIHRvIGJlIHV0aWxp
emVkIHVzdWFsbHkNCj4+IChvdGhlcndpc2UgdGhlIG1lbW9yeSB3b3VsZCBiZSBqdXN0IHdhc3Rl
ZCBhbmQgcG9vbCBzaHJ1bmspIGJ1dCB0aGVuDQo+PiB0aGUgbWlncmF0aW9uIHNpbXBseSBmYWls
cyB3aGljaCBicmVha3MgbWVtb3J5IGhvdHBsdWcgYW5kIG90aGVyDQo+PiBtaWdyYXRpb24gZGVw
ZW5kZW50IGZ1bmN0aW9uYWxpdHkgd2hpY2ggaXMgcXVpdGUgc3Vib3B0aW1hbC4gWW91IGNhbg0K
Pj4gd29ya2Fyb3VuZCB0aGF0IGJ5IGluY3JlYXNpbmcgdGhlIG92ZXJjb21taXQgbGltaXQuDQo+
IA0KPiBZZXMuICBJbiBhbiBlbnZpcm9ubWVudCBtYWtpbmcgb3B0aW1hbCB1c2Ugb2YgaHVnZSBw
YWdlcywgeW91IGFyZSB1bmxpa2VseQ0KPiB0byBoYXZlICdzcGFyZSBwYWdlcycgc2V0IGFzaWRl
IGZvciBhIHBvdGVudGlhbCBtaWdyYXRpb24gb3BlcmF0aW9uLiAgU28NCj4gSSBhZ3JlZSB0aGF0
IGl0IHdvdWxkIG1ha2Ugc2Vuc2UgdG8gdHJ5IGFuZCBhbGxvY2F0ZSBvdmVyY29tbWl0IHBhZ2Vz
IGZvcg0KPiB0aGlzIHB1cnBvc2UuDQoNClRoYW5rIHlvdSBmb3IgcG9pbnRpbmcgdGhpcyBvdXQs
IE1pY2hhbCwgTWlrZS4NCkRvaW5nIG92ZXJjb21taXR0aW5nIGluIGh1Z2VwYWdlIG1pZ3JhdGlv
biBpcyB0b3RhbGx5IHJpZ2h0IHRvIG1lLA0KSSBqdXN0IGRpZG4ndCBub3RpY2UgaXQgd2hlbiBJ
IHdyb3RlIHRoZSBjb2RlLg0KDQo+IA0KPj4gV2h5IGRvbid0IHdlIHNpbXBseSBtaWdyYXRlIGFz
IGxvbmcgYXMgd2UgYXJlIGFibGUgdG8gYWxsb2NhdGUgdGhlDQo+PiB0YXJnZXQgaHVnZXRsYiBw
YWdlPyBJIGhhdmUgYSBoYWxmIGJha2VkIHBhdGNoIHRvIHJlbW92ZSB0aGlzDQo+PiByZXN0cmlj
dGlvbiwgd291bGQgdGhlcmUgYmUgYW4gb3Bwb3NpdGlvbiB0byBkbyBzb21ldGhpbmcgbGlrZSB0
aGF0Pw0KPiANCj4gSSB3b3VsZCBub3QgYmUgb3Bwb3NlZCBhbmQgd291bGQgaGVscCB3aXRoIHRo
aXMgZWZmb3J0LiAgTXkgY29uY2VybiB3b3VsZA0KPiBiZSBhbnkgc3VidGxlIGh1Z2V0bGIgYWNj
b3VudGluZyBpc3N1ZXMgb25jZSB5b3Ugc3RhcnQgbWVzc2luZyB3aXRoDQo+IGFkZGl0aW9uYWwg
b3ZlcmNvbW1pdCBwYWdlcy4NCg0KWWVzLCBodWdldGxiIGFjY291bnRpbmcgYWx3YXlzIG5lZWRz
IGNhcmUgd2hlbiB0b3VjaGluZyByZWxhdGVkIGNvZGUuDQpJIGNhbiBoZWxwIHRlc3RpbmcuDQoN
ClRoYW5rcywNCk5hb3lhIEhvcmlndWNoaQ==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
