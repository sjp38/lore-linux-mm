Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 08E036B0031
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 04:18:24 -0400 (EDT)
Date: Mon, 09 Sep 2013 16:18:22 +0800 
Reply-To: dhillf@sina.com
From: "Hillf Danton" <dhillf@sina.com>
Subject: [patch] filemap: add missing unlock_page
MIME-Version: 1.0
Content-Type: text/plain; charset=GBK
Content-Transfer-Encoding: base64
Message-Id: <20130909081822.8D4DF428001@webmail.sinamail.sina.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Hillf Danton <dhillf@gmail.com>, Hillf Danton <dhillf@sina.com>


VW5sb2NrIGFuZCByZWxlYXNlIHBhZ2UgYmVmb3JlIHJldHVybmluZyBlcnJvci4NCg0KU2lnbmVk
LW9mZi1ieTogSGlsbGYgRGFudG9uIDxkaGlsbGZAZ21haWwuY29tPg0KLS0tDQoNCi0tLSBhL21t
L2ZpbGVtYXAuYwlNb24gU2VwICA5IDE1OjUxOjI4IDIwMTMNCisrKyBiL21tL2ZpbGVtYXAuYwlN
b24gU2VwICA5IDE1OjUyOjU0IDIwMTMNCkBAIC0xODQ0LDYgKzE4NDQsNyBAQCByZXRyeToNCiAJ
fQ0KIAllcnIgPSBmaWxsZXIoZGF0YSwgcGFnZSk7DQogCWlmIChlcnIgPCAwKSB7DQorCQl1bmxv
Y2tfcGFnZShwYWdlKTsNCiAJCXBhZ2VfY2FjaGVfcmVsZWFzZShwYWdlKTsNCiAJCXJldHVybiBF
UlJfUFRSKGVycik7DQogCX0NCi0t

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
