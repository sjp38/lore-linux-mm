Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 884D66B0007
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 17:05:29 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id d19so4446249pgn.20
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 14:05:29 -0800 (PST)
Received: from smtp-fw-33001.amazon.com (smtp-fw-33001.amazon.com. [207.171.190.10])
        by mx.google.com with ESMTPS id k62si1335510pgc.388.2018.03.09.14.05.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Mar 2018 14:05:28 -0800 (PST)
From: "Besogonov, Aleksei" <cyberax@amazon.com>
Subject: fallocate on XFS for swap
Date: Fri, 9 Mar 2018 22:05:24 +0000
Message-ID: <8C28C1CB-47F1-48D1-85C9-5373D29EA13E@amazon.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <F0C984197F169E4BBF99BA31819E2A81@amazon.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Dave Chinner <david@fromorbit.com>

SGkhDQoNCldl4oCZcmUgd29ya2luZyBhdCBBbWF6b24gb24gbWFraW5nIFhGUyBvdXIgZGVmYXVs
dCByb290IGZpbGVzeXN0ZW0gZm9yIHRoZSB1cGNvbWluZyBBbWF6b24gTGludXggMiAobm93IGlu
IHByb2QgcHJldmlldykuIE9uZSBvZiB0aGUgcHJvYmxlbXMgdGhhdCB3ZeKAmXZlIGVuY291bnRl
cmVkIGlzIGluYWJpbGl0eSB0byB1c2UgZmFsbG9jYXRlZCBmaWxlcyBmb3Igc3dhcCBvbiBYRlMu
IFRoaXMgaXMgcmVhbGx5IGltcG9ydGFudCBmb3IgdXMsIHNpbmNlIHdl4oCZcmUgc2hpcHBpbmcg
b3VyIGN1cnJlbnQgQW1hem9uIExpbnV4IHdpdGggaGliZXJuYXRpb24gc3VwcG9ydCAuDQoNCkni
gJl2ZSB0cmFjZWQgdGhlIHByb2JsZW0gdG8gYm1hcCgpLCB1c2VkIGluIGdlbmVyaWNfc3dhcGZp
bGVfYWN0aXZhdGUgY2FsbCwgd2hpY2ggcmV0dXJucyAwIGZvciBibG9ja3MgaW5zaWRlIGhvbGVz
IGNyZWF0ZWQgYnkgZmFsbG9jYXRlIGFuZCBEYXZlIENoaW5uZXIgY29uZmlybWVkIGl0IGluIGEg
cHJpdmF0ZSBlbWFpbC4gSeKAmW0gdGhpbmtpbmcgYWJvdXQgd2F5cyB0byBmaXggaXQsIHNvIGZh
ciBJIHNlZSB0aGUgZm9sbG93aW5nIHBvc3NpYmlsaXRpZXM6DQoNCjEuIENoYW5nZSBibWFwKCkg
dG8gbm90IHJldHVybiB6ZXJvZXMgZm9yIGJsb2NrcyBpbnNpZGUgaG9sZXMuIEJ1dCB0aGlzIGlz
IGFuIEFCSSBjaGFuZ2UgYW5kIGl0IGxpa2VseSB3aWxsIGJyZWFrIHNvbWUgb2JzY3VyZSB1c2Vy
c3BhY2UgdXRpbGl0eSBzb21ld2hlcmUuDQoyLiBDaGFuZ2UgZ2VuZXJpY19zd2FwX2FjdGl2YXRl
IHRvIHVzZSBhIG1vcmUgbW9kZXJuIGludGVyZmFjZSwgYnkgYWRkaW5nIGZpZW1hcC1saWtlIG9w
ZXJhdGlvbiB0byBhZGRyZXNzX3NwYWNlX29wZXJhdGlvbnMgd2l0aCBmYWxsYmFjayBvbiBibWFw
KCkuDQozLiBBZGQgYW4gWEZTLXNwZWNpZmljIGltcGxlbWVudGF0aW9uIG9mIHN3YXBmaWxlX2Fj
dGl2YXRlLg0KDQpXaGF0IGRvIHRoZSBwZW9wbGUgdGhpbmsgYWJvdXQgaXQ/IEkga2luZGEgbGlr
ZSBvcHRpb24gMiwgc2luY2UgaXQnbGwgbWFrZSBmYWxsb2NhdGUoKSB3b3JrIGZvciBhbnkgb3Ro
ZXIgRlMgdGhhdCBpbXBsZW1lbnRzIGZpZW1hcC4NCg0K
