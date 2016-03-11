Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id F06E26B0253
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 18:02:14 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id td3so83227862pab.2
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 15:02:14 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id rz3si16757906pab.115.2016.03.11.15.02.13
        for <linux-mm@kvack.org>;
        Fri, 11 Mar 2016 15:02:14 -0800 (PST)
From: "Rudoff, Andy" <andy.rudoff@intel.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
Date: Fri, 11 Mar 2016 23:02:12 +0000
Message-ID: <48BBDA71-0AD3-41A1-ACB0-DDB5E35F3FF0@intel.com>
References: <56C9EDCF.8010007@plexistor.com> <56E26940.8020203@kernel.org>
 <CAPcyv4hOrVWTgcGp8RnouroSdDpoc8Bnzt6pUY2jA57hLN3QNQ@mail.gmail.com>
 <CALCETrX-xkwM26Aut7HRs0Pe4iPyRQmDHrnsfGAC0NkFKxOGCA@mail.gmail.com>
In-Reply-To: <CALCETrX-xkwM26Aut7HRs0Pe4iPyRQmDHrnsfGAC0NkFKxOGCA@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <3872C4C84633DA4FB541340275574734@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, "Williams, Dan J" <dan.j.williams@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Dave Chinner <david@fromorbit.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

DQo+Pg0KPj4gVGhlIG1peGVkIG1hcHBpbmcgcHJvYmxlbSBpcyBtYWRlIHNsaWdodGx5IG1vcmUg
ZGlmZmljdWx0IGJ5IHRoZSBmYWN0DQo+PiB0aGF0IHdlIGFkZCBwZXJzaXN0ZW50IG1lbW9yeSB0
byB0aGUgZGlyZWN0LW1hcCB3aGVuIGFsbG9jYXRpbmcgc3RydWN0DQo+PiBwYWdlLCBidXQgcHJv
YmFibHkgbm90IGluc3VybW91bnRhYmxlLiAgQWxzbywgdGhpcyBzdGlsbCBoYXMgdGhlDQo+PiBz
eXNjYWxsIG92ZXJoZWFkIHRoYXQgYSBNQVBfU1lOQyBzZW1hbnRpYyBlbGltaW5hdGVzLCBidXQg
d2UgbmVlZCB0bw0KPj4gY29sbGVjdCBudW1iZXJzIHRvIHNlZSBpZiB0aGF0IG1hdHRlcnMuDQo+
Pg0KPj4gSG93ZXZlciwgY2hhdHRpbmcgd2l0aCBBbmR5IFIuIGFib3V0IHRoZSBOVk1MIHVzZSBj
YXNlLCB0aGUgbGlicmFyeQ0KPj4gYWx0ZXJuYXRlcyBiZXR3ZWVuIHN0cmVhbWluZyBub24tdGVt
cG9yYWwgd3JpdGVzIGFuZCBieXRlLWFjY2Vzc2VzICsNCj4+IGNsd2IoKS4gIFRoZSBieXRlIGFj
Y2Vzc2VzIGdldCBzbG93ZXIgd2l0aCBhIHdyaXRlLXRocm91Z2ggbWFwcGluZy4NCj4+IFNvLCBw
ZXJmb3JtYW5jZSBkYXRhIGlzIG5lZWRlZCBhbGwgYXJvdW5kIHRvIHNlZSB3aGVyZSB0aGVzZSBv
cHRpb25zDQo+PiBsYW5kLg0KPg0KPldoZW4geW91IHNheSAgImJ5dGUtYWNjZXNzICsgY2x3Yigp
IiwgZG8geW91IG1lYW4gbGl0ZXJhbGx5IHdyaXRlIGENCj5ieXRlLCBjbHdiLCB3cml0ZSBhIGJ5
dGUsIGNsd2IuLi4gb3IgZG8geW91IG1lYW4gbG90cyBvZiBieXRlIGFjY2Vzc2VzDQo+YW5kIHRo
ZW4gb25lIGNsd2I/ICBJZiB0aGUgZm9ybWVyLCBJIHN1c3BlY3QgaXQgY291bGQgYmUgY2hhbmdl
ZCB0bw0KPm5vbi10ZW1wb3JhbCBzdG9yZSArIHNmZW5jZSBhbmQgYmUgZmFzdGVyLg0KDQpUeXBp
Y2FsbHkgYSBtaXh0dXJlLiAgVGhhdCBpcywgdGhlcmUgYXJlIHRpbWVzIHdoZXJlIHdlIHN0b3Jl
IGEgcG9pbnRlcg0KYW5kIGZvbGxvdyBpdCBpbW1lZGlhdGVseSB3aXRoIENMV0IsIGFuZCB0aGVy
ZSBhcmUgdGltZXMgd2hlcmUgd2UgZG8NCmxvdHMgb2Ygd29yayBhbmQgdGhlbiBkZWNpZGUgdG8g
Y29tbWl0IHdoYXQgd2UndmUgZG9uZSBieSBydW5uaW5nIG92ZXINCmEgcmFuZ2UgZG9pbmcgQ0xX
Qi4gIEluIG91ciBsaWJyYXJpZXMsIE5UIHN0b3JlcyBhcmUgZWFzeSB0byB1c2UgYmVjYXVzZQ0K
d2UgY29udHJvbCB0aGUgY29kZS4gIEJ1dCBvbmUgb2YgdGhlIGJlbmVmaXRzIG9mIHBtZW0gaXMg
dGhhdCBhcHBsaWNhdGlvbnMNCmNhbiBhY2Nlc3MgZGF0YSBzdHJ1Y3R1cmVzIGluLXBsYWNlLCB3
aXRob3V0IGNhbGxpbmcgdGhyb3VnaCBBUElzIGZvcg0KZXZlcnkgcG9pbnRlciBkZS1yZWZlcmVu
Y2UsIHNvIGl0IGdldHMgc29ydCBvZiBpbXByYWN0aWNhbCB0byByZXF1aXJlDQpOVCBzdG9yZXMu
ICBJbWFnaW5lLCBmb3IgZXhhbXBsZSwgYXMgcGFydCBvZiBhbiB1cGRhdGUgdG8gcG1lbSB5b3Ug
d2FudA0KdG8gc3RyY3B5KCkgb3Igc3ByaW50ZigpIG9yIHNvbWUgb3RoZXIgZnVuY3Rpb24geW91
IGRpZG4ndCB3cml0ZS4gIEZvbGxvd2luZw0KdGhhdCB3aXRoIGEgY2FsbCB0byBhIGNvbW1pdCBB
UEkgdGhhdCBmbHVzaGVzIHRoaW5ncyBpcyBlYXNpZXIgb24gdGhlDQphcHAgZGV2ZWxvcGVyIHRo
YW4gcmVxdWlyaW5nIHRoZW0gdG8gaGF2ZSBOVCBzdG9yZSB2ZXJzaW9ucyBvZiBhbGwgdGhvc2UN
CnJvdXRpbmVzLg0KDQo+TXkgdW5kZXJzdGFuZGluZyBpcyB0aGF0IG5vbi10ZW1wb3JhbCBzdG9y
ZSArIHNmZW5jZSBkb2Vzbid0IHBvcHVsYXRlDQo+dGhlIGNhY2hlLCB0aG91Z2gsIHdoaWNoIGlz
IHVuZm9ydHVuYXRlIGZvciBzb21lIHVzZSBjYXNlcy4NCg0KVGhhdCBtYXRjaGVzIG15IHVuZGVy
c3RhbmRpbmcuDQoNCj5UaGUgcmVhbCBzb2x1dGlvbiB3b3VsZCBiZSBmb3IgSW50ZWwgdG8gYWRk
IGFuIGVmZmljaWVudCBvcGVyYXRpb24gdG8NCj5mb3JjZSB3cml0ZWJhY2sgb24gYSBsYXJnZSBy
ZWdpb24gb2YgcGh5c2ljYWwgcGFnZXMuDQoNClRoaXMgaXMgdW5kZXIgaW52ZXN0aWdhdGlvbiwg
YnV0IHVuZm9ydHVuYXRlbHkgbm90IGF2YWlsYWJsZSBqdXN0IHlldC4uLg0KDQotYW5keQ0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
