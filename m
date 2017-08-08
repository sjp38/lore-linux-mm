Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 23DF36B0493
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 09:16:08 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w63so4611761wrc.5
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 06:16:08 -0700 (PDT)
Received: from smtp-out4.electric.net (smtp-out4.electric.net. [192.162.216.189])
        by mx.google.com with ESMTPS id 35si1606531edo.414.2017.08.08.06.16.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 06:16:06 -0700 (PDT)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [v6 11/15] arm64/kasan: explicitly zero kasan shadow memory
Date: Tue, 8 Aug 2017 13:15:55 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD004DA79@AcuExch.aculab.com>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
 <1502138329-123460-12-git-send-email-pasha.tatashin@oracle.com>
 <20170808090743.GA12887@arm.com>
 <f8b2b9ed-abf0-0c16-faa2-98b66dcbed78@oracle.com>
In-Reply-To: <f8b2b9ed-abf0-0c16-faa2-98b66dcbed78@oracle.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Pasha Tatashin' <pasha.tatashin@oracle.com>, Will Deacon <will.deacon@arm.com>
Cc: "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "sam@ravnborg.org" <sam@ravnborg.org>, "borntraeger@de.ibm.com" <borntraeger@de.ibm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "x86@kernel.org" <x86@kernel.org>, "heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "willy@infradead.org" <willy@infradead.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "davem@davemloft.net" <davem@davemloft.net>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

RnJvbTogUGFzaGEgVGF0YXNoaW4NCj4gU2VudDogMDggQXVndXN0IDIwMTcgMTI6NDkNCj4gVGhh
bmsgeW91IGZvciBsb29raW5nIGF0IHRoaXMgY2hhbmdlLiBXaGF0IHlvdSBkZXNjcmliZWQgd2Fz
IGluIG15DQo+IHByZXZpb3VzIGl0ZXJhdGlvbnMgb2YgdGhpcyBwcm9qZWN0Lg0KPiANCj4gU2Vl
IGZvciBleGFtcGxlIGhlcmU6IGh0dHBzOi8vbGttbC5vcmcvbGttbC8yMDE3LzUvNS8zNjkNCj4g
DQo+IEkgd2FzIGFza2VkIHRvIHJlbW92ZSB0aGF0IGZsYWcsIGFuZCBvbmx5IHplcm8gbWVtb3J5
IGluIHBsYWNlIHdoZW4NCj4gbmVlZGVkLiBPdmVyYWxsIHRoZSBjdXJyZW50IGFwcHJvYWNoIGlz
IGJldHRlciBldmVyeXdoZXJlIGVsc2UgaW4gdGhlDQo+IGtlcm5lbCwgYnV0IGl0IGFkZHMgYSBs
aXR0bGUgZXh0cmEgY29kZSB0byBrYXNhbiBpbml0aWFsaXphdGlvbi4NCg0KUGVyaGFwcyB5b3Ug
Y291bGQgI2RlZmluZSB0aGUgZnVuY3Rpb24gcHJvdG90eXBlKHM/KSBzbyB0aGF0IHRoZSBmbGFn
cw0KYXJlIG5vdCBwYXNzZWQgdW5sZXNzIGl0IGlzIGEga2FzYW4gYnVpbGQ/DQoNCglEYXZpZA0K
DQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
