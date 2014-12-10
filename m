Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 81A186B0032
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 09:23:26 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id r20so11375637wiv.6
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 06:23:26 -0800 (PST)
Received: from mx0.aculab.com (mx0.aculab.com. [213.249.233.131])
        by mx.google.com with SMTP id cv8si7795656wjc.78.2014.12.10.06.23.25
        for <linux-mm@kvack.org>;
        Wed, 10 Dec 2014 06:23:25 -0800 (PST)
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 05297-08 for <linux-mm@kvack.org>; Wed, 10 Dec 2014 14:23:16 +0000 (GMT)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH 0/3] Faster than SLAB caching of SKBs with qmempool
	(backed by alf_queue)
Date: Wed, 10 Dec 2014 14:22:22 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CA0A193@AcuExch.aculab.com>
References: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20>
 <20141210141332.31779.56391.stgit@dragon>
In-Reply-To: <20141210141332.31779.56391.stgit@dragon>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Jesper Dangaard Brouer' <brouer@redhat.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux.com>
Cc: "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, "David S. Miller" <davem@davemloft.net>, Hannes
 Frederic Sowa <hannes@stressinduktion.org>, Alexander Duyck <alexander.duyck@gmail.com>, Alexei Starovoitov <ast@plumgrid.com>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Steven Rostedt <rostedt@goodmis.org>

RnJvbTogSmVzcGVyIERhbmdhYXJkIEJyb3Vlcg0KPiBUaGUgbmV0d29yayBzdGFjayBoYXZlIHNv
bWUgdXNlLWNhc2VzIHRoYXQgcHV0cyBzb21lIGV4dHJlbWUgZGVtYW5kcw0KPiBvbiB0aGUgbWVt
b3J5IGFsbG9jYXRvci4gIE9uZSB1c2UtY2FzZSwgMTBHYml0L3Mgd2lyZXNwZWVkIGF0IHNtYWxs
ZXN0DQo+IHBhY2tldCBzaXplWzFdLCByZXF1aXJlcyBoYW5kbGluZyBhIHBhY2tldCBldmVyeSA2
Ny4yIG5zIChuYW5vc2VjKS4NCj4gDQo+IE1pY3JvIGJlbmNobWFya2luZ1syXSB0aGUgU0xVQiBh
bGxvY2F0b3IgKHdpdGggc2tiIHNpemUgMjU2Ynl0ZXMNCj4gZWxlbWVudHMpLCBzaG93ICJmYXN0
LXBhdGgiIGluc3RhbnQgcmV1c2Ugb25seSBjb3N0cyAxOSBucywgYnV0IGENCj4gY2xvc2VyIHRv
IG5ldHdvcmsgdXNhZ2UgcGF0dGVybiBzaG93IHRoZSBjb3N0IHJpc2UgdG8gNDUgbnMuDQo+IA0K
PiBUaGlzIHBhdGNoc2V0IGludHJvZHVjZSBhIHF1aWNrIG1lbXBvb2wgKHFtZW1wb29sKSwgd2hp
Y2ggd2hlbiB1c2VkDQo+IGluLWZyb250IG9mIHRoZSBTS0IgKHNrX2J1ZmYpIGttZW1fY2FjaGUs
IHNhdmVzIDEyIG5zIG9uICJmYXN0LXBhdGgiDQo+IGRyb3AgaW4gaXB0YWJsZXMgInJhdyIgdGFi
bGUsIGJ1dCBtb3JlIGltcG9ydGFudGx5IHNhdmVzIDQwIG5zIHdpdGgNCj4gSVAtZm9yd2FyZGlu
Zywgd2hpY2ggd2VyZSBoaXR0aW5nIHRoZSBzbG93ZXIgU0xVQiB1c2UtY2FzZS4NCj4gDQo+IA0K
PiBPbmUgb2YgdGhlIGJ1aWxkaW5nIGJsb2NrcyBmb3IgYWNoaWV2aW5nIHRoaXMgc3BlZWR1cCBp
cyBhIGNtcHhjaGcNCj4gYmFzZWQgTG9jay1GcmVlIHF1ZXVlIHRoYXQgc3VwcG9ydHMgYnVsa2lu
ZywgbmFtZWQgYWxmX3F1ZXVlIGZvcg0KPiBBcnJheS1iYXNlZCBMb2NrLUZyZWUgcXVldWUuICBC
eSBidWxraW5nIGVsZW1lbnRzIChwb2ludGVycykgZnJvbSB0aGUNCj4gcXVldWUsIHRoZSBjb3N0
IG9mIHRoZSBjbXB4Y2hnIChhcHByb3ggOCBucykgaXMgYW1vcnRpemVkIG92ZXIgc2V2ZXJhbA0K
PiBlbGVtZW50cy4NCg0KSXQgc2VlbXMgdG8gbWUgdGhhdCB0aGVzZSBpbXByb3ZlbWVudHMgY291
bGQgYmUgYWRkZWQgdG8gdGhlDQp1bmRlcmx5aW5nIGFsbG9jYXRvciBpdHNlbGYuDQpOZXN0aW5n
IGFsbG9jYXRvcnMgZG9lc24ndCByZWFsbHkgc2VlbSByaWdodCB0byBtZS4NCg0KCURhdmlkDQoN
Cg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
