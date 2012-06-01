Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 5A0556B004D
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 09:17:20 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so3695952obb.14
        for <linux-mm@kvack.org>; Fri, 01 Jun 2012 06:17:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1205311422440.2764@chino.kir.corp.google.com>
References: <20120523203433.340661918@linux.com>
	<20120523203507.324764286@linux.com>
	<alpine.DEB.2.00.1205311422440.2764@chino.kir.corp.google.com>
Date: Fri, 1 Jun 2012 22:17:19 +0900
Message-ID: <CAAmzW4OTaNCsBasttuk9uJ0xMKAgyWHCEkvR3S-oGrUsMzjHVQ@mail.gmail.com>
Subject: Re: Common 04/22] [slab] Use page struct fields instead of casting
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>

Pj4gSW5kZXg6IGxpbnV4LTIuNi9pbmNsdWRlL2xpbnV4L21tX3R5cGVzLmgKPj4gPT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PQo+PiAtLS0gbGludXgtMi42Lm9yaWcvaW5jbHVkZS9saW51eC9tbV90eXBlcy5oIKAgMjAxMi0w
NS0yMiAwOTowNTo0OS43MTY0NjQwMjUgLTA1MDAKPj4gKysrIGxpbnV4LTIuNi9pbmNsdWRlL2xp
bnV4L21tX3R5cGVzLmggoCCgIKAgoDIwMTItMDUtMjIgMDk6MjE6MjguNTMyNDQ0NTcyIC0wNTAw
Cj4+IEBAIC05MCw2ICs5MCwxMCBAQCBzdHJ1Y3QgcGFnZSB7Cj4+IKAgoCCgIKAgoCCgIKAgoCCg
IKAgoCCgIKAgoCCgIGF0b21pY190IF9jb3VudDsgoCCgIKAgoCCgIKAgoCCgLyogVXNhZ2UgY291
bnQsIHNlZSBiZWxvdy4gKi8KPj4goCCgIKAgoCCgIKAgoCCgIKAgoCCgIH07Cj4+IKAgoCCgIKAg
oCCgIKAgfTsKPj4gKyCgIKAgoCCgIKAgoCBzdHJ1Y3QgeyCgIKAgoCCgIKAgoCCgIKAvKiBTTEFC
ICovCj4+ICsgoCCgIKAgoCCgIKAgoCCgIKAgoCBzdHJ1Y3Qga21lbV9jYWNoZSAqc2xhYl9jYWNo
ZTsKPj4gKyCgIKAgoCCgIKAgoCCgIKAgoCCgIHN0cnVjdCBzbGFiICpzbGFiX3BhZ2U7Cj4+ICsg
oCCgIKAgoCCgIKAgfTsKPj4goCCgIKAgfTsKPj4KPj4goCCgIKAgLyogVGhpcmQgZG91YmxlIHdv
cmQgYmxvY2sgKi8KPgo+IFRoZSBscnUgZmllbGRzIGFyZSBpbiB0aGUgdGhpcmQgZG91YmxlIHdv
cmQgYmxvY2suCgpZZXMuClRoaXMgcGF0Y2ggaXMgZGlmZmVyZW50IHdpdGggIkNvbW1vbiBmdW5j
dGlvbmFsaXR5IFYyIC0gWzIvMTJdIiB3aGljaCBJIHJldmlldy4KSSB0aGluayBmaXggaXMgbmVl
ZGVkLgo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
