Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id D71A46B0038
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 00:23:04 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so42180448pdb.1
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 21:23:04 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id vn7si989978pbc.27.2015.03.31.21.23.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 31 Mar 2015 21:23:04 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t314N0BU014786
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Wed, 1 Apr 2015 13:23:00 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 3/3] mm: hugetlb: cleanup using PageHugeActive flag
Date: Wed, 1 Apr 2015 03:27:38 +0000
Message-ID: <20150401032733.GA16407@hori1.linux.bs1.fc.nec.co.jp>
References: <1427791840-11247-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1427791840-11247-4-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20150331140814.b939a57340cb1d3bf6b32c9d@linux-foundation.org>
In-Reply-To: <20150331140814.b939a57340cb1d3bf6b32c9d@linux-foundation.org>
Content-Language: ja-JP
Content-Type: multipart/mixed;
	boundary="_002_20150401032733GA16407hori1linuxbs1fcneccojp_"
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

--_002_20150401032733GA16407hori1linuxbs1fcneccojp_
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable


--_002_20150401032733GA16407hori1linuxbs1fcneccojp_
Content-Type: text/plain; name="ATT00001.txt"
Content-Description: ATT00001.txt
Content-Disposition: attachment; filename="ATT00001.txt"; size=531;
	creation-date="Wed, 01 Apr 2015 03:27:38 GMT";
	modification-date="Wed, 01 Apr 2015 03:27:38 GMT"
Content-ID: <BF38411DCC452645A09A85A66E138AD7@gisp.nec.co.jp>
Content-Transfer-Encoding: base64

T24gVHVlLCBNYXIgMzEsIDIwMTUgYXQgMDI6MDg6MTRQTSAtMDcwMCwgQW5kcmV3IE1vcnRvbiB3
cm90ZToNCj4gT24gVHVlLCAzMSBNYXIgMjAxNSAwODo1MDo0NiArMDAwMCBOYW95YSBIb3JpZ3Vj
aGkgPG4taG9yaWd1Y2hpQGFoLmpwLm5lYy5jb20+IHdyb3RlOg0KPiANCj4gPiBOb3cgd2UgaGF2
ZSBhbiBlYXN5IGFjY2VzcyB0byBodWdlcGFnZXMnIGFjdGl2ZW5lc3MsIHNvIGV4aXN0aW5nIGhl
bHBlcnMgdG8NCj4gPiBnZXQgdGhlIGluZm9ybWF0aW9uIGNhbiBiZSBjbGVhbmVkIHVwLg0KPiAN
Cj4gU2ltaWxhcmx5LiAgQWxzbyBJIGFkYXB0ZWQgdGhlIGNvZGUgdG8gZml0IGluIHdpdGgNCj4g
aHR0cDovL296bGFicy5vcmcvfmFrcG0vbW1vdHMvYnJva2VuLW91dC9tbS1jb25zb2xpZGF0ZS1h
bGwtcGFnZS1mbGFncy1oZWxwZXJzLWluLWxpbnV4LXBhZ2UtZmxhZ3NoLnBhdGNoDQoNClRoYW5r
cywgbW92aW5nIHRoZSBkZWNsYXJhdGlvbi9kZWZpbml0aW9uIHRvIGluY2x1ZGUvbGludXgvcGFn
ZS1mbGFncy5oIGlzIE9LLg0K

--_002_20150401032733GA16407hori1linuxbs1fcneccojp_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
