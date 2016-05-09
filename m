Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5F7AC6B0005
	for <linux-mm@kvack.org>; Mon,  9 May 2016 17:28:09 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gw7so278734920pac.0
        for <linux-mm@kvack.org>; Mon, 09 May 2016 14:28:09 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id uq9si40941049pac.211.2016.05.09.14.28.08
        for <linux-mm@kvack.org>;
        Mon, 09 May 2016 14:28:08 -0700 (PDT)
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
Subject: Re: [RFC v3] [PATCH 0/18] DAX page fault locking
Date: Mon, 9 May 2016 21:28:06 +0000
Message-ID: <1462829283.3149.7.camel@intel.com>
References: <1461015341-20153-1-git-send-email-jack@suse.cz>
In-Reply-To: <1461015341-20153-1-git-send-email-jack@suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <82E77DBF790009479E8C05254ED55650@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "jack@suse.cz" <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Cc: "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

T24gTW9uLCAyMDE2LTA0LTE4IGF0IDIzOjM1ICswMjAwLCBKYW4gS2FyYSB3cm90ZToNCj4gPD4N
Cg0KSGkgSmFuLA0KDQpJJ3ZlIG5vdGljZWQgdGhhdCBwYXRjaGVzIDEgdGhyb3VnaCAxMiBvZiB5
b3VyIHNlcmllcyBhcmUgcmVsYXRpdmVseQ0KaW5kZXBlbmRlbnQsIGFuZCBhcmUgcHJvYmFibHkg
bW9yZSBzdGFibGUgdGhhbiB0aGUgcmVtYWluaW5nIHBhcnQgb2YNCnRoZSBzZXJpZXMgdGhhdCBh
Y3R1YWxseSBjaGFuZ2VzIGxvY2tpbmcuDQoNCk15IGRheCBlcnJvciBoYW5kbGluZyBzZXJpZXMg
YWxzbyBkZXBlbmRzIG9uIHRoZSBwYXRjaGVzIHRoYXQgY2hhbmdlDQp6ZXJvaW5nIGluIERBWCAo
cGF0Y2hlcyA1LCA2LCA5KS4NCg0KVG8gYWxsb3cgdGhlIGVycm9yIGhhbmRsaW5nIHN0dWZmIHRv
IG1vdmUgZmFzdGVyLCBjYW4gd2Ugc3BsaXQgdGhlc2UNCmludG8gdHdvIHBhdGNoc2V0cz8NCg0K
SSB3YXMgaG9waW5nIHRvIHNlbmQgdGhlIGRheCBlcnJvciBoYW5kbGluZyBzZXJpZXMgdGhyb3Vn
aCB0aGUgbnZkaW1tDQp0cmVlLCBhbmQgaWYgeW91J2QgbGlrZSwgSSBjYW4gYWxzbyBwcmVwZW5k
IHlvdXIgcGF0Y2hlcyAxLTEyIHdpdGggbXkNCnNlcmllcy4NCg0KTGV0IG1lIGtub3cgeW91ciBw
cmVmZXJlbmNlLg0KDQpUaGFua3MsDQoJLVZpc2hhbA==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
