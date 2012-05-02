Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 3C3396B004D
	for <linux-mm@kvack.org>; Wed,  2 May 2012 02:49:10 -0400 (EDT)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [PATCH v4] vmevent: Implement greater-than attribute state and
 one-shot mode
Date: Wed, 2 May 2012 06:46:15 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB98269045D2AC9@008-AM1MPN1-003.mgdnok.nokia.com>
References: <20120418083208.GA24904@lizard> <20120418083523.GB31556@lizard>
 <alpine.LFD.2.02.1204182259580.11868@tux.localdomain>
 <20120418224629.GA22150@lizard>
 <alpine.LFD.2.02.1204190841290.1704@tux.localdomain>
 <20120419162923.GA26630@lizard> <20120501131806.GA22249@lizard>
 <4FA04FD5.6010900@redhat.com> <20120502002026.GA3334@lizard>
 <4FA08BDB.1070009@gmail.com> <20120502033136.GA14740@lizard>
 <4FA0C042.9010907@kernel.org>
In-Reply-To: <4FA0C042.9010907@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, anton.vorontsov@linaro.org
Cc: kosaki.motohiro@gmail.com, riel@redhat.com, penberg@kernel.org, john.stultz@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, glommer@parallels.com, kamezawa.hiroyu@jp.fujitsu.com, suleiman@google.com

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBleHQgTWluY2hhbiBLaW0gW21h
aWx0bzptaW5jaGFuQGtlcm5lbC5vcmddDQo+IFNlbnQ6IDAyIE1heSwgMjAxMiAwODowNA0KPiBU
bzogQW50b24gVm9yb250c292DQo+IENjOiBLT1NBS0kgTW90b2hpcm87IFJpayB2YW4gUmllbDsg
UGVra2EgRW5iZXJnOyBNb2lzZWljaHVrIExlb25pZCAoTm9raWEtDQouLi4NCj4gSSB0aGluayBo
YXJkZXN0IHByb2JsZW0gaW4gbG93IG1lbSBub3RpZmljYXRpb24gaXMgaG93IHRvIGRlZmluZSBf
bG93bWVtDQo+IHNpdHVhdGlvbl8uDQo+IFdlIGFsbCBndXlzIChzZXJ2ZXIsIGRlc2t0b3AgYW5k
IGVtYmVkZGVkKSBzaG91bGQgcmVhY2ggYSBjb25jbHVzaW9uIG9uDQo+IGRlZmluZSBsb3dtZW0g
c2l0dWF0aW9uIGJlZm9yZSBwcm9ncmVzc2luZyBmdXJ0aGVyIGltcGxlbWVudGF0aW9uDQo+IGJl
Y2F1c2UgZWFjaCBwYXJ0IGNhbiByZXF1aXJlIGRpZmZlcmVudCBsaW1pdHMuDQo+IEhvcGVmdWxs
eSwgSSB3YW50IGl0Lg0KPiANCj4gV2hhdCBpcyB0aGUgYmVzdCBzaXR1YXRpb24gd2UgY2FuIGNh
bGwgaXQgYXMgImxvdyBtZW1vcnkiPw0KDQpUaGF0IGRlcGVuZHMgb24gd2hhdCB1c2VyLXNwYWNl
IGNhbiBkby4gSW4gbjkgY2FzZSBbMV0gd2UgY2FuIGhhbmRsZSBzb21lIE9PTS9zbG93bmVzcy1w
cmV2ZW50aW9uIGFuZCBhY3Rpb25zIGUuZy4gY2xvc2UgYmFja2dyb3VuZCBhcHBsaWNhdGlvbnMs
IHN0b3AgcHJlc3RhcnRlZCBhcHBzLCANCmZsdXNoIGJyb3dzZXIvZ3JhcGhpY3MgY2FjaGVzIGlu
IGFwcGxpY2F0aW9ucyBhbmQgZG8gYWxsIHRoZSB0aGluZ3Mga2VybmVsIGV2ZW4gZG9uJ3Qga25v
dyBhYm91dC4gVGhpcyBzZXQgb2YgYWN0aXZpdGllcyB1c3VhbGx5IGNvbWVzIGFzIG1lbW9yeSBt
YW5hZ2VtZW50IGRlc2lnbi4NCg0KRnJvbSBhbm90aGVyIHNpZGUsIHBvbGxpbmcgYnkgcmUtc2Nh
biB2bXN0YXQgZGF0YSB1c2luZyBwcm9jZnMgbWlnaHQgYmUgcGVyZm9ybWFuY2UgaGVhdnkgYW5k
IGZvciBzdXJlIC0gdXNlLXRpbWUgZGlzYXN0ZXIuDQoNCkxlb25pZA0KWzFdIGh0dHA6Ly9tYWVt
by5naXRvcmlvdXMub3JnL21hZW1vLXRvb2xzL2xpYm1lbW5vdGlmeSAtIHllcywgbm90IGlkZWFs
IGJ1dCBpdCB3b3JrcyBhbmQgcXVpdGUgd2VsbCBpc29sYXRlZCBjb2RlLg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
