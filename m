Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 85CC98E0025
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 19:48:25 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id e8-v6so1120196pls.23
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 16:48:25 -0700 (PDT)
Received: from g4t3426.houston.hpe.com (g4t3426.houston.hpe.com. [15.241.140.75])
        by mx.google.com with ESMTPS id v129-v6si32166938pfv.278.2018.09.21.16.48.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 16:48:24 -0700 (PDT)
From: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>
Subject: RE: [PATCH 0/3] mm: Randomize free memory
Date: Fri, 21 Sep 2018 23:48:18 +0000
Message-ID: <AT5PR8401MB1169D656C8B5E121752FC0F8AB120@AT5PR8401MB1169.NAMPRD84.PROD.OUTLOOK.COM>
References: <153702858249.1603922.12913911825267831671.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180917161245.c4bb8546d2c6069b0506c5dd@linux-foundation.org>
 <CAGXu5jLRuWOMPTfXAFFiVSb6CUKaa_TD4gncef+MT84pcazW6w@mail.gmail.com>
In-Reply-To: <CAGXu5jLRuWOMPTfXAFFiVSb6CUKaa_TD4gncef+MT84pcazW6w@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>, "Hocko, Michal" <MHocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Kani, Toshi" <toshi.kani@hpe.com>

DQo+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+IEZyb206IGxpbnV4LWtlcm5lbC1vd25l
ckB2Z2VyLmtlcm5lbC5vcmcgPGxpbnV4LWtlcm5lbC0NCj4gb3duZXJAdmdlci5rZXJuZWwub3Jn
PiBPbiBCZWhhbGYgT2YgS2VlcyBDb29rDQo+IFNlbnQ6IEZyaWRheSwgU2VwdGVtYmVyIDIxLCAy
MDE4IDI6MTMgUE0NCj4gU3ViamVjdDogUmU6IFtQQVRDSCAwLzNdIG1tOiBSYW5kb21pemUgZnJl
ZSBtZW1vcnkNCi4uLg0KPiBJJ2QgYmUgY3VyaW91cyB0byBoZWFyIG1vcmUgYWJvdXQgdGhlIG1l
bnRpb25lZCBjYWNoZSBwZXJmb3JtYW5jZQ0KPiBpbXByb3ZlbWVudHMuIEkgbG92ZSBpdCB3aGVu
IGEgc2VjdXJpdHkgZmVhdHVyZSBhY3R1YWxseSBfaW1wcm92ZXNfDQo+IHBlcmZvcm1hbmNlLiA6
KQ0KDQpJdCdzIGJlZW4gYSBwcm9ibGVtIGluIHRoZSBIUEMgc3BhY2U6DQpodHRwOi8vd3d3Lm5l
cnNjLmdvdi9yZXNlYXJjaC1hbmQtZGV2ZWxvcG1lbnQva25sLWNhY2hlLW1vZGUtcGVyZm9ybWFu
Y2UtY29lLw0KDQpBIGtlcm5lbCBtb2R1bGUgY2FsbGVkIHpvbmVzb3J0IGlzIGF2YWlsYWJsZSB0
byB0cnkgdG8gaGVscDoNCmh0dHBzOi8vc29mdHdhcmUuaW50ZWwuY29tL2VuLXVzL2FydGljbGVz
L3hlb24tcGhpLXNvZnR3YXJlDQoNCmFuZCB0aGlzIGFiYW5kb25lZCBwYXRjaCBzZXJpZXMgcHJv
cG9zZWQgdGhhdCBmb3IgdGhlIGtlcm5lbDoNCmh0dHBzOi8vbGttbC5vcmcvbGttbC8yMDE3Lzgv
MjMvMTk1DQoNCkRhbidzIHBhdGNoIHNlcmllcyBkb2Vzbid0IGF0dGVtcHQgdG8gZW5zdXJlIGJ1
ZmZlcnMgd29uJ3QgY29uZmxpY3QsIGJ1dA0KYWxzbyByZWR1Y2VzIHRoZSBjaGFuY2UgdGhhdCB0
aGUgYnVmZmVycyB3aWxsLiBUaGlzIHdpbGwgbWFrZSBwZXJmb3JtYW5jZQ0KbW9yZSBjb25zaXN0
ZW50LCBhbGJlaXQgc2xvd2VyIHRoYW4gIm9wdGltYWwiICh3aGljaCBpcyBuZWFyIGltcG9zc2li
bGUNCnRvIGF0dGFpbiBpbiBhIGdlbmVyYWwtcHVycG9zZSBrZXJuZWwpLiAgVGhhdCdzIGJldHRl
ciB0aGFuIGZvcmNpbmcNCnVzZXJzIHRvIGRlcGxveSByZW1lZGllcyBsaWtlOg0KICAgICJUbyBl
bGltaW5hdGUgdGhpcyBncmFkdWFsIGRlZ3JhZGF0aW9uLCB3ZSBoYXZlIGFkZGVkIGEgU3RyZWFt
DQogICAgIG1lYXN1cmVtZW50IHRvIHRoZSBOb2RlIEhlYWx0aCBDaGVjayB0aGF0IGZvbGxvd3Mg
ZWFjaCBqb2I7DQogICAgIG5vZGVzIGFyZSByZWJvb3RlZCB3aGVuZXZlciB0aGVpciBtZWFzdXJl
ZCBtZW1vcnkgYmFuZHdpZHRoDQogICAgIGZhbGxzIGJlbG93IDMwMCBHQi9zLiINCg0KLS0tDQpS
b2JlcnQgRWxsaW90dCwgSFBFIFBlcnNpc3RlbnQgTWVtb3J5DQoNCg0K
