Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 81B0A6B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 10:21:01 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id l24so1588782pgu.17
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 07:21:01 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0071.outbound.protection.outlook.com. [104.47.0.71])
        by mx.google.com with ESMTPS id s25si5905242pfk.554.2017.10.17.07.20.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 07:20:59 -0700 (PDT)
From: Guy Shattah <sguy@mellanox.com>
Subject: RE: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
Date: Tue, 17 Oct 2017 14:20:55 +0000
Message-ID: <AM6PR0502MB3783280D15C96E5A3A831DCBBD4C0@AM6PR0502MB3783.eurprd05.prod.outlook.com>
References: <20171013084054.me3kxhgbxzgm2lpr@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131015420.3949@nuc-kabylake>
 <20171013152801.nbpk6nluotgbmfrs@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131040570.4247@nuc-kabylake>
 <20171013154747.2jv7rtfqyyagiodn@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131053450.4400@nuc-kabylake>
 <20171013161736.htumyr4cskfrjq64@dhcp22.suse.cz>
 <752b49eb-55c6-5a34-ab41-6e91dd93ea70@mellanox.com>
 <20171016082456.no6ux63uy2rmj4fe@dhcp22.suse.cz>
 <0e238c56-c59d-f648-95fc-c8cb56c3652e@mellanox.com>
 <20171016123248.csntl6luxgafst6q@dhcp22.suse.cz>
 <AM6PR0502MB378375AF8B569DBCCFE20D7DBD4C0@AM6PR0502MB3783.eurprd05.prod.outlook.com>
 <xa1tlgk9c3j4.fsf@mina86.com>
In-Reply-To: <xa1tlgk9c3j4.fsf@mina86.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, Michal Hocko <mhocko@kernel.org>
Cc: Christopher Lameter <cl@linux.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

DQoNCj4gT24gVHVlLCBPY3QgMTcgMjAxNywgR3V5IFNoYXR0YWggd3JvdGU6DQo+ID4gQXJlIHlv
dSBnb2luZyB0byBiZSBPSyB3aXRoIGtlcm5lbCBBUEkgd2hpY2ggaW1wbGVtZW50cyBjb250aWd1
b3VzDQo+ID4gbWVtb3J5IGFsbG9jYXRpb24/ICBQb3NzaWJseSB3aXRoIG1tYXAgc3R5bGU/ICBN
YW55IGRyaXZlcnMgY291bGQNCj4gPiB1dGlsaXplIGl0IGluc3RlYWQgb2YgaGF2aW5nIHRoZWly
IG93biB3ZWlyZCBhbmQgcG9zc2libHkgbm9uLXN0YW5kYXJkDQo+ID4gd2F5IHRvIGFsbG9jYXRl
IGNvbnRpZ3VvdXMgbWVtb3J5LiAgU3VjaCBBUEkgd29uJ3QgYmUgYXZhaWxhYmxlIGZvcg0KPiA+
IHVzZXIgc3BhY2UuDQo+IA0KPiBXaGF0IHlvdSBkZXNjcmliZSBzb3VuZHMgbGlrZSBDTUEuICBJ
dCBtYXkgYmUgZmFyIGZyb20gcGVyZmVjdCBidXQgaXTigJlzIHRoZXJlDQo+IGFscmVhZHkgYW5k
IGRyaXZlcnMgd2hpY2ggbmVlZCBjb250aWd1b3VzIG1lbW9yeSBjYW4gYWxsb2NhdGUgaXQuDQo+
IA0KDQoxLiBDTUEgaGFzIHRvIHByZWNvbmZpZ3VyZWQuIFdlJ3JlIHN1Z2dlc3RpbmcgbWVjaGFu
aXNtIHRoYXQgd29ya3MgJ291dCBvZiB0aGUgYm94Jw0KMi4gRHVlIHRvIHRoZSBwcmUtYWxsb2Nh
dGlvbiB0ZWNobmlxdWVzIENNQSBpbXBvc2VzIGxpbWl0YXRpb24gb24gbWF4aW11bSANCiAgIGFs
bG9jYXRlZCBtZW1vcnkuIFJETUEgdXNlcnMgb2Z0ZW4gcmVxdWlyZSAxR2Igb3IgbW9yZSwgc29t
ZXRpbWVzIG1vcmUuDQozLiBDTUEgcmVzZXJ2ZXMgbWVtb3J5IGluIGFkdmFuY2UsIG91ciBzdWdn
ZXN0aW9uIGlzIHVzaW5nIGV4aXN0aW5nIGtlcm5lbCBtZW1vcnkNCiAgICAgbWVjaGFuaXNtcyAo
VEhQIGZvciBleGFtcGxlKSB0byBhbGxvY2F0ZSBtZW1vcnkuIA0KDQpHdXkNCg0KDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
