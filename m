Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 85B528E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:04:33 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id p22-v6so6914775pfj.7
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 12:04:33 -0700 (PDT)
Received: from NAM05-CO1-obe.outbound.protection.outlook.com (mail-eopbgr720131.outbound.protection.outlook.com. [40.107.72.131])
        by mx.google.com with ESMTPS id m11-v6si27263530pga.618.2018.09.21.12.04.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 21 Sep 2018 12:04:32 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH v4 1/5] mm: Provide kernel parameter to allow disabling
 page init poisoning
Date: Fri, 21 Sep 2018 19:04:30 +0000
Message-ID: <a40a78c0-207b-03b7-344c-847b12a4f896@microsoft.com>
References: <20180920215824.19464.8884.stgit@localhost.localdomain>
 <20180920222415.19464.38400.stgit@localhost.localdomain>
In-Reply-To: <20180920222415.19464.38400.stgit@localhost.localdomain>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <FC10A7A3A3CEBF40AA05D8612D8B3C0C@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "dave.jiang@intel.com" <dave.jiang@intel.com>, "mingo@kernel.org" <mingo@kernel.org>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "jglisse@redhat.com" <jglisse@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "logang@deltatee.com" <logang@deltatee.com>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

DQo+ICsJCQlwcl9lcnIoInZtX2RlYnVnIG9wdGlvbiAnJWMnIHVua25vd24uIHNraXBwZWRcbiIs
DQo+ICsJCQkgICAgICAgKnN0cik7DQo+ICsJCX0NCj4gKw0KPiArCQlzdHIrKzsNCj4gKwl9DQo+
ICtvdXQ6DQo+ICsJaWYgKHBhZ2VfaW5pdF9wb2lzb25pbmcgJiYgIV9fcGFnZV9pbml0X3BvaXNv
bmluZykNCj4gKwkJcHJfd2FybigiUGFnZSBzdHJ1Y3QgcG9pc29uaW5nIGRpc2FibGVkIGJ5IGtl
cm5lbCBjb21tYW5kIGxpbmUgb3B0aW9uICd2bV9kZWJ1ZydcbiIpOw0KDQpOZXcgbGluZXMgJ1xu
JyBjYW4gYmUgcmVtb3ZlZCwgdGhleSBhcmUgbm90IG5lZWRlZCBmb3Iga3ByaW50ZnMuDQoNCg0K
UmV2aWV3ZWQtYnk6IFBhdmVsIFRhdGFzaGluIDxwYXZlbC50YXRhc2hpbkBtaWNyb3NvZnQuY29t
Pg==
