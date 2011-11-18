Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 596BC6B0069
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 09:47:03 -0500 (EST)
Received: by eye4 with SMTP id 4so4449677eye.14
        for <linux-mm@kvack.org>; Fri, 18 Nov 2011 06:47:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAONaPpHybQL38PSq-hux5X44zuHDCQg=8L1fb+geWv00ktQq7g@mail.gmail.com>
References: <CAJd=RBC+p8033bHNfP=WQ2SU1Y1zRpj+FEi9FdjuFKkjF_=_iA@mail.gmail.com>
	<CAONaPpGQdpNDT9EuTq_xian+bRFDUsLn7AgjtG-=y0C6-9fDTQ@mail.gmail.com>
	<CAONaPpHybQL38PSq-hux5X44zuHDCQg=8L1fb+geWv00ktQq7g@mail.gmail.com>
Date: Fri, 18 Nov 2011 22:46:59 +0800
Message-ID: <CAJd=RBAxq4knDnehEXEy+yWYRwXp5ukwkNvgssKPLr+HrgUnPg@mail.gmail.com>
Subject: Re: [PATCH] hugetlb: detect race if fail to COW
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Kacur <jkacur@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

T24gRnJpLCBOb3YgMTgsIDIwMTEgYXQgMTA6MjEgUE0sIEpvaG4gS2FjdXIgPGprYWN1ckByZWRo
YXQuY29tPiB3cm90ZToKPiBPbiBGcmksIE5vdiAxOCwgMjAxMSBhdCAzOjE2IFBNLCBKb2huIEth
Y3VyIDxqa2FjdXJAcmVkaGF0LmNvbT4gd3JvdGU6Cj4+IE9uIEZyaSwgTm92IDE4LCAyMDExIGF0
IDM6MDQgUE0sIEhpbGxmIERhbnRvbiA8ZGhpbGxmQGdtYWlsLmNvbT4gd3JvdGU6Cj4+PiBJbiB0
aGUgZXJyb3IgcGF0aCB0aGF0IHdlIGZhaWwgdG8gYWxsb2NhdGUgbmV3IGh1Z2UgcGFnZSwgYmVm
b3JlIHRyeSBhZ2Fpbiwgd2UKPj4+IGhhdmUgdG8gY2hlY2sgcmFjZSBzaW5jZSBwYWdlX3RhYmxl
X2xvY2sgaXMgcmUtYWNxdWlyZWQuCj4+Pgo+Pj4gSWYgcmFjaW5nLCBvdXIgam9iIGlzIGRvbmUu
Cj4+Pgo+Pj4gU2lnbmVkLW9mZi1ieTogSGlsbGYgRGFudG9uIDxkaGlsbGZAZ21haWwuY29tPgo+
Pj4gLS0tCj4+Pgo+Pj4gLS0tIGEvbW0vaHVnZXRsYi5jIMKgIMKgIMKgRnJpIE5vdiAxOCAyMToz
ODozMCAyMDExCj4+PiArKysgYi9tbS9odWdldGxiLmMgwqAgwqAgwqBGcmkgTm92IDE4IDIxOjQ4
OjE1IDIwMTEKPj4+IEBAIC0yNDA3LDcgKzI0MDcsMTQgQEAgcmV0cnlfYXZvaWRjb3B5Ogo+Pj4g
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqBCVUdfT04ocGFn
ZV9jb3VudChvbGRfcGFnZSkgIT0gMSk7Cj4+PiDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoEJVR19PTihodWdlX3B0ZV9ub25lKHB0ZSkpOwo+Pj4gwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqBzcGluX2xvY2soJm1tLT5w
YWdlX3RhYmxlX2xvY2spOwo+Pj4gLSDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCBnb3RvIHJldHJ5X2F2b2lkY29weTsKPj4+ICsgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgcHRlcCA9IGh1Z2VfcHRlX29mZnNldChtbSwgYWRk
cmVzcyAmIGh1Z2VfcGFnZV9tYXNrKGgpKTsKPj4+ICsgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgaWYgKGxpa2VseShwdGVfc2FtZShodWdlX3B0ZXBfZ2V0KHB0
ZXApLCBwdGUpKSkKPj4+ICsgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgZ290byByZXRyeV9hdm9pZGNvcHk7Cj4+PiArIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIC8qCj4+PiArIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgKiByYWNlIG9jY3VycyB3aGlsZSByZS1h
Y3F1aXJpbmcgcGFnZV90YWJsZV9sb2NrLCBhbmQKPj4+ICsgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAqIG91ciBqb2IgaXMgZG9uZS4KPj4+ICsgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAqLwo+Pj4gKyDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCByZXR1cm4gMDsKPj4+IMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgfQo+Pj4gwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqBXQVJOX09OX09OQ0UoMSk7Cj4+PiDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oH0KPj4KPj4KPj4gSSdtIG5vdCBzdXJlIGFib3V0IHRoZSB2ZXJhY2l0eSBvZiB0aGUgcmFjZSBj
b25kaXRpb24sIGJ1dCB5b3UgYmV0dGVyCj4+IGRvIHNwaW5fdW5sb2NrIGJlZm9yZSB5b3UgcmV0
dXJuLgo+Pgo+Cj4gVWdoLCBzb3JyeSBmb3IgdGhlIG5vaXNlLCBJIHNlZSB0aGF0J3Mgbm90IGhv
dyBpdCB3b3JrcyBoZXJlLgoKV2VsY29tZTopCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
