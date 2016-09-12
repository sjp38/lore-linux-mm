Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9CDC56B0038
	for <linux-mm@kvack.org>; Sun, 11 Sep 2016 23:45:01 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g202so336073080pfb.3
        for <linux-mm@kvack.org>; Sun, 11 Sep 2016 20:45:01 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id t4si19289494pfd.97.2016.09.11.20.45.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 11 Sep 2016 20:45:00 -0700 (PDT)
From: "Rudoff, Andy" <andy.rudoff@intel.com>
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in
 /proc/self/smaps)
Date: Mon, 12 Sep 2016 03:44:59 +0000
Message-ID: <E987E30D-5C68-420C-B68D-7E0AAA7F2303@intel.com>
References: <CAPcyv4iDra+mRqEejfGqapKEAFZmUtUcg0dsJ8nt7mOhcT-Qpw@mail.gmail.com>
 <20160908225636.GB15167@linux.intel.com>
 <CAPcyv4h5y4MHdXtdrdPRtG7L0_KCoxf_xwDGnHQ2r5yZoqkFzQ@mail.gmail.com>
 <5d5ef209-e005-12c6-9b34-1fdd21e1e6e2@linux.intel.com>
In-Reply-To: <5d5ef209-e005-12c6-9b34-1fdd21e1e6e2@linux.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <76885E75BDC24242BEF18F4F486DC627@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <guangrong.xiao@linux.intel.com>, "Williams, Dan J" <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "Hansen, Dave" <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Gleb Natapov <gleb@kernel.org>, "mtosatti@redhat.com" <mtosatti@redhat.com>, KVM list <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Hajnoczi <stefanha@redhat.com>, Yumei Huang <yuhuang@redhat.com>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

PldoZXRoZXIgbXN5bmMvZnN5bmMgY2FuIG1ha2UgZGF0YSBwZXJzaXN0ZW50IGRlcGVuZHMgb24g
QURSIGZlYXR1cmUgb24NCj5tZW1vcnkgY29udHJvbGxlciwgaWYgaXQgZXhpc3RzIGV2ZXJ5dGhp
bmcgd29ya3Mgd2VsbCwgb3RoZXJ3aXNlLCB3ZSBuZWVkDQo+dG8gaGF2ZSBhbm90aGVyIGludGVy
ZmFjZSB0aGF0IGlzIHdoeSAnRmx1c2ggaGludCB0YWJsZScgaW4gQUNQSSBjb21lcw0KPmluLiAn
Rmx1c2ggaGludCB0YWJsZScgaXMgcGFydGljdWxhcmx5IHVzZWZ1bCBmb3IgbnZkaW1tIHZpcnR1
YWxpemF0aW9uIGlmDQo+d2UgdXNlIG5vcm1hbCBtZW1vcnkgdG8gZW11bGF0ZSBudmRpbW0gd2l0
aCBkYXRhIHBlcnNpc3RlbnQgY2hhcmFjdGVyaXN0aWMNCj4odGhlIGRhdGEgd2lsbCBiZSBmbHVz
aGVkIHRvIGEgcGVyc2lzdGVudCBzdG9yYWdlLCBlLmcsIGRpc2spLg0KPg0KPkRvZXMgY3VycmVu
dCBQTUVNIHByb2dyYW1taW5nIG1vZGVsIGZ1bGx5IHN1cHBvcnRzICdGbHVzaCBoaW50IHRhYmxl
Jz8gSXMNCj51c2Vyc3BhY2UgYWxsb3dlZCB0byB1c2UgdGhlc2UgYWRkcmVzc2VzPw0KDQpUaGUg
Rmx1c2ggaGludCB0YWJsZSBpcyBOT1QgYSByZXBsYWNlbWVudCBmb3IgQURSLiAgVG8gc3VwcG9y
dCBwbWVtIG9uDQp0aGUgeDg2IGFyY2hpdGVjdHVyZSwgdGhlIHBsYXRmb3JtIGlzIHJlcXVpcmVk
IHRvIGVuc3VyZSB0aGF0IGEgcG1lbQ0Kc3RvcmUgZmx1c2hlZCBmcm9tIHRoZSBDUFUgY2FjaGVz
IGlzIGluIHRoZSBwZXJzaXN0ZW50IGRvbWFpbiBzbyB0aGF0IHRoZQ0KYXBwbGljYXRpb24gbmVl
ZCBub3QgdGFrZSBhbnkgYWRkaXRpb25hbCBzdGVwcyB0byBtYWtlIGl0IHBlcnNpc3RlbnQuDQpU
aGUgbW9zdCBjb21tb24gd2F5IHRvIGRvIHRoaXMgaXMgdGhlIEFEUiBmZWF0dXJlLg0KDQpJZiB0
aGUgYWJvdmUgaXMgbm90IHRydWUsIHRoZW4geW91ciB4ODYgcGxhdGZvcm0gZG9lcyBub3Qgc3Vw
cG9ydCBwbWVtLg0KDQpGbHVzaCBoaW50cyBhcmUgZm9yIHVzZSBieSB0aGUgQklPUyBhbmQgZHJp
dmVycyBhbmQgYXJlIG5vdCBpbnRlbmRlZCB0bw0KYmUgdXNlZCBpbiB1c2VyIHNwYWNlLiAgRmx1
c2ggaGludHMgcHJvdmlkZSB0d28gdGhpbmdzOg0KDQpGaXJzdCwgaWYgYSBkcml2ZXIgbmVlZHMg
dG8gd3JpdGUgdG8gY29tbWFuZCByZWdpc3RlcnMgb3IgbW92YWJsZSB3aW5kb3dzDQpvbiBhIERJ
TU0sIHRoZSBGbHVzaCBoaW50IChpZiBwcm92aWRlZCBpbiB0aGUgTkZJVCkgaXMgcmVxdWlyZWQg
dG8gZmx1c2gNCnRoZSBjb21tYW5kIHRvIHRoZSBESU1NIG9yIGVuc3VyZSBzdG9yZXMgZG9uZSB0
aHJvdWdoIHRoZSBtb3ZhYmxlIHdpbmRvdw0KYXJlIGNvbXBsZXRlIGJlZm9yZSBtb3ZpbmcgaXQg
c29tZXdoZXJlIGVsc2UuDQoNClNlY29uZCwgZm9yIHRoZSByYXJlIGNhc2Ugd2hlcmUgdGhlIGtl
cm5lbCB3YW50cyB0byBmbHVzaCBzdG9yZXMgdG8gdGhlDQpzbWFsbGVzdCBwb3NzaWJsZSBmYWls
dXJlIGRvbWFpbiAoaS5lLiB0byB0aGUgRElNTSBldmVuIHRob3VnaCBBRFIgd2lsbA0KaGFuZGxl
IGZsdXNoaW5nIGl0IGZyb20gYSBsYXJnZXIgZG9tYWluKSwgdGhlIGZsdXNoIGhpbnRzIHByb3Zp
ZGUgYSB3YXkNCnRvIGRvIHRoaXMuICBUaGlzIG1pZ2h0IGJlIHVzZWZ1bCBmb3IgdGhpbmdzIGxp
a2UgZmlsZSBzeXN0ZW0gam91cm5hbHMgdG8NCmhlbHAgZW5zdXJlIHRoZSBmaWxlIHN5c3RlbSBp
cyBjb25zaXN0ZW50IGV2ZW4gaW4gdGhlIGZhY2Ugb2YgQURSIGZhaWx1cmUuDQoNCi1hbmR5DQoN
Cg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
