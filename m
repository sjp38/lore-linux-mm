Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id BC73D6B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 18:45:00 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so23083594pac.2
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 15:45:00 -0700 (PDT)
Received: from COL004-OMC4S7.hotmail.com (col004-omc4s7.hotmail.com. [65.55.34.209])
        by mx.google.com with ESMTPS id jf11si13943858pbd.111.2015.09.09.15.44.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Sep 2015 15:45:00 -0700 (PDT)
Message-ID: <COL130-W43C0C45AA4E2A7AA6361D0B9520@phx.gbl>
From: Chen Gang <xili_gchen_5257@hotmail.com>
Subject: Re: [PATCH] mm/mmap.c: Remove useless statement "vma = NULL" in
 find_vma()
Date: Thu, 10 Sep 2015 06:44:59 +0800
In-Reply-To: <55F0B6C2.2000706@hotmail.com>
References: <COL130-W64A6555222F8CEDA513171B9560@phx.gbl>
 <COL130-W6916929C85FB1943CC1B11B9530@phx.gbl>
 <20150909162605.GA4373@redhat.com>,<55F0B6C2.2000706@hotmail.com>
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "oleg@redhat.com" <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "pfeiner@google.com" <pfeiner@google.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

Ck9uIDkvMTAvMTUgMDA6MjYsIE9sZWcgTmVzdGVyb3Ygd3JvdGU6Cj4gT24gMDkvMDgsIENoZW4g
R2FuZyB3cm90ZToKPj4KPj4gSSBhbHNvIHdhbnQgdG8gY29uc3VsdDogdGhlIGNvbW1lbnRzIG9m
IGZpbmRfdm1hKCkgc2F5czoKPgo+IFNvcnJ5LCBJIGRvbid0IHVuZGVyc3RhbmQgdGhlIHF1ZXN0
aW9uIDspCj4KPj4gIkxvb2sgdXAgdGhlIGZpcnN0IFZNQSB3aGljaCBzYXRpc2ZpZXMgYWRkciA8
IHZtX2VuZCwgLi4uIgo+Pgo+PiBJcyBpdCBPSz8KPgo+IFdoeSBub3Q/Cj4KCldlIHdpbGwgY29u
dGludWUgZGlzY3VzcyBhYm91dCBpdCBiZWxvdy4gUGxlYXNlIGhlbHAgY2hlY2ssIHRoYW5rcy4K
Cj4+ICh3aHkgbm90ICJ2bV9zdGFydCA8PSBhZGRyIDwgdm1fZW5kIiksCj4KPiBCZWNhdXNlIHRo
aXMgc29tZSBjYWxsZXJzIGFjdHVhbGx5IHdhbnQgdG8gZmluZCB0aGUgMXN0IHZtYSB3aGljaAo+
IHNhdGlzZmllcyBhZGRyIDwgdm1fZW5kPyBGb3IgZXhhbXBsZSwgc2hpZnRfYXJnX3BhZ2VzKCku
Cj4KPiBPVE9ILCBJIHRoaW5rIHRoYXQgYW5vdGhlciBoZWxwZXIsCj4KPiBmaW5kX3ZtYV94eHgo
bW0sIGFkZHIpCj4gewo+IHZtYSA9IGZpbmRfdm1hKC4uLikKPiBpZiAodm1hICYmIHZtYS0+dm1f
c3RhcnQ+IGFkZHIpCj4gdm1hID0gTlVMTDsKPiByZXR1cm4gdm1hOwo+IH0KPgo+IG1ha2VzIHNl
bnNlLiBJdCBjYW4gaGF2ZSBhIGxvdCBvZiB1c2Vycy4KPgoKT0suIHRoYW5rIHlvdSB2ZXJ5IG11
Y2guIDotKQoKPj4gbmVlZCB3ZSBsZXQgInZtYSA9IHRtcCIKPj4gaW4gImlmICh0bXAtPnZtX3N0
YXJ0IDw9IGFkZHIpIj8gLS0gaXQgbG9va3MgdGhlIGNvbW1lbnRzIGlzIG5vdCBtYXRjaAo+PiB0
aGUgaW1wbGVtZW50YXRpb24sIHByZWNpc2VseSAobWF5YmUgbm90IDFzdCBWTUEpLgo+Cj4gVGhp
cyBjb250cmFkaWN0cyB3aXRoIGFib3ZlLi4uIEkgbWVhbiwgaXQgaXMgbm90IGNsZWFyIHdoYXQg
ZXhhY3RseSBkbwo+IHlvdSBibGFtZSwgc2VtYW50aWNzIG9yIGltcGxlbWVudGF0aW9uLgo+Cj4g
VGhlIGltcGxlbWVudGF0aW9uIGxvb2tzIGNvcnJlY3QuIFdoeSBkbyB5b3UgdGhpbmsgaXQgY2Fu
IGJlIG5vdCAxc3Qgdm1hPwo+CgpJdCBpcyBpbiB3aGlsZSAocmJfbm9kZSkgey4uLn0uCgotIFdo
ZW4gd2Ugc2V0ICJ2bWEgPSB0bXAiLCBpdCBpcyBhbHJlYXkgbWF0Y2ggImFkZHIgPCB2bV9lbmQi
LgoKLSBJZiAiYWRkcj49IHZtX3N0YXJ0Iiwgd2UgcmV0dXJuIHRoaXMgdm1hIChlbHNlIGNvbnRp
bnVlIHNlYXJjaGluZykuCgpJZiAidGhlIGZpcnN0IGxlZnQiIGlzIHRoZSByZWFsIGZpcnN0LCB3
aGVuICJhZGRyPj0gdm1fc3RhcnQiLCBpdAp3aWxsIHJldHVybiAobWF5IG5vdCByZXR1cm4gMXN0
IGxlZnQgbWF0Y2hlZCB2bWEpLgoKSWYgInRoZSBmaXJzdCBmaW5kIiBpcyB0aGUgcmVhbCBmaXJz
dCwgd2hlbiAiYWRkciA8IHZtX3N0YXJ0IiwgaXQKd2lsbCBjb250aW51ZSBzZWFyY2hpbmcgKG1h
eSBub3QgcmV0dXJuIDFzdCBmaW5kIG1hdGNoZWQgdm1hKS4KCkZvciBtZSwgaWYgd2Ugb25seSBm
b2N1cyBvbiAiYWRkciA8IHZtX2VuZCIsIHdlIG5lZWQgcmVtb3ZlICJ2bV9zdGFydCA8PQphZGRy
IiBjaGVja2luZykuIElmIHdlIGhhdmUgdG8gY29uc2lkZXIgYWJvdXQgImFkZHI+PSB2bV9zdGFy
dCIsIHdlIG1heQpuZWVkIGFkZGl0aW9uYWwgcGFyYW1ldGVyIG9yIGltcGxlbWVudCBhIG5ldyBm
dW5jdGlvbiBmb3IgaXQuCgoKV2VsY29tZSBhbnkgaWRlYXMsIHN1Z2dlc3Rpb25zIGFuZCBjb21w
bGV0aW9ucy4KCgpUaGFua3MuCi0tCkNoZW4gR2FuZyAos8K41SkKCk9wZW4sIHNoYXJlLCBhbmQg
YXR0aXR1ZGUgbGlrZSBhaXIsIHdhdGVyLCBhbmQgbGlmZSB3aGljaCBHb2QgYmxlc3NlZAogCQkg
CSAgIAkJICA=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
