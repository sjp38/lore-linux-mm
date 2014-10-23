Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id BB68E6B0069
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 20:41:15 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id lj1so4714350pab.24
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 17:41:15 -0700 (PDT)
Received: from outbound.mxmail.xiaomi.com ([42.62.48.242])
        by mx.google.com with ESMTP id hk4si145904pbc.190.2014.10.22.17.41.13
        for <linux-mm@kvack.org>;
        Wed, 22 Oct 2014 17:41:14 -0700 (PDT)
From: =?gb2312?B?1uy71A==?= <zhuhui@xiaomi.com>
Subject: Re: [PATCH 0/4] (CMA_AGGRESSIVE) Make CMA memory be more aggressive
 about allocation
Date: Thu, 23 Oct 2014 00:40:57 +0000
Message-ID: <04a07ed889c840f1919e220f906af3af@cnbox4.mioffice.cn>
References: <1413430551-22392-1-git-send-email-zhuhui@xiaomi.com>
 <543F8812.2020002@codeaurora.org> <54479CB2.5040408@hurleysoftware.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Hurley <peter@hurleysoftware.com>, Laura Abbott <lauraa@codeaurora.org>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "riel@redhat.com" <riel@redhat.com>, "mgorman@suse.de" <mgorman@suse.de>, "hughd@google.com" <hughd@google.com>, "akinobu.mita@gmail.com" <akinobu.mita@gmail.com>
Cc: "rjw@rjwysocki.net" <rjw@rjwysocki.net>, "len.brown@intel.com" <len.brown@intel.com>, "pavel@ucw.cz" <pavel@ucw.cz>, "mina86@mina86.com" <mina86@mina86.com>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "minchan@kernel.org" <minchan@kernel.org>, "nasa4836@gmail.com" <nasa4836@gmail.com>, "ddstreet@ieee.org" <ddstreet@ieee.org>, "mingo@kernel.org" <mingo@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "peterz@infradead.org" <peterz@infradead.org>, "keescook@chromium.org" <keescook@chromium.org>, "atomlin@redhat.com" <atomlin@redhat.com>, "raistlin@linux.it" <raistlin@linux.it>, "axboe@fb.com" <axboe@fb.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "k.khlebnikov@samsung.com" <k.khlebnikov@samsung.com>, "msalter@redhat.com" <msalter@redhat.com>, "deller@gmx.de" <deller@gmx.de>, "tangchen@cn.fujitsu.com" <tangchen@cn.fujitsu.com>, "ben@decadent.org.uk" <ben@decadent.org.uk>, "vbabka@suse.cz" <vbabka@suse.cz>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "vdavydov@parallels.com" <vdavydov@parallels.com>, "suleiman@google.com" <suleiman@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

CgpPbiAxMC8yMi8xNCAyMDowMiwgUGV0ZXIgSHVybGV5IHdyb3RlOgo+IE9uIDEwLzE2LzIwMTQg
MDQ6NTUgQU0sIExhdXJhIEFiYm90dCB3cm90ZToKPj4gT24gMTAvMTUvMjAxNCA4OjM1IFBNLCBI
dWkgWmh1IHdyb3RlOgo+Pj4gSW4gZmFsbGJhY2tzIG9mIHBhZ2VfYWxsb2MuYywgTUlHUkFURV9D
TUEgaXMgdGhlIGZhbGxiYWNrIG9mCj4+PiBNSUdSQVRFX01PVkFCTEUuCj4+PiBNSUdSQVRFX01P
VkFCTEUgd2lsbCB1c2UgTUlHUkFURV9DTUEgd2hlbiBpdCBkb2Vzbid0IGhhdmUgYSBwYWdlIGlu
Cj4+PiBvcmRlciB0aGF0IExpbnV4IGtlcm5lbCB3YW50Lgo+Pj4KPj4+IElmIGEgc3lzdGVtIHRo
YXQgaGFzIGEgbG90IG9mIHVzZXIgc3BhY2UgcHJvZ3JhbSBpcyBydW5uaW5nLCBmb3IKPj4+IGlu
c3RhbmNlLCBhbiBBbmRyb2lkIGJvYXJkLCBtb3N0IG9mIG1lbW9yeSBpcyBpbiBNSUdSQVRFX01P
VkFCTEUgYW5kCj4+PiBhbGxvY2F0ZWQuICBCZWZvcmUgZnVuY3Rpb24gX19ybXF1ZXVlX2ZhbGxi
YWNrIGdldCBtZW1vcnkgZnJvbQo+Pj4gTUlHUkFURV9DTUEsIHRoZSBvb21fa2lsbGVyIHdpbGwg
a2lsbCBhIHRhc2sgdG8gcmVsZWFzZSBtZW1vcnkgd2hlbgo+Pj4ga2VybmVsIHdhbnQgZ2V0IE1J
R1JBVEVfVU5NT1ZBQkxFIG1lbW9yeSBiZWNhdXNlIGZhbGxiYWNrcyBvZgo+Pj4gTUlHUkFURV9V
Tk1PVkFCTEUgYXJlIE1JR1JBVEVfUkVDTEFJTUFCTEUgYW5kIE1JR1JBVEVfTU9WQUJMRS4KPj4+
IFRoaXMgc3RhdHVzIGlzIG9kZC4gIFRoZSBNSUdSQVRFX0NNQSBoYXMgYSBsb3QgZnJlZSBtZW1v
cnkgYnV0IExpbnV4Cj4+PiBrZXJuZWwga2lsbCBzb21lIHRhc2tzIHRvIHJlbGVhc2UgbWVtb3J5
Lgo+Pj4KPj4+IFRoaXMgcGF0Y2ggc2VyaWVzIGFkZHMgYSBuZXcgZnVuY3Rpb24gQ01BX0FHR1JF
U1NJVkUgdG8gbWFrZSBDTUEgbWVtb3J5Cj4+PiBiZSBtb3JlIGFnZ3Jlc3NpdmUgYWJvdXQgYWxs
b2NhdGlvbi4KPj4+IElmIGZ1bmN0aW9uIENNQV9BR0dSRVNTSVZFIGlzIGF2YWlsYWJsZSwgd2hl
biBMaW51eCBrZXJuZWwgY2FsbCBmdW5jdGlvbgo+Pj4gX19ybXF1ZXVlIHRyeSB0byBnZXQgcGFn
ZXMgZnJvbSBNSUdSQVRFX01PVkFCTEUgYW5kIGNvbmRpdGlvbnMgYWxsb3csCj4+PiBNSUdSQVRF
X0NNQSB3aWxsIGJlIGFsbG9jYXRlZCBhcyBNSUdSQVRFX01PVkFCTEUgZmlyc3QuICBJZiBNSUdS
QVRFX0NNQQo+Pj4gZG9lc24ndCBoYXZlIGVub3VnaCBwYWdlcyBmb3IgYWxsb2NhdGlvbiwgZ28g
YmFjayB0byBhbGxvY2F0ZSBtZW1vcnkgZnJvbQo+Pj4gTUlHUkFURV9NT1ZBQkxFLgo+Pj4gVGhl
biB0aGUgbWVtb3J5IG9mIE1JR1JBVEVfTU9WQUJMRSBjYW4gYmUga2VwdCBmb3IgTUlHUkFURV9V
Tk1PVkFCTEUgYW5kCj4+PiBNSUdSQVRFX1JFQ0xBSU1BQkxFIHdoaWNoIGRvZXNuJ3QgaGF2ZSBm
YWxsYmFjayBNSUdSQVRFX0NNQS4KPj4+Cj4+Cj4+IEl0J3MgZ29vZCB0byBzZWUgYW5vdGhlciBw
cm9wb3NhbCB0byBmaXggQ01BIHV0aWxpemF0aW9uLiBEbyB5b3UgaGF2ZQo+PiBhbnkgZGF0YSBh
Ym91dCB0aGUgc3VjY2VzcyByYXRlIG9mIENNQSBjb250aWd1b3VzIGFsbG9jYXRpb24gYWZ0ZXIK
Pj4gdGhpcyBwYXRjaCBzZXJpZXM/IEkgcGxheWVkIGFyb3VuZCB3aXRoIGEgc2ltaWxhciBhcHBy
b2FjaCBvZiB1c2luZwo+PiBDTUEgZm9yIE1JR1JBVEVfTU9WQUJMRSBhbGxvY2F0aW9ucyBhbmQg
Zm91bmQgdGhhdCBhbHRob3VnaCB1dGlsaXphdGlvbgo+PiBkaWQgaW5jcmVhc2UsIGNvbnRpZ3Vv
dXMgYWxsb2NhdGlvbnMgZmFpbGVkIGF0IGEgaGlnaGVyIHJhdGUgYW5kIHdlcmUKPj4gbXVjaCBz
bG93ZXIuIEkgc2VlIHdoYXQgdGhpcyBzZXJpZXMgaXMgdHJ5aW5nIHRvIGRvIHdpdGggYXZvaWRp
bmcKPj4gYWxsb2NhdGlvbiBmcm9tIENNQSBwYWdlcyB3aGVuIGEgY29udGlndW91cyBhbGxvY2F0
aW9uIGlzIHByb2dyZXNzLgo+PiBNeSBjb25jZXJuIGlzIHRoYXQgdGhlcmUgd291bGQgc3RpbGwg
YmUgcHJvYmxlbXMgd2l0aCBjb250aWd1b3VzCj4+IGFsbG9jYXRpb24gYWZ0ZXIgYWxsIHRoZSBN
SUdSQVRFX01PVkFCTEUgZmFsbGJhY2sgaGFzIGhhcHBlbmVkLgo+Cj4gV2hhdCBpbXBhY3QgZG9l
cyB0aGlzIHNlcmllcyBoYXZlIG9uIHg4NiBwbGF0Zm9ybXMgbm93IHRoYXQgQ01BIGlzIHRoZQo+
IGJhY2t1cCBhbGxvY2F0b3IgZm9yIGFsbCBpb21tdSBkbWEgYWxsb2NhdGlvbnM/CgpUaGV5IHdp
bGwgbm90IGFmZmVjdCBkcml2ZXIgQ01BIG1lbW9yeSBhbGxvY2F0aW9uLgoKVGhhbmtzLApIdWkK
Cj4KPiBSZWdhcmRzLAo+IFBldGVyIEh1cmxleQo+Cg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
