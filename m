From: Dave McCracken <dave.mccracken@oracle.com>
Subject: Re: [PATCH 4/5] hugetlb: Try to grow hugetlb pool for MAP_SHARED mappings
Date: Thu, 13 Sep 2007 17:24:48 -0500
References: <20070913175855.27074.27030.stgit@kernel> <20070913175940.27074.34082.stgit@kernel>
In-Reply-To: <20070913175940.27074.34082.stgit@kernel>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: base64
Content-Disposition: inline
Message-Id: <200709131724.48818.dave.mccracken@oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, libhugetlbfs-devel@lists.sourceforge.net, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@skynet.ie>, Bill Irwin <bill.irwin@oracle.com>, Ken Chen <kenchen@google.com>
List-ID: <linux-mm.kvack.org>

T24gVGh1cnNkYXkgMTMgU2VwdGVtYmVyIDIwMDcsIEFkYW0gTGl0a2Ugd3JvdGU6Cj4gK3N0YXRp
YyBpbnQgZ2F0aGVyX3N1cnBsdXNfcGFnZXMoaW50IGRlbHRhKQo+ICt7Cj4gK8KgwqDCoMKgwqDC
oMKgc3RydWN0IGxpc3RfaGVhZCBzdXJwbHVzX2xpc3Q7Cj4gK8KgwqDCoMKgwqDCoMKgc3RydWN0
IHBhZ2UgKnBhZ2UsICp0bXA7Cj4gK8KgwqDCoMKgwqDCoMKgaW50IHJldCwgaTsKPiArwqDCoMKg
wqDCoMKgwqBpbnQgbmVlZGVkLCBhbGxvY2F0ZWQ7Cj4gKwo+ICvCoMKgwqDCoMKgwqDCoG5lZWRl
ZCA9IChyZXN2X2h1Z2VfcGFnZXMgKyBkZWx0YSkgLSBmcmVlX2h1Z2VfcGFnZXM7Cj4gK8KgwqDC
oMKgwqDCoMKgaWYgKCFuZWVkZWQpCj4gK8KgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoHJl
dHVybiAwOwoKSXQgbG9va3MgaGVyZSBsaWtlIG5lZWRlZCBjYW4gYmUgbGVzcyB0aGFuIHplcm8u
ICBEbyB3ZSByZWFsbHkgaW50ZW5kIHRvIApjb250aW51ZSB3aXRoIHRoZSBmdW5jdGlvbiBpZiB0
aGF0J3MgdHJ1ZT8gIE9yIHNob3VsZCB0aGF0IHRlc3QgcmVhbGx5IGJlICJpZiAKKG5lZWRlZCA8
PSAwKSI/CgpEYXZlCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
