Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f182.google.com (mail-vc0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3B3A96B0031
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 12:02:52 -0400 (EDT)
Received: by mail-vc0-f182.google.com with SMTP id il7so6139836vcb.41
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 09:02:51 -0700 (PDT)
Received: from fujitsu24.fnanic.fujitsu.com (fujitsu24.fnanic.fujitsu.com. [192.240.6.14])
        by mx.google.com with ESMTPS id i5si9269121vcp.33.2014.06.23.09.02.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 09:02:51 -0700 (PDT)
From: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>
Date: Mon, 23 Jun 2014 09:01:26 -0700
Subject: RE: [patch 1/4] mm: vmscan: remove remains of kswapd-managed
 zone->all_unreclaimable
Message-ID: <6B2BA408B38BA1478B473C31C3D2074E341D40237A@SV-EXCHANGE1.Corp.FC.LOCAL>
References: <1403282030-29915-1-git-send-email-hannes@cmpxchg.org>
 <20140623061604.GA15594@bbox>
In-Reply-To: <20140623061604.GA15594@bbox>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogTWluY2hhbiBLaW0gW21h
aWx0bzptaW5jaGFuQGtlcm5lbC5vcmddDQo+IFNlbnQ6IE1vbmRheSwgSnVuZSAyMywgMjAxNCAy
OjE2IEFNDQo+IFRvOiBKb2hhbm5lcyBXZWluZXINCj4gQ2M6IEFuZHJldyBNb3J0b247IE1lbCBH
b3JtYW47IFJpayB2YW4gUmllbDsgTWljaGFsIEhvY2tvOyBsaW51eC1tbUBrdmFjay5vcmc7IGxp
bnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc7IE1vdG9oaXJvIEtvc2FraSBKUA0KPiBTdWJqZWN0
OiBSZTogW3BhdGNoIDEvNF0gbW06IHZtc2NhbjogcmVtb3ZlIHJlbWFpbnMgb2Yga3N3YXBkLW1h
bmFnZWQgem9uZS0+YWxsX3VucmVjbGFpbWFibGUNCj4gDQo+IE9uIEZyaSwgSnVuIDIwLCAyMDE0
IGF0IDEyOjMzOjQ3UE0gLTA0MDAsIEpvaGFubmVzIFdlaW5lciB3cm90ZToNCj4gPiBzaHJpbmtf
em9uZXMoKSBoYXMgYSBzcGVjaWFsIGJyYW5jaCB0byBza2lwIHRoZSBhbGxfdW5yZWNsYWltYWJs
ZSgpDQo+ID4gY2hlY2sgZHVyaW5nIGhpYmVybmF0aW9uLCBiZWNhdXNlIGEgZnJvemVuIGtzd2Fw
ZCBjYW4ndCBtYXJrIGEgem9uZQ0KPiA+IHVucmVjbGFpbWFibGUuDQo+ID4NCj4gPiBCdXQgZXZl
ciBzaW5jZSA2ZTU0M2Q1NzgwZTMgKCJtbTogdm1zY2FuOiBmaXggZG9fdHJ5X3RvX2ZyZWVfcGFn
ZXMoKQ0KPiA+IGxpdmVsb2NrIiksIGRldGVybWluaW5nIGEgem9uZSB0byBiZSB1bnJlY2xhaW1h
YmxlIGlzIGRvbmUgYnkgZGlyZWN0bHkNCj4gPiBsb29raW5nIGF0IGl0cyBzY2FuIGhpc3Rvcnkg
YW5kIG5vIGxvbmdlciByZWxpZXMgb24ga3N3YXBkIHNldHRpbmcgdGhlDQo+ID4gcGVyLXpvbmUg
ZmxhZy4NCj4gPg0KPiA+IFJlbW92ZSB0aGlzIGJyYW5jaCBhbmQgbGV0IHNocmlua196b25lcygp
IGNoZWNrIHRoZSByZWNsYWltYWJpbGl0eSBvZg0KPiA+IHRoZSB0YXJnZXQgem9uZXMgcmVnYXJk
bGVzcyBvZiBoaWJlcm5hdGlvbiBzdGF0ZS4NCj4gPg0KPiA+IFNpZ25lZC1vZmYtYnk6IEpvaGFu
bmVzIFdlaW5lciA8aGFubmVzQGNtcHhjaGcub3JnPg0KPiBBY2tlZC1ieTogTWluY2hhbiBLaW0g
PG1pbmNoYW5Aa2VybmVsLm9yZz4NCj4gDQo+IEl0IHdvdWxkIGJlIG5vdCBiYWQgdG8gQ2NlZCBL
T1NBS0kgd2hvIHdhcyBpbnZvbHZlZCBhbGxfdW5yZWNsYWltYWJsZSBzZXJpZXMgc2V2ZXJhbCB0
aW1lIHdpdGggbWUuDQoNCkxvb2tzIGdvb2QgdG8gbWUuDQoNCktPU0FLSSBNb3RvaGlybyA8S29z
YWtpLm1vdG9oaXJvQGpwLmZ1aml0c3UuY29tPg0KDQoNCg0KDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
