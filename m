Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id CBD258E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 13:57:04 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id a10-v6so10254745pls.23
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 10:57:04 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id q2-v6si17674178pgs.108.2018.09.10.10.57.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 10:57:03 -0700 (PDT)
From: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Subject: Re: [RFC 05/12] x86/mm: Add a helper function to set keyid bits in
 encrypted VMA's
Date: Mon, 10 Sep 2018 17:57:00 +0000
Message-ID: <7d89c2ca26aee64d1e8d36332c770746a9462d13.camel@intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
	 <efec45aae8dab3f4db8a79d001ec65137748cdb1.1536356108.git.alison.schofield@intel.com>
In-Reply-To: <efec45aae8dab3f4db8a79d001ec65137748cdb1.1536356108.git.alison.schofield@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <D8296D50EAA11C479C17B0C7BEEE66D1@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "tglx@linutronix.de" <tglx@linutronix.de>, "Schofield, Alison" <alison.schofield@intel.com>, "dhowells@redhat.com" <dhowells@redhat.com>
Cc: "Shutemov, Kirill" <kirill.shutemov@intel.com>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "jmorris@namei.org" <jmorris@namei.org>, "Huang,
 Kai" <kai.huang@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

T24gRnJpLCAyMDE4LTA5LTA3IGF0IDE1OjM2IC0wNzAwLCBBbGlzb24gU2Nob2ZpZWxkIHdyb3Rl
Og0KPiBTdG9yZSB0aGUgbWVtb3J5IGVuY3J5cHRpb24ga2V5aWQgaW4gdGhlIHVwcGVyIGJpdHMg
b2Ygdm1fcGFnZV9wcm90DQo+IHRoYXQgbWF0Y2ggcG9zaXRpb24gb2Yga2V5aWQsIGJpdHMgNTE6
NDYsIGluIGEgUFRFLg0KDQpXb3VsZCBub3QgZG8gYmFkIHRvIGV4cGxhaW4gdGhlIGNvbnRleHQg
YSBiaXQgaGVyZS4gQXQgbGVhc3QgSSBkbyBub3QNCmtub3cgd2h5IHlvdSBlbmRlZCB1cCB0byB0
aGlzIGJpdCByYW5nZS4NCg0KL0phcmtrbw0K
