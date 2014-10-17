Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id BF6EA6B0069
	for <linux-mm@kvack.org>; Fri, 17 Oct 2014 03:45:21 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id p10so330807pdj.29
        for <linux-mm@kvack.org>; Fri, 17 Oct 2014 00:45:21 -0700 (PDT)
Received: from manager.mioffice.cn ([42.62.48.242])
        by mx.google.com with ESMTP id on3si552009pbc.29.2014.10.17.00.45.18
        for <linux-mm@kvack.org>;
        Fri, 17 Oct 2014 00:45:20 -0700 (PDT)
From: =?gb2312?B?1uy71A==?= <zhuhui@xiaomi.com>
Subject: Re: [PATCH 0/4] (CMA_AGGRESSIVE) Make CMA memory be more aggressive
 about allocation
Date: Fri, 17 Oct 2014 07:44:26 +0000
Message-ID: <cf4a9f99f7b24b4fb688cb3bcccefb0e@cnbox4.mioffice.cn>
References: <1413430551-22392-1-git-send-email-zhuhui@xiaomi.com>
 <543F8812.2020002@codeaurora.org>
Content-Language: zh-CN
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>, "rjw@rjwysocki.net" <rjw@rjwysocki.net>, "len.brown@intel.com" <len.brown@intel.com>, "pavel@ucw.cz" <pavel@ucw.cz>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mina86@mina86.com" <mina86@mina86.com>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, "mgorman@suse.de" <mgorman@suse.de>, "minchan@kernel.org" <minchan@kernel.org>, "nasa4836@gmail.com" <nasa4836@gmail.com>, "ddstreet@ieee.org" <ddstreet@ieee.org>, "hughd@google.com" <hughd@google.com>, "mingo@kernel.org" <mingo@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "peterz@infradead.org" <peterz@infradead.org>, "keescook@chromium.org" <keescook@chromium.org>, "atomlin@redhat.com" <atomlin@redhat.com>, "raistlin@linux.it" <raistlin@linux.it>, "axboe@fb.com" <axboe@fb.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "k.khlebnikov@samsung.com" <k.khlebnikov@samsung.com>, "msalter@redhat.com" <msalter@redhat.com>, "deller@gmx.de" <deller@gmx.de>, "tangchen@cn.fujitsu.com" <tangchen@cn.fujitsu.com>, "ben@decadent.org.uk" <ben@decadent.org.uk>, "akinobu.mita@gmail.com" <akinobu.mita@gmail.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "vdavydov@parallels.com" <vdavydov@parallels.com>, "suleiman@google.com" <suleiman@google.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

CgpPbiAxMC8xNi8xNCAxNjo1NiwgTGF1cmEgQWJib3R0IHdyb3RlOgo+IE9uIDEwLzE1LzIwMTQg
ODozNSBQTSwgSHVpIFpodSB3cm90ZToKPj4gSW4gZmFsbGJhY2tzIG9mIHBhZ2VfYWxsb2MuYywg
TUlHUkFURV9DTUEgaXMgdGhlIGZhbGxiYWNrIG9mCj4+IE1JR1JBVEVfTU9WQUJMRS4KPj4gTUlH
UkFURV9NT1ZBQkxFIHdpbGwgdXNlIE1JR1JBVEVfQ01BIHdoZW4gaXQgZG9lc24ndCBoYXZlIGEg
cGFnZSBpbgo+PiBvcmRlciB0aGF0IExpbnV4IGtlcm5lbCB3YW50Lgo+Pgo+PiBJZiBhIHN5c3Rl
bSB0aGF0IGhhcyBhIGxvdCBvZiB1c2VyIHNwYWNlIHByb2dyYW0gaXMgcnVubmluZywgZm9yCj4+
IGluc3RhbmNlLCBhbiBBbmRyb2lkIGJvYXJkLCBtb3N0IG9mIG1lbW9yeSBpcyBpbiBNSUdSQVRF
X01PVkFCTEUgYW5kCj4+IGFsbG9jYXRlZC4gIEJlZm9yZSBmdW5jdGlvbiBfX3JtcXVldWVfZmFs
bGJhY2sgZ2V0IG1lbW9yeSBmcm9tCj4+IE1JR1JBVEVfQ01BLCB0aGUgb29tX2tpbGxlciB3aWxs
IGtpbGwgYSB0YXNrIHRvIHJlbGVhc2UgbWVtb3J5IHdoZW4KPj4ga2VybmVsIHdhbnQgZ2V0IE1J
R1JBVEVfVU5NT1ZBQkxFIG1lbW9yeSBiZWNhdXNlIGZhbGxiYWNrcyBvZgo+PiBNSUdSQVRFX1VO
TU9WQUJMRSBhcmUgTUlHUkFURV9SRUNMQUlNQUJMRSBhbmQgTUlHUkFURV9NT1ZBQkxFLgo+PiBU
aGlzIHN0YXR1cyBpcyBvZGQuICBUaGUgTUlHUkFURV9DTUEgaGFzIGEgbG90IGZyZWUgbWVtb3J5
IGJ1dCBMaW51eAo+PiBrZXJuZWwga2lsbCBzb21lIHRhc2tzIHRvIHJlbGVhc2UgbWVtb3J5Lgo+
Pgo+PiBUaGlzIHBhdGNoIHNlcmllcyBhZGRzIGEgbmV3IGZ1bmN0aW9uIENNQV9BR0dSRVNTSVZF
IHRvIG1ha2UgQ01BIG1lbW9yeQo+PiBiZSBtb3JlIGFnZ3Jlc3NpdmUgYWJvdXQgYWxsb2NhdGlv
bi4KPj4gSWYgZnVuY3Rpb24gQ01BX0FHR1JFU1NJVkUgaXMgYXZhaWxhYmxlLCB3aGVuIExpbnV4
IGtlcm5lbCBjYWxsIGZ1bmN0aW9uCj4+IF9fcm1xdWV1ZSB0cnkgdG8gZ2V0IHBhZ2VzIGZyb20g
TUlHUkFURV9NT1ZBQkxFIGFuZCBjb25kaXRpb25zIGFsbG93LAo+PiBNSUdSQVRFX0NNQSB3aWxs
IGJlIGFsbG9jYXRlZCBhcyBNSUdSQVRFX01PVkFCTEUgZmlyc3QuICBJZiBNSUdSQVRFX0NNQQo+
PiBkb2Vzbid0IGhhdmUgZW5vdWdoIHBhZ2VzIGZvciBhbGxvY2F0aW9uLCBnbyBiYWNrIHRvIGFs
bG9jYXRlIG1lbW9yeSBmcm9tCj4+IE1JR1JBVEVfTU9WQUJMRS4KPj4gVGhlbiB0aGUgbWVtb3J5
IG9mIE1JR1JBVEVfTU9WQUJMRSBjYW4gYmUga2VwdCBmb3IgTUlHUkFURV9VTk1PVkFCTEUgYW5k
Cj4+IE1JR1JBVEVfUkVDTEFJTUFCTEUgd2hpY2ggZG9lc24ndCBoYXZlIGZhbGxiYWNrIE1JR1JB
VEVfQ01BLgo+Pgo+Cj4gSXQncyBnb29kIHRvIHNlZSBhbm90aGVyIHByb3Bvc2FsIHRvIGZpeCBD
TUEgdXRpbGl6YXRpb24uCgpUaGFua3MgTGF1cmEuCgpEbyB5b3UgaGF2ZQo+IGFueSBkYXRhIGFi
b3V0IHRoZSBzdWNjZXNzIHJhdGUgb2YgQ01BIGNvbnRpZ3VvdXMgYWxsb2NhdGlvbiBhZnRlcgo+
IHRoaXMgcGF0Y2ggc2VyaWVzPyAgIEkgcGxheWVkIGFyb3VuZCB3aXRoIGEgc2ltaWxhciBhcHBy
b2FjaCBvZiB1c2luZwo+IENNQSBmb3IgTUlHUkFURV9NT1ZBQkxFIGFsbG9jYXRpb25zIGFuZCBm
b3VuZCB0aGF0IGFsdGhvdWdoIHV0aWxpemF0aW9uCj4gZGlkIGluY3JlYXNlLCBjb250aWd1b3Vz
IGFsbG9jYXRpb25zIGZhaWxlZCBhdCBhIGhpZ2hlciByYXRlIGFuZCB3ZXJlCj4gbXVjaCBzbG93
ZXIuIEkgc2VlIHdoYXQgdGhpcyBzZXJpZXMgaXMgdHJ5aW5nIHRvIGRvIHdpdGggYXZvaWRpbmcK
PiBhbGxvY2F0aW9uIGZyb20gQ01BIHBhZ2VzIHdoZW4gYSBjb250aWd1b3VzIGFsbG9jYXRpb24g
aXMgcHJvZ3Jlc3MuCj4gTXkgY29uY2VybiBpcyB0aGF0IHRoZXJlIHdvdWxkIHN0aWxsIGJlIHBy
b2JsZW1zIHdpdGggY29udGlndW91cwo+IGFsbG9jYXRpb24gYWZ0ZXIgYWxsIHRoZSBNSUdSQVRF
X01PVkFCTEUgZmFsbGJhY2sgaGFzIGhhcHBlbmVkLgoKSSBkaWQgc29tZSB0ZXN0IHdpdGggdGhl
IGNtYV9hbGxvY19jb3VudGVyIGFuZCBjbWEtYWdncmVzc2l2ZS1zaHJpbmsgaW4gCmEgYW5kcm9p
ZCBib2FyZCB0aGF0IGhhcyAxZyBtZW1vcnkuICBSdW4gc29tZSBhcHBzIHRvIG1ha2UgZnJlZSBD
TUEgCmNsb3NlIHRvIHRoZSB2YWx1ZSBvZiBjbWFfYWdncmVzc2l2ZV9mcmVlX21pbig1MDAgcGFn
ZXMpLiAgQSBkcml2ZXIgCkJlZ2luIHRvIHJlcXVlc3QgQ01BIG1vcmUgdGhhbiAxMCB0aW1lcy4g
RWFjaCB0aW1lLCBpdCB3aWxsIHJlcXVlc3QgbW9yZSAKdGhhbiAzMDAwIHBhZ2VzLgoKSSBkb24n
dCBoYXZlIGVzdGFibGlzaGVkIG51bWJlciBmb3IgdGhhdCBiZWNhdXNlIGl0IGlzIHJlYWxseSBo
YXJkIHRvIApnZXQgYSBmYWlsLiAgSSB0aGluayB0aGUgc3VjY2VzcyByYXRlIGlzIG92ZXIgOTUl
IGF0IGxlYXN0LgoKQW5kIEkgdGhpbmsgbWF5YmUgdGhlIGlzb2xhdGUgZmFpbCBoYXMgcmVsYXRp
b24gd2l0aCBwYWdlIGFsbG9jIGFuZCBmcmVlIApjb2RlLiAgTWF5YmUgbGV0IHpvbmUtPmxvY2sg
cHJvdGVjdCBtb3JlIGNvZGUgY2FuIGhhbmRsZSB0aGlzIGlzc3VlLgoKVGhhbmtzLApIdWkKCj4K
PiBUaGFua3MsCj4gTGF1cmEKPgo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
