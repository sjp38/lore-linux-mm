Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 33A2B6B0038
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 20:59:52 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id i13so26694901qki.16
        for <linux-mm@kvack.org>; Fri, 14 Apr 2017 17:59:52 -0700 (PDT)
Received: from esa3.hgst.iphmx.com (esa3.hgst.iphmx.com. [216.71.153.141])
        by mx.google.com with ESMTPS id 87si3298930qkv.49.2017.04.14.17.59.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Apr 2017 17:59:51 -0700 (PDT)
From: Bart Van Assche <Bart.VanAssche@sandisk.com>
Subject: Re: [PATCH] mm: Make truncate_inode_pages_range() killable
Date: Sat, 15 Apr 2017 00:59:46 +0000
Message-ID: <1492217984.2557.1.camel@sandisk.com>
References: <20170414215507.27682-1-bart.vanassche@sandisk.com>
	 <alpine.LSU.2.11.1704141726260.9676@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1704141726260.9676@eggly.anvils>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <D7C7E26841E9A04B8BAA9643A85BD225@namprd04.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "hughd@google.com" <hughd@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "snitzer@redhat.com" <snitzer@redhat.com>, "oleg@redhat.com" <oleg@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hare@suse.com" <hare@suse.com>, "mhocko@suse.com" <mhocko@suse.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "jack@suse.cz" <jack@suse.cz>

T24gRnJpLCAyMDE3LTA0LTE0IGF0IDE3OjQwIC0wNzAwLCBIdWdoIERpY2tpbnMgd3JvdGU6DQo+
IENoYW5naW5nIGEgZnVuZGFtZW50YWwgZnVuY3Rpb24sIHNpbGVudGx5IG5vdCB0byBkbyBpdHMg
ZXNzZW50aWFsIGpvYiwNCj4gd2hlbiBzb21ldGhpbmcgaW4gdGhlIGtlcm5lbCBoYXMgZm9yZ290
dGVuIChvciBpcyBzbG93IHRvKSB1bmxvY2tfcGFnZSgpOg0KPiB0aGF0IHNlZW1zIHZlcnkgd3Jv
bmcgdG8gbWUgaW4gbWFueSB3YXlzLiAgQnV0IGxpbnV4LWZzZGV2ZWwsIENjJ2VkLCB3aWxsDQo+
IGJlIGEgYmV0dGVyIGZvcnVtIHRvIGFkdmlzZSBvbiBob3cgdG8gc29sdmUgdGhlIHByb2JsZW0g
eW91J3JlIHNlZWluZy4NCg0KSGVsbG8gSHVnaCwNCg0KSXQgc2VlbXMgbGlrZSB5b3UgaGF2ZSBt
aXN1bmRlcnN0b29kIHRoZSBwdXJwb3NlIG9mIHRoZSBwYXRjaCBJIHBvc3RlZC4gSXQncw0KbmVp
dGhlciBhIG1pc3NpbmcgdW5sb2NrX3BhZ2UoKSBub3Igc2xvdyBJL08gdGhhdCBJIHdhbnQgdG8g
YWRkcmVzcyBidXQgYQ0KZ2VudWluZSBkZWFkbG9jay4gSW4gY2FzZSB5b3Ugd291bGQgbm90IGJl
IGZhbWlsaWFyIHdpdGggdGhlIHF1ZXVlX2lmX25vX3BhdGgNCm11bHRpcGF0aCBjb25maWd1cmF0
aW9uIG9wdGlvbiwgdGhlIG11bHRpcGF0aC5jb25mIG1hbiBwYWdlIGlzIGF2YWlsYWJsZSBhdA0K
ZS5nLiBodHRwczovL2xpbnV4LmRpZS5uZXQvbWFuLzUvbXVsdGlwYXRoLmNvbmYuDQoNCkJhcnQu
DQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
