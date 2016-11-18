Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E3176B03A4
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 01:28:42 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y68so134343733pfb.6
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 22:28:42 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m1si6643186pfa.104.2016.11.17.22.28.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 22:28:41 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAI6SVCj103454
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 01:28:40 -0500
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26ssdnf7w4-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 01:28:40 -0500
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingzhh@cn.ibm.com>;
	Fri, 18 Nov 2016 16:28:38 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id BC3DF3578056
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 17:28:34 +1100 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAI6SYxK35061888
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 17:28:34 +1100
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAI6SYEd017834
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 17:28:34 +1100
Received: from d50lp31.co.us.ibm.com (d50lp31.boulder.ibm.com [9.17.249.32])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVin) with ESMTP id uAI6SW35017735
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 17:28:33 +1100
Received: from localhost
	by d50lp31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingzhh@cn.ibm.com>;
	Thu, 17 Nov 2016 23:28:32 -0700
Received: from localhost
	by smtp.notes.na.collabserv.com with smtp.notes.na.collabserv.com ESMTP
	for <linux-mm@kvack.org> from <dingzhh@cn.ibm.com>;
	Fri, 18 Nov 2016 06:28:30 -0000
In-Reply-To: <5b03def0-2dc4-842f-0d0e-53cc2d94936f@gmail.com>
Subject: Re: memory.force_empty is deprecated
From: "Zhao Hui Ding" <dingzhh@cn.ibm.com>
Date: Fri, 18 Nov 2016 14:28:21 +0800
References: <OF57AEC2D2.FA566D70-ON48258061.002C144F-48258061.002E2E50@notes.na.collabserv.com>
 <20161104152103.GC8825@cmpxchg.org>
 <5b03def0-2dc4-842f-0d0e-53cc2d94936f@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/alternative; boundary="=_alternative 00238EA34825806F_="
Message-Id: <OF4C17DCE5.3A69F6D5-ON4825806F.00234EAD-4825806F.00238F1A@notes.na.collabserv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>


--=_alternative 00238EA34825806F_=
Content-Transfer-Encoding: base64
Content-Type: text/plain; charset="GB2312"

VGhhbmsgeW91LiANCkRvIHlvdSBtZWFuIG1lbW9yeS5mb3JjZV9lbXB0eSB3b24ndCBiZSBkZXBy
ZWNhdGVkIGFuZCByZW1vdmVkPw0KDQpSZWdhcmRzLA0KLS1aaGFvaHVpDQoNCg0KDQpGcm9tOiAg
IEJhbGJpciBTaW5naCA8YnNpbmdoYXJvcmFAZ21haWwuY29tPg0KVG86ICAgICBKb2hhbm5lcyBX
ZWluZXIgPGhhbm5lc0BjbXB4Y2hnLm9yZz4sIFpoYW8gSHVpIA0KRGluZy9DaGluYS9JQk1ASUJN
Q04NCkNjOiAgICAgVGVqdW4gSGVvIDx0akBrZXJuZWwub3JnPiwgY2dyb3Vwc0B2Z2VyLmtlcm5l
bC5vcmcsIA0KbGludXgtbW1Aa3ZhY2sub3JnDQpEYXRlOiAgIDIwMTYtMTEtMTcgz8LO5yAwNjoz
OQ0KU3ViamVjdDogICAgICAgIFJlOiBtZW1vcnkuZm9yY2VfZW1wdHkgaXMgZGVwcmVjYXRlZA0K
DQoNCg0KDQoNCk9uIDA1LzExLzE2IDAyOjIxLCBKb2hhbm5lcyBXZWluZXIgd3JvdGU6DQo+IEhp
LA0KPiANCj4gT24gRnJpLCBOb3YgMDQsIDIwMTYgYXQgMDQ6MjQ6MjVQTSArMDgwMCwgWmhhbyBI
dWkgRGluZyB3cm90ZToNCj4+IEhlbGxvLA0KPj4NCj4+IEknbSBaaGFvaHVpIGZyb20gSUJNIFNw
ZWN0cnVtIExTRiBkZXZlbG9wbWVudCB0ZWFtLiBJIGdvdCBiZWxvdyBtZXNzYWdlIA0KDQo+PiB3
aGVuIHJ1bm5pbmcgTFNGIG9uIFNVU0UxMS40LCBzbyBJIHdvdWxkIGxpa2UgdG8gc2hhcmUgb3Vy
IHVzZSBzY2VuYXJpbyANCg0KPj4gYW5kIGFzayBmb3IgdGhlIHN1Z2dlc3Rpb25zIHdpdGhvdXQg
dXNpbmcgbWVtb3J5LmZvcmNlX2VtcHR5Lg0KPj4NCj4+IG1lbW9yeS5mb3JjZV9lbXB0eSBpcyBk
ZXByZWNhdGVkIGFuZCB3aWxsIGJlIHJlbW92ZWQuIExldCB1cyBrbm93IGlmIGl0IA0KaXMgDQo+
PiBuZWVkZWQgaW4geW91ciB1c2VjYXNlIGF0IGxpbnV4LW1tQGt2YWNrLm9yZw0KPj4NCj4+IExT
RiBpcyBhIGJhdGNoIHdvcmtsb2FkIHNjaGVkdWxlciwgaXQgdXNlcyBjZ3JvdXAgdG8gZG8gYmF0
Y2ggam9icyANCj4+IHJlc291cmNlIGVuZm9yY2VtZW50IGFuZCBhY2NvdW50aW5nLiBGb3IgZWFj
aCBqb2IsIExTRiBjcmVhdGVzIGEgY2dyb3VwIA0KDQo+PiBkaXJlY3RvcnkgYW5kIHB1dCBqb2In
cyBQSURzIHRvIHRoZSBjZ3JvdXAuDQo+Pg0KPj4gV2hlbiB3ZSBpbXBsZW1lbnQgTFNGIGNncm91
cCBpbnRlZ3JhdGlvbiwgd2UgZm91bmQgY3JlYXRpbmcgYSBuZXcgDQpjZ3JvdXAgDQo+PiBpcyBt
dWNoIHNsb3dlciB0aGFuIHJlbmFtaW5nIGFuIGV4aXN0aW5nIGNncm91cCwgaXQncyBhYm91dCBo
dW5kcmVkcyBvZiANCg0KPj4gbWlsbGlzZWNvbmRzIHZzIGxlc3MgdGhhbiAxMCBtaWxsaXNlY29u
ZHMuDQo+IA0KDQpXZSBhZGRlZCBmb3JjZV9lbXB0eSBhIGxvbmcgdGltZSBiYWNrIHNvIHRoYXQg
d2UgY291bGQgZm9yY2UgZGVsZXRlDQpjZ3JvdXBzLiBUaGVyZSB3YXMgbm8gZGVmaW5pdGl2ZSB3
YXkgb2YgcmVtb3ZpbmcgcmVmZXJlbmNlcyB0byB0aGUgY2dyb3VwDQpmcm9tIHBhZ2VfY2dyb3Vw
IG90aGVyd2lzZS4NCg0KPiBDZ3JvdXAgY3JlYXRpb24vZGVsZXRpb24gaXMgbm90IGV4cGVjdGVk
IHRvIGJlIGFuIHVsdHJhLWhvdCBwYXRoLCBidXQNCj4gSSdtIHN1cnByaXNlZCBpdCB0YWtlcyBs
b25nZXIgdGhhbiBhY3R1YWxseSByZWNsYWltaW5nIGxlZnRvdmVyIHBhZ2VzLg0KPiANCj4gQnkg
dGhlIHRpbWUgdGhlIGpvYnMgY29uY2x1ZGUsIGhvdyBtdWNoIGlzIHVzdWFsbHkgbGVmdCBpbiB0
aGUgZ3JvdXA/DQo+IA0KPiBUaGF0IHNhaWQsIGlzIGl0IGV2ZW4gbmVjZXNzYXJ5IHRvIHByby1h
Y3RpdmVseSByZW1vdmUgdGhlIGxlZnRvdmVyDQo+IGNhY2hlIGZyb20gdGhlIGdyb3VwIGJlZm9y
ZSBzdGFydGluZyB0aGUgbmV4dCBqb2I/IFdoeSBub3QgbGVhdmUgaXQNCj4gZm9yIHRoZSBuZXh0
IGpvYiB0byByZWNsYWltIGl0IGxhemlseSBzaG91bGQgbWVtb3J5IHByZXNzdXJlIGFyaXNlPw0K
PiBJdCdzIGVhc3kgdG8gcmVjbGFpbSBwYWdlIGNhY2hlLCBhbmQgdGhlIGZpcnN0IHRvIGdvIGFz
IGl0J3MgYmVoaW5kDQo+IHRoZSBuZXh0IGpvYidzIG1lbW9yeSBvbiB0aGUgTFJVIGxpc3QuDQoN
Ckl0IG1pZ2h0IGFjdHVhbGx5IG1ha2Ugc2Vuc2UgdG8gbWlncmF0ZSBhbGwgdGFza3Mgb3V0IGFu
ZCBjaGVjayB3aGF0DQp0aGUgbGVmdCBvdmVycyBsb29rIGxpa2UgLS0gc2hvdWxkIGJlIGVhc3kg
dG8gcmVjbGFpbS4gQWxzbyBiZSBtaW5kZnVsDQppZiB5b3UgYXJlIHVzaW5nIHYxIGFuZCBoYXZl
IHVzZV9oaWVyYXJjaHkgc2V0Lg0KDQpCYWxiaXIgU2luZ2guDQoNCg0KDQoNCg0K

--=_alternative 00238EA34825806F_=
Content-Transfer-Encoding: base64
Content-Type: text/html; charset="GB2312"

PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYiPlRoYW5rIHlvdS4gPC9mb250Pjxicj48Zm9u
dCBzaXplPTIgZmFjZT0ic2Fucy1zZXJpZiI+RG8geW91IG1lYW4gbWVtb3J5LmZvcmNlX2VtcHR5
IHdvbid0DQpiZSBkZXByZWNhdGVkIGFuZCByZW1vdmVkPzwvZm9udD48YnI+PGJyPjxmb250IHNp
emU9MiBmYWNlPSJzYW5zLXNlcmlmIj5SZWdhcmRzLDwvZm9udD48YnI+PGZvbnQgc2l6ZT0yIGZh
Y2U9InNhbnMtc2VyaWYiPi0tWmhhb2h1aTwvZm9udD48YnI+PGJyPjxicj48YnI+PGZvbnQgc2l6
ZT0xIGNvbG9yPSM1ZjVmNWYgZmFjZT0ic2Fucy1zZXJpZiI+RnJvbTogJm5ic3A7ICZuYnNwOyAm
bmJzcDsNCiZuYnNwOzwvZm9udD48Zm9udCBzaXplPTEgZmFjZT0ic2Fucy1zZXJpZiI+QmFsYmly
IFNpbmdoICZsdDtic2luZ2hhcm9yYUBnbWFpbC5jb20mZ3Q7PC9mb250Pjxicj48Zm9udCBzaXpl
PTEgY29sb3I9IzVmNWY1ZiBmYWNlPSJzYW5zLXNlcmlmIj5UbzogJm5ic3A7ICZuYnNwOyAmbmJz
cDsNCiZuYnNwOzwvZm9udD48Zm9udCBzaXplPTEgZmFjZT0ic2Fucy1zZXJpZiI+Sm9oYW5uZXMg
V2VpbmVyICZsdDtoYW5uZXNAY21weGNoZy5vcmcmZ3Q7LA0KWmhhbyBIdWkgRGluZy9DaGluYS9J
Qk1ASUJNQ048L2ZvbnQ+PGJyPjxmb250IHNpemU9MSBjb2xvcj0jNWY1ZjVmIGZhY2U9InNhbnMt
c2VyaWYiPkNjOiAmbmJzcDsgJm5ic3A7ICZuYnNwOw0KJm5ic3A7PC9mb250Pjxmb250IHNpemU9
MSBmYWNlPSJzYW5zLXNlcmlmIj5UZWp1biBIZW8gJmx0O3RqQGtlcm5lbC5vcmcmZ3Q7LA0KY2dy
b3Vwc0B2Z2VyLmtlcm5lbC5vcmcsIGxpbnV4LW1tQGt2YWNrLm9yZzwvZm9udD48YnI+PGZvbnQg
c2l6ZT0xIGNvbG9yPSM1ZjVmNWYgZmFjZT0ic2Fucy1zZXJpZiI+RGF0ZTogJm5ic3A7ICZuYnNw
OyAmbmJzcDsNCiZuYnNwOzwvZm9udD48Zm9udCBzaXplPTEgZmFjZT0ic2Fucy1zZXJpZiI+MjAx
Ni0xMS0xNyDPws7nIDA2OjM5PC9mb250Pjxicj48Zm9udCBzaXplPTEgY29sb3I9IzVmNWY1ZiBm
YWNlPSJzYW5zLXNlcmlmIj5TdWJqZWN0OiAmbmJzcDsgJm5ic3A7DQombmJzcDsgJm5ic3A7PC9m
b250Pjxmb250IHNpemU9MSBmYWNlPSJzYW5zLXNlcmlmIj5SZTogbWVtb3J5LmZvcmNlX2VtcHR5
DQppcyBkZXByZWNhdGVkPC9mb250Pjxicj48aHIgbm9zaGFkZT48YnI+PGJyPjxicj48dHQ+PGZv
bnQgc2l6ZT0yPjxicj48YnI+T24gMDUvMTEvMTYgMDI6MjEsIEpvaGFubmVzIFdlaW5lciB3cm90
ZTo8YnI+Jmd0OyBIaSw8YnI+Jmd0OyA8YnI+Jmd0OyBPbiBGcmksIE5vdiAwNCwgMjAxNiBhdCAw
NDoyNDoyNVBNICswODAwLCBaaGFvIEh1aSBEaW5nIHdyb3RlOjxicj4mZ3Q7Jmd0OyBIZWxsbyw8
YnI+Jmd0OyZndDs8YnI+Jmd0OyZndDsgSSdtIFpoYW9odWkgZnJvbSBJQk0gU3BlY3RydW0gTFNG
IGRldmVsb3BtZW50IHRlYW0uIEkgZ290IGJlbG93DQptZXNzYWdlIDxicj4mZ3Q7Jmd0OyB3aGVu
IHJ1bm5pbmcgTFNGIG9uIFNVU0UxMS40LCBzbyBJIHdvdWxkIGxpa2UgdG8gc2hhcmUgb3VyIHVz
ZQ0Kc2NlbmFyaW8gPGJyPiZndDsmZ3Q7IGFuZCBhc2sgZm9yIHRoZSBzdWdnZXN0aW9ucyB3aXRo
b3V0IHVzaW5nIG1lbW9yeS5mb3JjZV9lbXB0eS48YnI+Jmd0OyZndDs8YnI+Jmd0OyZndDsgbWVt
b3J5LmZvcmNlX2VtcHR5IGlzIGRlcHJlY2F0ZWQgYW5kIHdpbGwgYmUgcmVtb3ZlZC4gTGV0IHVz
IGtub3cNCmlmIGl0IGlzIDxicj4mZ3Q7Jmd0OyBuZWVkZWQgaW4geW91ciB1c2VjYXNlIGF0IGxp
bnV4LW1tQGt2YWNrLm9yZzxicj4mZ3Q7Jmd0Ozxicj4mZ3Q7Jmd0OyBMU0YgaXMgYSBiYXRjaCB3
b3JrbG9hZCBzY2hlZHVsZXIsIGl0IHVzZXMgY2dyb3VwIHRvIGRvIGJhdGNoDQpqb2JzIDxicj4m
Z3Q7Jmd0OyByZXNvdXJjZSBlbmZvcmNlbWVudCBhbmQgYWNjb3VudGluZy4gRm9yIGVhY2ggam9i
LCBMU0YgY3JlYXRlcw0KYSBjZ3JvdXAgPGJyPiZndDsmZ3Q7IGRpcmVjdG9yeSBhbmQgcHV0IGpv
YidzIFBJRHMgdG8gdGhlIGNncm91cC48YnI+Jmd0OyZndDs8YnI+Jmd0OyZndDsgV2hlbiB3ZSBp
bXBsZW1lbnQgTFNGIGNncm91cCBpbnRlZ3JhdGlvbiwgd2UgZm91bmQgY3JlYXRpbmcgYQ0KbmV3
IGNncm91cCA8YnI+Jmd0OyZndDsgaXMgbXVjaCBzbG93ZXIgdGhhbiByZW5hbWluZyBhbiBleGlz
dGluZyBjZ3JvdXAsIGl0J3MgYWJvdXQgaHVuZHJlZHMNCm9mIDxicj4mZ3Q7Jmd0OyBtaWxsaXNl
Y29uZHMgdnMgbGVzcyB0aGFuIDEwIG1pbGxpc2Vjb25kcy48YnI+Jmd0OyA8YnI+PGJyPldlIGFk
ZGVkIGZvcmNlX2VtcHR5IGEgbG9uZyB0aW1lIGJhY2sgc28gdGhhdCB3ZSBjb3VsZCBmb3JjZSBk
ZWxldGU8YnI+Y2dyb3Vwcy4gVGhlcmUgd2FzIG5vIGRlZmluaXRpdmUgd2F5IG9mIHJlbW92aW5n
IHJlZmVyZW5jZXMgdG8gdGhlIGNncm91cDxicj5mcm9tIHBhZ2VfY2dyb3VwIG90aGVyd2lzZS48
YnI+PGJyPiZndDsgQ2dyb3VwIGNyZWF0aW9uL2RlbGV0aW9uIGlzIG5vdCBleHBlY3RlZCB0byBi
ZSBhbiB1bHRyYS1ob3QgcGF0aCwNCmJ1dDxicj4mZ3Q7IEknbSBzdXJwcmlzZWQgaXQgdGFrZXMg
bG9uZ2VyIHRoYW4gYWN0dWFsbHkgcmVjbGFpbWluZyBsZWZ0b3ZlciBwYWdlcy48YnI+Jmd0OyA8
YnI+Jmd0OyBCeSB0aGUgdGltZSB0aGUgam9icyBjb25jbHVkZSwgaG93IG11Y2ggaXMgdXN1YWxs
eSBsZWZ0IGluIHRoZSBncm91cD88YnI+Jmd0OyA8YnI+Jmd0OyBUaGF0IHNhaWQsIGlzIGl0IGV2
ZW4gbmVjZXNzYXJ5IHRvIHByby1hY3RpdmVseSByZW1vdmUgdGhlIGxlZnRvdmVyPGJyPiZndDsg
Y2FjaGUgZnJvbSB0aGUgZ3JvdXAgYmVmb3JlIHN0YXJ0aW5nIHRoZSBuZXh0IGpvYj8gV2h5IG5v
dCBsZWF2ZSBpdDxicj4mZ3Q7IGZvciB0aGUgbmV4dCBqb2IgdG8gcmVjbGFpbSBpdCBsYXppbHkg
c2hvdWxkIG1lbW9yeSBwcmVzc3VyZSBhcmlzZT88YnI+Jmd0OyBJdCdzIGVhc3kgdG8gcmVjbGFp
bSBwYWdlIGNhY2hlLCBhbmQgdGhlIGZpcnN0IHRvIGdvIGFzIGl0J3MgYmVoaW5kPGJyPiZndDsg
dGhlIG5leHQgam9iJ3MgbWVtb3J5IG9uIHRoZSBMUlUgbGlzdC48YnI+PGJyPkl0IG1pZ2h0IGFj
dHVhbGx5IG1ha2Ugc2Vuc2UgdG8gbWlncmF0ZSBhbGwgdGFza3Mgb3V0IGFuZCBjaGVjayB3aGF0
PGJyPnRoZSBsZWZ0IG92ZXJzIGxvb2sgbGlrZSAtLSBzaG91bGQgYmUgZWFzeSB0byByZWNsYWlt
LiBBbHNvIGJlIG1pbmRmdWw8YnI+aWYgeW91IGFyZSB1c2luZyB2MSBhbmQgaGF2ZSB1c2VfaGll
cmFyY2h5IHNldC48YnI+PGJyPkJhbGJpciBTaW5naC48YnI+PGJyPjwvZm9udD48L3R0Pjxicj48
YnI+PEJSPg0K
--=_alternative 00238EA34825806F_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
