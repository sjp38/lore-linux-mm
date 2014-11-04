Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6C6806B0071
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 22:36:31 -0500 (EST)
Received: by mail-oi0-f49.google.com with SMTP id u20so9648368oif.22
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 19:36:31 -0800 (PST)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id o6si20038288obi.101.2014.11.03.19.36.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 19:36:29 -0800 (PST)
From: "Elliott, Robert (Server Storage)" <Elliott@hp.com>
Subject: RE: [PATCH v4 4/7] x86, mm, pat: Add pgprot_writethrough() for WT
Date: Tue, 4 Nov 2014 03:34:35 +0000
Message-ID: <94D0CD8314A33A4D9D801C0FE68B40295936556E@G4W3202.americas.hpqcorp.net>
References: <1414450545-14028-1-git-send-email-toshi.kani@hp.com>
 <1414450545-14028-5-git-send-email-toshi.kani@hp.com>
 <94D0CD8314A33A4D9D801C0FE68B4029593578ED@G9W0745.americas.hpqcorp.net>
 <1415052905.10958.39.camel@misato.fc.hp.com>
 <alpine.DEB.2.11.1411032352161.5308@nanos>
 <CALCETrXs0SotEmqs0B7rbnnqkLvMV+fzOJzNbp+y2U=zB+25OQ@mail.gmail.com>
In-Reply-To: <CALCETrXs0SotEmqs0B7rbnnqkLvMV+fzOJzNbp+y2U=zB+25OQ@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Thomas Gleixner <tglx@linutronix.de>
Cc: "Kani, Toshimitsu" <toshi.kani@hp.com>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "arnd@arndb.de" <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "jgross@suse.com" <jgross@suse.com>, "stefan.bader@canonical.com" <stefan.bader@canonical.com>, "hmh@hmh.eng.br" <hmh@hmh.eng.br>, "yigal@plexistor.com" <yigal@plexistor.com>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogQW5keSBMdXRvbWlyc2tp
IFttYWlsdG86bHV0b0BhbWFjYXBpdGFsLm5ldF0NCj4gU2VudDogTW9uZGF5LCBOb3ZlbWJlciAw
MywgMjAxNCA1OjAxIFBNDQo+IFRvOiBUaG9tYXMgR2xlaXhuZXINCj4gQ2M6IEthbmksIFRvc2hp
bWl0c3U7IEVsbGlvdHQsIFJvYmVydCAoU2VydmVyIFN0b3JhZ2UpOyBocGFAenl0b3IuY29tOw0K
PiBtaW5nb0ByZWRoYXQuY29tOyBha3BtQGxpbnV4LWZvdW5kYXRpb24ub3JnOyBhcm5kQGFybmRi
LmRlOyBsaW51eC0NCj4gbW1Aa3ZhY2sub3JnOyBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3Jn
OyBqZ3Jvc3NAc3VzZS5jb207DQo+IHN0ZWZhbi5iYWRlckBjYW5vbmljYWwuY29tOyBobWhAaG1o
LmVuZy5icjsgeWlnYWxAcGxleGlzdG9yLmNvbTsNCj4ga29ucmFkLndpbGtAb3JhY2xlLmNvbQ0K
PiBTdWJqZWN0OiBSZTogW1BBVENIIHY0IDQvN10geDg2LCBtbSwgcGF0OiBBZGQgcGdwcm90X3dy
aXRldGhyb3VnaCgpIGZvcg0KPiBXVA0KPiANCj4gT24gTW9uLCBOb3YgMywgMjAxNCBhdCAyOjUz
IFBNLCBUaG9tYXMgR2xlaXhuZXIgPHRnbHhAbGludXRyb25peC5kZT4NCj4gd3JvdGU6DQouLi4N
Cj4gT24gdGhlIG90aGVyIGhhbmQsIEkgdGhvdWdodCB0aGF0IF9HUEwgd2FzIHN1cHBvc2VkIHRv
IGJlIG1vcmUgYWJvdXQNCj4gd2hldGhlciB0aGUgdGhpbmcgdXNpbmcgaXQgaXMgaW5oZXJlbnRs
eSBhIGRlcml2ZWQgd29yayBvZiB0aGUgTGludXgNCj4ga2VybmVsLiAgU2luY2UgV1QgaXMgYW4g
SW50ZWwgY29uY2VwdCwgbm90IGEgTGludXggY29uY2VwdCwgdGhlbiBJDQo+IHRoaW5rIHRoYXQg
dGhpcyBpcyBhIGhhcmQgYXJndW1lbnQgdG8gbWFrZS4NCg0KSUJNIFN5c3RlbS8zNjAgTW9kZWwg
ODUgKDE5NjgpIGhhZCB3cml0ZS10aHJvdWdoIChpLmUuLCBzdG9yZS10aHJvdWdoKQ0KY2FjaGlu
Zy4gIEludGVsIG1pZ2h0IGNsYWltIFdyaXRlIENvbWJpbmluZywgdGhvdWdoLg0KDQoNCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
