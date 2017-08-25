Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8839D6810D7
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 18:51:34 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id y15so6622579pgc.9
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 15:51:34 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0088.outbound.protection.outlook.com. [104.47.32.88])
        by mx.google.com with ESMTPS id 32si5942735pla.214.2017.08.25.15.51.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 25 Aug 2017 15:51:32 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: Re: + mm-madvise-fix-freeing-of-locked-page-with-madv_free.patch
 added to -mm tree
Date: Fri, 25 Aug 2017 22:51:28 +0000
Message-ID: <10E0D3D9-F7D4-4A0F-AD2F-9E40F3DE6CCC@vmware.com>
References: <599df681.NreP1dR3/HGSfpCe%akpm@linux-foundation.org>
 <20170824060957.GA29811@dhcp22.suse.cz>
 <81C11D6F-653D-4B14-A3A6-E6BB6FB5436D@vmware.com>
 <3452db57-d847-ec8e-c9be-7710f4ddd5d4@oracle.com>
In-Reply-To: <3452db57-d847-ec8e-c9be-7710f4ddd5d4@oracle.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <A3A524337E079043B9F619C836C35B0A@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "ebiggers@google.com" <ebiggers@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry
 Vyukov <dvyukov@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, "open list:MEMORY
 MANAGEMENT" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, "nyc@holomorphy.com" <nyc@holomorphy.com>

TWlrZSBLcmF2ZXR6IDxtaWtlLmtyYXZldHpAb3JhY2xlLmNvbT4gd3JvdGU6DQoNCj4gT24gMDgv
MjUvMjAxNyAwMzowMiBQTSwgTmFkYXYgQW1pdCB3cm90ZToNCj4+IE1pY2hhbCBIb2NrbyA8bWhv
Y2tvQGtlcm5lbC5vcmc+IHdyb3RlOg0KPj4gDQo+Pj4gSG1tLCBJIGRvIG5vdCBzZWUgdGhpcyBu
ZWl0aGVyIGluIGxpbnV4LW1tIG5vciBMS01MLiBTdHJhbmdlDQo+Pj4gDQo+Pj4gT24gV2VkIDIz
LTA4LTE3IDE0OjQxOjIxLCBBbmRyZXcgTW9ydG9uIHdyb3RlOg0KPj4+PiBGcm9tOiBFcmljIEJp
Z2dlcnMgPGViaWdnZXJzQGdvb2dsZS5jb20+DQo+Pj4+IFN1YmplY3Q6IG1tL21hZHZpc2UuYzog
Zml4IGZyZWVpbmcgb2YgbG9ja2VkIHBhZ2Ugd2l0aCBNQURWX0ZSRUUNCj4+Pj4gDQo+Pj4+IElm
IG1hZHZpc2UoLi4uLCBNQURWX0ZSRUUpIHNwbGl0IGEgdHJhbnNwYXJlbnQgaHVnZXBhZ2UsIGl0
IGNhbGxlZA0KPj4+PiBwdXRfcGFnZSgpIGJlZm9yZSB1bmxvY2tfcGFnZSgpLiAgVGhpcyB3YXMg
d3JvbmcgYmVjYXVzZSBwdXRfcGFnZSgpIGNhbg0KPj4+PiBmcmVlIHRoZSBwYWdlLCBlLmcuICBp
ZiBhIGNvbmN1cnJlbnQgbWFkdmlzZSguLi4sIE1BRFZfRE9OVE5FRUQpIGhhcw0KPj4+PiByZW1v
dmVkIGl0IGZyb20gdGhlIG1lbW9yeSBtYXBwaW5nLiAgcHV0X3BhZ2UoKSB0aGVuIHJpZ2h0ZnVs
bHkgY29tcGxhaW5lZA0KPj4+PiBhYm91dCBmcmVlaW5nIGEgbG9ja2VkIHBhZ2UuDQo+Pj4+IA0K
Pj4+PiBGaXggdGhpcyBieSBtb3ZpbmcgdGhlIHVubG9ja19wYWdlKCkgYmVmb3JlIHB1dF9wYWdl
KCkuDQo+PiANCj4+IFF1aWNrIGdyZXAgc2hvd3MgdGhhdCBhIHNpbWlsYXIgZmxvdyAocHV0X3Bh
Z2UoKSBmb2xsb3dlZCBieSBhbg0KPj4gdW5sb2NrX3BhZ2UoKSApIGFsc28gaGFwcGVucyBpbiBo
dWdldGxiZnNfZmFsbG9jYXRlKCkuIElzbuKAmXQgaXQgYSBwcm9ibGVtIGFzDQo+PiB3ZWxsPw0K
PiANCj4gSSBhc3N1bWUgeW91IGFyZSBhc2tpbmcgYWJvdXQgdGhpcyBibG9jayBvZiBjb2RlPw0K
DQpZZXMuDQoNCj4gDQo+ICAgICAgICAgICAgICAgIC8qDQo+ICAgICAgICAgICAgICAgICAqIHBh
Z2VfcHV0IGR1ZSB0byByZWZlcmVuY2UgZnJvbSBhbGxvY19odWdlX3BhZ2UoKQ0KPiAgICAgICAg
ICAgICAgICAgKiB1bmxvY2tfcGFnZSBiZWNhdXNlIGxvY2tlZCBieSBhZGRfdG9fcGFnZV9jYWNo
ZSgpDQo+ICAgICAgICAgICAgICAgICAqLw0KPiAgICAgICAgICAgICAgICBwdXRfcGFnZShwYWdl
KTsNCj4gICAgICAgICAgICAgICAgdW5sb2NrX3BhZ2UocGFnZSk7DQo+IA0KPiBXZWxsLCB0aGVy
ZSBpcyBhIHR5cG8gKHBhZ2VfcHV0KSBpbiB0aGUgY29tbWVudC4gOigNCj4gDQo+IEhvd2V2ZXIs
IGluIHRoaXMgY2FzZSB3ZSBoYXZlIGp1c3QgYWRkZWQgdGhlIGh1Z2UgcGFnZSB0byBhIGh1Z2V0
bGJmcw0KPiBmaWxlLiAgVGhlIHB1dF9wYWdlKCkgaXMgdGhlcmUganVzdCB0byBkcm9wIHRoZSBy
ZWZlcmVuY2UgY291bnQgb24gdGhlDQo+IHBhZ2UgKHRha2VuIHdoZW4gYWxsb2NhdGVkKS4gIEl0
IHdpbGwgc3RpbGwgYmUgbm9uLXplcm8gYXMgd2UgaGF2ZQ0KPiBzdWNjZXNzZnVsbHkgYWRkZWQg
aXQgdG8gdGhlIHBhZ2UgY2FjaGUuICBTbywgd2UgYXJlIG5vdCBmcmVlaW5nIHRoZQ0KPiBwYWdl
IGhlcmUsIGp1c3QgZHJvcHBpbmcgdGhlIHJlZmVyZW5jZSBjb3VudC4NCj4gDQo+IFRoaXMgc2hv
dWxkIG5vdCBjYXVzZSBhIHByb2JsZW0gbGlrZSB0aGF0IHNlZW4gaW4gbWFkdmlzZS4NCg0KVGhh
bmtzIGZvciB0aGUgcXVpY2sgcmVzcG9uc2UuDQoNCkkgYW0gbm90IHRvbyBmYW1pbGlhciB3aXRo
IHRoaXMgcGllY2Ugb2YgY29kZSwgc28ganVzdCBmb3IgdGhlIG1hdHRlciBvZg0KdW5kZXJzdGFu
ZGluZzogd2hhdCBwcmV2ZW50cyB0aGUgcGFnZSBmcm9tIGJlaW5nIHJlbW92ZWQgZnJvbSB0aGUg
cGFnZSBjYWNoZQ0Kc2hvcnRseSBhZnRlciBpdCBpcyBhZGRlZCAoZXZlbiBpZiBpdCBpcyBoaWdo
bHkgdW5saWtlbHkpPyBUaGUgcGFnZSBsb2NrPyBUaGUNCmlub2RlIGxvY2s/DQoNClRoYW5rcyBh
Z2FpbiwNCk5hZGF2DQoNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
