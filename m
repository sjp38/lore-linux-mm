Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 962EF6B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 23:42:36 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id di3so5059362pab.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 20:42:36 -0700 (PDT)
Received: from smtpbgau1.qq.com (smtpbgau1.qq.com. [54.206.16.166])
        by mx.google.com with ESMTPS id o90si47914609pfa.151.2016.05.31.20.42.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 May 2016 20:42:35 -0700 (PDT)
From: "=?ISO-8859-1?B?V2FuZyBTaGVuZy1IdWk=?=" <shhuiw@foxmail.com>
Subject: Why __alloc_contig_migrate_range calls  migrate_prep() at first?
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-1"
Content-Transfer-Encoding: base64
Date: Wed, 1 Jun 2016 11:42:29 +0800
Message-ID: <tencent_29E1A2CA78CE0C9046C1494E@qq.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?B?YWtwbQ==?= <akpm@linux-foundation.org>, =?ISO-8859-1?B?bWdvcm1hbg==?= <mgorman@techsingularity.net>, =?ISO-8859-1?B?aWFtam9vbnNvby5raW0=?= <iamjoonsoo.kim@lge.com>
Cc: =?ISO-8859-1?B?bGludXgtbW0=?= <linux-mm@kvack.org>

RGVhciwKClNvcnJ5IHRvIHRyb3VibGUgeW91LgoKSSBub3RpY2VkIGNtYV9hbGxvYyB3b3Vs
ZCB0dXJuIHRvICBfX2FsbG9jX2NvbnRpZ19taWdyYXRlX3JhbmdlIGZvciBhbGxvY2F0aW5n
IHBhZ2VzLgpCdXQgIF9fYWxsb2NfY29udGlnX21pZ3JhdGVfcmFuZ2UgY2FsbHMgIG1pZ3Jh
dGVfcHJlcCgpIGF0IGZpcnN0LCBldmVuIGlmIHRoZSByZXF1ZXN0ZWQgcGFnZQppcyBzaW5n
bGUgYW5kIGZyZWUsIGxydV9hZGRfZHJhaW5fYWxsIHN0aWxsIHJ1biAoY2FsbGVkIGJ5ICBt
aWdyYXRlX3ByZXAoKSk/CgpJbWFnZSBhIGxhcmdlIGNodW5rIG9mIGZyZWUgY29udGlnIHBh
Z2VzIGZvciBDTUEsIHZhcmlvdXMgZHJpdmVycyBtYXkgcmVxdWVzdCBhIHNpbmdsZSBwYWdl
IGZyb20KdGhlIENNQSBhcmVhLCB3ZSdsbCBnZXQgIGxydV9hZGRfZHJhaW5fYWxsIHJ1biBm
b3IgZWFjaCBwYWdlLgoKU2hvdWxkIHdlIGRldGVjdCBpZiB0aGUgcmVxdWlyZWQgcGFnZXMg
YXJlIGZyZWUgYmVmb3JlIG1pZ3JhdGVfcHJlcCgpLCBvciBkZXRlY3QgYXQgbGVhc3QgZm9y
IHNpbmdsZSAKcGFnZSBhbGxvY2F0aW9uPwoKLS0tLS0tLS0tLS0tLS0tLS0tClJlZ2FyZHMs
CldhbmcgU2hlbmctSHVp



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
