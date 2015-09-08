Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id BB5B86B0255
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 10:44:54 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so120337213ioi.2
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 07:44:54 -0700 (PDT)
Received: from COL004-OMC2S6.hotmail.com (col004-omc2s6.hotmail.com. [65.55.34.80])
        by mx.google.com with ESMTPS id hm3si5877269pdb.152.2015.09.08.07.44.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 08 Sep 2015 07:44:54 -0700 (PDT)
Message-ID: <COL130-W25EE93C6762646736C6156B9530@phx.gbl>
From: Chen Gang <xili_gchen_5257@hotmail.com>
Subject: Re: [PATCH] mm/mmap.c: Only call vma_unlock_anon_vm() when failure
 occurs in expand_upwards() and expand_downwards()
Date: Tue, 8 Sep 2015 22:44:52 +0800
In-Reply-To: <55EEF4B4.5010205@hotmail.com>
References: <COL130-W9593F65D7C12B5353FE079B96B0@phx.gbl>
 <55E5AD17.6060901@hotmail.com> <COL130-W4895D78CDAEA273AB88C53B96A0@phx.gbl>
 <55E96E01.5010605@hotmail.com> <COL130-W49B21394779B6662272AD0B9570@phx.gbl>
 <55EAC021.3080205@hotmail.com> <COL130-W64DF8D947992A52E4CBE40B9560@phx.gbl>
 <20150907072418.GA6022@dhcp22.suse.cz>,<55EEF4B4.5010205@hotmail.com>
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>, Max Filippov <jcmvbkbc@gmail.com>

T24gOS83LzE1IDE1OjI0LCBNaWNoYWwgSG9ja28gd3JvdGU6Cj4gT24gU2F0IDA1LTA5LTE1IDE4
OjExOjQwLCBDaGVuIEdhbmcgd3JvdGU6Cj4+IEhlbGxvIEFsbDoKPj4KPj4gSSBoYXZlIHNlbmQg
MiBuZXcgcGF0Y2hlcyBhYm91dCBtbSwgYW5kIDEgcGF0Y2ggZm9yIGFyY2ggbWV0YWcgdmlhIG15
Cj4+IDIxY24gbWFpbC4gQ291bGQgYW55IG1lbWJlcnMgaGVscCB0byB0ZWxsIG1lLCB3aGV0aGVy
IGhlL3NoZSBoYXZlCj4+IHJlY2VpdmVkIHRoZSBwYXRjaGVzIG9yIG5vdD8KPgo+IFllcyB0aGV5
IHNlZW0gdG8gYmUgaW4gdGhlIGFyY2hpdmUuCj4gaHR0cDovL2xrbWwua2VybmVsLm9yZy9yL0NP
TDEzMC1XNjRBNjU1NTIyMkY4Q0VEQTUxMzE3MUI5NTYwJTQwcGh4LmdibAo+IGh0dHA6Ly9sa21s
Lmtlcm5lbC5vcmcvci9DT0wxMzAtVzE2Qzk3MkIwNDU3RDVDN0M5Q0IwNkI5NTYwJTQwcGh4Lmdi
bAo+Cj4gWW91IGNhbiBjaGVjayB0aGF0IGVhc2lseSBieSBodHRwOi8vbGttbC5rZXJuZWwub3Jn
L3IvJE1FU1NBR0VfSUQKPgoKVGhhbmsgeW91IHZlcnkgbXVjaCBmb3IgeW91ciByZXBseS4gOi0p
CgoKRXhjdXNlIG1lLCBJIGNhbiBub3Qgb3BlbiBodHRwOi8vbGttbC5rZXJuZWwub3JnL3IvLi4u
LCBidXQgSSBjYW4gb3BlbgpodHRwczovL2xrbWwub3JnL2xrbWwvMjAxNS85LzMgKG9yIGFub3Ro
ZXIgZGF0ZSkuIFVuZGVyIHRoaXMgd2ViIHNpdGUsCkkgY2FuIG5vdCBmaW5kIGFueSBwYXRjaGVz
IHdoaWNoIEkgc2VudCAoSSBzZW50IHRoZW0gaW4gMjAxNS0wOS0wMy8wNCkuCgpJbiAyMDE1LTA5
LTA1LCBhIHFlbXUgbWVtYmVyIHRvbGQgbWUgdG8gY2hlY2sgdGhlIHBhdGNoZXMgb24gd2Vic2l0
ZSwgc28KSSBjb3VsZCBrbm93IG15c2VsZiB3aGV0aGVyIHBhdGNoZXMgYXJlIGFjdHVhbGx5IHNl
bnQgKEkgbWV0IGFsbW9zdCB0aGUKc2FtZSBpc3N1ZSBmb3IgcWVtdSwgc28gSSBjb25zdWx0IHRo
ZW0sIHRvbykuIFNvIGZvdW5kIGh0dHBzOi8vbGttbC5vcmcKClNvIEkgc2VudCBrZXJuZWwgcGF0
Y2hlcyBhZ2FpbiB3aXRoIHRoZSBhdHRhY2htZW50cyB2aWEgbXkgaG90bWFpbCBpbiAyMAoxNS0w
OS0wNS8wNi4gSSBndWVzcywgdGhlIHBhdGNoZXMgeW91IHNhdyBhcmUgc2VudCB2aWEgbXkgaG90
bWFpbCBpbiAyMDEKNS0wOS0wNS8wNi4gUGxlYXNlIGhlbHAgY2hlY2ssIGFnYWluLCB0aGFua3Mu
CgoKVGhhbmtzLgotLQpDaGVuIEdhbmcgKLPCuNUpCgpPcGVuLCBzaGFyZSwgYW5kIGF0dGl0dWRl
IGxpa2UgYWlyLCB3YXRlciwgYW5kIGxpZmUgd2hpY2ggR29kIGJsZXNzZWQKIAkJIAkgICAJCSAg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
