Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id CB9EC6B0069
	for <linux-mm@kvack.org>; Thu,  9 Oct 2014 03:25:57 -0400 (EDT)
Received: by mail-ig0-f175.google.com with SMTP id uq10so11240010igb.2
        for <linux-mm@kvack.org>; Thu, 09 Oct 2014 00:25:57 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id q20si8630283icd.10.2014.10.09.00.25.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Oct 2014 00:25:56 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Thu, 9 Oct 2014 15:25:16 +0800
Subject: RE: [PATCH resend] arm:extend the reserved memory for initrd to be
 page aligned
Message-ID: <35FD53F367049845BC99AC72306C23D103D6DB491642@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103D6DB49161F@CNBJMBX05.corpusers.net>
 <CAMuHMdUDxemAOsE1E1Ba3zjhtMSp-k=n4_YxRJ2k_C_kZdBr=Q@mail.gmail.com>
In-Reply-To: <CAMuHMdUDxemAOsE1E1Ba3zjhtMSp-k=n4_YxRJ2k_C_kZdBr=Q@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Geert Uytterhoeven' <geert@linux-m68k.org>
Cc: Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, =?utf-8?B?VXdlIEtsZWluZS1Lw7ZuaWc=?= <u.kleine-koenig@pengutronix.de>, Catalin Marinas <Catalin.Marinas@arm.com>, DL-WW-ContributionOfficers-Linux <DL-WW-ContributionOfficers-Linux@sonymobile.com>

PiBXaG8gZ3VhcmFudGVlcyB0aGVyZSdzIG5vIHZhbHVhYmxlIGRhdGEgaW4gW3N0YXJ0LCBpbml0
cmRfc3RhcnQpIGFuZA0KPiBbaW5pdHJkX2VuZCwgZW5kKSBiZWluZyBjb3JydXB0ZWQ/DQo+IA0K
bW0uLg0KSSBhbSBub3Qgc3VyZSBpZiB0aGUgbWVtYmxvY2tfcmVzZXJ2ZSB3aWxsIHJlc2VydmUN
Ck1lbW9yeSBmcm9tIHBhZ2UgYWxpZ25lZCBhZGRyZXNzPw0KSWYgbm90LCBkbyB3ZSBuZWVkIGFs
c28gbWFrZSBtZW1ibG9ja19yZXNlcnZlIHRoZSBpbml0cmQgbWVtb3J5DQpGcm9tIHBhZ2UgYWxp
Z25lZCBzdGFydChyb3VuZCBkb3duKSB0byBwYWdlIGFsaWduZWQgZW5kIGFkZHJlc3Mocm91bmQg
dXApID8gDQoNClRoYW5rcw0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
