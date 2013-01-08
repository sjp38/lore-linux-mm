Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 555CE6B005A
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 03:00:56 -0500 (EST)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [PATCH 1/2] Add mempressure cgroup
Date: Tue, 8 Jan 2013 07:57:25 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB98269046C33F0@008-AM1MPN1-003.mgdnok.nokia.com>
References: <20130104082751.GA22227@lizard.gateway.2wire.net>
 <1357288152-23625-1-git-send-email-anton.vorontsov@linaro.org>
 <50EA8CA2.7020608@jp.fujitsu.com>
 <20130108072935.GA15431@lizard.gateway.2wire.net>
In-Reply-To: <20130108072935.GA15431@lizard.gateway.2wire.net>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: anton.vorontsov@linaro.org, kamezawa.hiroyu@jp.fujitsu.com
Cc: rientjes@google.com, penberg@kernel.org, mgorman@suse.de, glommer@parallels.com, mhocko@suse.cz, kirill@shutemov.name, lcapitulino@redhat.com, akpm@linux-foundation.org, gthelen@google.com, kosaki.motohiro@gmail.com, minchan@kernel.org, b.zolnierkie@samsung.com, john.stultz@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

LS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCkZyb206IGV4dCBBbnRvbiBWb3JvbnRzb3YgW21h
aWx0bzphbnRvbi52b3JvbnRzb3ZAbGluYXJvLm9yZ10gDQpTZW50OiAwOCBKYW51YXJ5LCAyMDEz
IDA4OjMwDQouLi4NCj4gPiArc3RhdGljIGNvbnN0IHVpbnQgdm1wcmVzc3VyZV9sZXZlbF9tZWQg
PSA2MDsNCj4gPiArc3RhdGljIGNvbnN0IHVpbnQgdm1wcmVzc3VyZV9sZXZlbF9vb20gPSA5OTsN
Cj4gPiArc3RhdGljIGNvbnN0IHVpbnQgdm1wcmVzc3VyZV9sZXZlbF9vb21fcHJpbyA9IDQ7DQo+
ID4gKw0KLi4NClNlZW1zIHZtcHJlc3N1cmVfbGV2ZWxfb29tID0gOTkgaXMgcXVpdGUgaGlnaCBp
ZiBJIHVuZGVyc3RhbmQgaXQgYXMgYSBnbG9iYWwuIElmIEkgZG8gbm90IHdyb25nIGluIG9sZCB2
ZXJzaW9uIG9mIGtlcm5lbCB0aGUga2VybmVsIG9ubHkgbWVtb3J5IGJvcmRlciB3YXMgc3RhdGVk
IGFzIDEvMzIgcGFydCBvZiBhdmFpbGFibGUgbWVtb3J5IG1lYW5pbmcgbm8gYWxsb2NhdGlvbiBm
b3IgdXNlci1zcGFjZSBpZiBhbW91bnQgb2YgZnJlZSBtZW1vcnkgcmVhY2hlZCAxLzMyLiBTbywg
ZGVjcmVhc2luZyB0aGlzIHBhcmFtZXRlciB0byA5NSBvciA5MCB3aWxsIGFsbG93IG5vdGlmaWNh
dGlvbiB0byBiZSBwcm9wYWdhdGVkIHRvIHVzZXItc3BhY2UgYW5kIGhhbmRsZWQuDQoNCkJlc3Qg
d2lzaGVzLA0KTGVvbmlkDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
