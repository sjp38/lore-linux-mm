Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 869F46B52F8
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 15:35:53 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id u45-v6so9716835qte.12
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 12:35:53 -0700 (PDT)
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (mail-eopbgr700123.outbound.protection.outlook.com. [40.107.70.123])
        by mx.google.com with ESMTPS id 133-v6si82129qkd.22.2018.08.30.12.35.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Aug 2018 12:35:52 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH RFCv2 1/6] mm/memory_hotplug: make remove_memory() take
 the device_hotplug_lock
Date: Thu, 30 Aug 2018 19:35:48 +0000
Message-ID: <46a0119b-da16-0203-a8c2-d127738517f4@microsoft.com>
References: <20180821104418.12710-1-david@redhat.com>
 <20180821104418.12710-2-david@redhat.com>
In-Reply-To: <20180821104418.12710-2-david@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <DCFCA70729284F4B88E5C6C04E0B640A@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rashmica Gupta <rashmica.g@gmail.com>, Michael Neuling <mikey@neuling.org>, Balbir Singh <bsingharora@gmail.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, John Allen <jallen@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Oscar Salvador <osalvador@suse.de>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Mathieu Malaterre <malat@debian.org>

PiArDQo+ICt2b2lkIF9fcmVmIHJlbW92ZV9tZW1vcnkoaW50IG5pZCwgdTY0IHN0YXJ0LCB1NjQg
c2l6ZSkNCg0KUmVtb3ZlIF9fcmVmLCBvdGhlcndpc2UgbG9va3MgZ29vZDoNCg0KUmV2aWV3ZWQt
Ynk6IFBhdmVsIFRhdGFzaGluIDxwYXZlbC50YXRhc2hpbkBtaWNyb3NvZnQuY29tPg0KDQo+ICt7
DQo+ICsJbG9ja19kZXZpY2VfaG90cGx1ZygpOw0KPiArCV9fcmVtb3ZlX21lbW9yeShuaWQsIHN0
YXJ0LCBzaXplKTsNCj4gKwl1bmxvY2tfZGV2aWNlX2hvdHBsdWcoKTsNCj4gK30NCj4gIEVYUE9S
VF9TWU1CT0xfR1BMKHJlbW92ZV9tZW1vcnkpOw0KPiAgI2VuZGlmIC8qIENPTkZJR19NRU1PUllf
SE9UUkVNT1ZFICovDQo+IA==
