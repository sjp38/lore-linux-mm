Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 6AC966B0044
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 01:37:43 -0400 (EDT)
Received: by yenr5 with SMTP id r5so3349673yen.14
        for <linux-mm@kvack.org>; Thu, 26 Jul 2012 22:37:42 -0700 (PDT)
Date: Fri, 27 Jul 2012 13:38:51 +0800
From: majianpeng <majianpeng@gmail.com>
Subject: Re: Re: [RFC] block_dev:Fix bug when read/write block-device which is larger than 16TB in 32bit-OS.
References: <201205291656322966937@gmail.com> <201207242044249532601@gmail.com>,
	<20120724134838.GA26102@infradead.org>
Mime-Version: 1.0
Message-ID: <201207271338486719122@gmail.com>
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, "fengguang.wu" <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, viro <viro@ZenIV.linux.org.uk>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

T24gMjAxMi0wNy0yNCAyMTo0OCBDaHJpc3RvcGggSGVsbHdpZyA8aGNoQGluZnJhZGVhZC5vcmc+
IFdyb3RlOg0KPk9uIFR1ZSwgSnVsIDI0LCAyMDEyIGF0IDA4OjQ0OjI3UE0gKzA4MDAsIG1hamlh
bnBlbmcgd3JvdGU6DQo+PiBPbiAyMDEyLTA1LTI5IDE2OjU2IG1hamlhbnBlbmcgPG1hamlhbnBl
bmdAZ21haWwuY29tPiBXcm90ZToNCj4+ID5UaGUgc2l6ZSBvZiBibG9jay1kZXZpY2UgaXMgbGFy
Z2VyIHRoYW4gMTZUQiwgYW5kIHRoZSBvcyBpcyAzMmJpdC4NCj4+ID5JZiB0aGUgb2Zmc2V0IG9m
IHJlYWQvd3JpdGUgaXMgbGFyZ2VyIHRoZW4gMTZUQi4gVGhlIGluZGV4IG9mIGFkZHJlc3Nfc3Bh
Y2Ugd2lsbA0KPj4gPm92ZXJmbG93IGFuZCBzdXBwbHkgZGF0YSBmcm9tIGxvdyBvZmZzZXQgaW5z
dGVhZC4NCj4NCj5XZSBjYW4ndCBzdXBwb3J0ID4gMTZUQiBibG9jayBkZXZpY2Ugb24gMzItYml0
IHN5c3RlbXMgd2l0aCA0ayBwYWdlDQo+c2l6ZSwganVzdCBsaWtlIHdlIGNhbid0IHN1cHBvcnQg
ZmlsZXMgdGhhdCBsYXJnZS4NCj4NCj5Gb3IgZmlsZXN5c3RlbXMgdGhlIHNfbWF4Ynl0ZXMgbGlt
aXQgb2YgTUFYX0xGU19GSUxFU0laRSB0YWtlcyBjYXJlIG9mDQo+dGhhdCwgYnV0IGl0IHNlZW1z
IGxpa2Ugd2UgbWlzcyB0aGF0IGNoZWNrIGZvciBibG9jayBkZXZpY2VzLg0KPg0KPlRoZSBwcm9w
ZXIgZml4IGlzIHRvIGFkZCB0aGF0IGNoZWNrIChlaXRoZXIgdmlhIHNfbWF4Ynl0ZXMgb3IgYnkN
Cj5jaGVja2luZyBNQVhfTEZTX0ZJTEVTSVpFKSB0byBnZW5lcmljX3dyaXRlX2NoZWNrcyBhbmQN
Cj5nZW5lcmljX2ZpbGVfYWlvX3JlYWQgKG9yIGEgYmxvY2sgZGV2aWNlIHNwZWNpZmljIHdyYXBw
ZXIpDQo+DQovKiBQYWdlIGNhY2hlIGxpbWl0LiBUaGUgZmlsZXN5c3RlbXMgc2hvdWxkIHB1dCB0
aGF0IGludG8gdGhlaXIgc19tYXhieXRlcyANCiAgIGxpbWl0cywgb3RoZXJ3aXNlIGJhZCB0aGlu
Z3MgY2FuIGhhcHBlbiBpbiBWTS4gKi8gDQojaWYgQklUU19QRVJfTE9ORz09MzINCiNkZWZpbmUg
TUFYX0xGU19GSUxFU0laRQkoKCh1NjQpUEFHRV9DQUNIRV9TSVpFIDw8IChCSVRTX1BFUl9MT05H
LTEpKS0xKSANCiNlbGlmIEJJVFNfUEVSX0xPTkc9PTY0DQojZGVmaW5lIE1BWF9MRlNfRklMRVNJ
WkUgCTB4N2ZmZmZmZmZmZmZmZmZmZlVMDQojZW5kaWYNCg0KSWYgd2UgdXNlZCBNQVhfTEZTX0ZJ
TEVTSVpFIHRvIGxpbWl0IHRoZSBibG9jay1kZXZpY2UsIHNvIGluIDMyYml0LW9zLCB0aGUgc2l6
ZSBvZiBibG9jayBpcw0Kb25seSA4VCAtMS4NCkJ1dCBpbiBmdW5jdGlvbiBkb19nZW5lcmljX2Zp
bGVfcmVhZCgpOg0KPj5pbmRleCA9ICpwcG9zID4+IFBBR0VfQ0FDSEVfU0hJRlQ7DQppbmRleCBp
cyB1bnNpZ25lZCBsb25nIHR5cGUuIFNvIHRoZSBwcG9zIGNhbiAxNlQgLTEuDQoNCkJ1dCB0aGUg
Y29tbWVudCBzYWlkOg0KPj4vKiBQYWdlIGNhY2hlIGxpbWl0LiBUaGUgZmlsZXN5c3RlbXMgc2hv
dWxkIHB1dCB0aGF0IGludG8gdGhlaXIgc19tYXhieXRlcyANCj4+ICAgbGltaXRzLCBvdGhlcndp
c2UgYmFkIHRoaW5ncyBjYW4gaGFwcGVuIGluIFZNLiAqLyANCldoeSA/DQoNClRoYW5rcyAhDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
