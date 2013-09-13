Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id C43EC6B0031
	for <linux-mm@kvack.org>; Thu, 12 Sep 2013 20:45:40 -0400 (EDT)
Date: Fri, 13 Sep 2013 08:45:38 +0800 
Reply-To: dhillf@sina.com
From: "Hillf Danton" <dhillf@sina.com>
Subject: [RFC PATCH] ANB(Automatic NUMA Balancing): erase mm footprint of migrated page
MIME-Version: 1.0
Content-Type: text/plain; charset=GBK
Content-Transfer-Encoding: base64
Message-Id: <20130913004538.A7AA3428001@webmail.sinamail.sina.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Hillf Danton <dhillf@gmail.com>


SWYgYSBwYWdlIG1vbml0b3JlZCBieSBBTkIgaXMgbWlncmF0ZWQsIGl0cyBmb290cHJpbnQgc2hv
dWxkIGJlIGVyYXNlZCBmcm9tDQpudW1hLWhpbnQtZmF1bHQgYWNjb3VudCwgYmVjYXVzZSBpdCBp
cyBubyBsb25nZXIgdXNlZC4gT3IgdHdvIHBhZ2VzLCB0aGUNCm1pZ3JhdGVkIHBhZ2UgYW5kIGl0
cyB0YXJnZXQgcGFnZSwgYXJlIHVzZWQgaW4gdGhlIHZpZXcgb2YgdGFzayBwbGFjZW1lbnQuDQoN
Cg0KU2lnbmVkLW9mZi1ieTogSGlsbGYgRGFudG9uIDxkaGlsbGZAZ21haWwuY29tPg0KLS0tDQoN
Ci0tLSBhL2tlcm5lbC9zY2hlZC9mYWlyLmMJV2VkIFNlcCAxMSAxODozMzowMCAyMDEzDQorKysg
Yi9rZXJuZWwvc2NoZWQvZmFpci5jCUZyaSBTZXAgMTMgMDg6MjQ6MjQgMjAxMw0KQEAgLTE1NjAs
NiArMTU2MCwyMCBAQCB2b2lkIHRhc2tfbnVtYV9mYXVsdChpbnQgbGFzdF9jcHVwaWQsIGluDQog
CQlwLT5udW1hX3BhZ2VzX21pZ3JhdGVkICs9IHBhZ2VzOw0KIA0KIAlwLT5udW1hX2ZhdWx0c19i
dWZmZXJbdGFza19mYXVsdHNfaWR4KG5vZGUsIHByaXYpXSArPSBwYWdlczsNCisNCisJaWYgKG1p
Z3JhdGVkICYmIGxhc3RfY3B1cGlkICE9ICgtMSAmIExBU1RfQ1BVUElEX01BU0spKSB7DQorCQkv
KiBFcmFzZSBmb290cHJpbnQgb2YgbWlncmF0ZWQgcGFnZSAqLw0KKwkJaW50IGlkeDsNCisNCisJ
CWlkeCA9IGNwdXBpZF90b19jcHUobGFzdF9jcHVwaWQpOw0KKwkJaWR4ID0gY3B1X3RvX25vZGUo
aWR4KTsNCisJCWlkeCA9IHRhc2tfZmF1bHRzX2lkeChpZHgsIHByaXYpOw0KKw0KKwkJaWYgKHAt
Pm51bWFfZmF1bHRzX2J1ZmZlcltpZHhdID49IHBhZ2VzKQ0KKwkJICAgIHAtPm51bWFfZmF1bHRz
X2J1ZmZlcltpZHhdIC09IHBhZ2VzOw0KKwkJZWxzZSBpZiAocC0+bnVtYV9mYXVsdHNfYnVmZmVy
W2lkeF0pDQorCQkJIHAtPm51bWFfZmF1bHRzX2J1ZmZlcltpZHhdID0gMDsNCisJfQ0KIH0NCiAN
CiBzdGF0aWMgdm9pZCByZXNldF9wdGVudW1hX3NjYW4oc3RydWN0IHRhc2tfc3RydWN0ICpwKQ0K
LS0=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
