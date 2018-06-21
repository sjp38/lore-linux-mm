Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B79DC6B0003
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 18:02:50 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id bf1-v6so2484089plb.2
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 15:02:50 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id q186-v6si4685750pga.322.2018.06.21.15.02.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jun 2018 15:02:44 -0700 (PDT)
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Subject: Re: [PATCH 1/3] vmalloc: Add __vmalloc_node_try_addr function
Date: Thu, 21 Jun 2018 22:02:39 +0000
Message-ID: <1529618574.29548.207.camel@intel.com>
References: <1529532570-21765-1-git-send-email-rick.p.edgecombe@intel.com>
	 <1529532570-21765-2-git-send-email-rick.p.edgecombe@intel.com>
	 <20180620222653.GC11479@bombadil.infradead.org>
In-Reply-To: <20180620222653.GC11479@bombadil.infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <FBF7B1AD2130BB4D8BDEDBD442B31691@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "willy@infradead.org" <willy@infradead.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Van De
 Ven, Arjan" <arjan.van.de.ven@intel.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "Accardi, Kristen C" <kristen.c.accardi@intel.com>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Hansen, Dave" <dave.hansen@intel.com>

T24gV2VkLCAyMDE4LTA2LTIwIGF0IDE1OjI2IC0wNzAwLCBNYXR0aGV3IFdpbGNveCB3cm90ZToN
Cj4gTm90IG5lZWRlZDoNCj4gDQo+IHZvaWQgd2Fybl9hbGxvYyhnZnBfdCBnZnBfbWFzaywgbm9k
ZW1hc2tfdCAqbm9kZW1hc2ssIGNvbnN0IGNoYXINCj4gKmZtdCwgLi4uKQ0KPiB7DQo+IC4uLg0K
PiDCoMKgwqDCoMKgwqDCoMKgaWYgKChnZnBfbWFzayAmIF9fR0ZQX05PV0FSTikgfHwgIV9fcmF0
ZWxpbWl0KCZub3BhZ2VfcnMpKQ0KPiDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoHJl
dHVybjsNCj4gDQpZZXMsIHRoYW5rcyE=
