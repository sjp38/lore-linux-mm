Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 302366B0032
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 04:08:38 -0400 (EDT)
Received: by pdcu2 with SMTP id u2so7441028pdc.3
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 01:08:37 -0700 (PDT)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id lz6si28446105pdb.199.2015.06.22.01.08.36
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 22 Jun 2015 01:08:37 -0700 (PDT)
From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [arc-linux-dev] [PATCH] stmmac: explicitly zero des0 & des1 on
 init
Date: Mon, 22 Jun 2015 08:08:31 +0000
Message-ID: <1434960510.4269.25.camel@synopsys.com>
References: <1434476441-18241-1-git-send-email-abrodkin@synopsys.com>
	 <C2D7FE5348E1B147BCA15975FBA23075665A5DED@IN01WEMBXB.internal.synopsys.com>
In-Reply-To: <C2D7FE5348E1B147BCA15975FBA23075665A5DED@IN01WEMBXB.internal.synopsys.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <9C754CE371BF664B83E790960FE8A875@internal.synopsys.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peppe.cavallaro@st.com" <peppe.cavallaro@st.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "arc-linux-dev@synopsys.com" <arc-linux-dev@synopsys.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "arnd@arndb.de" <arnd@arndb.de>

SGkgYWxsLA0KDQpPbiBXZWQsIDIwMTUtMDYtMTcgYXQgMDc6MDMgKzAwMDAsIFZpbmVldCBHdXB0
YSB3cm90ZToNCitDQyBsaW51eC1hcmNoLCBsaW51eC1tbSwgQXJuZCBhbmQgTWFyZWsNCg0KT24g
VHVlc2RheSAxNiBKdW5lIDIwMTUgMTE6MTEgUE0sIEFsZXhleSBCcm9ka2luIHdyb3RlOg0KDQpD
dXJyZW50IGltcGxlbWVudHRpb24gb2YgZGVzY3JpcHRvciBpbml0IHByb2NlZHVyZSBvbmx5IHRh
a2VzIGNhcmUgYWJvdXQNCm93bmVyc2hpcCBmbGFnLiBXaGlsZSBpdCBpcyBwZXJmZWN0bHkgcG9z
c2libGUgdG8gaGF2ZSB1bmRlcmx5aW5nIG1lbW9yeQ0KZmlsbGVkIHdpdGggZ2FyYmFnZSBvbiBi
b290IG9yIGRyaXZlciBpbnN0YWxsYXRpb24uDQoNCkFuZCByYW5kb21seSBzZXQgZmxhZ3MgaW4g
bm9uLXplcm9lZCBkZXMwIGFuZCBkZXMxIGZpZWxkcyBtYXkgbGVhZCB0bw0KdW5wcmVkaWN0YWJs
ZSBiZWhhdmlvciBvZiB0aGUgR01BQyBETUEgYmxvY2suDQoNClNvbHV0aW9uIHRvIHRoaXMgcHJv
YmxlbSBpcyBhcyBzaW1wbGUgYXMgZXhwbGljaXQgemVyb2luZyBvZiBib3RoIGRlczANCmFuZCBk
ZXMxIGZpZWxkcyBvZiBhbGwgYnVmZmVyIGRlc2NyaXB0b3JzLg0KDQpTaWduZWQtb2ZmLWJ5OiBB
bGV4ZXkgQnJvZGtpbiA8YWJyb2RraW5Ac3lub3BzeXMuY29tPjxtYWlsdG86YWJyb2RraW5Ac3lu
b3BzeXMuY29tPg0KQ2M6IEdpdXNlcHBlIENhdmFsbGFybyA8cGVwcGUuY2F2YWxsYXJvQHN0LmNv
bT48bWFpbHRvOnBlcHBlLmNhdmFsbGFyb0BzdC5jb20+DQpDYzogYXJjLWxpbnV4LWRldkBzeW5v
cHN5cy5jb208bWFpbHRvOmFyYy1saW51eC1kZXZAc3lub3BzeXMuY29tPg0KQ2M6IGxpbnV4LWtl
cm5lbEB2Z2VyLmtlcm5lbC5vcmc8bWFpbHRvOmxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc+
DQpDYzogc3RhYmxlQHZnZXIua2VybmVsLm9yZzxtYWlsdG86c3RhYmxlQHZnZXIua2VybmVsLm9y
Zz4NCg0KRldJVywgdGhpcyB3YXMgY2F1c2luZyBzcG9yYWRpYy9yYW5kb20gbmV0d29ya2luZyBm
bGFraW5lc3Mgb24gQVJDIFNEUCBwbGF0Zm9ybSAoc2NoZWR1bGVkIGZvciB1cHN0cmVhbSBpbmNs
dXNpb24gaW4gbmV4dCB3aW5kb3cpDQoNClRoaXMgYWxzbyBsZWFkcyB0byBhbiBpbnRlcmVzdGlu
ZyBxdWVzdGlvbiAtIHNob3VsZCBhcmNoLyovZG1hX2FsbG9jX2NvaGVyZW50KCkgYW5kIGZyaWVu
ZHMgdW5jb25kaXRpb25hbGx5IHplcm8gb3V0IG1lbW9yeSAodnMuIHRoZSBjdXJyZW50IHNlbWFu
dGljcyBvZiBsZXR0aW5nIG9ubHkgZG9pbmcgaXQgYmFzZWQgb24gZ2ZwLCBhcyByZXF1ZXN0ZWQg
YnkgZHJpdmVyKS4gVGhpcyBpcyB0aGUgc2Vjb25kIGluc3RhbmNlIHdlIHJhbiBpbnRvIHN0YWxl
IGRlc2NyaXB0b3IgbWVtb3J5LCB0aGUgZmlyc3Qgb25lIHdhcyBpbiBkd19tbWMgZHJpdmVyIHdo
aWNoIHdhcyByZWNlbnRseSBmaXhlZCBpbiB1cHN0cmVhbSBhcyB3ZWxsIChhbHRob3VnaCBkZWJ1
Z2dlZCBpbmRlcGVuZGVudGx5IGJ5IEFsZXhleSBhbmQgdXNpbmcgdGhlIHVwc3RyZWFtIGZpeCkN
Cg0KaHR0cDovL3d3dy5zcGluaWNzLm5ldC9saXN0cy9saW51eC1tbWMvbXNnMzE2MDAuaHRtbA0K
DQpUaGUgcHJvcyBpcyBiZXR0ZXIgb3V0IG9mIGJveCBleHBlcmllbmNlIChkZXNwaXRlIGJ1Z2d5
IGRyaXZlcnMpIHdoaWxlIHRoZSBjb25zIGFyZSB0aGV5IHJlbWFpbiBicm9rZW4gYW5kIHBlcmhh
cHMgaW5jcmVhc2VkIGJvb3QgdGltZSBkdWUgdG8gZXh0cmEgbWVtemVyby4uLi4NCg0KUHJvYmFi
bHkgaWYgd2UgYWxyZWFkeSBoYXZlIGRtYV96YWxsb2NfY29oZXJlbnQoKSB0aGF0IGRvZXMgZXhw
bGljaXQgemVyb2luZyBvZiByZXR1cm5lZCBtZW1vcnkgdGhlbiB0aGVyZSdzIG5vIG5lZWQgdG8g
ZG8gaW1wbGljaXQgemVyb2luZyBpbiBkbWFfYWxsb2NfY29oZXJlbnQoKT8NCg0KLUFsZXhleQ0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
