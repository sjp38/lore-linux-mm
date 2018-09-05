Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id D61676B74D4
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 15:51:39 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id q20-v6so8452430iod.19
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 12:51:39 -0700 (PDT)
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (mail-eopbgr700104.outbound.protection.outlook.com. [40.107.70.104])
        by mx.google.com with ESMTPS id v25-v6si1639775iom.112.2018.09.05.12.51.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 05 Sep 2018 12:51:38 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: Plumbers 2018 - Performance and Scalability Microconference
Date: Wed, 5 Sep 2018 19:51:34 +0000
Message-ID: <846ac52b-1839-4aa1-3154-1925c159bf4c@microsoft.com>
References: <1dc80ff6-f53f-ae89-be29-3408bf7d69cc@oracle.com>
 <20180905063845.GA23342@rapoport-lnx>
In-Reply-To: <20180905063845.GA23342@rapoport-lnx>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <F73FBD97B54F4C4FB21EF65E7C1052EA@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Aaron Lu <aaron.lu@intel.com>, "alex.kogan@oracle.com" <alex.kogan@oracle.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "boqun.feng@gmail.com" <boqun.feng@gmail.com>, "brouer@redhat.com" <brouer@redhat.com>, "dave@stgolabs.net" <dave@stgolabs.net>, "dave.dice@oracle.com" <dave.dice@oracle.com>, Dhaval Giani <dhaval.giani@oracle.com>, "ktkhai@virtuozzo.com" <ktkhai@virtuozzo.com>, "ldufour@linux.vnet.ibm.com" <ldufour@linux.vnet.ibm.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "shady.issa@oracle.com" <shady.issa@oracle.com>, "tariqt@mellanox.com" <tariqt@mellanox.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "tim.c.chen@intel.com" <tim.c.chen@intel.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "longman@redhat.com" <longman@redhat.com>, "yang.shi@linux.alibaba.com" <yang.shi@linux.alibaba.com>, "shy828301@gmail.com" <shy828301@gmail.com>, Huang Ying <ying.huang@intel.com>, "subhra.mazumdar@oracle.com" <subhra.mazumdar@oracle.com>, Steven Sistare <steven.sistare@oracle.com>, "jwadams@google.com" <jwadams@google.com>, "ashwinch@google.com" <ashwinch@google.com>, "sqazi@google.com" <sqazi@google.com>, Shakeel Butt <shakeelb@google.com>, "walken@google.com" <walken@google.com>, "rientjes@google.com" <rientjes@google.com>, "junaids@google.com" <junaids@google.com>, Neha Agarwal <nehaagarwal@google.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Andrei Vagin <avagin@virtuozzo.com>

DQoNCk9uIDkvNS8xOCAyOjM4IEFNLCBNaWtlIFJhcG9wb3J0IHdyb3RlOg0KPiBPbiBUdWUsIFNl
cCAwNCwgMjAxOCBhdCAwNToyODoxM1BNIC0wNDAwLCBEYW5pZWwgSm9yZGFuIHdyb3RlOg0KPj4g
UGF2ZWwgVGF0YXNoaW4sIFlpbmcgSHVhbmcsIGFuZCBJIGFyZSBleGNpdGVkIHRvIGJlIG9yZ2Fu
aXppbmcgYSBwZXJmb3JtYW5jZSBhbmQgc2NhbGFiaWxpdHkgbWljcm9jb25mZXJlbmNlIHRoaXMg
eWVhciBhdCBQbHVtYmVyc1sqXSwgd2hpY2ggaXMgaGFwcGVuaW5nIGluIFZhbmNvdXZlciB0aGlz
IHllYXIuICBUaGUgbWljcm9jb25mZXJlbmNlIGlzIHNjaGVkdWxlZCBmb3IgdGhlIG1vcm5pbmcg
b2YgdGhlIHNlY29uZCBkYXkgKFdlZCwgTm92IDE0KS4NCj4+DQo+PiBXZSBoYXZlIGEgcHJlbGlt
aW5hcnkgYWdlbmRhIGFuZCBhIGxpc3Qgb2YgY29uZmlybWVkIGFuZCBpbnRlcmVzdGVkIGF0dGVu
ZGVlcyAoY2MnZWQpLCBhbmQgYXJlIHNlZWtpbmcgbW9yZSBvZiBib3RoIQ0KPj4NCj4+IFNvbWUg
b2YgdGhlIGl0ZW1zIG9uIHRoZSBhZ2VuZGEgYXMgaXQgc3RhbmRzIG5vdyBhcmU6DQo+Pg0KPj4g
IC0gUHJvbW90aW5nIGh1Z2UgcGFnZSB1c2FnZTogIFdpdGggbWVtb3J5IHNpemVzIGJlY29taW5n
IGV2ZXIgbGFyZ2VyLCBodWdlIHBhZ2VzIGFyZSBiZWNvbWluZyBtb3JlIGFuZCBtb3JlIGltcG9y
dGFudCB0byByZWR1Y2UgVExCIG1pc3NlcyBhbmQgdGhlIG92ZXJoZWFkIG9mIG1lbW9yeSBtYW5h
Z2VtZW50IGl0c2VsZi0tdGhhdCBpcywgdG8gbWFrZSB0aGUgc3lzdGVtIHNjYWxhYmxlIHdpdGgg
dGhlIG1lbW9yeSBzaXplLiAgQnV0IHRoZXJlIGFyZSBzdGlsbCBzb21lIHJlbWFpbmluZyBnYXBz
IHRoYXQgcHJldmVudCBodWdlIHBhZ2VzIGZyb20gYmVpbmcgZGVwbG95ZWQgaW4gc29tZSBzaXR1
YXRpb25zLCBzdWNoIGFzIGh1Z2UgcGFnZSBhbGxvY2F0aW9uIGxhdGVuY3kgYW5kIG1lbW9yeSBm
cmFnbWVudGF0aW9uLg0KPj4NCj4+ICAtIFJlZHVjaW5nIHRoZSBudW1iZXIgb2YgdXNlcnMgb2Yg
bW1hcF9zZW06ICBUaGlzIHNlbWFwaG9yZSBpcyBmcmVxdWVudGx5IHVzZWQgdGhyb3VnaG91dCB0
aGUga2VybmVsLiAgSW4gb3JkZXIgdG8gZmFjaWxpdGF0ZSBzY2FsaW5nIHRoaXMgbG9uZ3N0YW5k
aW5nIGJvdHRsZW5lY2ssIHRoZXNlIHVzZXMgc2hvdWxkIGJlIGRvY3VtZW50ZWQgYW5kIHVubmVj
ZXNzYXJ5IHVzZXJzIHNob3VsZCBiZSBmaXhlZC4NCj4+DQo+PiAgLSBQYXJhbGxlbGl6aW5nIGNw
dS1pbnRlbnNpdmUga2VybmVsIHdvcms6ICBSZXNvbHZlIHByb2JsZW1zIG9mIHBhc3QgYXBwcm9h
Y2hlcyBpbmNsdWRpbmcgZXh0cmEgdGhyZWFkcyBpbnRlcmZlcmluZyB3aXRoIG90aGVyIHByb2Nl
c3NlcywgcGxheWluZyB3ZWxsIHdpdGggcG93ZXIgbWFuYWdlbWVudCwgYW5kIHByb3BlciBjZ3Jv
dXAgYWNjb3VudGluZyBmb3IgdGhlIGV4dHJhIHRocmVhZHMuICBCb251cyB0b3BpYzogcHJvcGVy
IGFjY291bnRpbmcgb2Ygd29ya3F1ZXVlIHRocmVhZHMgcnVubmluZyBvbiBiZWhhbGYgb2YgY2dy
b3Vwcy4NCj4+DQo+PiAgLSBQcmVzZXJ2aW5nIHVzZXJsYW5kIGR1cmluZyBrZXhlYyB3aXRoIGEg
aGliZXJuYXRpb24tbGlrZSBtZWNoYW5pc20uDQo+IA0KPiBKdXN0IHNvbWUgY3JhenkgaWRlYTog
aGF2ZSB5b3UgY29uc2lkZXJlZCB1c2luZyBjaGVja3BvaW50LXJlc3RvcmUgYXMgYQ0KPiByZXBs
YWNlbWVudCBvciBhbiBhZGRpdGlvbiB0byBoaWJlcm5hdGlvbj8NCg0KSGkgTWlrZSwNCg0KWWVz
LCB0aGlzIGlzIG9uZSB3YXkgSSB3YXMgdGhpbmtpbmcgYWJvdXQsIGFuZCB1c2Uga2VybmVsIHRv
IHBhc3MgdGhlDQphcHBsaWNhdGlvbiBzdG9yZWQgc3RhdGUgdG8gbmV3IGtlcm5lbCBpbiBwbWVt
LiBUaGUgb25seSBwcm9ibGVtIGlzIHRoYXQNCndlIHdhc3RlIG1lbW9yeTogd2hlbiB0aGVyZSBp
cyBub3QgZW5vdWdoIHN5c3RlbSBtZW1vcnkgdG8gY29weSBhbmQgcGFzcw0KYXBwbGljYXRpb24g
c3RhdGUgdG8gbmV3IGtlcm5lbCB0aGlzIHNjaGVtZSB3b24ndCB3b3JrLiBUaGluayBhYm91dCBE
Qg0KdGhhdCBvY2N1cGllcyA4MCUgb2Ygc3lzdGVtIG1lbW9yeSBhbmQgd2Ugd2FudCB0byBjaGVj
a3BvaW50L3Jlc3RvcmUgaXQuDQoNClNvLCB3ZSBuZWVkIHRvIGhhdmUgYW5vdGhlciB3YXksIHdo
ZXJlIHRoZSBwcmVzZXJ2ZWQgbWVtb3J5IGlzIHRoZQ0KbWVtb3J5IHRoYXQgaXMgYWN0dWFsbHkg
dXNlZCBieSB0aGUgYXBwbGljYXRpb25zLCBub3QgY29waWVkLiBPbmUgZWFzeQ0Kd2F5IGlzIHRv
IGdpdmUgZWFjaCBhcHBsaWNhdGlvbiB0aGF0IGhhcyBhIGxhcmdlIHN0YXRlIHRoYXQgaXMgZXhw
ZW5zaXZlDQp0byByZWNyZWF0ZSBhIHBlcnNpc3RlbnQgbWVtb3J5IGRldmljZSBhbmQgbGV0IGFw
cGxpY2F0aW9ucyB0byBrZWVwIGl0cw0Kc3RhdGUgb24gdGhhdCBkZXZpY2UgKHNheSAvZGV2L3Bt
ZW1OKS4gVGhlIG9ubHkgcHJvYmxlbSBpcyB0aGF0IG1lbW9yeQ0Kb24gdGhhdCBkZXZpY2UgbXVz
dCBiZSBhY2Nlc3NpYmxlIGp1c3QgYXMgZmFzdCBhcyByZWd1bGFyIG1lbW9yeSB3aXRob3V0DQph
bnkgZmlsZSBzeXN0ZW0gb3ZlcmhlYWQgYW5kIGhvcGVmdWxseSB3aXRob3V0IG5lZWQgZm9yIERB
WC4NCg0KSSBqdXN0IHdhbnQgdG8gZ2V0IHNvbWUgaWRlYXMgb2Ygd2hhdCBwZW9wbGUgYXJlIHRo
aW5raW5nIGFib3V0IHRoaXMsDQphbmQgd2hhdCB3b3VsZCBiZSB0aGUgYmVzdCB3YXkgdG8gYWNo
aWV2ZSBpdC4NCg0KUGF2ZWwNCg0KDQo+ICANCj4+IFRoZXNlIGNlbnRlciBhcm91bmQgb3VyIGlu
dGVyZXN0cywgYnV0IGhhdmluZyBsb3RzIG9mIHRvcGljcyB0byBjaG9vc2UgZnJvbSBlbnN1cmVz
IHdlIGNvdmVyIHdoYXQncyBtb3N0IGltcG9ydGFudCB0byB0aGUgY29tbXVuaXR5LCBzbyB3ZSB3
b3VsZCBsaWtlIHRvIGhlYXIgYWJvdXQgYWRkaXRpb25hbCB0b3BpY3MgYW5kIGV4dGVuc2lvbnMg
dG8gdGhvc2UgbGlzdGVkIGhlcmUuICBUaGlzIGluY2x1ZGVzLCBidXQgaXMgY2VydGFpbmx5IG5v
dCBsaW1pdGVkIHRvLCB3b3JrIGluIHByb2dyZXNzIHRoYXQgd291bGQgYmVuZWZpdCBmcm9tIGlu
LXBlcnNvbiBkaXNjdXNzaW9uLCByZWFsLXdvcmxkIHBlcmZvcm1hbmNlIHByb2JsZW1zLCBhbmQg
ZXhwZXJpbWVudGFsIGFuZCBhY2FkZW1pYyB3b3JrLg0KPj4NCj4+IElmIHlvdSBoYXZlbid0IGFs
cmVhZHkgZG9uZSBzbywgcGxlYXNlIGxldCB1cyBrbm93IGlmIHlvdSBhcmUgaW50ZXJlc3RlZCBp
biBhdHRlbmRpbmcsIG9yIGhhdmUgc3VnZ2VzdGlvbnMgZm9yIG90aGVyIGF0dGVuZGVlcy4NCj4+
DQo+PiBUaGFua3MsDQo+PiBEYW5pZWwNCj4+DQo+PiBbKl0gaHR0cHM6Ly9ibG9nLmxpbnV4cGx1
bWJlcnNjb25mLm9yZy8yMDE4L3BlcmZvcm1hbmNlLW1jLw0KPj4NCj4g
