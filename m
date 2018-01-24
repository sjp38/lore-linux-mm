Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 33450800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 11:22:31 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id y62so2731006pgy.0
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 08:22:31 -0800 (PST)
Received: from esa2.hgst.iphmx.com (esa2.hgst.iphmx.com. [68.232.143.124])
        by mx.google.com with ESMTPS id l185si328052pge.147.2018.01.24.08.22.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 08:22:29 -0800 (PST)
From: Adam Manzanares <Adam.Manzanares@wdc.com>
Subject: [LSF/MM TOPIC] User Directed Tiered Memory Management
Date: Wed, 24 Jan 2018 16:22:26 +0000
Message-ID: <cae10844-35cd-991c-c69d-545e774d5a50@wdc.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <C1E6702F07CAD44298D57B75B3E11E3F@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>

V2l0aCB0aGUgaW50cm9kdWN0aW9uIG9mIGJ5dGUgYWRkcmVzc2FibGUgc3RvcmFnZSBkZXZpY2Vz
IHRoYXQgaGF2ZSBsb3cgDQpsYXRlbmNpZXMsIGl0IGJlY29tZXMgZGlmZmljdWx0IHRvIGRlY2lk
ZSBob3cgdG8gZXhwb3NlIHRoZXNlIGRldmljZXMgdG8gDQp1c2VyIHNwYWNlIGFwcGxpY2F0aW9u
cy4gRG8gd2UgdHJlYXQgdGhlbSBhcyB0cmFkaXRpb25hbCBibG9jayBkZXZpY2VzIA0Kb3IgZXhw
b3NlIHRoZW0gYXMgYSBEQVggY2FwYWJsZSBkZXZpY2U/IEEgdHJhZGl0aW9uYWwgYmxvY2sgZGV2
aWNlIA0KYWxsb3dzIHVzIHRvIHVzZSB0aGUgcGFnZSBjYWNoZSB0byB0YWtlIGFkdmFudGFnZSBv
ZiBsb2NhbGl0eSBpbiBhY2Nlc3MgDQpwYXR0ZXJucywgYnV0IGNvbWVzIGF0IHRoZSBleHBlbnNl
IG9mIGV4dHJhIG1lbW9yeSBjb3BpZXMgdGhhdCBhcmUgDQpleHRyZW1lbHkgY29zdGx5IGZvciBy
YW5kb20gd29ya2xvYWRzLiBBIERBWCBjYXBhYmxlIGRldmljZSBzZWVtcyBncmVhdCANCmZvciB0
aGUgYWZvcmVtZW50aW9uZWQgcmFuZG9tIGFjY2VzcyB3b3JrbG9hZCwgYnV0IHN1ZmZlcnMgb25j
ZSB0aGVyZSBpcyANCnNvbWUgbG9jYWxpdHkgaW4gdGhlIGFjY2VzcyBwYXR0ZXJuLg0KDQpXaGVu
IERBWC1jYXBhYmxlIGRldmljZXMgYXJlIHVzZWQgYXMgc2xvd2VyL2NoZWFwZXIgdm9sYXRpbGUg
bWVtb3J5LCANCnRyZWF0aW5nIHRoZW0gYXMgYSBzbG93ZXIgTlVNQSBub2RlIHdpdGggYW4gYXNz
b2NpYXRlZCBOVU1BIG1pZ3JhdGlvbiANCnBvbGljeSB3b3VsZCBhbGxvdyBmb3IgdGFraW5nIGFk
dmFudGFnZSBvZiBhY2Nlc3MgcGF0dGVybiBsb2NhbGl0eS4gDQpIb3dldmVyIHRoaXMgYXBwcm9h
Y2ggc3VmZmVycyBmcm9tIGEgZmV3IGRyYXdiYWNrcy4gRmlyc3QsIHdoZW4gdGhvc2UgDQpkZXZp
Y2VzIGFyZSBhbHNvIHBlcnNpc3RlbnQsIHRoZSB0aWVyaW5nIGFwcHJvYWNoIHVzZWQgaW4gTlVN
QSBtaWdyYXRpb24gDQptYXkgbm90IGd1YXJhbnRlZSBwZXJzaXN0ZW5jZS4gU2Vjb25kbHksIGZv
ciBkZXZpY2VzIHdpdGggc2lnbmlmaWNhbnRseSANCmhpZ2hlciBsYXRlbmNpZXMgdGhhbiBEUkFN
LCB0aGUgY29zdCBvZiBtb3ZpbmcgY2xlYW4gcGFnZXMgbWF5IGJlIA0Kc2lnbmlmaWNhbnQuIEZp
bmFsbHksIHBhZ2VzIGhhbmRsZWQgdmlhIE5VTUEgbWlncmF0aW9uIGFyZSBhIGNvbW1vbiANCnJl
c291cmNlIHN1YmplY3QgdG8gdGhyYXNoaW5nIGluIGNhc2Ugb2YgbWVtb3J5IHByZXNzdXJlLg0K
DQpJIHdvdWxkIGxpa2UgdG8gZGlzY3VzcyBhbiBhbHRlcm5hdGl2ZSBhcHByb2FjaCB3aGVyZSBt
ZW1vcnkgaW50ZW5zaXZlIA0KYXBwbGljYXRpb25zIG1tYXAgdGhlc2Ugc3RvcmFnZSBkZXZpY2Vz
IGludG8gdGhlaXIgYWRkcmVzcyBzcGFjZS4gVGhlIA0KYXBwbGljYXRpb24gY2FuIHNwZWNpZnkg
aG93IG11Y2ggRFJBTSBjb3VsZCBiZSB1c2VkIGFzIGEgY2FjaGUgYW5kIGhhdmUgDQpzb21lIGlu
Zmx1ZW5jZSBvbiBwcmVmZXRjaGluZyBhbmQgZXZpY3Rpb24gcG9saWNpZXMuIFRoZSBnb2FsIG9m
IHN1Y2ggYW4gDQphcHByb2FjaCB3b3VsZCBiZSB0byBtaW5pbWl6ZSB0aGUgaW1wYWN0IG9mIHRo
ZSBzbGlnaHRseSBzbG93ZXIgbWVtb3J5IA0KY291bGQgcG90ZW50aWFsbHkgaGF2ZSBvbiBhIHN5
c3RlbSB3aGVuIGl0IGlzIHRyZWF0ZWQgYXMga2VybmVsIG1hbmFnZWQgDQpnbG9iYWwgcmVzb3Vy
Y2UsIGFzIHdlbGwgYXMgZW5hYmxlIHVzZSBvZiB0aG9zZSBkZXZpY2VzIGFzIHBlcnNpc3RlbnQg
DQptZW1vcnkuIEJUVyB3ZSBjcmltaW5hbGx5IDspIHVzZWQgdGhlIHZtX2luc2VydF9wYWdlIGZ1
bmN0aW9uIGluIGEgDQpwcm90b3R5cGUgYW5kIGhhdmUgZm91bmQgdGhhdCBpdCBpcyBmYXN0ZXIg
dG8gdXNlIHZzIHBhZ2UgY2FjaGUgYW5kIA0Kc3dhcHBpbmcgbWVjaGFuaXNtcyBsaW1pdGVkIHRv
IHVzZSBhIHNtYWxsIGFtb3VudCBvZiBEUkFNLg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
