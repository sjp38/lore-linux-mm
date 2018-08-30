Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A938E6B5307
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 15:38:46 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id m13-v6so8613122ioq.9
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 12:38:46 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0121.outbound.protection.outlook.com. [104.47.36.121])
        by mx.google.com with ESMTPS id y25-v6si4726559ioj.17.2018.08.30.12.38.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Aug 2018 12:38:45 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH RFCv2 6/6] memory-hotplug.txt: Add some details about
 locking internals
Date: Thu, 30 Aug 2018 19:38:43 +0000
Message-ID: <b46f358b-8fea-b380-1978-5f3e772130d4@microsoft.com>
References: <20180821104418.12710-1-david@redhat.com>
 <20180821104418.12710-7-david@redhat.com>
In-Reply-To: <20180821104418.12710-7-david@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <9F9046A8AD873D478941CC2B49BDEB5E@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>

DQpSZXZpZXdlZC1ieTogUGF2ZWwgVGF0YXNoaW4gPHBhdmVsLnRhdGFzaGluQG1pY3Jvc29mdC5j
b20+DQoNCk9uIDgvMjEvMTggNjo0NCBBTSwgRGF2aWQgSGlsZGVuYnJhbmQgd3JvdGU6DQo+IExl
dCdzIGRvY3VtZW50IHRoZSBtYWdpYyBhIGJpdCwgZXNwZWNpYWxseSB3aHkgZGV2aWNlX2hvdHBs
dWdfbG9jayBpcw0KPiByZXF1aXJlZCB3aGVuIGFkZGluZy9yZW1vdmluZyBtZW1vcnkgYW5kIGhv
dyBpdCBhbGwgcGxheSB0b2dldGhlciB3aXRoDQo+IHJlcXVlc3RzIHRvIG9ubGluZS9vZmZsaW5l
IG1lbW9yeSBmcm9tIHVzZXIgc3BhY2UuDQo+IA==
