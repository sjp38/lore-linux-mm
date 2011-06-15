Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C3ECB6B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 20:48:13 -0400 (EDT)
From: H Hartley Sweeten <hartleys@visionengravers.com>
Date: Tue, 14 Jun 2011 19:47:19 -0500
Subject: [Q] mm/memblock.c: cast truncates bits from RED_INACTIVE
Message-ID: <ADE657CA350FB648AAC2C43247A983F001F382220E0F@AUSP01VMBX24.collaborationhost.net>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "yinghai@kernel.org" <yinghai@kernel.org>, "hpa@linux.intel.com" <hpa@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>

SGVsbG8gYWxsLA0KDQpTcGFyc2UgaXMgcmVwb3J0aW5nIGEgY291cGxlIHdhcm5pbmdzIGluIG1t
L21lbWJsb2NrLmM6DQoNCgl3YXJuaW5nOiBjYXN0IHRydW5jYXRlcyBiaXRzIGZyb20gY29uc3Rh
bnQgdmFsdWUgKDlmOTExMDI5ZDc0ZTM1YiBiZWNvbWVzIDlkNzRlMzViKQ0KDQpUaGUgd2Fybmlu
Z3MgYXJlIGR1ZSB0byB0aGUgY2FzdCBvZiBSRURfSU5BQ1RJVkUgaW4gbWVtYmxvY2tfYW5hbHl6
ZSgpOg0KDQoJLyogQ2hlY2sgbWFya2VyIGluIHRoZSB1bnVzZWQgbGFzdCBhcnJheSBlbnRyeSAq
Lw0KCVdBUk5fT04obWVtYmxvY2tfbWVtb3J5X2luaXRfcmVnaW9uc1tJTklUX01FTUJMT0NLX1JF
R0lPTlNdLmJhc2UNCgkJIT0gKHBoeXNfYWRkcl90KVJFRF9JTkFDVElWRSk7DQoJV0FSTl9PTiht
ZW1ibG9ja19yZXNlcnZlZF9pbml0X3JlZ2lvbnNbSU5JVF9NRU1CTE9DS19SRUdJT05TXS5iYXNl
DQoJCSE9IChwaHlzX2FkZHJfdClSRURfSU5BQ1RJVkUpOw0KDQpBbmQgaW4gbWVtYmxvY2tfaW5p
dCgpOg0KDQoJLyogV3JpdGUgYSBtYXJrZXIgaW4gdGhlIHVudXNlZCBsYXN0IGFycmF5IGVudHJ5
ICovDQoJbWVtYmxvY2subWVtb3J5LnJlZ2lvbnNbSU5JVF9NRU1CTE9DS19SRUdJT05TXS5iYXNl
ID0gKHBoeXNfYWRkcl90KVJFRF9JTkFDVElWRTsNCgltZW1ibG9jay5yZXNlcnZlZC5yZWdpb25z
W0lOSVRfTUVNQkxPQ0tfUkVHSU9OU10uYmFzZSA9IChwaHlzX2FkZHJfdClSRURfSU5BQ1RJVkU7
DQoNCkNvdWxkIHRoaXMgY2F1c2UgYW55IHByb2JsZW1zPyAgSWYgbm90LCBpcyB0aGVyZSBhbnl3
YXkgdG8gcXVpZXQgdGhlIHNwYXJzZSBub2lzZT8NCg0KUmVnYXJkcywNCkhhcnRsZXkNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
